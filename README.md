# E-Commerce Data Model & Analytics (PostgreSQL)

An Amazon-style transactional schema with sample data and analytics queries. Includes ER diagram, DDL (`schema.sql`), seed data (`values.sql`), and analysis queries (`queries.sql`) covering AOV, LTV, refund rates, category margins, and market-basket pairs.

## Repository Contents
- **`schema.sql`** – DDL for Users, Products, Orders, Order_Items, Payments, Reviews  
- **`values.sql`** – Rich sample dataset (10 users, 15 products, 12 orders, payments, reviews)  
- **`queries.sql`** – Analytics: AOV (overall/monthly), repeat customer rate, category margins, refund rate, cross-sell pairs, LTV, ratings summary  
- **`assets/ecommerce_erd.png`** – ER diagram (PNG)  
- **`assets/ecommerce_erd.drawio`** – Editable diagram for draw.io  
- **`.gitignore`** – Basic ignores for macOS and editor files  
- **`LICENSE`** – MIT  

---

## ER Diagram
![ER Diagram](https://github.com/IshanH9/ecommerce-sql-analysis/blob/main/ecommerce_erd.drawio.drawio.png)

---

## Features
- 3NF-style relational model with PK/FK constraints  
- `ORDER_ITEMS.unit_price` captures historical pricing at purchase time  
- `PAYMENTS.order_id` is UNIQUE → one payment per order (enables 1–1 with ORDERS)  
- Analytics examples use window functions, CTEs, and robust joins  

---

## Getting Started
1. Create a PostgreSQL database:
   ```bash
   createdb ecommerce_demo
