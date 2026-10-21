## Project Objectives

### Overall Objective
To analyze retail sales performance and estimated product profitability using SQL Server to identify key revenue contributors, assess profitability across products and territories, evaluate data reliability, and investigate unusual sales patterns that may affect business decisions.

### Specific Objectives

1. **Evaluate sales performance** by measuring total revenue, order volume, units sold, and average order value, and identifying the product categories and individual products that contribute most to revenue.

2. **Assess data quality and reliability** by checking key sales-detail fields, validating revenue calculations, and reconciling order-detail revenue with order-header subtotals.

3. **Investigate unusual sales patterns** by examining monthly performance, identifying exceptional sales activity, and determining whether changes in category sales records affect the interpretation of sales trends.

4. **Evaluate estimated product profitability** by comparing estimated gross profit and gross margin across product categories and individual products, and identifying products with weak or negative estimated profitability.

5. **Compare territory performance and product contribution** by examining revenue and estimated profitability across sales territories, assessing category-level differences between territories, and measuring product revenue concentration.

## Business Questions

The analysis is designed to answer the following questions:

1. **Sales performance:** Which product categories and individual products contribute the most to total sales revenue, and how concentrated is revenue among the leading products?

2. **Data reliability and sales patterns:** How reliable are the recorded sales figures, and what unusual sales patterns or changes in category sales records could affect the interpretation of performance over time?

3. **Product profitability:** Which product categories and individual products generate the highest and lowest estimated gross profit and gross margins? Do high-revenue products also demonstrate strong estimated profitability?

4. **Territory performance:** Which sales territories generate the highest revenue and estimated gross profit, and which territories have weak or negative estimated gross margins?

5. **Differences in product mix and profitability:** To what extent do product-category performance and estimated profitability differ across territories, and which differences warrant further investigation?

## Scope and Methodological Limitation

The analysis uses the AdventureWorks2025 database, focusing on sales orders, sales-order details, products, product categories, and sales territories.

Product costs are estimated using the current `Production.Product.StandardCost` multiplied by historical quantities sold. Consequently, estimated gross profit and gross margin are analytical proxies, not verified historical profitability. They exclude operating expenses and should not be interpreted as net profit.

The diagnostic analysis identifies unusual patterns and changes in recorded sales activity, but does not establish their underlying causes.
