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

# Business Implications

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
