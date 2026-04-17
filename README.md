## 📊 DataVista-Business-Intelligence

End-to-end business analytics project using SQL, Excel, and Power BI

## 🗂️ Project Overview

This project simulates the role of a **Business/Data Analyst** at a mid-sized company.
Using a relational MySQL database of 8 tables and 1,500+ records, I answered real business
questions across four domains and delivered insights through SQL, Excel, and a Power BI dashboard.

**Tools Used**
- MySQL Workbench — data extraction and transformation
- Microsoft Excel — exploratory analysis and charts
- Power BI — interactive dashboard and storytelling

---

## 🗃️ Database Schema

The database contains 8 tables:

| Table | Description | Rows |
|---|---|---|
| `departments` | 8 company departments across 8 US cities | 8 |
| `employees` | Employee records with salary, performance score, hire date | 133 |
| `salaries` | Historical salary snapshots across 5 months | 665 |
| `customers` | Customers from 5 countries with loyalty scores | 150 |
| `orders` | Orders placed Oct 2025 – Mar 2026 | 450 |
| `order_items` | Individual line items per order | 930 |
| `products` | 60 products across 6 categories | 60 |
| `product_categories` | Lookup table for product categories | 6 |

**Entity Relationship:**
```
departments ──< employees >── orders >── order_items >── products
                                │                           │
                            customers              product_categories
                                │
                           salaries
```

---

## 📁 Repository Structure

```
company-sales-analytics/
│
├── README.md
├── database/
│   └── Project_Database.sql        ← Full schema + seed data
├── sql-queries/
│   ├── q1_top_sales_reps.sql       ← Top reps by revenue
│   ├── q2_monthly_revenue.sql      ← Monthly revenue trend
│   ├── q3_order_status.sql         ← Order health breakdown
│   ├── q4_payment_methods.sql      ← Payment method analysis
│   └── q5_score_vs_revenue.sql     ← HR × Sales cross-domain
├── exports/
│   └── *.csv                       ← Query outputs for Power BI
└── dashboard/
    └── sales_dashboard.pbix        ← Final Power BI report
```

---

## 🔍 Analysis Phases

### Phase 1 — HR & Workforce Analytics
**Questions answered:**
- Which department has the highest headcount and payroll cost?
- Are high-performing employees paid more than low performers?
- Which year had the most new hires?
- Who left the company, and is there a pattern?
- How did the December (+5%) and January (+10%) salary hikes impact total payroll?

**Tools:** MySQL · Excel

---

### Phase 2 — Sales Performance Analytics ✅
**Questions answered:**
- Who are the top sales reps by total revenue generated?
- What is the monthly revenue trend from Oct 2025 to Mar 2026?
- What percentage of orders are Completed vs Pending vs Cancelled?
- Which payment method is most used, and does it correlate with order size?
- Do sales reps with higher HR performance scores generate more revenue?

**Tools:** MySQL · Power BI

---

### Phase 3 — Product & Category Analytics
**Questions answered:**
- Which products sell the most by quantity vs by revenue?
- Which product category contributes the most to total revenue?
- What is the average basket size (items per order)?
- Which products are at risk of running out of stock?

**Tools:** MySQL · Power BI

---

### Phase 4 — Customer Analytics
**Questions answered:**
- Who are the top customers by total spend?
- How do loyalty tiers (Low / Medium / High) behave differently in spending?
- Which country generates the most revenue?
- How has new customer acquisition grown month over month?

**Tools:** MySQL · Power BI

---

### Phase 5 — Executive Dashboard
A 4-page interactive Power BI dashboard covering all domains with:
- KPI summary cards (revenue, orders, headcount, customers)
- Interactive slicers by department, country, and date
- Cross-filtered visuals across all pages

---

## 💡 Key Findings (Sample)

> These are examples of the type of insights uncovered during analysis.
> Full findings are documented inside each SQL file and the Power BI report.

- The **top 3 sales reps** account for over 40% of total completed revenue
- Revenue showed a **consistent upward trend** from Oct 2025 through Jan 2026
- Approximately **8–10% of orders** remain Pending or Cancelled, representing significant revenue at risk
- Customers in the **High loyalty tier** place 2× more orders than Low tier customers
- **Bank Transfer orders** have a notably higher average order value than Card payments
- **Engineering** is the largest and highest-paid department by total payroll

---

## 🚀 How to Run This Project

### 1. Set up the database
```sql
-- Open MySQL Workbench
-- Run the full file:
source database/Project_Database.sql;
```

### 2. Run the queries
Open each file in `sql-queries/` and run in MySQL Workbench.
Export results as CSV to the `exports/` folder.

### 3. Open the dashboard
Open `dashboard/sales_dashboard.pbix` in Power BI Desktop.
Refresh data sources to point to your local `exports/` folder.

---

## 👤 About

Built as a portfolio data analytics project to demonstrate end-to-end analytical skills:
data modeling → SQL extraction → Excel analysis → Power BI dashboarding.

**Skills demonstrated:** SQL (JOINs, Window Functions, CASE WHEN, Aggregations),
Data Cleaning, Exploratory Analysis, Data Visualization, Business Storytelling

---

*Database is simulated and contains no real personal data.*
