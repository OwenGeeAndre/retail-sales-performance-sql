/*=======================
QUESTION 1: Which product categories and products contribute the most revenue?
=========================*/

USE AdventureWorks2025;
GO

----------- Revenue by product category
SELECT COALESCE(pc.Name, 'Uncateogrized') AS ProductCategory,
	COUNT(DISTINCT sod.SalesOrderID) AS TotalOrders,
	SUM(sod.OrderQty) AS UnitsSold,
	SUM(sod.LineTotal) AS TotalRevenue,
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
GROUP BY COALESCE(pc.Name, 'Uncateogrized')
ORDER BY TotalRevenue DESC


----------- Top 10 products by revenue
DROP TABLE IF EXISTS #Top10ProductCategoryRevenue
SELECT * INTO #Top10ProductCategoryRevenue FROM (
SELECT TOP(10) p.ProductID, p.Name AS ProductName,
	COALESCE(pc.Name, 'Uncategorized') AS ProductCategory,
	SUM(sod.OrderQty) AS UnitsSold,
	SUM(sod.LineTotal) AS TotalRevenue,
	SUM(sod.LineTotal) * 100.0 / SUM(SUM(sod.LineTotal)) OVER () AS RevenueContributionPct,
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
ORDER BY TotalRevenue DESC, p.ProductID) AS Top10ProductCategoryRevenue;


SELECT *
FROM #Top10ProductCategoryRevenue

SELECT SUM(RevenueContributionPct) AS PctContributionOfTop10
FROM #Top10ProductCategoryRevenue;

----------- Rank products by revenue

WITH ProductRevenue AS (
SELECT p.ProductID, p.Name AS ProductName,
	SUM(sod.OrderQty) AS UnitsSold,
	SUM(sod.LineTotal) AS TotalRevenue
FROM Sales.SalesOrderDetail AS sod
JOIN Production.Product AS p
	ON sod.ProductID = p.ProductID
GROUP BY p.ProductID, p.Name
)
SELECT ProductID, ProductName, UnitsSold, TotalRevenue,
	RANK() OVER (ORDER BY TotalRevenue DESC) AS RevenueRank
FROM ProductRevenue
ORDER BY RevenueRank, ProductID;



