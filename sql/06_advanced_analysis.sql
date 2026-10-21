USE AdventureWorks2025;
GO

---------------- 1. SALES AND PROFITABILITY BY TERRITORY
SELECT CONCAT(st.Name, ', ', st.CountryRegionCode) AS Territory,
	COUNT(DISTINCT soh.SalesOrderID) AS TotalOrders,
	SUM(sod.OrderQty) AS UnitsSold, 
	CAST(SUM(sod.LineTotal) AS DECIMAL(18, 2)) AS TotalRevenue,
    CAST(SUM(sod.OrderQty * pp.StandardCost) AS DECIMAL(18, 2)) AS EstimatedProductCost,
    CAST(SUM(sod.LineTotal) - SUM(sod.OrderQty * pp.StandardCost) AS DECIMAL(18, 2)) AS EstimatedGrossProfit,
    CAST((SUM(sod.LineTotal) - SUM(sod.OrderQty * pp.StandardCost)) * 100.0
			/ NULLIF(SUM(sod.LineTotal), 0)
        AS DECIMAL(10, 2)) AS EstimatedGrossMarginPct
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
	ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS pp
	ON sod.ProductID = pp.ProductID
INNER JOIN Sales.SalesTerritory AS st
	ON soh.TerritoryID = st.TerritoryID
GROUP BY CONCAT(st.Name, ', ', st.CountryRegionCode)
ORDER BY TotalRevenue DESC;

GO

---------------- 2. TERRITORY PERFORMANCE BY PRODUCT CATEGORY
/* Are the territory-level profitability differences associated with the types of products sold in each territory? */

SELECT CONCAT(st.Name, ', ', st.CountryRegionCode) AS Territory,
    COALESCE(cat.Name, 'Uncategorized') AS ProductCategory,
    COUNT(DISTINCT soh.SalesOrderID) AS TotalOrders, SUM(sod.OrderQty) AS UnitsSold,
    CAST(SUM(sod.LineTotal) AS DECIMAL(18, 2)) AS TotalRevenue,
    CAST(SUM(sod.LineTotal) - SUM(sod.OrderQty * pp.StandardCost)
        AS DECIMAL(18, 2)) AS EstimatedGrossProfit,
    CAST((SUM(sod.LineTotal) - SUM(sod.OrderQty * pp.StandardCost)) * 100.0
        / NULLIF(SUM(sod.LineTotal), 0)
        AS DECIMAL(10, 2)) AS EstimatedGrossMarginPct
FROM Sales.SalesOrderHeader AS soh
INNER JOIN Sales.SalesOrderDetail AS sod
    ON soh.SalesOrderID = sod.SalesOrderID
INNER JOIN Production.Product AS pp
    ON sod.ProductID = pp.ProductID
INNER JOIN Sales.SalesTerritory AS st
    ON soh.TerritoryID = st.TerritoryID
LEFT JOIN Production.ProductSubcategory AS subc
    ON pp.ProductSubcategoryID = subc.ProductSubcategoryID
LEFT JOIN Production.ProductCategory AS cat
    ON subc.ProductCategoryID = cat.ProductCategoryID
GROUP BY st.Name, st.CountryRegionCode, cat.Name
ORDER BY st.Name, TotalRevenue DESC;

GO

---------------- 3. PRODUCT CONTRIBUTION ANALYSIS
         /* Which products account for a large share of revenue, and do they also contribute strongly to estimated gross profit */
WITH ProductContribution AS (
SELECT pp.ProductID, pp.Name AS ProductName,
    CAST(SUM(sod.OrderQty) AS DECIMAL(18, 2)) AS UnitsSold,
    CAST(SUM(sod.LineTotal) AS DECIMAL(18, 2)) AS TotalRevenue,
    CAST(SUM(sod.OrderQty * pp.StandardCost) AS DECIMAL(18, 2)) AS EstimatedProductCost,
    CAST(SUM(sod.LineTotal) - SUM(sod.OrderQty * pp.StandardCost) AS DECIMAL(18, 2)) 
        AS EstimatedGrossProfit
FROM Sales.SalesOrderDetail AS sod
INNER JOIN Production.Product AS pp
    ON sod.ProductID = pp.ProductID
GROUP BY  pp.ProductID, pp.Name)
SELECT ProductID, ProductName, UnitsSold, TotalRevenue, EstimatedGrossProfit, 
    CAST(TotalRevenue * 100.0 / NULLIF(SUM(TotalRevenue) OVER (), 0) 
        AS DECIMAL(18, 2)) AS RevenueSharePcnt,
    CAST(EstimatedGrossProfit * 100.0 / NULLIF(TotalRevenue, 0)
        AS DECIMAL(18, 2)) AS EstimatedGrossMarginPcnt,
    CAST(SUM(TotalRevenue) OVER (ORDER BY TotalRevenue DESC, ProductID 
                                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) * 100.0
        / NULLIF(SUM(TotalRevenue) OVER (), 0)
        AS DECIMAL(18, 2)) AS CumulativeRevenueSharePcnt
FROM ProductContribution
ORDER BY TotalRevenue DESC, ProductID;
