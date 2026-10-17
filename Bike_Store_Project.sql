---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--  PROJECT: BIKE STORES PROJECT - DATABASE SETUP & SCHEMA CONFIGURATION
--  DESCRIPTION: Database renaming, connection troubleshooting, flat file import  setup,Primary Key assignment, and Foreign Key relationship creation.
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--  =============================================================================================================================================================================
--  STEP 1: DATABASE RENAMING & EXCLUSIVE LOCK ISSUE RESOLUTION
--  =============================================================================================================================================================================
--  Issue Encountered:
--  "Msg 5030: The database MARKET could not be exclusively locked to perform the operation."
--
--  Solution:
--  Switch context to master database, force active sessions to disconnect by putting the database into SINGLE_USER mode, rename the database, and restore MULTI_USER mode.

USE master;
GO

IF EXISTS(SELECT * FROM sys.databases WHERE name = 'Market')
BEGIN
	-- Terminate active connections immediately and set to SINGLE_USER mode
	ALTER DATABASE MARKET SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

	-- Rename database to project name
	ALTER DATABASE MARKET MODIFY NAME = 'Bike_Store_Project';

	-- Revert database access mode back to MULTI_USER
	ALTER DATABASE Bike_Store_Project SET MULTI_USER;
END
GO

-- Switch active connection to the newly renamed database
USE Bike_Store_Project;
GO


--  =============================================================================================================================================================================
--  STEP 2: DATA IMPORT METHODOLOGY
--  =============================================================================================================================================================================
--  Note on Data Ingestion:
--  Imported dataset files via SSMS 'Import Flat File' wizard into SQL Server Express.
--  Imported Tables:
--  1. brands
--  2. categories
--  3. customers
--  4. order_items
--  5. orders
--  6. products
--  7. staffs
--  8. stocks
--  9. stores


--  =============================================================================================================================================================================
--  STEP 3: CONSTRAINTS SETUP - PRIMARY KEYS
--  =============================================================================================================================================================================
--  Enforcing Primary Keys to maintain entity integrity across all tables.

--  Brands Table (Primary Key already created: PK_brands)
--  ALTER TABLE brands ADD CONSTRAINT PK_brands PRIMARY KEY(brand_id);

--  Categories Table (Primary key already created: PK_categories)
--  ALTER TABLE categories ADD CONSTRAINT PK_categories PRIMARY KEY(category_id);


--  Customers Table
ALTER TABLE customers ADD CONSTRAINT PK_customers PRIMARY KEY(customer_id);

--  Stores Table
ALTER TABLE stores ADD CONSTRAINT PK_stores PRIMARY KEY(store_id);

--  Staff Table
ALTER TABLE staffs ADD CONSTRAINT PK_staffs PRIMARY KEY(staff_id);

--  Products Table
ALTER TABLE products ADD CONSTRAINT PK_products PRIMARY KEY(product_id);

--  Orders Table
ALTER TABLE orders ADD CONSTRAINT PK_orders PRIMARY KEY(order_id);

--  Composite Primary Keys for Junction/Bridge Tables
ALTER TABLE order_items ADD CONSTRAINT PK_order_items PRIMARY KEY(order_id,item_id);
ALTER TABLE stocks ADD CONSTRAINT PK_stocks PRIMARY KEY(store_id,product_id);
GO


--  =============================================================================================================================================================================
--  STEP 4: CONSTRAINTS SETUP - FOREIGN KEYS (RELATIONAL INTEGRITY)
--  =============================================================================================================================================================================
--  Troubleshooting Note:
--  If FK creation fails due to reference mismatch (e.g., INT vs SMALLINTB),
--  align data types beforehand using: ALTER TABLE table_name ALTER COLUMN col_name INT NOT_NULL;

--  Products Relationships
ALTER TABLE products ADD CONSTRAINT FK_products_brands FOREIGN KEY(brand_id)
	REFERENCES brands(brand_id) ON DELETE CASCADE ON UPDATE CASCADE;
	
ALTER TABLE products ADD CONSTRAINT FK_products_categories FOREIGN KEY(category_id)
	REFERENCES categories(category_id) ON DELETE CASCADE ON UPDATE CASCADE;

--  Staffs Relationships (Self-referencing FK for manager hierarchy)
ALTER TABLE staffs ADD CONSTRAINT FK_staffs_stores FOREIGN KEY(store_id)
	REFERENCES stores(store_id) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE staffs ADD CONSTRAINT FK_staffs_manager FOREIGN KEY(manager_id)
	REFERENCES staffs(staff_id);

--  Orders Relationships
ALTER TABLE orders ADD CONSTRAINT FK_orders_customers FOREIGN KEY(customer_id)
	REFERENCES customers(customer_id) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE orders ADD CONSTRAINT FK_orders_stores FOREIGN KEY(store_id)
	REFERENCES stores(store_id) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE orders ADD CONSTRAINT FK_orders_staffs FOREIGN KEY(staff_id)
	REFERENCES staffs(staff_id);

--  Order Items Relationships
ALTER TABLE order_items ADD CONSTRAINT FK_order_items_orders FOREIGN KEY(order_id)
	REFERENCES orders(order_id) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE order_items ADD CONSTRAINT FK_order_items_products FOREIGN KEY(product_id)
	REFERENCES products(product_id) ON DELETE CASCADE ON UPDATE CASCADE;

-- Stocks Relationships
ALTER TABLE stocks ADD CONSTRAINT FK_stocks_stores FOREIGN KEY(store_id)
	REFERENCES stores(store_id) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE stocks ADD CONSTRAINT FK_stocks_products FOREIGN KEY(product_id)
	REFERENCES products(product_id) ON DELETE CASCADE ON UPDATE CASCADE;


--  =============================================================================================================================================================================
--  STEP 5: EXPLORATORY DATA ANALYSIS (EDA) & ANALYTICAL SQL QUERIES
--  =============================================================================================================================================================================

--  A) Total Revenue Generated Per Store (Identifies which store location drives the highest financial returns.)
SELECT
	s.store_name,
	COUNT(DISTINCT o.order_id) AS total_orders,
	ROUND(SUM(i.quantity*i.list_price*(1-i.discount)),2) AS total_revenue
FROM orders o
JOIN order_items i ON o.order_id = i.order_id
JOIN stores s ON o.store_id = s.store_id
GROUP BY s.store_name
ORDER BY total_revenue DESC;


--  B) Top 10 Best-Selling Products, by Revenue (Highlights key revenue-generating generating inventory items.)
SELECT TOP 10
	p.product_name,
	b.brand_name,
	c.category_name,
	SUM(i.quantity) AS total_units_sold,
	ROUND(SUM(i.quantity*i.list_price*(1-i.discount)),2) AS total_sales
FROM order_items i
JOIN products p ON i.product_id = p.product_id
JOIN brands b ON p.brand_id = b.brand_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY p.product_name,b.brand_name,c.category_name
ORDER BY total_sales DESC;


--  C) Customer Lifetime Value(LTV) Top 10 Spenders (Tracks high-value customers for targeted retention and marketing campaigns.)
SELECT TOP 10
	c.customer_id,
	c.first_name+' '+c.last_name AS customer_name,
	c.city,
	c.state,
	COUNT(o.order_id) AS total_orders,
	ROUND(SUM(i.quantity*i.list_price*(1-i.discount)),2) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items i ON o.order_id = i.order_id
GROUP BY c.customer_id,c.first_name,c.last_name,c.city,c.state
ORDER BY total_spent DESC;


--  D) Inventory Status & Stockouts Analysis (Monitors stock availability across warehouse to prevent supply shortages.)
SELECT
	s.store_name,
	p.product_name,
	st.quantity AS stock_level
FROM stocks st
JOIN stores s ON st.store_id = s.store_id
JOIN products p ON st.product_id = p.product_id
WHERE st.quantity = 0
ORDER BY s.store_name;



--  =============================================================================================================================================================================
--  END OF SCRIPT: BIKE_STORES_ANALYSIS SETUP & EDA
--  =============================================================================================================================================================================