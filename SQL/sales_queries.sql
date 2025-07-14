--Create 3 main tables: Customers, Products, Sales

CREATE TABLE Customers AS
SELECT CustomerID, Country
FROM online_retail
WHERE CustomerID IS NOT NULL
-- to remove duplicates
GROUP BY CustomerID
;

CREATE TABLE Products AS
SELECT StockCode, Description, UnitPrice
FROM online_retail
WHERE StockCode IS NOT NULL
-- to remove duplicates
GROUP BY StockCode
;

--I then found that some product IDs had no description or price assigned. So, I need to update the table to remove these products from the list.

DELETE FROM Products
WHERE Description IS NULL 
OR UnitPrice  = '0.0';

--Now I will create the Sales Table:

CREATE TABLE Sales AS
SELECT InvoiceNo, InvoiceDate, StockCode, Quantity,UnitPrice, CustomerID
FROM online_retail
WHERE InvoiceNo IS NOT NULL
; 

--Now I need to calculate revenue by multiplying the quantity by the unit price and create a new column in the Sales table:

ALTER TABLE Sales
ADD COLUMN Revenue AS
(Quantity * UnitPrice)
;

--I want to identify the highest product generating sales:

SELECT s.StockCode AS ProductID, 
p.Description, 
SUM (Revenue) AS Total_Sales
FROM  Sales as s
LEFT JOIN Products as p
ON s.StockCode = p.StockCode
Group BY s.StockCode
ORDER by Total_Sales DESC
LIMIT 10
; 

--Now I can check what is the highest revenue month:

SELECT 
substr(InvoiceDate, 4, 2) AS month,
substr(InvoiceDate, 7, 4) AS year,
SUM (Revenue) As totalsales
FROM Sales
GROUP BY month
ORDER BY totalsales;

--I also want to know who the highest spending customers are that we have:

SELECT 
CustomerID,
SUM (Revenue) As totalsales
FROM Sales
GROUP by CustomerID
order by totalsales DESC
LIMIT 10;

--Selecting the highest customer ID in the United Kingdom:

SELECT 
s.CustomerID,
SUM (Revenue) As totalsales,
c.Country
FROM Sales as s
LEFT JOIN Customers as c
ON s.CustomerID = c.CustomerID
WHERE c.Country = "United Kingdom"
GROUP by c.CustomerID
order by totalsales DESC
LIMIT 10;

--Revenue by country:

SELECT 
SUM (Revenue) As totalsales,
c.Country
FROM Sales as s
LEFT JOIN Customers as c
ON s.CustomerID = c.CustomerID
GROUP by c.Country
order by totalsales DESC
LIMIT 10;

--To check if table have duplicated rows
SELECT DISTINCT *
FROM Sales  
;

--To delete duplicate data entries:
DELETE FROM Sales
WHERE rowid NOT IN (
    SELECT MIN(rowid)
    FROM Sales
    GROUP BY InvoiceNo, InvoiceDate, StockCode, Quantity, UnitPrice, CustomerID, Revenue
);
