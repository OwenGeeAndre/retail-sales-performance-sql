# 1. Project Overview
This document presents the key findings from a cycle store supply chain analysis.

The analysis uses SQL Server to evaluate sales performance, revenue contribution, estimated product profitability, and differences across products, categories, territories, and periods.

# 2. Exploration Analysis

## 2.1 Dataset Overview
The initial exploration established the size and structure of the primary datasets used in the analysis.

| Dataset | Sales Order Header | Sales Order Detail | Product Catalogue |
| :--- | ---: | ---: | ---: |
| Number of Records | 31,465 | 121,317 | 504 |

The Sales Order Header contains records of every sales, Sales Order Detail contains records of every item sold in each sale. The Catalogue of products contain 504 products, this is not the number of distinct products purchased, just available items offered.

## 2.2 Sales Period
The available sales records cover the following period:

| Metric | First Order Date | Last Order Date | Total Orders |
| :--- | ---: | ---: | ---: |
| Result | 30 May 2022 | 29 June 2025 |   31,465 |

The data covers just over three (3) years of activity

## 2.3 Baseline Sales Performance
The initial sales KPI analysis established the following baseline:

| Metric | Total Revenue | Total Units Sold | Total Orders | Average Order Value |
| :--- | ---: | ---: | ---: | ---: |
| Result | $109,846,381.40 | 274,914 | 31,465 | $3,491.07 |

The business raised approximately $109.85 million in sales revenue across 31,465 orders, with 274,914 units sold.
These figures establish the baseline against which subsequent analyses of sales trends, product contribution, and profitability can be evaluated.

# 3. Data Quality Assessment

## 3.1 Order Status Distribution
All sale records have a distribution status "5", which generally is adopted as "delivered/completed"

## 3.2 Order-Line Completeness and Identifier Uniqueness
All 121,317 order-detail records are unique.

The following were checked for missing values:
| Validation | Missing Order IDs | Missing Product IDs | Missing Quantities | Missing Unit Prices | Missing Line Totals | Missing Unit Price Discounts |
| :--- | ---: | ---: | ---: | ---: | ---: | ---: |
| Result | 0 | 0 | 0 | 0 | 0 | 0 | 

No missing values were identified from the data

## 3.3 Revenue Calculation Validation
The difference estimated when comparing the revenue in the data (LineTotal) and calculated revenue (quantity ordered * unit price (1-unit price discount)) is 2.5cents across 121,217 records, this is negligible and indicates strong consistency

Also, the difference between the sum of Subtotal from the header table and sum of LineTotal from detail table is 0.4cents revealing a strong consistency between both tables

# 4. Sales Performance Analysis

## 4.1 Revenue Contribution by Product Category

| Product Category | Total Orders | Units Sold | Total Revenue | Revenue Contribution |
| :--- | ---: | ---: | ---: | ---: |
| Bikes | 18,368 | 90,268 | $94,651,172.70 | 86.17% |
| Components | 2,650 | 49,044 | $11,802,593.29 | 10.74% |
| Clothing | 9,877 | 73,670 | $2,120,542.52 | 1.93% |
| Accessories | 19,524 | 61,932 | $1,272,072.88 | 1.16% |

Revenue is heavily concentrated in Bikes and Components. The difference between unit volume and revenue contribution across categories indicates substantially different revenue-per-unit profiles.

## 4.2 Top 10 Products by Revenue

The top 10 products collectively generated $31.01 million in revenue which accounted for approximately 28.2% of total business revenue and are all bikes, suggesting that revenue is spread across multiple leading products.

The dominance of Bikes among the leading products reinforces the importance of this category to the business's revenue performance.

## 4.3 Monthly Revenue Trend

* Revenue does not follow a consistent upward or downward trajectory. There are alternating periods of growth and decline across the three years.
* The largest positive percentage movement in the supplied results occurred in June 2022, with a 286.54% increase over May 2022. May 2025 recorded the largest negative absolute MoM revenue change, approximately -$3.31 million, representing a 63.47% decline from April 2025.
* The substantial increase in recorded order volume from July 2024 does not correspond to a proportional increase in revenue. This indicates that order volume alone does not explain the observed revenue movements.

# 5. Estimated Profitability Findings

## 5.1 Overall estimated profitability
Estimated product costs represent approximately 91.47% of revenue, the overall estimated gross margin is 8.53%.

## 5.2 Estimated profitability by product category
* Bikes generate the highest estimated gross profit at $7.94 million and contribute approximately 84.68% of total estimated gross profit.
* Accessories have the highest estimated gross margin at 50.03%, despite contributing only 1.16% of revenue.
* Components generate substantial revenue but have a relatively low estimated gross margin of 4.15%.
* Clothing records an estimated gross margin of 14.57%.

## Top 10 products by estimated gross profit
The ten highest estimated gross-profit products generated a cumulative estimated gross profit of $5,682,781.05, representing 60.64% of total estimated gross profit.
All ten products belong to the Bikes category.

## 5.4 10 Lowest-margin products
* Seven of the ten products belong to Clothing. Three belong to Bikes.
* Long-Sleeve Logo Jersey, L (ProductID 715) records the lowest estimated gross margin at -27.67%, with an estimated gross loss of $54,986.27.
* Road-650 Red, 44 (ProductID 762) records the largest absolute estimated gross loss among the ten, at $153,696.12, with an estimated gross margin of -16.29%.

## 5.5 Loss-making products by category
* Bikes have the highest number and percentage of loss-making products: 30 products, representing 30.93% of the category.
* Clothing has 7 loss-making products, representing 20.59%.
* Components have 19 loss-making products, representing 17.12%.
* No Accessories products recorded negative or break-even estimated gross profit.

Overall, 56 out of 266 products sold (21.05%) recorded negative estimated gross profit under the current cost assumptions.

## 5.6 Monthly estimated profitability
* April 2023 recorded an estimated gross loss of $400,288.42, with an estimated gross margin of -24.49%.
* June 2023 also recorded a small estimated gross loss of $4,579.62, with an estimated gross margin of -0.11%.
* From July 2023 onward, monthly estimated gross profit remained positive.
* November 2024 recorded estimated gross profit of $673,002.31 and an estimated gross margin of 20.45%.
* April 2025 recorded estimated gross profit of $735,187.74 and a margin of 14.08%.
* May 2025 recorded estimated gross profit of $789,823.55 and a margin of 41.39%.

# 6. Other Findings

## 6.1 Territory performance
- Southwest generated the highest revenue: $24.18 million.
- Australia generated the highest estimated gross profit: $3.43 million.
- Australia had the highest estimated gross margin: 32.23%.
- Northeast recorded the weakest estimated margin: -3.88%.
## 6.2 Territory performance by category
- Bikes dominate revenue across all territories.
- Australia's Bikes margin was 32.40%.
- Canada's Bikes margin was only 1.13%, despite its substantial Bikes revenue.
- Central, Northeast and Southeast recorded negative estimated Bikes margins.
- Accessories were profitable across all ten territories, with margins ranging from 34.68% to 58.90%.
## 6.3 Product revenue contribution versus profitability
- The six leading Mountain-200 variants contributed 20.29% of total revenue and approximately $3.92 million in estimated gross profit.
- Road-250 Black, 44 generated $2.52 million in revenue but recorded an estimated gross loss of $36,367.
- Road-150 Red, 48 generated a 30.53% estimated gross margin despite ranking seventeenth by revenue.
- The top ten products contributed 28.23% of total revenue.


Key Findings
1. **Revenue leader:** Mountain-200 Black, 38 generated the highest product revenue at $4,400,592.80, representing 4.01% of total revenue.
2. **Revenue concentration:** The top 6 products accounted for 20.29% of total revenue, the top 10 for 28.23%, and the top 20 for 44.20%. Revenue is therefore distributed across a relatively broad product portfolio.
3. **Strong revenue and positive estimated profitability:** The six highest-revenue products were Mountain-200 variants. Their estimated gross margins ranged from 15.30% to 20.15%.
4. **High revenue does not guarantee profitability:** Road-250 Black, 44 generated $2,516,857.31 in revenue but recorded an estimated gross loss of $36,367.14, with an estimated gross margin of −1.44%.
5. **Low-margin products require attention:** Road-250 Black, 48 generated $2,347,655.95 in revenue but had an estimated gross margin of only 0.78%.
6. **Lower revenue can still produce stronger profitability:** Road-150 Red, 48 generated $1,540,803.06 in revenue and $470,355.02 in estimated gross profit, achieving an estimated gross margin of 30.53%.
7. **Another potential profitability concern:** Touring-1000 Yellow, 60 generated $1,518,133.10 in revenue but recorded an estimated gross loss of $132,745.72, with an estimated gross margin of −8.74%.
