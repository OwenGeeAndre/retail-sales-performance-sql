USE AdventureWorks2025;
GO

----------- Revenue by product category
SELECT COALESCE(pc.Name, 'Uncategorized') AS ProductCategory,
	COUNT(DISTINCT sod.SalesOrderID) AS TotalOrders,
	SUM(sod.OrderQty) AS UnitsSold,
	CAST(SUM(sod.LineTotal) AS DECIMAL(18, 2)) AS TotalRevenue,
	CAST( SUM(sod.LineTotal) * 100.0 /
			SUM(SUM(sod.LineTotal)) OVER ()
		AS decimal(6,2)) AS RevenueContributionPct
FROM Sales.SalesOrderDetail AS sod
JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
LEFT JOIN Production.ProductSubcategory AS psc
	ON p.ProductSubcategoryID = psc.ProductSubcategoryID
LEFT JOIN Production.ProductCategory AS pc
	ON psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY COALESCE(pc.Name, 'Uncategorized')
ORDER BY TotalRevenue DESC;

GO

----------- Top 10 products by revenue
DROP TABLE IF EXISTS #Top10ProductByRevenue
SELECT * INTO #Top10ProductByRevenue FROM (
SELECT TOP(10) p.ProductID, p.Name AS ProductName,
	COALESCE(pc.Name, 'Uncategorized') AS ProductCategory,
	SUM(sod.OrderQty) AS UnitsSold,
	CAST(SUM(sod.LineTotal) AS DECIMAL(18, 2)) AS TotalRevenue,
	CAST(SUM(sod.LineTotal) * 100.0 / SUM(SUM(sod.LineTotal)) OVER () AS DECIMAL(18, 2)) AS RevenueContributionPct,
	CAST( SUM(sod.LineTotal) / 
			NULLIF(SUM(sod.OrderQty), 0)
			AS decimal(18,2)
		) AS RevenuePerUnit
FROM Sales.SalesOrderDetail AS sod
JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
LEFT JOIN Production.ProductSubcategory AS psc
	ON p.ProductSubcategoryID = psc.ProductSubcategoryID
LEFT JOIN Production.ProductCategory AS pc
	ON psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY p.ProductID, p.Name, COALESCE(pc.Name, 'Uncategorized')
ORDER BY TotalRevenue DESC, p.ProductID) AS Top10ProductByRevenue;


SELECT *
FROM #Top10ProductByRevenue
ORDER BY TotalRevenue DESC;

SELECT SUM(TotalRevenue) AS Top10Revenue, SUM(RevenueContributionPct) AS PctContributionOfTop10
FROM #Top10ProductByRevenue;

GO

/* =====> Revenue Trend over time */

WITH MonthlyRevenue AS (
SELECT YEAR(OrderDate) AS OrderYear, MONTH(OrderDate) AS OrderMonth, DATENAME(MONTH, OrderDate) AS MonthName,
    COUNT(DISTINCT SalesOrderID) AS TotalOrders, SUM(SubTotal) AS TotalRevenue,
	SUM(SubTotal) / COUNT(DISTINCT SalesOrderID) AS MonthlyAOV
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate), MONTH(OrderDate), DATENAME(MONTH, OrderDate)),

RevenueChanges AS ( 
SELECT *, LAG(TotalRevenue) OVER (ORDER BY OrderYear, OrderMonth) AS PreviousMonthRevenue,
		LAG(TotalOrders) OVER (ORDER BY OrderYear, OrderMonth) AS PreviousMonthOrders,
		LAG(MonthlyAOV) OVER (ORDER BY OrderYear, OrderMonth) AS PreviousMonthAOV
FROM MonthlyRevenue)

SELECT OrderYear, OrderMonth, MonthName, TotalOrders, TotalRevenue, MonthlyAOV,
		TotalRevenue - PreviousMonthRevenue AS MoMRevnueChange,
		TotalOrders - PreviousMonthOrders AS MoMOrdersChange,
		CAST((TotalRevenue - PreviousMonthRevenue) * 100.0 /	
				NULLIF(PreviousMonthRevenue, 0) AS DECIMAL(18, 2)) AS MoMRevenueGrowthPct,
		CAST((TotalOrders - PreviousMonthOrders) * 100.0 /	
				NULLIF(PreviousMonthOrders, 0) AS DECIMAL(18, 2)) AS MoMOrdersGrowthPct,
		CAST((MonthlyAOV - PreviousMonthAOV) * 100.0 /	
				NULLIF(PreviousMonthAOV, 0) AS DECIMAL(18, 2)) AS MoMAOVGrowthPct
FROM RevenueChanges
ORDER BY OrderYear, OrderMonth;
