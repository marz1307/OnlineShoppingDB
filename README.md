# 🛒 OnlineShoppingDB

This project contains the SQL schema, queries, and stored procedures for the **OnlineShoppingDB**, a relational database designed to simulate the core functionality of an online shopping platform. It includes management of customers, products, orders, payments, and more.

## 📁 Contents

- `OnlineShoppingDB.sql`: SQL script containing various SQL queries and stored procedures for interacting with the database.

## 🧱 Database Schema Overview

The database consists of the following core tables:

- **Products** – Stores product details.
- **Customers** – Holds information about registered users.
- **Orders** – Represents customer orders.
- **Order_items** – Items within each order.
- **Payments** – Payment details associated with orders.

## 📌 Features & Queries

The `OnlineShoppingDB.sql` script includes:

- **Data Retrieval**:
  - List products based on various filters.
  - Aggregate order and payment information.
  - Customer purchase history.

- **Nested Queries**:
  - Top spenders.
  - Most ordered products.
  - Unpaid orders.

- **Joins & Aggregations**:
  - Combining order and payment data.
  - Calculating revenue per customer or product.

- **Stored Procedures**:
  - Inserting new orders.
  - Updating payment status.
  - Returning customer order summaries.

## 🚀 Getting Started

1. Import the SQL script (`OnlineShoppingDB.sql`) into your MySQL or PostgreSQL environment.
2. Run the script to set up and interact with the OnlineShoppingDB.
3. Customize queries or procedures as needed for your application.

## 🛠 Requirements

- MySQL or compatible RDBMS
- SQL client or interface (e.g., MySQL Workbench, DBeaver, phpMyAdmin)

## 🤝 Contributing

Feel free to fork the repository and submit pull requests with improvements or additional features!

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

**Author**: Marvis Osazuwa 
**GitHub**: @marz1307
