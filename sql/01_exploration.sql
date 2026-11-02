USE AdventureWorks2025;
GO

-------- SIZE OF TABLES

SELECT 'SalesOrderHeader' AS table_name, COUNT(*) AS total_rows
FROM Sales.SalesOrderHeader

UNION ALL

SELECT 'SalesOrderDetail', COUNT(*)
FROM Sales.SalesOrderDetail

UNION ALL

SELECT 'Product', COUNT(*)
FROM Production.Product;

GO

------------- SALES DATE RANGE
SELECT MIN(OrderDate) AS first_order_date,
		MAX(OrderDate) AS last_order_date,
		COUNT(DISTINCT SalesOrderID) AS total_orders
FROM Sales.SalesOrderHeader;

GO

------------- SALES COLUMNS

SELECT TOP (10) SalesOrderID, OrderDate, TerritoryID, SubTotal,
    TaxAmt, Freight, TotalDue
FROM Sales.SalesOrderHeader
ORDER BY OrderDate;

SELECT TOP (10) SalesOrderID, SalesOrderDetailID, ProductID,
    OrderQty, UnitPrice, UnitPriceDiscount, LineTotal
FROM Sales.SalesOrderDetail;

GO

------------- BASELINE SALES KPIs
SELECT CAST(SUM(LineTotal) AS DECIMAL(18, 2)) AS total_revenue,
		SUM(OrderQty) AS units_sold,
		COUNT(DISTINCT SalesOrderID) AS total_orders,
		CAST(
			SUM(LineTotal) / COUNT(DISTINCT SalesOrderID)
			AS DECIMAL(18,2)) AS average_order_value
FROM Sales.SalesOrderDetail;
