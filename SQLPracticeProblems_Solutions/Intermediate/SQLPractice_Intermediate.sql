/*
Author:			
	Lynnetta Curtis
Report:			
	N/A
Date:			
	Feb 2018
Purpose:		
	SQL Challenge - Intermediate
Design Tool:	
	SSMS
DBMS:			
	SQL SERVER 2017, Developer Edition
DB:				
	Northwind_SPP
Retention:		
	KP TEMP
*/

--Q20 CATEGORIES, AND THE TOTAL PRODUCTS IN EACH CATEGORY?
--Q20_SOLUTION:
SELECT CATEGORYNAME,
COUNT(PRODUCTID) AS TOTALPRODUCTS
FROM CATEGORIES
JOIN PRODUCTS ON PRODUCTS.CATEGORYID=CATEGORIES.CATEGORYID
GROUP BY CATEGORYNAME
ORDER BY TOTALPRODUCTS DESC;

--Q21 TOTAL CUSTOMERS PER COUNTRY/CITY?
--Q21_SOLUTION:
SELECT COUNTRY, 
CITY,
COUNT(CUSTOMERID) AS TOTAL_CUSTOMERS
FROM CUSTOMERS
GROUP BY COUNTRY, CITY
ORDER BY TOTAL_CUSTOMERS DESC;

--Q22 PRODUCTS THAT NEED REORDERING?
--Q22_SOLUTION:
SELECT PRODUCTID,
PRODUCTNAME,
UNITSINSTOCK,
REORDERLEVEL
FROM PRODUCTS
WHERE UNITSINSTOCK < REORDERLEVEL
ORDER BY PRODUCTID ASC;

--Q23 PRODUCTS THAT NEED REORDERING, NEW CRITERIA?
--Q23_SOLUTION:
SELECT PRODUCTID,
PRODUCTNAME,
UNITSINSTOCK,
UNITSONORDER,
REORDERLEVEL,
DISCONTINUED
FROM PRODUCTS
WHERE (UNITSINSTOCK + UNITSONORDER) < REORDERLEVEL
	AND DISCONTINUED = 0
ORDER BY PRODUCTID ASC;

--Q24 CUSTOMER LIST BY REGION?
--Q24_SOLUTION:
SELECT CUSTOMERID,
COMPANYNAME,
CONTACTNAME,
REGION
FROM CUSTOMERS
ORDER BY CASE 
	WHEN REGION IS NULL THEN 1
	ELSE 0
	END,
	REGION, COMPANYNAME;

--Q25 HIGH FREIGHT CHARGES?
--Q25_SOLUTION:
SELECT TOP 3 SHIPCOUNTRY,
AVG(FREIGHT) AS AVG_FREIGHT
FROM ORDERS
GROUP BY SHIPCOUNTRY
ORDER BY AVG_FREIGHT DESC;

--Q26 HIGH FREIGHT CHARGES IN 2015?
--Q26_SOLUTION:
SELECT TOP 3 SHIPCOUNTRY,
AVG(FREIGHT) AS AVG_FREIGHT
FROM ORDERS
WHERE YEAR(ORDERDATE) = 2015
GROUP BY SHIPCOUNTRY
ORDER BY AVG_FREIGHT DESC;

--Q27 HIGH FREIGHT CHARGES WITH BETWEEN STATEMENT?
--Q27_SOLUTION_1:
SELECT TOP 3 SHIPCOUNTRY,
AVG(FREIGHT) AS AVG_FREIGHT
FROM ORDERS
WHERE ORDERDATE BETWEEN DATEADD(YEAR,-1,(SELECT MAX(ORDERDATE) FROM ORDERS)) 
	AND (SELECT MAX(ORDERDATE) FROM ORDERS)
GROUP BY SHIPCOUNTRY
ORDER BY AVG_FREIGHT DESC;

--Q28 HIGHEST FREIGHT CHARGES LAST YEAR?
--Q28_SOLUTION:
SELECT TOP 3 SHIPCOUNTRY,
AVG(FREIGHT) AS AVG_FREIGHT
FROM ORDERS
WHERE ORDERDATE >= DATEADD(YEAR,-1,(SELECT MAX(ORDERDATE) FROM ORDERS))
GROUP BY SHIPCOUNTRY
ORDER BY AVG_FREIGHT DESC;

--Q29 EMPLOYEE/ORDER DETAIL REPORT?
--Q29_SOLUTION:
SELECT EMPLOYEES.EMPLOYEEID,
LASTNAME,
ORDERS.ORDERID,
PRODUCTNAME,
QUANTITY
FROM EMPLOYEES
JOIN ORDERS ON EMPLOYEES.EMPLOYEEID=ORDERS.EMPLOYEEID
JOIN ORDERDETAILS ON ORDERS.ORDERID=ORDERDETAILS.ORDERID
JOIN PRODUCTS ON ORDERDETAILS.PRODUCTID=PRODUCTS.PRODUCTID
ORDER BY ORDERID, PRODUCTS.PRODUCTID;

--Q30 CUSTOMERS WITH NO ORDERS?
--Q30_SOLUTION:
SELECT CUST.CUSTOMERID AS CUSTOMERS_CUSTOMERID,
ORDERS.CUSTOMERID AS ORDERS_CUSTOMERID
FROM CUSTOMERS AS CUST
LEFT JOIN ORDERS AS ORDERS 
	ON CUST.CUSTOMERID=ORDERS.CUSTOMERID
WHERE ORDERID IS NULL;

--Q31 CUSTOMERS WITH NO ORDERS FROM EMPLOYEEID 4?
--Q31_SOLUTION:
SELECT CUSTOMERS.CUSTOMERID,
ORDERS.CUSTOMERID 
FROM CUSTOMERS
LEFT JOIN ORDERS ON 
CUSTOMERS.CUSTOMERID=ORDERS.CUSTOMERID
	AND ORDERS.EMPLOYEEID = 4
WHERE ORDERID IS NULL;
