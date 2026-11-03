/*==============================================================
Diagnostic Analysis

Investigate the concentration of sales around month-end and  compare month-end sales with sales on regular days.

  MONTH-END DEFINITION:
  The final four calendar days of each month.
==============================================================*/


------------------------ 1. PREPARE REUSABLE ORDER-LEVEL TABLES

DROP TABLE IF EXISTS #OrderSales;

SELECT OrderData.SalesOrderID, OrderData.OrderDate, OrderData.SalesYear, OrderData.SalesMonth, OrderData.SalesPeriod, OrderData.OrderType, OrderData.CustomerType,
    SUM(sod.OrderQty) AS Units, SUM(sod.LineTotal) AS Revenue
INTO #OrderSales
FROM (
    SELECT soh.SalesOrderID, CAST(soh.OrderDate AS DATE) AS OrderDate, YEAR(soh.OrderDate) AS SalesYear, MONTH(soh.OrderDate) AS SalesMonth,
        CASE WHEN DATEDIFF(DAY, CAST(soh.OrderDate AS DATE), EOMONTH(CAST(soh.OrderDate AS DATE))) <= 3
            THEN 'Month-End' ELSE 'Regular Days'
        END AS SalesPeriod,
        CASE WHEN soh.OnlineOrderFlag = 1
            THEN 'Online' ELSE 'Non-Online'
        END AS OrderType,
        CASE WHEN c.StoreID IS NOT NULL
            THEN 'Store Customer' ELSE 'Individual Customer'
        END AS CustomerType
    FROM Sales.SalesOrderHeader AS soh
    LEFT JOIN Sales.Customer AS c
        ON soh.CustomerID = c.CustomerID
    ) AS OrderData
INNER JOIN Sales.SalesOrderDetail AS sod
    ON OrderData.SalesOrderID = sod.SalesOrderID
GROUP BY OrderData.SalesOrderID, OrderData.OrderDate, OrderData.SalesYear, OrderData.SalesMonth, OrderData.SalesPeriod, OrderData.OrderType, OrderData.CustomerType;


/* Create index for reusable order-level analysis */
CREATE UNIQUE CLUSTERED INDEX IX_OrderSales_SalesOrderID
ON #OrderSales (SalesOrderID);


----------------------------- 2. PREPARE DAILY SALES DATA

DROP TABLE IF EXISTS #DailySales;

SELECT OrderDate, SalesYear, SalesMonth, SalesPeriod, COUNT(SalesOrderID) AS TotalOrders, SUM(Units) AS TotalUnits, SUM(Revenue) AS TotalRevenue
INTO #DailySales
FROM #OrderSales
GROUP BY OrderDate, SalesYear, SalesMonth, SalesPeriod;


--------------------- 3. DAILY REVENUE ANALYSIS
-- Identify unusually high-revenue dates and determine whether high-revenue days frequently occur near month-end

SELECT TOP 20 OrderDate, TotalOrders, TotalUnits, TotalRevenue 
FROM #DailySales
ORDER BY TotalRevenue DESC;


---------------------- 4. REVENUE BY DAY OF THE MONTH
--  Identify whether certain days of the month consistently generate higher revenue.

SELECT DAY(OrderDate) AS DayOfMonth, COUNT(*) AS SellingDays, SUM(TotalOrders) AS TotalOrders, SUM(TotalRevenue) AS TotalRevenue, AVG(TotalRevenue) AS AverageDailyRevenue
FROM #DailySales
GROUP BY DAY(OrderDate)
ORDER BY DayOfMonth;


---------------------- 5. MONTH-END VS REGULAR DAYS
-- How much do the final four days of each month contribute to overall sales compared with regular days?

SELECT SalesPeriod, COUNT(SalesOrderID) AS TotalOrders, SUM(Units) AS TotalUnits, SUM(Revenue) AS TotalRevenue, COUNT(DISTINCT OrderDate) AS SellingDays,
    SUM(Revenue) / NULLIF(COUNT(DISTINCT OrderDate), 0) AS AverageDailyRevenue,
    COUNT(SalesOrderID) * 1.0 / NULLIF(COUNT(DISTINCT OrderDate), 0) AS AverageDailyOrders,
    SUM(Revenue) / NULLIF(COUNT(SalesOrderID), 0) AS AverageOrderValue
FROM #OrderSales
GROUP BY SalesPeriod
ORDER BY CASE WHEN SalesPeriod = 'Month-End' THEN 1 ELSE 2 END;


--------------------- 6. MONTHLY MONTH-END REVENUE CONTRIBUTION
-- What proportion of each month's revenue is generated during the final four calendar days?
-- Determine whether month-end revenue concentration is consistent across different months and years.

SELECT SalesYear, SalesMonth,
    SUM( CASE WHEN SalesPeriod = 'Month-End' THEN Revenue ELSE 0 END) AS MonthEndRevenue,
    SUM( CASE WHEN SalesPeriod = 'Regular Days' THEN Revenue ELSE 0 END ) AS RegularDaysRevenue,
    SUM(Revenue) AS TotalMonthlyRevenue,
    SUM( CASE WHEN SalesPeriod = 'Month-End' THEN Revenue ELSE 0 END) * 100.0 /
        NULLIF(SUM(Revenue), 0) AS MonthEndRevenueContributionPct
FROM #OrderSales
GROUP BY SalesYear, SalesMonth
ORDER BY SalesYear, SalesMonth;


--------------- 7. PRODUCT CATEGORY CONTRIBUTION BY SALES PERIOD
-- Which product categories contribute most to revenue during month-end and regular days?
-- does the product revenue mix differs between the two periods.

DROP TABLE IF EXISTS #CategorySales;
SELECT CASE WHEN DATEDIFF( DAY, CAST(soh.OrderDate AS DATE), EOMONTH(CAST(soh.OrderDate AS DATE))) <= 3 THEN 'Month-End' ELSE 'Regular Days'
    END AS SalesPeriod,
    pc.Name AS ProductCategory, COUNT(DISTINCT sod.SalesOrderID) AS TotalOrders, SUM(sod.OrderQty) AS TotalUnits,
    SUM(sod.LineTotal) AS TotalRevenue
INTO #CategorySales
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
    ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS p
    ON sod.ProductID = p.ProductID
INNER JOIN Production.ProductSubcategory AS psc
    ON p.ProductSubcategoryID = psc.ProductSubcategoryID
INNER JOIN Production.ProductCategory AS pc
    ON psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY CASE WHEN DATEDIFF( DAY, CAST(soh.OrderDate AS DATE), EOMONTH(CAST(soh.OrderDate AS DATE))) <= 3 THEN 'Month-End' ELSE 'Regular Days' END, pc.Name;


/* Category revenue contribution within each sales period */

SELECT SalesPeriod, ProductCategory, TotalOrders, TotalUnits, TotalRevenue,
    TotalRevenue * 100.0 / NULLIF(SUM(TotalRevenue) OVER (PARTITION BY SalesPeriod), 0) AS RevenueContributionPct
FROM #CategorySales
ORDER BY SalesPeriod, TotalRevenue DESC;


------------------ 8. ORDER SIZE ANALYSIS
-- Are month-end orders larger than regular-day orders? Lrt's compare average order value, average units per order and revenue per unit across the two periods.

SELECT SalesPeriod, COUNT(SalesOrderID) AS TotalOrders, SUM(Units) AS TotalUnits, SUM(Revenue) AS TotalRevenue,
    SUM(Revenue) / NULLIF(COUNT(SalesOrderID), 0) AS AverageOrderValue,
    SUM(Units) * 1.0 / NULLIF(COUNT(SalesOrderID), 0)
        AS AverageUnitsPerOrder,
    SUM(Revenue) / NULLIF(SUM(Units), 0) AS AverageRevenuePerUnit
FROM #OrderSales
GROUP BY SalesPeriod
ORDER BY CASE WHEN SalesPeriod = 'Month-End' THEN 1 ELSE 2 END;


------------------ 9. ONLINE VS NON-ONLINE ORDER ANALYSIS
-- Does the month-end sales pattern differ between online and non-online orders?
-- Let's identify which order channel contributes most to the month-end revenue concentration.
SELECT SalesPeriod, OrderType, COUNT(SalesOrderID) AS TotalOrders, SUM(Units) AS TotalUnits,
    SUM(Revenue) AS TotalRevenue, SUM(Revenue) / NULLIF(COUNT(SalesOrderID), 0) AS AverageOrderValue,
    SUM(Units) * 1.0 / NULLIF(COUNT(SalesOrderID), 0) AS AverageUnitsPerOrder
FROM #OrderSales 
GROUP BY SalesPeriod, OrderType
ORDER BY
    SalesPeriod,
    OrderType;


----------------- 10. CUSTOMER TYPE ANALYSIS
-- Which customer type contributes most to month-end sales?

SELECT SalesPeriod,OrderType, CustomerType, COUNT(SalesOrderID) AS TotalOrders,
    SUM(Units) AS TotalUnits, SUM(Revenue) AS TotalRevenue, SUM(Revenue) /  NULLIF(COUNT(SalesOrderID), 0)
        AS AverageOrderValue,   SUM(Units) * 1.0 / NULLIF(COUNT(SalesOrderID), 0) AS AverageUnitsPerOrder
FROM #OrderSales
GROUP BY SalesPeriod, OrderType, CustomerType
ORDER BY SalesPeriod, CustomerType;


--                      CLEAN UP TEMPORARY TABLES
DROP TABLE IF EXISTS #CategorySales;
DROP TABLE IF EXISTS #DailySales;
DROP TABLE IF EXISTS #OrderSales;


/*==============================================================
  END OF MONTH-END SALES ANALYSIS
==============================================================*/