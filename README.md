### Project Structure

```text
retail-sales-performance-sql/
├── README.md
├── sql/
│   ├── 01_exploration.sql
│   ├── 02_data_quality.sql
|   ├── 03_diagnostic_analysis.sql
│   ├── 03_sales_performance.sql
│   ├── 04_profitability.sql
│   └── 05_advanced_analysis.sql
├── results/
│   └── key_findings.md
└── visuals/
```
# Preliminary Sales Performance Findings

1. **Revenue concentration by category:** Bikes generated 86.17% of total revenue, making them the dominant product category.
2. **Secondary revenue contributor:** Components accounted for 10.74% of revenue. Bikes and Components combined contributed 96.91% of total revenue.
3. **Leading product:** Mountain-200 Black, 38 ranked first among 266 products, generating 4.40 million in revenue from 2,977 units sold.
4. **Product concentration:** The highest-revenue product contributed approximately 4.01% of total revenue. The top 10 products collectively accounted for approximately 28.2%, suggesting that revenue is spread across multiple leading products.

**Limitation:** These findings describe sales revenue and volume, not profitability. Profitability requires suitable cost data, and any conclusions should account for the limitations of the available cost fields.


# Diagnostic Findings
The checks found no missing values in the inspected sales-detail fields, and aggregate revenue reconciled closely between detail and header records. However, two significant patterns require caution:

1. **April 30, 2025 is an extreme sales outlier:** 227 orders, 10,384 units, and approximately 3.46 million in revenue. Both typical order size and order volume were much higher than on the adjacent days. The cause remains unverified.
2. **Recorded category sales end at different times:** Components after April 30 and Bikes after May 29, while Accessories and Clothing continue. This creates a discontinuity in the product mix and can distort later category comparisons.
