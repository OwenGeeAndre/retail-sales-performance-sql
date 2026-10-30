# Project Objectives

## Overall Objective
This project aims to analyze sales performance and profitability of a cycling store supply chain using SQL Server to identify key revenue contributors, assess profitability across products and territories, evaluate data reliability, and investigate unusual sales patterns that may affect business decisions and visualize these findings with Power BI.

## Specific Objectives

1. **Evaluate sales performance:** I will reveal the overall sales performance by measuring total revenue, order volume, units sold, and average order value, sales trend.

2. **Evaluate revenue contribution:** I will determine key drivers of revenue in products and categories and the level of revenue contribution. I'd consider revenue y product category, product revenue rankings, revenue contribution percentages, cumulative revenue contribution and units sold against revenue contribution.

3. **Evaluate estimated product profitability across products and categories:** by considering the relationship between revenue and product cost, I will identify the products, categories with relatively strong or weak profitability. Strong indicators include estimated product cost, estimated gross profit and gross margin, product-level profitability and loss-making products.
   _**NOTE:** profitability uses currently recorded StandardCost, and not historical figures. The assumption is that the StandardCost has always been the same._

4. **Examine sales and profitability across territories:** Beyond the products, territories hold influence on the performance of sales. To prove this, I'll monitor the revenue, estimated gross profit and margin, cateogory contribution and product mix and performance across territories.

5. **Investigate differences in sales and profitability:** By examining order volume and sales volume, average order value, product contribution, product mix and differences across periods and territories, I'll investigate possible variations in business performance.
  
6. **Assess data quality and identify sales pattern:** I'll check for missing and duplicate records, reconcile revenue, unusual changes in sales activity, product-category sales cutoffs.


## Business Questions

The analysis is designed to answer the following questions:

| **s/n** | **Objectives** | **Questions** |
| :--- | :--- | :--- |
| 1. | Overall Sales performance | 1. What is the overall revenue, order volume, units sold, and average order value? <br> 2. How does revenue change over time? <br> |
| 2. | Product and Category Contribution | 3. Which categories contribute most to revenue? <br> 4. Which products generate the highest revenue? <br> 5. How concentrated is revenue among the leading products? <br> |
| 3. | Profitability | 6. What are the estimated gross profit and margin at business, category, and product levels? <br> 7. Which products have the weakest or negative estimated margins? <br> |
| 4. | Territory Performance | 8. Which territories generate the highest revenue and estimated gross profit? <br> 9. How does product-category contribution differ across territories? <br> 10. Which territories have relatively weak estimated profitability? <br> |
| 5. | Performance Drivers | 11. What factors are associated with differences in revenue across periods and territories? <br> 12. Do high-revenue products also generate strong estimated gross profitability? <br> |
| 6. | Data Reliability and Discontinuation | 13. Are the transaction records sufficiently complete and internally consistent? <br> 14. Are there unusual sales patterns or category cutoffs that could distort comparisons? <br> |

## Scope and Methodological Limitation

The analysis uses the AdventureWorks2025 database, focusing on sales orders, sales-order details, products, product categories, and sales territories.

Product costs are estimated using the current `Production.Product.StandardCost` multiplied by historical quantities sold. Consequently, estimated gross profit and gross margin are analytical proxies, not verified historical profitability. They exclude operating expenses and should not be interpreted as net profit.
