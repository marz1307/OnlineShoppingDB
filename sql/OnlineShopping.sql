CREATE DATABASE OnlineShoppingDB

USE OnlineShoppingDB;
GO


-- Products Table
IF OBJECT_ID('dbo.Products', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Products (
        product_id INT PRIMARY KEY,
        product_name NVARCHAR(255),
        category NVARCHAR(100),
        price DECIMAL(10,2)
    );
END

-- Customers Table
IF OBJECT_ID('dbo.Customers', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Customers (
        customer_id INT PRIMARY KEY,
        name NVARCHAR(255),
        email NVARCHAR(255),
        phone NVARCHAR(50),
        country NVARCHAR(100)
    );
END

-- Orders Table
IF OBJECT_ID('dbo.Orders', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Orders (
        order_id INT PRIMARY KEY,
        customer_id INT,
        order_date DATE,
        FOREIGN KEY (customer_id) REFERENCES dbo.Customers(customer_id)
    );
END

-- Order_items Table
IF OBJECT_ID('dbo.Order_items', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Order_items (
        order_item_id INT PRIMARY KEY,
        order_id INT,
        product_id INT,
        quantity INT,
        price_each DECIMAL(10,2),
        total_price AS (quantity * price_each) PERSISTED, -- Calculated column
        FOREIGN KEY (order_id) REFERENCES dbo.Orders(order_id),
        FOREIGN KEY (product_id) REFERENCES dbo.Products(product_id)
    );
END

-- Payments Table
IF OBJECT_ID('dbo.Payments', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Payments (
        payment_id INT PRIMARY KEY,
        order_id INT,
        payment_date DATE,
        payment_method NVARCHAR(100),
        amount_paid DECIMAL(10,2),
        FOREIGN KEY (order_id) REFERENCES dbo.Orders(order_id)
    );
END

-- Bulk Insert Statements (CSV Import)
-- Ensure the file path is accessible by the SQL Server service

-- Products
BULK INSERT dbo.Products
FROM 'C:\Temp\Products.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- Customers
BULK INSERT dbo.Customers
FROM 'C:\Temp\Customers.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- Orders
BULK INSERT dbo.Orders
FROM 'C:\Temp\Orders.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- Order_items
BULK INSERT dbo.Order_items
FROM 'C:\Temp\Order_items.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- Payments
BULK INSERT dbo.Payments
FROM 'C:\Temp\Payments.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

-- Sample Queries

-- View Customers
SELECT * FROM Customers;
SELECT COUNT(*) AS [RowCount] FROM Customers;

-- View Orders
SELECT * FROM Orders;
SELECT COUNT(*) AS [RowCount] FROM Orders;

-- View Order_items
SELECT * FROM Order_items;
SELECT COUNT(*) AS [RowCount] FROM Order_items;

-- View Products
SELECT * FROM Products;
SELECT COUNT(*) AS [RowCount] FROM Products;

-- View Payments
SELECT * FROM Payments;
SELECT COUNT(*) AS [RowCount] FROM Payments;

-- Customer Orders Within a Price Range
SELECT c.name, c.country
FROM dbo.Customers c
JOIN dbo.Orders o ON c.customer_id = o.customer_id
JOIN dbo.Order_items oi ON o.order_id = oi.order_id
WHERE oi.total_price BETWEEN 500 AND 1000;


-- Query 2: Total Amount Paid by UK Customers Who Bought More Than 3 Products in an Order
SELECT 
    customer_id,
    name,
    SUM(total_amount_paid) AS grand_total_amount_paid
FROM (
    SELECT 
        c.customer_id,
        c.name,
        p.amount_paid AS total_amount_paid
    FROM 
        Customers c
    JOIN Orders o ON c.customer_id = o.customer_id
    JOIN Order_items oi ON o.order_id = oi.order_id
    JOIN Payments p ON o.order_id = p.order_id
    WHERE 
        c.country = 'UK'
    GROUP BY 
        c.customer_id, c.name, o.order_id, p.amount_paid
    HAVING 
        SUM(oi.quantity) > 3
) AS qualifying_orders
GROUP BY 
    customer_id, name

-- QUESTION 3
/*  Get the total amount paid by customers belonging to UK who bought at least more than 
three products in an order. */

WITH RankedPayments AS (
    SELECT 
        ROUND(p.amount_paid * 1.122, 0) AS total_amount_with_vat,
        ROW_NUMBER() OVER (ORDER BY ROUND(p.amount_paid * 1.122, 0) DESC) AS rank
    FROM 
        Payments p
    JOIN Orders o ON p.order_id = o.order_id
    JOIN Customers c ON o.customer_id = c.customer_id
    WHERE 
        c.country IN ('UK', 'Australia')
)
SELECT 
    total_amount_with_vat
FROM 
    RankedPayments
WHERE 
    rank IN (1, 2);


-- 	Write a query that returns a list of the distinct product_name and the total quantity purchased for each product called as total_quantity. Sort by total_quantity.
    SELECT 
    p.product_name, 
    SUM(oi.quantity) AS total_quantity
FROM 
    Products p
JOIN Order_items oi ON p.product_id = oi.product_id
GROUP BY 
    p.product_name
ORDER BY 
    total_quantity DESC;

**** QUESTION 6 ****/
/*  Write a stored procedure for the query given as: Update the amount_paid of customers 
who purchased either laptop or smartphone as products and amount_paid>= 17000 of 
all orders to the discount of 5%. */



/* Create procedure*/
DROP PROCEDURE IF EXISTS UpdateCustomerPayments;
GO

CREATE PROCEDURE UpdateCustomerPayments
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE p
    SET p.amount_paid = p.amount_paid * 0.95
    FROM Payments p
    JOIN Orders o ON p.order_id = o.order_id
    JOIN Order_items oi ON o.order_id = oi.order_id
    JOIN Products pr ON oi.product_id = pr.product_id
    WHERE 
        LOWER(pr.product_name) IN ('laptop', 'smartphone')
        AND p.amount_paid >= 17000;
END;



--  QUESTION 7
/* You should also write at least five queries of your own and provide a brief explanation 
of the results which each query returns. You should make use of all of the following at 
least once:  
o Nested query including use of EXISTS or IN  
o Joins 
o System functions 
o Use of GROUP BY, HAVING and ORDER BY clauses  */

--Nested Query with EXISTS

SELECT c.name
FROM Customers c
WHERE EXISTS (
    SELECT 1
    FROM Orders o
    WHERE o.customer_id = c.customer_id 
      AND o.order_date > '2024-04-01'
);

--  Three-way Join
SELECT c.customer_id, c.email, c.country, p.payment_method
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN Payments p ON o.order_id = p.order_id;

--  Group By + Order By (Payment Method Analysis)
SELECT 
    p.payment_method, 
    COUNT(DISTINCT c.customer_id) AS customer_count
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN Payments p ON o.order_id = p.order_id
GROUP BY p.payment_method
ORDER BY customer_count DESC;

-- System Functions – Total Spending
SELECT 
    c.customer_id, 
    COUNT(o.order_id) AS total_orders,
    SUM(p.amount_paid) AS total_spent
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN Payments p ON o.order_id = p.order_id
GROUP BY c.customer_id
HAVING SUM(p.amount_paid) > 500;


--Complex Nested Query using IN
SELECT name
FROM Customers
WHERE customer_id IN (
    SELECT customer_id
    FROM Orders
    WHERE YEAR(order_date) = 2024
    GROUP BY customer_id
    HAVING COUNT(order_id) > 2
);

--Function – Evaluate Customer Spending
DROP FUNCTION IF EXISTS dbo.EvaluateCustomerSpending;
GO

CREATE FUNCTION dbo.EvaluateCustomerSpending()
RETURNS TABLE
AS 
RETURN
(    
    SELECT
        c.customer_id,
        c.name,
        SUM(p.amount_paid) AS total_amount_paid,
        CASE
            WHEN SUM(p.amount_paid) >= 1000 THEN 'High Spender'
            WHEN SUM(p.amount_paid) BETWEEN 500 AND 999 THEN 'Medium Spender'
            ELSE 'Low Spender' 
        END AS spending_category
    FROM Customers c
    LEFT JOIN Orders o ON c.customer_id = o.customer_id
    LEFT JOIN Payments p ON o.order_id = p.order_id 
    GROUP BY c.customer_id, c.name
);




