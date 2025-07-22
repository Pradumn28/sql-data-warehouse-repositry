🏆 Gold Layer: Data Catalog
The Gold Layer represents cleaned, business-ready data, designed for dashboards, analytics, and decision-making. It includes both 🗃️ Dimension Tables and 📊 Fact Tables.

🗂️ 1. gold.dim_customers – Customer Dimension
🎯 Purpose: Stores detailed customer data, including demographics and geography.

| 🧱 Column Name    | 🧬 Data Type   | 📄 Description                                    |
| ----------------- | -------------- | ------------------------------------------------- |
| `customer_key`    | `INT`          | Surrogate key uniquely identifying each customer. |
| `customer_id`     | `INT`          | Internal unique ID assigned to the customer.      |
| `customer_number` | `NVARCHAR(50)` | Alphanumeric code used to track the customer.     |
| `first_name`      | `NVARCHAR(50)` | Customer's first name.                            |
| `last_name`       | `NVARCHAR(50)` | Customer's last name.                             |
| `country`         | `NVARCHAR(50)` | Country of residence (e.g., 🇦🇺 Australia).      |
| `marital_status`  | `NVARCHAR(50)` | Marital status (e.g., Married / Single).          |
| `gender`          | `NVARCHAR(50)` | Gender identity (e.g., Male / Female / n/a).      |
| `birthdate`       | `DATE`         | Date of birth (📅 format: YYYY-MM-DD).            |
| `create_date`     | `DATE`         | When the record was created in the system.        |



📦 2. gold.dim_products – Product Dimension
🎯 Purpose: Describes each product and its classifications.

| 🧱 Column Name         | 🧬 Data Type   | 📄 Description                                              |
| ---------------------- | -------------- | ----------------------------------------------------------- |
| `product_key`          | `INT`          | Surrogate key uniquely identifying the product.             |
| `product_id`           | `INT`          | Unique product ID used internally.                          |
| `product_number`       | `NVARCHAR(50)` | Alphanumeric product code.                                  |
| `product_name`         | `NVARCHAR(50)` | Descriptive product name (e.g., 🚴‍♂️ Mountain Bike - Red). |
| `category_id`          | `NVARCHAR(50)` | ID linking product to category.                             |
| `category`             | `NVARCHAR(50)` | High-level classification (e.g., Bikes, Components).        |
| `subcategory`          | `NVARCHAR(50)` | More detailed product classification.                       |
| `maintenance_required` | `NVARCHAR(50)` | Does it need maintenance? ('Yes' or 'No').                  |
| `cost`                 | `INT`          | Base cost of the product.                                   |
| `product_line`         | `NVARCHAR(50)` | Series or line it belongs to (e.g., Road, Mountain).        |
| `start_date`           | `DATE`         | Date product became available.                              |


📊 3. gold.fact_sales – Sales Fact Table
🎯 Purpose: Tracks transactions, quantities, and sales amounts.


| 🧱 Column Name  | 🧬 Data Type   | 📄 Description                         |
| --------------- | -------------- | -------------------------------------- |
| `order_number`  | `NVARCHAR(50)` | Unique sales order ID (e.g., SO54496). |
| `product_key`   | `INT`          | FK linking to `dim_products`.          |
| `customer_key`  | `INT`          | FK linking to `dim_customers`.         |
| `order_date`    | `DATE`         | When the order was placed.             |
| `shipping_date` | `DATE`         | When the order was shipped.            |
| `due_date`      | `DATE`         | Payment due date.                      |
| `sales_amount`  | `INT`          | Total sale amount for the line item.   |
| `quantity`      | `INT`          | Number of units sold.                  |
| `price`         | `INT`          | Price per unit sold.                   |
