USE AdventureWorks2025;
GO

-------------- INSPECT ORDER STATUS
SELECT Status, COUNT(*) AS total_orders, SUM(SubTotal) AS subtotal_value
FROM Sales.SalesOrderHeader
GROUP BY Status
ORDER BY Status;

GO

--------------- VALIDATE ORDER-LINE IDENTIFIERS AND MISSING VALUES
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT SalesOrderDetailID) AS unique_detail_ids,
	SUM(CASE 
			WHEN SalesOrderID IS NULL THEN 1
			ELSE 0 END
		) AS missing_order_ids,
	SUM(CASE
			WHEN ProductID IS NULL THEN 1
			ELSE 0 END
		) AS missing_product_ids,
	SUM(CASE
			WHEN OrderQty IS NULL THEN 1
			ELSE 0	END
		) AS missing_quantities,
	SUM(CASE
			WHEN UnitPrice IS NULL THEN 1
			ELSE 0	END
		) AS missing_unit_prices,
	SUM(CASE
			WHEN LineTotal IS NULL THEN 1
			ELSE 0 END
		) AS missing_line_totals
FROM Sales.SalesOrderDetail;

GO

------------- VERIFY REVENUE CALCULATION
SELECT COUNT(*) AS total_order_lines, SUM(LineTotal) AS stored_revenue,
	SUM(OrderQty * UnitPrice * (1 - UnitPriceDiscount)) AS recalculated_revenue,
	SUM(LineTotal) - SUM(OrderQty * UnitPrice * (1 - UnitPriceDiscount)) AS revenue_difference
FROM Sales.SalesOrderDetail;

GO

------------- RECONCILE ORDER-LINE REVENUE WITH ORDER SUBTOTALS
WITH LineRevenue AS (
SELECT SalesOrderID, SUM(LineTotal) AS order_line_revenue
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
)
SELECT COUNT(*) AS matched_orders,	SUM(soh.SubTotal) AS header_subtotal,
	SUM(lr.order_line_revenue) AS detail_revenue,
	SUM(soh.SubTotal) - SUM(lr.order_line_revenue) AS difference
FROM Sales.SalesOrderHeader AS soh
JOIN LineRevenue AS lr
	ON soh.SalesOrderID = LR.SalesOrderID;
