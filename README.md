# E-Commerce Sales & Inventory Analytics Portfolio Project

## Overview
This repository contains a complete, end‑to‑end analytics solution for a fictional e‑commerce business. The solution demonstrates practical data‑analyst skills using **Microsoft Excel**, **SQL**, and **Power BI**. All data is synthetic but realistic and fully linked across tables.

## Repository Structure
```
Ecommerce-Sales-Inventory-Analytics/
├─ data/                # CSV files with the synthetic data
│   ├─ orders.csv
│   ├─ products.csv
│   ├─ customers.csv
│   ├─ inventory.csv
│   └─ returns.csv
├─ excel/               # Excel workbook with raw data, cleaned tables, formulas, and a simple dashboard
│   └─ Ecommerce_Analytics.xlsx
├─ sql/                 # SQL schema, data‑loading script, and example analysis queries
│   ├─ schema.sql
│   ├─ load_data.sql
│   └─ queries.sql
├─ powerbi/             # Power BI data‑model description and DAX measures (PBIX file cannot be generated here)
│   ├─ data_model.md
│   └─ dax_measures.md
├─ screenshots/         # Placeholder for screenshots of the finished Power BI dashboard
│   └─ (add your screenshots here)
├─ generate_data.py     # Python script that creates the synthetic CSV files
├─ generate_excel.py    # Python script that builds the Excel workbook with formulas & pivots
├─ .gitignore
└─ README.md            # (this file)
```

## Setup Instructions
1. **Python (optional – for data generation)**
   - Install the required packages:
     ```bash
     pip install pandas numpy openpyxl faker
     ```
   - Run the data‑generation script:
     ```bash
     python generate_data.py
     ```
   - This creates the `data/` CSV files.

2. **Excel**
   - Open `excel/Ecommerce_Analytics.xlsx` in Microsoft Excel.
   - The workbook contains:
     - Raw data sheets (linked to the CSV files).
     - Cleaned tables with calculated columns (Revenue, Discount Amount, Net Sales, etc.).
     - PivotTable‑ready tables.
     - A simple dashboard with KPI cards and charts.

3. **SQL**
   - The solution uses **SQLite** for simplicity (compatible with most environments). You can also run it on PostgreSQL, MySQL, or SQL Server with minor adjustments.
   - Create the database and load the CSV data:
     ```bash
     sqlite3 ecommerce.db < sql/schema.sql
     sqlite3 ecommerce.db < sql/load_data.sql
     ```
   - Run example analysis queries:
     ```bash
     sqlite3 ecommerce.db < sql/queries.sql
     ```
   - See `sql/queries.sql` for a collection of useful SELECT statements, CTEs, window functions, and KPI calculations.

4. **Power BI**
   - Open Power BI Desktop and **Get Data → CSV** for each file in the `data/` folder (or use the SQLite database you created).
   - Follow the data‑model instructions in `powerbi/data_model.md` to set up relationships (star‑schema) and import the calendar table.
   - Add the DAX measures from `powerbi/dax_measures.md`.
   - Recreate the dashboard pages (Executive Overview, Sales Performance, Product & Channel Analysis, Inventory Health, Returns & Discounts) using the visual design guidelines in the project description.
   - Save the report as `Ecommerce_Analytics.pbix` (not provided by this repo).

5. **Version Control**
   - Initialise a Git repository and push to GitHub:
     ```bash
     git init
     git add .
     git commit -m "Initial commit – portfolio analytics project"
     git remote add origin <your‑repo‑url>
     git push -u origin master
     ```

## Key Features
- **Realistic synthetic data** (≈ 5 000 order lines, seasonal patterns, discounts, returns, low‑stock warnings).
- **Excel workbook** with structured tables, formulas, data validation, conditional formatting, and a lightweight dashboard.
- **SQL schema** with primary/foreign keys, CTEs, window functions, and a suite of analytical queries.
- **Power BI data model** (star schema) and reusable DAX measures for all major KPIs.
- **Consistent KPI definitions** across Excel, SQL, and Power BI.
- **Portfolio‑ready** – clean folder layout, clear documentation, and screenshots ready for a GitHub portfolio.

---
*The synthetic data is labeled as such and generated solely for demonstration purposes.*
