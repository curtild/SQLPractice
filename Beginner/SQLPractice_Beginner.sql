/*
Author:			
	Lynnetta Curtis
Report:			
	N/A
Date:			
	February 2018
Purpose:		
	SQL Challenge - Beginner
Design Tool:	
	SSMS
DBMS:			
	SQL SERVER 2019, Developer Edition
DB:				
	Northwind_SPP
Retention:		
	KP TEMP
*/

--Q1 WHICH SHIPPERS DO WE HAVE?
--Q1_SOLUTION:
SELECT * 
FROM SHIPPERS;

--Q2 CERTAIN FIELDS FROM CATEGORIES?
--Q2_SOLUTION:
SELECT CATEGORYNAME, 
[DESCRIPTION] 
FROM CATEGORIES;

--Q3 SALES REPRESENTATIVES?
--Q3_SOLUTION:
SELECT FIRSTNAME, 
LASTNAME, 
HIREDATE 
FROM EMPLOYEES
WHERE TITLE='Sales Representative';

--Q4 SALES REPRESENTATIVES IN THE UNITED STATES?
--Q4_SOLUTION:
SELECT FIRSTNAME, 
LASTNAME, 
HIREDATE 
FROM EMPLOYEES
WHERE TITLE='Sales Representative' AND COUNTRY='USA';

--Q5 ORDERS PLACED BY SPECIFIC EMPLOYEEID?
--Q5_SOLUTION:
SELECT ORDERID,
ORDERDATE
FROM ORDERS
WHERE EMPLOYEEID=5;

--Q6 SUPPLIERS AND CONTACT TITLES?
--Q6_SOLUTION:
SELECT SUPPLIERID,
CONTACTNAME,
CONTACTTITLE
FROM SUPPLIERS
WHERE CONTACTTITLE <> 'Marketing Manager';

--Q7 PRODUCTS WITH "QUESO" IN PRODUCT NAME?
--Q7_SOLUTION:
SELECT PRODUCTID,
PRODUCTNAME
FROM PRODUCTS
WHERE PRODUCTNAME LIKE '%Queso%';

--Q8 ORDERS SHIPPING TO FRANCE OR BELGIUM?
--Q8_SOLUTION:
SELECT ORDERID,
ORDERDATE,
CUSTOMERID,
SHIPCOUNTRY
FROM ORDERS
WHERE SHIPCOUNTRY IN ('France','Belgium');

--Q9 ORDERS SHIPPING TO ANY COUNTRY IN LATIN AMERICA?
--Q9_SOLUTION:
SELECT ORDERID,
ORDERDATE,
CUSTOMERID,
SHIPCOUNTRY
FROM ORDERS
WHERE SHIPCOUNTRY IN ('Brazil','Mexico','Argentina','Venezuela');

--Q10 EMPLOYEES, IN ORDER OF AGE
--Q10_SOLUTION:
SELECT FIRSTNAME,
LASTNAME,
TITLE,
BIRTHDATE
FROM EMPLOYEES
ORDER BY BIRTHDATE ASC;

--Q11_SHOW ONLY THE DATE WITH A DATE TIME FIELD?
--Q11_SOLUTION:
SELECT FIRSTNAME,
LASTNAME,
TITLE,
CONVERT(DATE,BIRTHDATE) AS DOB
FROM EMPLOYEES
ORDER BY BIRTHDATE ASC;

--Q12 EMPLOYEES FULL NAME?
--Q12_SOLUTION:
SELECT
FIRSTNAME,
LASTNAME,
CONCAT_WS(' ', FIRSTNAME,LASTNAME) AS FULLNAME
FROM EMPLOYEES;

--Q13 ORDER DETAILS, AMOUNT PER LINE ITEM (WITH DERIVED FIELD)?
--Q13_SOLUTION:
SELECT ORDERID,
PRODUCTID,
UNITPRICE,
QUANTITY,
(UNITPRICE * QUANTITY) AS TOTALPRICE
FROM ORDERDETAILS
ORDER BY ORDERID, PRODUCTID;

--Q14 HOW MANY CUSTOMERS?
--Q14_SOLUTION:
SELECT COUNT(CUSTOMERID) AS TOTALCUSTOMERS
FROM CUSTOMERS;

--Q15 WHEN WAS THE FIRST ORDER?
--Q15_SOLUTION:
SELECT MIN(ORDERDATE) AS FIRSTORDER
FROM ORDERS;

--Q16 COUNTRIES WHERE THERE ARE CUSTOMERS?
--Q16_SOLUTION 1:
SELECT DISTINCT COUNTRY FROM CUSTOMERS;

--Q16_SOLUTION 2:
SELECT COUNTRY FROM CUSTOMERS
GROUP BY COUNTRY;

--Q17 CONTACT TITLES FOR CUSTOMERS?
--Q17_SOLUTION:
SELECT CONTACTTITLE,
COUNT(*) AS TITLE_COUNT
FROM CUSTOMERS
GROUP BY CONTACTTITLE
ORDER BY COUNT(*) DESC;

--Q18 PRODUCTS WITH ASSOCIATED SUPPLIER NAMES?
--Q18_SOLUTION:
SELECT PRODUCTID, 
PRODUCTNAME,
COMPANYNAME
FROM PRODUCTS
JOIN SUPPLIERS ON PRODUCTS.SUPPLIERID=SUPPLIERS.SUPPLIERID
ORDER BY PRODUCTS.PRODUCTID;

--Q19 ORDERS AND THE SHIPPER THAT WAS USED?
--Q19_SOLUTION:
SELECT ORDERID,
CONVERT(DATE, ORDERDATE) AS ORDERDATE,
COMPANYNAME AS SHIPPER
FROM ORDERS
JOIN SHIPPERS ON ORDERS.SHIPVIA=SHIPPERS.SHIPPERID
WHERE ORDERS.ORDERID < 10270
ORDER BY ORDERID;
