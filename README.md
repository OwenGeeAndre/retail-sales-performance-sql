### Project Structure

```text
retail-sales-performance-sql/
├── README.md
├── sql/
│   ├── 01_exploration.sql
│   ├── 02_data_quality.sql
|   ├── 03_diagnostic_analysis.sql
│   ├── 04_sales_performance.sql
│   ├── 05_profitability.sql
│   └── 06_advanced_analysis.sql
├── results/
│   └── key_findings.md
└── visuals/
```
# Preliminary Sales Performance Findings

1. **Revenue:** The business recorded approximately 109.85 million in sales revenue across 31,465 orders.
2. **Estimated product cost:** The recorded standard costs, multiplied by quantities sold, total approximately 100.47 million.
3. **Revenue concentration by category:** Bikes generated 86.17% of total revenue, making them the dominant product category.
4. **Secondary revenue contributor:** Components accounted for 10.74% of revenue. Bikes and Components combined contributed 96.91% of total revenue.
5. **Leading product:** Mountain-200 Black, 38 ranked first among 266 products, generating 4.40 million in revenue from 2,977 units sold.
6. **Product concentration:** The highest-revenue product contributed approximately 4.01% of total revenue. The top 10 products collectively accounted for approximately 28.2%, suggesting that revenue is spread across multiple leading products.

**Limitation:** These findings describe sales revenue and volume, not profitability. Profitability requires suitable cost data, and any conclusions should account for the limitations of the available cost fields.


# Diagnostic Findings
The checks found no missing values in the inspected sales-detail fields, and aggregate revenue reconciled closely between detail and header records. However, two significant patterns require caution:

1. **April 30, 2025 is an extreme sales outlier:** 227 orders, 10,384 units, and approximately 3.46 million in revenue. Both typical order size and order volume were much higher than on the adjacent days. The cause remains unverified.
2. **Recorded category sales end at different times:** Components after April 30 and Bikes after May 29, while Accessories and Clothing continue. This creates a discontinuity in the product mix and can distort later category comparisons.


# Profitability Findings


1. **Estimated gross profit and gross margin percent:** Revenue exceeds estimated product cost by approximately 9.37 million. The estimated gross margin percent is 8.53%. In other words, approximately 8.53 of every 100 in revenue remains after the estimated product cost, before operating expenses and other costs excluded from this analysis.
2. Bikes are the largest contributor to estimated gross profit with $7.94 million and a highest Revenue of $94.65 million, Accessories have the highest estimated gross margin with 50.03%.
3. **Highest estimated gross profit:** Mountain-200 Black, 42 (ProductID 783), at $674,216.58. The top 10 products by gross profit accumulates 53.12% of total gross profit
4. Product 715, Long-Sleeve Logo Jersey, L, has the lowest estimated gross margin in the supplied results at −27.67%. Multiple jersey variants have negative estimated gross margins.
5. **Bikes:** 30 of 97 products sold are estimated to be loss-making (30.93%), **Components:** 19 of 111 (17.12%), **Clothing:** 7 of 34 (20.59%), **Accessories: 0 of 24 (0%)**.
6. April 2023 recorded the lowest estimated monthly gross margin at −24.49%.
May 2025 recorded an unusually high estimated margin of 41.39%, requiring caution because of changing product mix. June 2025's 55.88% margin is based on low revenue and an incomplete product-category mix.  
April 2025 revenue was affected by the previously identified April 30 anomaly.
May 2022 is a partial month because the dataset begins on May 30.


# Advanced Analytics

## Level Sales and Profitability:
- Southwest, US recorded the highest revenue at $24.18 million.
- Australia recorded the highest estimated gross profit ($3.43 million) and estimated gross margin (32.23%).
- Northeast, US recorded the lowest estimated gross margin (-3.88%) and the largest estimated gross loss (-$269,493.18).
- Canada generated $16.36 million in revenue but had an estimated gross margin of only 2.47%.
- Central, Southeast, and Northeast US recorded negative estimated gross profit.
- Profitability estimates use current product standard costs and should not be interpreted as verified historical profits or losses.

## Territory-Level Profitability by Product Category

- Bikes generate the majority of territory revenue but are also the source of negative estimated gross profit in Northeast, Central, and Southeast US.
- Northeast recorded the lowest estimated bike margin at -5.84% and the largest estimated bike loss at approximately $331,170.
- Australia recorded a 32.40% estimated gross margin on Bikes, substantially higher than the US territories with negative bike margins.
- Accessories consistently recorded high estimated gross margins across territories, ranging from 34.68% to 58.90%.
- Components generally recorded low estimated gross margins, ranging from 2.86% to 6.73% in the displayed results.
- These figures use current product standard costs as a proxy for historical costs. They indicate patterns for further investigation, not verified historical profitability.

## Product Revenue Contribution and Profitability

Identify which products contribute most to total revenue and assess whether high-revenue products also generate strong estimated gross profit.

Key Findings
1. **Revenue leader:** Mountain-200 Black, 38 generated the highest product revenue at $4,400,592.80, representing 4.01% of total revenue.
2. **Revenue concentration:** The top 6 products accounted for 20.29% of total revenue, the top 10 for 28.23%, and the top 20 for 44.20%. Revenue is therefore distributed across a relatively broad product portfolio.
3. **Strong revenue and positive estimated profitability:** The six highest-revenue products were Mountain-200 variants. Their estimated gross margins ranged from 15.30% to 20.15%.
4. **High revenue does not guarantee profitability:** Road-250 Black, 44 generated $2,516,857.31 in revenue but recorded an estimated gross loss of $36,367.14, with an estimated gross margin of −1.44%.
5. **Low-margin products require attention:** Road-250 Black, 48 generated $2,347,655.95 in revenue but had an estimated gross margin of only 0.78%.
6. **Lower revenue can still produce stronger profitability:** Road-150 Red, 48 generated $1,540,803.06 in revenue and $470,355.02 in estimated gross profit, achieving an estimated gross margin of 30.53%.
7. **Another potential profitability concern:** Touring-1000 Yellow, 60 generated $1,518,133.10 in revenue but recorded an estimated gross loss of $132,745.72, with an estimated gross margin of −8.74%.



# Overall Business Implications

## 1. Revenue Depends Heavily on Bikes and Components
Bikes generated 86.17% of total revenue, while Components contributed 10.74%. Together, these categories accounted for 96.91% of revenue.

**Business implication:** The business is highly dependent on these two categories. Management should protect their sales performance while assessing whether other categories offer opportunities to diversify revenue.

## 2. High Revenue Does Not Guarantee Strong Profitability
The overall estimated gross margin was 8.53%. Bikes generated the largest estimated gross profit of approximately $7.94 million, while Components had a relatively low estimated gross margin of 4.15%. Accessories achieved the highest category margin at 50.03%, although its revenue contribution was only 1.16%.

**Business implication:** Management should evaluate products and categories using both revenue and estimated gross profitability. High-margin categories may offer growth opportunities, but their costs, sales potential, and scalability should be assessed before reallocating resources.

## 3. Profitability Varies Across Territories
Australia recorded an estimated gross margin of 32.23%, compared with 2.47% for Canada. Central, Southeast, and Northeast US recorded negative estimated gross margins of −1.80%, −1.92%, and −3.88%, respectively.

**Business implication:** Management should investigate differences in product mix, pricing, and costs across territories. The negative estimated margins in three US territories warrant further review before decisions are made about pricing or market strategy.

## 4. Some High-Revenue Products Have Weak Estimated Profitability
Some products generated substantial revenue but had very low or negative estimated gross margins. For example, Road-250 Black, 44 generated approximately $2.52 million in revenue but had an estimated gross loss of $36,367.14.

**Business implication:** Product-level revenue rankings alone are insufficient for commercial decisions. Management should investigate low-margin and loss-making products to determine whether pricing, costs, or other factors need attention.

## 5. Sales Patterns Include Significant Anomalies and Category Cutoffs
April 30, 2025, recorded approximately $3.46 million in revenue, substantially exceeding the adjacent days examined. Sales for some product categories also stopped before the end of the dataset, while other categories continued.

**Business implication:** Management should validate the unusual sales spike and investigate the category cutoffs before using these periods for forecasting, performance comparisons, or operational planning. The analysis identifies anomalies but does not establish their causes.

## 6. Data Quality Supports Analysis, but Historical Cost Limitations Remain
The checked order-detail records contained no missing values in the key fields examined, and the differences between stored and recalculated sales amounts were negligible. However, profitability was estimated using current product standard costs applied to historical sales quantities.

**Business implication:** The sales results provide a useful basis for performance analysis. However, management should validate historical product costs before using the estimated profit figures for pricing, budgeting, or other financial decisions.

## 7. Sales Performance Should Be Monitored Across Multiple Dimensions
The project examined revenue, units sold, orders, revenue contribution, estimated gross profit, estimated gross margin, and changes over time across products, categories, and territories.

**Business implication:** A recurring performance dashboard could help management monitor sales trends, identify changes in category and territory performance, and prioritize products requiring investigation. Revenue and profitability indicators should be interpreted together.

# Overall Conclusion

The analysis shows that the business generates most of its revenue from Bikes and Components, while estimated profitability varies substantially across product categories, individual products, and territories. Some high-revenue products have weak or negative estimated gross profitability, and unusual sales patterns require validation.

The key business recommendation is to **manage performance using revenue and profitability together, investigate weak-margin products and territories, validate unusual sales patterns, and improve the reliability of historical cost data before making major commercial decisions.**
