USE AdventureWorks2025;
GO

--==================> DIAGNOSTIC ANALYSIS
------- 1. VALIDATE DETAIL RECORDS AND RECONCILE REVENUE

--- a. checking for suplicates and missing detail IDs
		/* Check whether important sales-detail fields are 
missing and whether detail IDs are unique. */
SELECT COUNT(*) AS DetailRows,
	COUNT(DISTINCT SalesOrderDetailID) AS UniqueDetailIDs,
	SUM(CASE WHEN SalesOrderID IS NULL THEN 1 ELSE 0 END) AS MissingOrderIDs,
	SUM(CASE WHEN ProductID IS NULL THEN 1 ELSE 0 END) AS MissingProductIDs,
	SUM(CASE WHEN OrderQty IS NULL THEN 1 ELSE 0 END) AS MissingQuantities,
	SUM(CASE WHEN UnitPrice IS NULL THEN 1 ELSE 0 END) AS MissingUnitPrices,
	SUM(CASE WHEN LineTotal IS NULL THEN 1 ELSE 0 END) AS MissingLineTotals
FROM Sales.SalesOrderDetail;

GO

/* There are no missing values and no duplicate detail IDs */

--- b. compare stored line totals with recalculated totals
		/* Next, we check whether stored LineTotal values match 
revenue recalculated from quantity and unit price. */

SELECT SUM(LineTotal) AS StoredRevenue,
	SUM(OrderQty * UnitPrice * (1 - UnitPriceDiscount)) AS RecalculatedRevenue,
	SUM(LineTotal) - SUM(OrderQty * UnitPrice * (1 - UnitPriceDiscount)) AS Difference
FROM Sales.SalesOrderDetail;

GO

/* The discrepancy is very small and appears consistent with decimal precision or rounding. */

--- c. reconcile order-header subtotals with detail revenue
		/* Let's compare each order’s header subtotal against the 
sum of its detail-line revenue*/
SELECT COUNT(*) AS MatchedOrders, SUM(soh.SubTotal) AS HeaderSubTotal,
	SUM(sod.DetailRevenue) AS DetailRevenue,
	SUM(soh.SubTotal - sod.DetailRevenue) AS Difference
FROM Sales.SalesOrderHeader AS soh
INNER JOIN (SELECT SalesOrderID, SUM(LineTotal) AS DetailRevenue
			FROM Sales.SalesOrderDetail
			GROUP BY SalesOrderID) AS sod
	ON soh.SalesOrderID = sod.SalesOrderID;

GO

/* The totals reconcile closely at dataset level */


------- 2. REVIEW MONTHLY REVENUE AND ESTIMATED GROSS-PROFIT PROXY
		/* Let's check for unusual monthly patterns in revenue and profitability 
estimates */
SELECT YEAR(soh.OrderDate) AS SalesYear, MONTH(soh.OrderDate) AS SalesMonth,
	COUNT(DISTINCT soh.SalesOrderID) AS Orders, SUM(sod.OrderQty) AS UnitsSold,
	CAST(SUM(LineTotal) AS DECIMAL(18, 2)) AS Revenue,
	CAST(SUM(sod.OrderQty * pp.StandardCost) AS DECIMAL(18, 2)) AS EstimatedCost,
	CAST(SUM(sod.LineTotal - (sod.OrderQty * pp.StandardCost)) 
		AS DECIMAL(18, 2)) AS EstimatedGrossProfit,
	CAST(SUM(sod.LineTotal - (sod.OrderQty * pp.StandardCost)) * 100.0
		/ NULLIF(SUM(sod.LineTotal), 0)
		AS DECIMAL(18, 2)) AS EstimatedGrossMarginPct
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS pp
	ON sod.ProductID = pp.ProductID
GROUP BY YEAR(soh.OrderDate), MONTH(soh.OrderDate)
ORDER BY SalesYear, SalesMonth;

GO

/* => Monthly revenue generally increased across the observed period, though it fluctuated.
=> April 2023 showed an unusual estimated gross-profit result: 
approximately −400,288, with an estimated margin around −24.49%.
=> May 2025 showed a markedly higher estimated margin, around 41.39%; 
June’s margin was also high, but June was incomplete in the available data. */

------- 3. FIND THE LAST RECORDED SALE DATE FOR EACH CATEGORY
		/* When does each product category last appears in sales. */
SELECT cat.Name AS ProductCategory, MAX(soh.OrderDate) AS LastSaleDate,
	COUNT(DISTINCT soh.SalesOrderID) AS Orders,
	COUNT(DISTINCT pp.ProductID) AS ProductsSold, sUM(sod.OrderQty) AS UnitsSold,
	CAST(SUM(sod.LineTotal) AS DECIMAL(18, 2)) AS Revenue
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS pp
	ON sod.ProductID = pp.ProductID
INNER JOIN Production.ProductSubcategory AS subc
	ON pp.ProductSubcategoryID = subc.ProductSubcategoryID
INNER JOIN Production.ProductCategory AS cat
	ON subc.ProductCategoryID = cat.ProductCategoryID
GROUP BY cat.Name
ORDER BY LastSaleDate;

GO

/* Components and Bikes stop appearing before the end of the available sales period, 
while Accessories and Clothing continue. */

------- 4. INSPECT CATEGORY SALES BY DAY AROUND THE CUTOFFS
		/* Lets determine whether the category changes occur gradually or abruptly. */

SELECT CAST(soh.OrderDate AS DATE) AS OrderDate, cat.Name AS Category,
	COUNT(DISTINCT soh.SalesOrderID) AS Orders,
	COUNT(sod.SalesOrderDetailID) AS DetailLines,
	SUM(sod.OrderQty) AS Units,
	CAST(SUM(sod.LineTotal) AS DECIMAL(18, 2)) AS Revenue
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS pp
	ON sod.ProductID = PP.ProductID
INNER JOIN Production.ProductSubcategory AS subc
	ON pp.ProductSubcategoryID = subc.ProductSubcategoryID
INNER JOIN Production.ProductCategory AS cat
	ON subc.ProductCategoryID = cat.ProductCategoryID
WHERE soh.OrderDate BETWEEN '2025-04-28' AND '2025-06-03'
GROUP BY CAST(soh.OrderDate AS DATE), cat.Name
ORDER BY Category, OrderDate;

GO

/* Components appear through April 30, then stop.
Bikes continue through May 29, then stop appearing from May 30.
Accessories and Clothing continue across the period.
The changes are abrupt rather than a gradual decline to zero. */

------- 6. LIST THE LARGEST ORDERS ON APRIL 30
		/* Is the the day’s extraordinary revenue
concentrated in a handful of large orders. */
WITH OrderSummary AS (
SELECT soh.SalesOrderID, soh.OrderDate,
	COUNT(sod.SalesOrderDetailID) AS DetailLines, SUM(sod.OrderQty) AS Units,
	CAST(SUM(sod.LineTotal) AS DECIMAL(18, 2)) AS DetailRevenue
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.OrderDate BETWEEN '2025-04-30' AND '2025-05-01'
GROUP BY soh.SalesOrderID, soh.OrderDate, soh.SubTotal)

SELECT *, SUM(DetailRevenue) OVER 
			(ORDER BY DetailRevenue DESC 
				ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningRevenue,
	CAST(SUM(DetailRevenue) OVER (ORDER BY DetailRevenue DESC) * 100.0
		/ SUM(DetailRevenue) OVER () AS DECIMAL(18, 2)) AS CumulativePcnt
FROM OrderSummary
ORDER BY DetailRevenue DESC;

GO
/* 
Together, the top 20 contributed approximately 1.38 million, 
	or 39.8% of April 30 revenue.
These were multi-line, multi-unit orders, not simply individual 
	high-priced line items.
*/
------- 7. COMPARE ORDER-SIZE STATISTICS FOR APRIL 29, APRIL 30, AND MAY 1
		/* Check if April 30’s unusual total reflects only a few giant orders or
a broader increase in typical order size. */
WITH OrderStats AS (
SELECT soh.SalesOrderID, CAST(soh.OrderDate AS DATE) AS OrderDate,
	SUM(sod.LineTotal) AS DetailRevenue, COUNT(sod.SalesOrderDetailID) AS DetailLines,
	SUM(sod.OrderQty) AS Units
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
WHERE soh.OrderDate BETWEEN '2025-04-29' AND '2025-05-02'
GROUP BY soh.SalesOrderID, CAST(soh.OrderDate AS DATE)
),
DailyStats AS (
SELECT OrderDate, COUNT(*) AS OrderCount, 
	CAST(SUM(DetailRevenue) AS DECIMAL(18, 2)) AS TotalRevenue,
	CAST(AVG(DetailRevenue) AS DECIMAL(18, 2)) AS AvgOrderRevenue, 
	CAST(MAX(DetailRevenue) AS DECIMAL(18, 2)) AS LargestOrder,
	CAST(AVG(DetailLines) AS DECIMAL(10, 2)) AS AvgDetailLines,
	CAST(AVG(Units) AS DECIMAL(10, 2)) AS AvgUnits
FROM OrderStats
GROUP BY OrderDate),
MedianStats AS (
SELECT DISTINCT OrderDate,
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY DetailRevenue)
	OVER (PARTITION BY OrderDate) AS MedianOrderRevenue
FROM OrderStats)
SELECT d.OrderDate, d.OrderCount, TotalRevenue, AvgOrderRevenue,
	CAST(MedianOrderRevenue AS DECIMAL(18, 2)) AS MedianOrderRevenue,
	LargestOrder, AvgDetailLines, AvgUnits
FROM DailyStats AS d
INNER JOIN MedianStats AS m
	ON d.OrderDate = m.OrderDate
ORDER BY d.OrderDate;

GO

/* 
Because the median was also elevated, the unusual order size was not confined 
	to just the largest few orders. April 30 is an exceptional observation
	relative to its adjacent days. */


