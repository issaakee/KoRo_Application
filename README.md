# DataAnalytics_Interview

This repository contains my SQL assessment for the Data Science Working Student position at KoRo. All analyses were performed in Google Cloud Platform’s BigQuery, and the full write-up of findings and methodology is available in **KoRo Report.pdf**.

---
## Repository Structure

```plaintext
DataAnalytics_Interview/
├── task1/
│   ├── task1.sql           # Early-lifecycle customer order activity query
│   └── task1.csv           # Query results exported from BigQuery
│
├── task2/
│   ├── task2_1.sql         # Category summary by country
│   ├── task2_1.csv         # Total orders & SKUs per main_category
│   ├── task2_2.sql         # Top 5 most-ordered products per country
│   ├── task2_2.csv         # Top 5 product results
│   ├── task2_3.sql         # Bottom 5 least-ordered products per country
│   └── task2_3.csv         # Bottom 5 product results
│
├── task3/
│   ├── task3.sql           # Daily new-customer share (overall + by channel)
│   └── task3.csv           # Query results exported from BigQuery
│
├── orders.csv              # Raw data for `orders` table
├── marketing_sources.csv   # Raw data for `marketing_sources` table
├── product_locale.csv      # Raw data for `product_locale` table
├── product_universal.csv   # Raw data for `product_universal` table
│
├── KoRo Report.pdf         # Detailed findings and methodology
├── KoRo Data Science Internship - Case Study.pdf  # Original case study prompt
└── README.md               # This file

