USE AdventureWorks2025;
GO


------- 1. Inspect Order Status

SELECT Status, COUNT(*) AS total_orders, SUM(SubTotal) AS subtotal_value
FROM Sales.SalesOrderHeader
GROUP BY Status
ORDER BY Status;

GO

/* The status of orders, 5 meaning delivered */

------- 2. VALIDATE DETAIL RECORDS AND RECONCILE REVENUE

--- a. checking for duplicates and missing detail IDs
		/* Check whether important sales-detail fields are 
missing and whether detail IDs are unique. */

SELECT COUNT(*) AS DetailRows,
	COUNT(DISTINCT SalesOrderDetailID) AS UniqueDetailIDs,
	SUM(CASE WHEN SalesOrderID IS NULL THEN 1 ELSE 0 END) AS MissingOrderIDs,
	SUM(CASE WHEN ProductID IS NULL THEN 1 ELSE 0 END) AS MissingProductIDs,
	SUM(CASE WHEN OrderQty IS NULL THEN 1 ELSE 0 END) AS MissingQuantities,
	SUM(CASE WHEN UnitPrice IS NULL THEN 1 ELSE 0 END) AS MissingUnitPrices,
	SUM(CASE WHEN LineTotal IS NULL THEN 1 ELSE 0 END) AS MissingLineTotals,
	SUM(CASE WHEN UnitPriceDiscount IS NULL THEN 1 ELSE 0 END) AS missing_unit_price_discounts
FROM Sales.SalesOrderDetail;

/* There are no missing values and no duplicate detail IDs */

GO


------------- compare stored line totals with recalculated totals
		/* Next, we check whether stored LineTotal values match 
revenue recalculated from quantity and unit price. */

SELECT COUNT(*) AS OrderDetails, SUM(LineTotal) AS StoredRevenue,
	CAST(SUM(OrderQty * UnitPrice * (1 - UnitPriceDiscount)) 
			AS DECIMAL(18, 2)) AS RecalculatedRevenue,
	CAST(SUM(LineTotal) - SUM(OrderQty * UnitPrice * (1 - UnitPriceDiscount)) 
			AS DECIMAL(18, 2)) AS Difference
FROM Sales.SalesOrderDetail;

/* The discrepancy is very small and appears consistent with decimal precision or rounding. */

GO

------------- RECONCILE ORDER-LINE REVENUE WITH ORDER SUBTOTALS
WITH LineRevenue AS (
SELECT SalesOrderID,
	SUM(LineTotal) AS order_line_revenue
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
)
SELECT COUNT(*) AS matched_orders,
	CAST(SUM(soh.SubTotal) AS DECIMAL(18, 2)) AS header_subtotal,
	CAST(SUM(lr.order_line_revenue) AS DECIMAL(18, 2)) AS detail_revenue,
	SUM(soh.SubTotal) - SUM(lr.order_line_revenue) AS difference
FROM Sales.SalesOrderHeader AS soh
JOIN LineRevenue AS lr
	ON soh.SalesOrderID = LR.SalesOrderID;

GO

/* The totals reconcile closely at dataset level */
