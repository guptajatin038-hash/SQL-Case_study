create database case_study;
use case_study;
alter table customer_profiles
rename column `ï»¿CustomerID` to CustomerId;
alter table product_inventory
rename column `ï»¿ProductID` to `productId`;
alter table sales_transaction
rename column `ï»¿TransactionID` to `TransactionID`;
select TransactionID, count(*) from sales_transaction
group by TransactionID
having count(CustomerID)>1;
select * from sales_transaction;
create table sales_transaction_dubli as 
select distinct * from sales_transaction;
select *from sales_transaction_dubli;
drop table sales_transaction;
alter table sales_transaction_dubli rename to sales_transaction;
select *from sales_transaction;

/*problem satatement 2
Write a query to identify the discrepancies in the price of the same product in 
"sales_transaction" and "product_inventory" tables. Also, update those discrepancies to 
match the price in both the tables.*/

SELECT pi.productID, st.TransactionID, st.Price AS TransactionPrice, 
pi.Price AS InventoryPrice 
FROM sales_transaction st 
JOIN product_inventory pi ON st.ProductID = pi.ProductID 
WHERE st.Price <> pi.Price;

UPDATE sales_transaction st 
SET Price = ( SELECT pi.Price FROM product_inventory pi WHERE st.ProductID = pi.ProductID ) 
WHERE st.ProductID IN 
    (SELECT ProductID FROM product_inventory WHERE st.Price <> product_inventory.Price ); 

Select * from sales_transaction;

/*problem statement 3
Write a SQL query to identify the null values in the dataset and replace those by “Unknown”.*/

select count(*) from customer_profiles where (Location = "") or (location is null);
update customer_profiles 
set location = "Unknown" where (Location = "") or (location is null);
select * from customer_profiles;

/* Problem statement 4
Write a SQL query to clean the DATE column in the dataset.
Steps:
Create a separate table and change the data type of the date column as it is in TEXT format and name 
it as you wish to.
Remove the original table from the database.
Change the name of the new table and replace it with the original name of the table*/

create table sale_dub as select * , cast(TransactionDate as date) as TransactionDate_updated
 from Sales_transaction;
drop table Sales_transaction;
 alter table sale_dub Rename to Sales_transaction;
 select * from Sales_transaction;
# ---------------------EDA---------------------------- 
 /*Write a SQL query to summarize the total sales and quantities sold per product by the company.
(Here, the data has been already cleaned in the previous steps and from here we will be understanding 
the different types of data analysis from the given dataset.)*/

select ProductID, sum(QuantityPurchased) as totalQuantityPurchased, 
round(sum(Price*QuantityPurchased),2) as totalsale
 from sales_transaction
 group by productid
 order by productid;
 
 /*Problem statement
Write a SQL query to count the number of transactions per customer to understand purchase frequency.*/

select CustomerID, count(CustomerID) as NumberofTransaction
from sales_transaction
group by CustomerID
order by NumberofTransaction desc;

/*Write a SQL query to evaluate the performance of the product categories based on the total sales 
which help us understand the product categories which needs to be promoted in the marketing campaigns.*/

select pi.Category, sum(st.QuantityPurchased) as TotalUnitSold,
sum(st.QuantityPurchased*st.Price) as TotalSales
from product_inventory pi
join sales_transaction st
on pi.productid= st.productid
group by pi.Category
order by TotalUnitSold desc;

/*Problem statement
Write a SQL query to find the top 10 products with the highest total sales revenue from the sales transactions. 
This will help the company to identify the High sales products which needs to be focused to increase the revenue 
of the company.*/

select ProductID, sum(QuantityPurchased*Price) as TotalSalesRevenue from sales_transaction
group by ProductID
order by TotalSalesRevenue desc
limit 10;

/*Write a SQL query to find the ten products with the least amount of units sold from the sales transactions, 
provided that at least one unit was sold for those products.*/

select productid, sum(QuantityPurchased) as TotalUnitsSold
from sales_transaction 
group by ProductID 
having sum(QuantityPurchased)>0
order by TotalUnitsSold
limit 10;

/*Write a SQL query to identify the sales trend to understand the revenue pattern of the company.*/
select TransactionDate as Datetrans, count(TransactionID), sum(QuantityPurchased) as TotalUnitsSold,
sum(QuantityPurchased*Price) as TotalSales
from sales_transaction 
group by datetrans
order by datetrans;

/*Problem statement
Write a SQL query to understand the month on month growth rate of sales of the company which will help understand
the growth trend of the company.
*/
select 
date_format(TransactionDate,'%M') as Month, 
round(sum(QuantityPurchased*Price),2) as Total_Sales, 
lag(round(sum(QuantityPurchased*Price),2)) 
over (order by EXTRACT(MONTH FROM TransactionDate)) as previous_month_sale,
round((sum(QuantityPurchased*Price)- lag(sum(QuantityPurchased*Price)) 
over (order by EXTRACT(MONTH FROM TransactionDate)))
/lag(sum(QuantityPurchased*Price)) over (order by EXTRACT(MONTH FROM TransactionDate))*100,2) as previous_month_sale_per
from sales_transaction
group by 1,2
order by EXTRACT(MONTH FROM TransactionDate);

/*Write a SQL query that describes the number of transaction along with the total amount spent by each customer 
which are on the higher side and will help us understand the customers who are the high frequency purchase 
customers in the company.*/
select CustomerID, count(TransactionID) as NumberOfTransactions, 
sum(QuantityPurchased*Price) as TotalSpent
from sales_transaction 
group by CustomerID
having count(TransactionID)>10 and sum(QuantityPurchased*Price)>1000
order by totalspent desc;

/*Write a SQL query that describes the number of transaction along with the total amount spent by each customer, 
which will help us understand the customers who are occasional customers or have low purchase frequency 
in the company.*/
select CustomerID, count(TransactionID) as NumberOfTransactions, 
sum(QuantityPurchased*Price) as TotalSpent
from sales_transaction 
group by CustomerID
having count(TransactionID)<=2
order by  NumberOfTransactions asc, totalspent desc;

/*Write a SQL query that describes the total number of purchases made by each customer against each productID to 
understand the repeat customers in the company.*/
select CustomerID, ProductID, count(ProductID) as TimesPurchased
from sales_transaction
group by CustomerID, ProductID
having count(ProductID)>1
order by TimesPurchased desc;

/*Write a SQL query that describes the duration between the first and the last purchase of the customer in that 
particular company to understand the loyalty of the customer.*/
	SELECT 
		CustomerID,
		MIN(TransactionDate) AS FirstPurchaseDate,
		MAX(TransactionDate) AS LastPurchaseDate,
		MAX(TransactionDate) - MIN(TransactionDate) AS PurchaseDuration_Days
	FROM sales_transaction
	GROUP BY CustomerID
	having PurchaseDuration_Days>0
	ORDER BY CustomerID DESC;
	select TransactionDate from sales_transaction;

/*Write an SQL query that segments customers based on the total quantity of products they have purchased. 
Also, count the number of customers in each segment which will help us target a particular segment for marketing.*/
select ProductID, 
case 
when sum(QuantityPurchased) <10 then 'Low Sale'
when sum(QuantityPurchased)<30 then "Medium"
else "Heigh" end as SaleSegment, count(CustomerId) as TotalquantityPurchased
from sales_transaction
group by ProductID
order by TotalquantityPurchased;
CREATE TABLE customer_SEGMENT AS
SELECT t.CustomerID,
  CASE 
    WHEN t.TotalQuantity > 30 THEN "High"
    WHEN t.TotalQuantity BETWEEN 10 AND 30 THEN "Med"
    WHEN t.TotalQuantity BETWEEN 1 AND 10 THEN "Low"
    ELSE "None"
  END AS CustomerSegment
FROM (
  SELECT a.CustomerID, SUM(b.QuantityPurchased) AS TotalQuantity
  FROM customer_profiles a
  JOIN sales_transaction b
  ON a.CustomerID = b.CustomerID
  GROUP BY a.CustomerID) t;
# Counting distribution of customer segments  
SELECT CustomerSegment, COUNT(*)
FROM customer_SEGMENT
GROUP BY CustomerSegment;