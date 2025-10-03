#be careful about the column name : custmer/customer

USE sales;

-- List all customers in the customers table
SELECT DISTINCT customer_name 
FROM sales.customers;

-- Retrieve all products with their corresponding customer IDs
SELECT T.customer_code, P.Product_code, P.Product_type
FROM Transactions T
INNER JOIN Products P 
    ON T.product_code = P.Product_code
ORDER BY T.customer_code;

-- Show all markets in the South region
SELECT * 
FROM markets 
WHERE LOWER(zone) = 'south';

-- Select all transactions where the quantity is greater than 50
SELECT * 
FROM transactions 
WHERE sales_qty > 50;

-- Show columns from transactions
SHOW COLUMNS FROM transactions;

-- Retrieve all products sold after 2018-01-01
SELECT * 
FROM transactions 
WHERE order_date > '2018-01-01' 
ORDER BY order_date;

-- Show customers whose name contains "Stores"
SELECT * 
FROM customers 
WHERE customer_name LIKE '%stores%';

-- Rename column in customers table
ALTER TABLE customers
RENAME COLUMN custmer_name TO customer_name;

-- List transactions in descending order of price
SELECT *  
FROM transactions 
ORDER BY sales_amount DESC;

-- Find all markets not in the Central region
SELECT * 
FROM markets 
WHERE zone NOT IN ('Central');

-- Count the number of products sold by each customer
SELECT customer_code, COUNT(product_code) AS number_of_products
FROM transactions
GROUP BY customer_code
ORDER BY number_of_products;

-- Calculate the total quantity sold for each product
SELECT product_code, SUM(sales_qty) AS total_qty_by_product
FROM transactions
GROUP BY product_code
ORDER BY total_qty_by_product;

-- Average sales_amount per market
SELECT market_code, ROUND(AVG(sales_amount), 3) AS avg_price
FROM transactions
GROUP BY market_code
ORDER BY avg_price;

-- List the number of transactions per year
SELECT YEAR(order_date) AS years, COUNT(*) AS number_of_transaction
FROM transactions
GROUP BY YEAR(order_date);

-- List all products along with their market name
SELECT T.product_code, M.markets_name
FROM Transactions T
INNER JOIN markets M 
    ON T.market_code = M.markets_code;

-- Show all transactions with customer name, product, and market region
SELECT C.customer_name, P.product_type, M.zone
FROM Transactions T
JOIN Customers C 
    ON T.customer_code = C.Customer_code
JOIN Products P 
    ON T.Product_code = P.Product_code
JOIN Markets M 
    ON T.market_code = M.markets_code;

-- Return customers that placed orders
-- Method 1: INNER JOIN
SELECT DISTINCT C.*
FROM Customers C
INNER JOIN Transactions T
    ON C.Customer_code = T.Customer_code;

-- Method 2: EXISTS
SELECT * 
FROM customers 
WHERE EXISTS (
    SELECT 1 
    FROM transactions 
    WHERE customers.Customer_code = transactions.Customer_code
);

-- List customers who have never bought Prod002
-- Method 1: Using GROUP_CONCAT
SELECT Customer_code,
       GROUP_CONCAT(DISTINCT Product_code ORDER BY Product_code) AS Products_Bought
FROM Transactions
GROUP BY Customer_code
HAVING NOT FIND_IN_SET('Prod002', Products_Bought);

-- Method 2: Using NOT EXISTS
SELECT Customer_code
FROM Customers C
WHERE NOT EXISTS (
    SELECT 1
    FROM Transactions T
    WHERE T.Customer_code = C.Customer_code
      AND T.Product_code = 'Prod002'
);

-- Show the total amount spent by each customer
SELECT customer_code, SUM(sales_amount) AS total_amount_spent
FROM transactions
GROUP BY customer_code;

-- Find the product(s) with the highest price
SELECT product_code, sales_amount
FROM transactions
ORDER BY sales_amount DESC
LIMIT 1;

-- List customers who have made transactions in Central
SELECT customer_code, market_code
FROM transactions
WHERE market_code IN (
    SELECT market_code 
    FROM markets 
    WHERE LOWER(zone) = 'central'
)
GROUP BY customer_code, market_code;

-- Retrieve markets where total sales exceeded 10,000,000,000
SELECT market_code, SUM(sales_amount) AS total_sales
FROM transactions
GROUP BY market_code
HAVING SUM(sales_amount) > 10000000000;

-- Find products that have never been sold
-- Method 1: NOT EXISTS
SELECT product_code 
FROM products 
WHERE NOT EXISTS (
    SELECT 1 
    FROM transactions 
    WHERE products.product_code = transactions.product_code
);

-- Method 2: NOT IN
SELECT product_code 
FROM products 
WHERE product_code NOT IN (
    SELECT product_code 
    FROM transactions
);

-- Show monthly sales totals for each product
SELECT product_code, MONTH(order_date) AS monthly, SUM(sales_amount) AS total
FROM transactions
GROUP BY MONTH(order_date), product_code
ORDER BY monthly, product_code;

-- Show average transaction price per customer and rank them
SELECT customer_code,
       AVG(sales_amount) AS avg_transaction_price,
       DENSE_RANK() OVER(ORDER BY AVG(sales_amount) DESC) AS rank_by_avg
FROM transactions
GROUP BY customer_code;

-- How many unique products bought by each customer
SELECT customer_code, COUNT(DISTINCT product_code) AS number_unique_products
FROM transactions
GROUP BY customer_code
ORDER BY number_unique_products ASC;

-- Customers who bought products from more than one market
SELECT customer_code, COUNT(DISTINCT market_code) AS num_markets
FROM transactions
GROUP BY customer_code
HAVING num_markets > 1
ORDER BY customer_code;

-- Trend of sales per region over the years
SELECT YEAR(t.order_date) AS years, M.zone, SUM(t.sales_amount) AS total_sales
FROM Transactions t
JOIN markets M 
    ON t.market_code = M.markets_code
GROUP BY years, M.zone
ORDER BY years;
