USE sales;

#List all customers in the customers table:
SELECT DISTINCT custmer_name FROM sales.customers;

#Retrieve all products with their corresponding customer IDs.
select T.customer_code , P.Product_code,P.Product_type
from Transactions T 
inner join Products P 
on T.product_code=P.Product_code
order by T.customer_code;

#Show all markets in the markets table located in the South region.
select * from markets where LOWER(zone) ='south';

#Select all transactions where the quantity is greater than 50.
select * from transactions where sales_qty>50;

SHOW COLUMNS FROM transactions;

#Retrieve all products sold after 2018-01-01.
select * from transactions where order_date>'2018-01-01' order by order_date;

#Show customers whose name contains Stores.
select * from customers where custmer_name like '%stores%';

ALTER TABLE customers
RENAME COLUMN custmer_name TO customer_name;

#List transactions in descending order of price.
select *  from transactions order by sales_amount desc ; 

#Find all markets not in the Central region.
select * from markets where zone not in ('Central') ; 

#Count the number of products sold by each customer.
select customer_code , count(product_code) as  number_of_products   from transactions group by customer_code order by number_of_products ;

#Calculate the total quantity sold for each product.
select product_code , sum(sales_qty) as  total_qty_by_product   from transactions group by product_code order by total_qty_by_product  ;

#average sales_amount per market.
select market_code, round(avg(sales_amount),3) as  avg_price  from transactions group by market_code order by avg_price ;

#List the number of transactions per year.
select year(order_date) as years , count(*) as number_of_transaction from transactions group by  year(order_date) ;

#List all products along with their market name.
select T.product_code , M.markets_name 
from Transactions T 
inner join markets M 
on T.market_code=M.markets_code;
 
#Show all transactions with customer name, product, and market region.
select customer_name , product_type ,zone
from Transactions T 
join Customers C 
on T.customer_code=C.Customer_code
join Products P 
on T.Product_code = P.Product_code
join Markets M
on T.market_code=M.markets_code;

#return customers that placed orders 
#we can do it with inner join or with exist
#methode 1 
SELECT DISTINCT C.*
FROM Customers C
INNER JOIN Transactions T
  ON C.Customer_code = T.Customer_code;
# methode 2 
select * from customers where exists (select * from transactions where  customers.Customer_code=transactions.Customer_code);


#List customers who have never bought Prod002.
#methode 1 
SELECT 
    Customer_code,
    GROUP_CONCAT(DISTINCT Product_code ORDER BY Product_code) AS Products_Bought
FROM Transactions
GROUP BY Customer_code
HAVING NOT FIND_IN_SET('Prod002', Products_Bought);

#methode 2
select customer_code from transactions where product_code not in ('Prod002') ;
#wrong becasue  If a customer bought Prod002 once and another product in another row, the row of the customer_code will still appear bc where clasue check row by row , each transactions individually 
#it does not check the full set of transactions 
#so: 
SELECT Customer_code
FROM Customers C
WHERE NOT EXISTS (
    SELECT 1 #it doesnt matter the value selected , the exist checks if at least one row exists and  in this case it chekcs the condition across all transactions of a customer
    FROM Transactions T
    WHERE T.Customer_code = C.Customer_code
      AND T.Product_code = 'Prod002'
);
#It does not stop at the first row that fails; it looks for at least one matching row anywhere in the customer’s transactions.

#Show the total amount spent by each customer (price × quantity).
select customer_code , sum(sales_qty*sales_amount) as total_amount_spent from transactions group by customer_code;


#Find the product(s) with the highest price.
select product_code ,sales_amount from transactions order by sales_amount desc limit 1 ; 

#List customers who have made transactions in Central.
select customer_code,market_code  from transactions where market_code in (select market_code from markets where Lower(zone)='Central') group by customer_code,market_code;


#Retrieve markets where total sales quantity exceeded 10000000000.
select  market_code,sum(sales_amount*sales_qty) as total_sales from transactions group by market_code  having total_sales > 10000000000;


#Find products that have never been sold.
select product_code from products where not exists(select * from transactions where products.product_code=transactions.product_code);#M1
select product_code from products where product_code not in  (select product_code  from transactions );#M2


#Show monthly sales totals for each product. 
select min(order_date) day1 , max(order_date) as last_date from transactions; #quick check
select product_code,month(order_date) as monthly , sum(sales_amount*sales_qty) as total from transactions group by monthly,product_code order by monthly ,product_code;

#Show average transaction price per customer and rank them. 
select
 customer_code , avg(sales_amount*sales_qty) as average , dense_rank() over(order by avg(sales_amount*sales_qty)  desc) as rank_by_avg 
 from transactions group by customer_code ;

#how many products bought by each customer
select customer_code , count(distinct product_code)as number_unique_products from transactions group by customer_code  order by number_unique_products asc;

#customers who bought products from more than one market.
select customer_code ,count(distinct market_code) num_markets from transactions group by customer_code having num_markets > 1 order by customer_code;

#the trend of sales per region over the years.
select year(order_date) as years , zone, sum(sales_amount*sales_qty) as total_sales
from Transactions t 
join markets M 
on T.market_code=M.Markets_code
group by years,zone
order by years;
 