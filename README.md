# 🚲 Bike Stores Inventory & Sales Analytics Dashboard

An end-to-end data analytics project combining **SQL Server** for relational database management.
---

## 📌 Project Overview
This project simulates a retail bike store chain tracking system. It covers the full data lifecycle: from importing flat files and enforcing database integrity via Primary and Foreign Keys, to running analytical SQL queries (EDA).

---

## 🛠️ Tech Stack & Tools
* **Database Management:** SQL Server Management Studio (SSMS) / SQL Server Express
* **Languages:** T-SQL
---

## 🗄️ Part 1: SQL Database Setup & EDA (`Bike_Store_Project`)
The database pipeline handles exclusive lock error resolution, flat file ingestion across 9 distinct tables, and explicit relational modeling:

1. **Schema Integrity:** Configured Primary Keys and Foreign Key cascade constraints across relational entities (`brands`, `categories`, `customers`, `orders`, `order_items`, `products`, `staffs`, `stocks`, `stores`).
2. **Exploratory Data Analysis (EDA) Queries:**
   * **Store Performance:** Aggregates total revenue and order volume by store location.
   * **Product Performance:** Identifies top 10 best-selling products by total sales and units moved.
   * **Customer Analytics:** Computes Customer Lifetime Value (LTV) to find top-tier spenders.
   * **Stockout Tracking:** Monitors warehouse inventory status to highlight critical stock shortages (`quantity = 0`).

---
## 📂 Repository Structure
```text
├── database/
│   └── bike_stores_setup_and_eda.sql    # Full SQL script for schema, constraints & EDA
└── README.md
