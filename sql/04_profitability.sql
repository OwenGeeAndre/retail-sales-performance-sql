/*					PROFITABILITY METRICS
			Revenue ==> SUM(LineTotal)
			Estimated Product Cost ==> SUM(OrderQty * StandardCost)
			Estimated Gross Profit ==> Revenue - Estimated Product Cost
			Estimated Gross Margin ==> Estimated Gross Profit / Revenue * 100

*/

USE AdventureWorks2025;
GO

----------------- 1. OVERALL PROFITABILITY
WITH RevenueStats AS (
SELECT COUNT(DISTINCT sod.SalesOrderID) AS TotalOrders, SUM(sod.OrderQty) AS TotalUnitsSold,
	CAST(SUM(sod.LineTotal) AS DECIMAL(18,2)) AS TotalRevenue, 
	CAST(SUM(sod.OrderQty * pp.StandardCost) AS DECIMAL(18, 2)) AS EstimatedProductCost
FROM Sales.SalesOrderDetail AS sod
INNER JOIN Production.Product AS pp
	ON sod.ProductID = pp.ProductID)

SELECT *, CAST(TotalRevenue - EstimatedProductCost AS DECIMAL(18,2)) AS EstimatedGrossProfit,
		CAST((TotalRevenue - EstimatedProductCost) * 100.0 
			/ NULLIF(TotalRevenue, 0) AS DECIMAL(18, 2)) AS EstimatedGrossMarginPcnt
FROM RevenueStats;

GO

----------------- 2. PROFITABILITY BY PRODUCT CATEGORY
SELECT COALESCE(cat.Name, 'Uncategorized') AS Category,
	CAST(SUM(sod.LineTotal) AS DECIMAL(18,2)) AS TotalRevenue, 
	CAST(SUM(sod.OrderQty * pp.StandardCost) AS DECIMAL(18, 2)) AS EstimatedProductCost,
	CAST(SUM(sod.LineTotal) - SUM(sod.OrderQty * pp.StandardCost) AS DECIMAL(18,2)) AS EstimatedGrossProfit,
	CAST((SUM(sod.LineTotal) - SUM(sod.OrderQty * pp.StandardCost)) * 100.0 
			/ NULLIF(SUM(sod.LineTotal), 0) AS	DECIMAL(18, 2)) AS EstimatedGrossMarginPcnt
FROM Sales.SalesOrderDetail AS sod
INNER JOIN Production.Product AS pp
	ON sod.ProductID = pp.ProductID
LEFT JOIN Production.ProductSubcategory AS subc
	ON pp.ProductSubcategoryID = subc.ProductSubcategoryID
LEFT JOIN Production.ProductCategory AS cat
	ON subc.ProductCategoryID = cat.ProductCategoryID
GROUP BY COALESCE(cat.Name, 'Uncategorized')
ORDER BY EstimatedGrossProfit DESC;

GO

----------------- 3. TOP 10 PRODUCTS BY ESTIMATED GROSS PROFIT
WITH ProductStats AS (
SELECT pp.ProductID, pp.Name AS ProductName, cat.Name AS Category,
	SUM(sod.OrderQty) AS TotalUnitsSold,
	CAST(SUM(sod.LineTotal) AS DECIMAL(18,2)) AS TotalRevenue, 
	CAST(SUM(sod.OrderQty * pp.StandardCost) AS DECIMAL(18, 2)) AS EstimatedProductCost,
	CAST(SUM(sod.LineTotal) - SUM(sod.OrderQty * pp.StandardCost) AS DECIMAL(18,2)) AS EstimatedGrossProfit,
	CAST((SUM(sod.LineTotal) - SUM(sod.OrderQty * pp.StandardCost)) * 100.0 
			/ NULLIF(SUM(sod.LineTotal), 0) AS	DECIMAL(18, 2)) AS EstimatedGrossMarginPcnt
FROM Sales.SalesOrderDetail AS sod
INNER JOIN Production.Product AS pp
	ON sod.ProductID = pp.ProductID
INNER JOIN Production.ProductSubcategory AS subc
	ON pp.ProductSubcategoryID = subc.ProductSubcategoryID
INNER JOIN Production.ProductCategory AS cat
	ON cat.ProductCategoryID = subc.ProductCategoryID
GROUP BY pp.ProductID, pp.Name, cat.Name), 
ProductContributions AS (
SELECT *, SUM(EstimatedGrossProfit) OVER ( ORDER BY EstimatedGrossProfit DESC, ProductID ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS CumGrossProfit,
    SUM(EstimatedGrossProfit) OVER () AS OverallGrossProfit
FROM ProductStats )

SELECT TOP 10 ProductID, ProductName, Category, TotalRevenue, EstimatedGrossProfit,
	CumGrossProfit,
	CAST(CumGrossProfit * 100.0
			/ NULLIF(OverallGrossProfit, 0)	AS DECIMAL(18, 2)) AS CumGrossProfitPcnt,
	EstimatedGrossMarginPcnt
FROM ProductContributions
WHERE EstimatedGrossProfit >= 0
ORDER BY EstimatedGrossProfit DESC;

GO

----------------- 4. 10 LOWEST-MARGIN PRODUCTS
/*         for more meaningful analysis, we'll consider products with over 100 units
		sold, we want to avoid conclusions based on very small sales volumes     */

SELECT TOP 10 pp.ProductID, pp.Name AS ProductName, cat.Name AS Category,
	SUM(sod.OrderQty) AS TotalUnitsSold, 
	CAST(SUM(sod.LineTotal) AS DECIMAL(18,2)) AS TotalRevenue, 
	CAST(SUM(sod.OrderQty * pp.StandardCost) AS DECIMAL(18, 2)) AS EstimatedProductCost,
	CAST(SUM(sod.LineTotal) - SUM(sod.OrderQty * pp.StandardCost) AS DECIMAL(18,2)) AS EstimatedGrossProfit,
	CAST((SUM(sod.LineTotal) - SUM(sod.OrderQty * pp.StandardCost)) * 100.0 
			/ NULLIF(SUM(sod.LineTotal), 0) AS	DECIMAL(18, 2)) AS EstimatedGrossMarginPcnt
FROM Sales.SalesOrderDetail AS sod
INNER JOIN Production.Product AS pp
	ON sod.ProductID = pp.ProductID
INNER JOIN Production.ProductSubcategory AS subc
	ON pp.ProductSubcategoryID = subc.ProductSubcategoryID
INNER JOIN Production.ProductCategory AS cat
	ON cat.ProductCategoryID = subc.ProductCategoryID
GROUP BY pp.ProductID, pp.Name, cat.Name
HAVING SUM(sod.OrderQty) >= 100 AND SUM(LineTotal) > 0
ORDER BY EstimatedGrossMarginPcnt ASC;

GO

----------------- 5. LOSS-MAKING PRODUCTS BY CATEGORY
WITH ProductProfitability AS (
SELECT pp.ProductID, cat.Name AS Category,
	CAST(SUM(sod.LineTotal) AS DECIMAL(18,2)) AS TotalRevenue, 
	CAST(SUM(sod.LineTotal) - SUM(sod.OrderQty * pp.StandardCost) AS DECIMAL(18,2)) AS EstimatedGrossProfit,
	CAST((SUM(sod.LineTotal) - SUM(sod.OrderQty * pp.StandardCost)) * 100.0 
			/ NULLIF(SUM(sod.LineTotal), 0) AS	DECIMAL(18, 2)) AS EstimatedGrossMarginPcnt
FROM Sales.SalesOrderDetail AS sod
INNER JOIN Production.Product AS pp
	ON sod.ProductID = pp.ProductID
INNER JOIN Production.ProductSubcategory AS subc
	ON pp.ProductSubcategoryID = subc.ProductSubcategoryID
INNER JOIN Production.ProductCategory AS cat
	ON cat.ProductCategoryID = subc.ProductCategoryID
GROUP BY pp.ProductID, cat.Name)

SELECT Category, COUNT(*) AS TotalProducts,
	SUM(
		CASE
			WHEN EstimatedGrossProfit < -0.01 THEN 1
			ELSE 0 END
		) AS LossMakingProducts,
	SUM(
		CASE
			WHEN ABS(EstimatedGrossProfit) <= 0.01 THEN 1
			ELSE 0 END
		) AS BreakEvenProducts,
	CAST(100.0 * SUM(
		CASE
			WHEN EstimatedGrossProfit < -0.01 THEN 1
			ELSE 0 END
		) / NULLIF(COUNT(*), 0)
		AS DECIMAL(18, 2)) AS LossMakingProductPcnt
FROM ProductProfitability
GROUP BY Category
ORDER BY LossMakingProducts DESC;

GO

----------------- 6. MONTHLY ESTIMATED PROFITABILITY

WITH MonthlyProfitability AS (
SELECT YEAR(soh.OrderDate) AS OrderYear, MONTH(soh.OrderDate) AS OrderMonth,
    DATENAME(MONTH, soh.OrderDate) AS MonthName, COUNT(DISTINCT soh.SalesOrderID) AS TotalOrders,
    SUM(sod.OrderQty) AS TotalUnitsSold, SUM(sod.LineTotal) AS TotalRevenue,
    SUM(sod.OrderQty * pp.StandardCost) AS EstimatedProductCost, SUM(sod.LineTotal)
        - SUM(sod.OrderQty * pp.StandardCost) AS EstimatedGrossProfit
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
    ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS pp
    ON sod.ProductID = pp.ProductID
GROUP BY YEAR(soh.OrderDate), MONTH(soh.OrderDate), DATENAME(MONTH, soh.OrderDate)
),
MonthlyChanges AS (
SELECT *, EstimatedGrossProfit - LAG(EstimatedGrossProfit) OVER (ORDER BY OrderYear, OrderMonth) AS MoMEstimatedGrossProfitChange
FROM MonthlyProfitability
)
SELECT OrderYear, OrderMonth, MonthName, TotalOrders, TotalUnitsSold,
    CAST(TotalRevenue AS DECIMAL(18,2)) AS TotalRevenue,
    CAST(EstimatedProductCost AS DECIMAL(18,2)) AS EstimatedProductCost,
    CAST(EstimatedGrossProfit AS DECIMAL(18,2)) AS EstimatedGrossProfit,
    CAST(
        EstimatedGrossProfit * 100.0
        / NULLIF(TotalRevenue, 0)
        AS DECIMAL(18,2)
    ) AS EstimatedGrossMarginPcnt,
    CAST(
        MoMEstimatedGrossProfitChange AS DECIMAL(18,2)
    ) AS MoMEstimatedGrossProfitChange
FROM MonthlyChanges
ORDER BY OrderYear, OrderMonth;
