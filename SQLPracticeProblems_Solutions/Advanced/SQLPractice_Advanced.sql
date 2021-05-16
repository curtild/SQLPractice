/*
Author:			
	Lynnetta Curtis
Report:			
	N/A
Date:			
	February 2018
Purpose:		
	SQL Challenge - Advanced
Design Tool:	
	SSMS
DBMS:			
	SQL SERVER 2017, Developer Edition
DB:				
	Northwind_SPP
Retention:		
	KP TEMP
*/

USE NORTHWIND_SPP
GO

--Q32: HIGH-VALUE CUSTOMERS?
--Q32_SOLUTION: 
SELECT CUSTOMERS.CUSTOMERID AS CUSTOMER_ID,
COMPANYNAME AS COMPANY_NAME,
ORDERS.ORDERID AS ORDER_ID,
SUM(UNITPRICE * QUANTITY) AS TOTAL_ORDER_AMOUNT
FROM CUSTOMERS
JOIN ORDERS ON CUSTOMERS.CUSTOMERID=ORDERS.CUSTOMERID
JOIN ORDERDETAILS ON ORDERS.ORDERID=ORDERDETAILS.ORDERID
WHERE YEAR(ORDERDATE) = 2016
GROUP BY CUSTOMERS.CUSTOMERID, COMPANYNAME, ORDERS.ORDERID
HAVING SUM(UNITPRICE * QUANTITY) >= 10000
ORDER BY TOTAL_ORDER_AMOUNT DESC;

--Q33: HIGH-VALUE CUSTOMERS - TOTAL ORDERS?
--Q33_SOLUTION:  
SELECT CUSTOMERS.CUSTOMERID AS CUSTOMER_ID,
COMPANYNAME AS COMPANY_NAME,
SUM(UNITPRICE * QUANTITY) AS TOTAL_ORDER_AMOUNT
FROM CUSTOMERS
JOIN ORDERS ON CUSTOMERS.CUSTOMERID=ORDERS.CUSTOMERID
JOIN ORDERDETAILS ON ORDERS.ORDERID=ORDERDETAILS.ORDERID
WHERE YEAR(ORDERDATE) = 2016
GROUP BY CUSTOMERS.CUSTOMERID, COMPANYNAME
HAVING SUM(UNITPRICE * QUANTITY) >= 15000
ORDER BY TOTAL_ORDER_AMOUNT DESC;

--Q34: HIGH-VALUE CUSTOMERS - WITH DISCOUNT?
--Q34_SOLUTION:  
SELECT CUSTOMERS.CUSTOMERID AS CUSTOMER_ID,
COMPANYNAME AS COMPANY_NAME,
SUM(UNITPRICE * QUANTITY) AS TOTALS_WITHOUT_DISCOUNT,
SUM(UNITPRICE * QUANTITY * (1-DISCOUNT)) AS TOTALS_WITH_DISCOUNT
FROM CUSTOMERS
JOIN ORDERS ON CUSTOMERS.CUSTOMERID=ORDERS.CUSTOMERID
JOIN ORDERDETAILS ON ORDERS.ORDERID=ORDERDETAILS.ORDERID
WHERE YEAR(ORDERDATE) = 2016
GROUP BY CUSTOMERS.CUSTOMERID, COMPANYNAME
HAVING SUM(UNITPRICE * QUANTITY * (1-DISCOUNT)) >= 10000
ORDER BY TOTALS_WITH_DISCOUNT DESC;

--Q35: MONTH-END ORDERS?
--Q35_SOLUTION:  
SELECT EMPLOYEEID AS EMPLOYEE_ID,
ORDERS.ORDERID AS ORDER_ID,
CONVERT(DATE, ORDERDATE) AS ORDER_DATE
FROM ORDERS
WHERE ORDERDATE >= EOMONTH(ORDERDATE)
ORDER BY EMPLOYEEID, ORDERID;

--Q36: ORDERS WITH MANY LINE ITEMS?
--Q36_SOLUTION:  
--(SOLVED WITH A SUBQUERY)
SELECT TOP 10 
ORDERS.ORDERID AS ORDER_ID,
ORDER_LINE_ITEMS AS TOTAL_ORDER_DETAILS
FROM
(SELECT ORDERS.ORDERID,
COUNT(*) AS ORDER_LINE_ITEMS
FROM ORDERS
JOIN ORDERDETAILS AS OD
ON ORDERS.ORDERID=OD.ORDERID
GROUP BY ORDERS.ORDERID
ORDER BY COUNT(*) DESC
OFFSET 0 ROWS) AS ORDERS

--(SOLVED WITH A CTE)
WITH ORDER_LINE_ITEMS AS
(
SELECT ORDERS.ORDERID,
COUNT(*) AS ORDER_LINEITEMS
FROM ORDERS
JOIN ORDERDETAILS AS OD
ON ORDERS.ORDERID=OD.ORDERID
GROUP BY ORDERS.ORDERID
ORDER BY COUNT(*) DESC
OFFSET 0 ROWS
)
SELECT TOP 10 
ORDERID AS ORDER_ID,
ORDER_LINEITEMS AS TOTAL_ORDER_DETAILS
FROM ORDER_LINE_ITEMS


--Q37: ORDERS - RANDOM ASSORTMENT?
--Q37_SOLUTION: 
SELECT TOP 2 PERCENT
ORDERID AS ORDER_ID
FROM ORDERS
ORDER BY NEWID();

--Q38: ORDERS - ACCIDENTAL DOUBLE ENTRY?
--Q38_SOLUTION:
SELECT ORDERID AS ORDER_ID
FROM ORDERDETAILS
WHERE QUANTITY >=60
GROUP BY ORDERID, QUANTITY
HAVING COUNT(*) > 1;

--Q39: ORDERS - ACCIDENTAL DOUBLE-ENTRY DETAILS?
--Q39_SOLUTION:
--(SOLVED WITH A SUBQUERY)
SELECT ORDERID AS ORDER_ID,
PRODUCTID AS PRODUCT_ID,
UNITPRICE AS UNIT_PRICE,
QUANTITY,
DISCOUNT
FROM ORDERDETAILS
WHERE ORDERID IN (SELECT ORDERID
FROM ORDERDETAILS
WHERE QUANTITY >=60
GROUP BY ORDERID, QUANTITY
HAVING COUNT(*) > 1)
ORDER BY ORDERID, QUANTITY;

--Q40 ORDERS - ACCIDENTAL DOUBLE-ENTRY DETAILS, DERIVED TABLE? 
--Q40_SOLUTION:
--(SOLVED WITH A CTE)
WITH MULTIPLE_QTYS_OF_60PLUS AS
(
SELECT ORDERID
FROM ORDERDETAILS
WHERE QUANTITY >=60
GROUP BY ORDERID, QUANTITY
HAVING COUNT(*) > 1
)
SELECT ORDERID AS ORDER_ID,
PRODUCTID AS PRODUCT_ID,
UNITPRICE AS UNIT_PRICE,
QUANTITY,
DISCOUNT
FROM ORDERDETAILS
WHERE ORDERID IN (SELECT * FROM MULTIPLE_QTYS_OF_60PLUS);

--Q41: LATE ORDERS?
--Q41_SOLUTION:
SELECT ORDERID AS ORDER_ID,
CONVERT(DATE, ORDERDATE) AS ORDER_DATE,
CONVERT(DATE, REQUIREDDATE) AS REQUIRED_DATE,
CONVERT(DATE, SHIPPEDDATE) AS SHIPPED_DATE
FROM ORDERS
WHERE SHIPPEDDATE >= REQUIREDDATE;

--Q42: LATE ORDERS - WHICH EMPLOYEES?
--Q42_SOLUTION:
SELECT EMPLOYEES.EMPLOYEEID AS EMPLOYEE_ID,
LASTNAME AS LAST_NAME,
COUNT(*) AS TOTAL_LATE_ORDERS
FROM EMPLOYEES
JOIN ORDERS ON EMPLOYEES.EMPLOYEEID=ORDERS.EMPLOYEEID
WHERE SHIPPEDDATE >= REQUIREDDATE
GROUP BY EMPLOYEES.EMPLOYEEID, LASTNAME
ORDER BY TOTAL_LATE_ORDERS DESC;

--Q43: LATE ORDERS VS. TOTAL ORDERS?
--Q43_SOLUTION:
--(SOLVED WITH A SUBQUERY)
SELECT ALL_ORDERS.EMPLOYEEID AS EMPLOYEE_ID,
ALL_ORDERS.LASTNAME AS LAST_NAME,
ALL_ORDERS.ALLORDERS AS ALL_ORDERS,
COUNT(*) AS LATE_ORDERS
FROM
(SELECT EMPLOYEES.EMPLOYEEID,
LASTNAME,
COUNT(*) AS ALLORDERS
FROM EMPLOYEES
LEFT JOIN ORDERS ON EMPLOYEES.EMPLOYEEID=ORDERS.EMPLOYEEID
GROUP BY EMPLOYEES.EMPLOYEEID, LASTNAME
) AS ALL_ORDERS
JOIN ORDERS ON ALL_ORDERS.EMPLOYEEID=ORDERS.EMPLOYEEID
WHERE SHIPPEDDATE >= REQUIREDDATE
GROUP BY ALL_ORDERS.EMPLOYEEID, LASTNAME, ALLORDERS
ORDER BY ALL_ORDERS.EMPLOYEEID;

--(SOLVED WITH A CTE)
WITH ALL_ORDERS AS
(
SELECT EMPLOYEES.EMPLOYEEID,
LASTNAME,
COUNT(*) AS ALLORDERS
FROM EMPLOYEES
LEFT JOIN ORDERS ON EMPLOYEES.EMPLOYEEID=ORDERS.EMPLOYEEID
GROUP BY EMPLOYEES.EMPLOYEEID, LASTNAME
)
SELECT ALL_ORDERS.EMPLOYEEID AS EMPLOYEE_ID,
ALL_ORDERS.LASTNAME AS LAST_NAME,
ALL_ORDERS.ALLORDERS AS ALL_ORDERS,
COUNT(*) AS LATE_ORDERS
FROM ALL_ORDERS
JOIN ORDERS ON ALL_ORDERS.EMPLOYEEID=ORDERS.EMPLOYEEID
WHERE SHIPPEDDATE >= REQUIREDDATE
GROUP BY ALL_ORDERS.EMPLOYEEID, LASTNAME, ALLORDERS
ORDER BY ALL_ORDERS.EMPLOYEEID;

--Q44: LATE ORDERS VS. TOTAL ORDERS - MISSING EMPLOYEES?
--Q44_SOLUTION:
--(SOLVED WITH SUBQUERIES)
SELECT ALL_ORDERS.EMPLOYEEID AS EMPLOYEE_ID,
ALL_ORDERS.LASTNAME AS LAST_NAME,
ALLORDERS AS ALL_ORDERS,
LATEORDERS AS LATE_ORDERS
FROM
(SELECT EMPLOYEES.EMPLOYEEID,
EMPLOYEES.LASTNAME,
COUNT(*) AS ALLORDERS
FROM EMPLOYEES
LEFT JOIN ORDERS ON EMPLOYEES.EMPLOYEEID=ORDERS.EMPLOYEEID
GROUP BY EMPLOYEES.EMPLOYEEID, LASTNAME) AS ALL_ORDERS
LEFT JOIN
(SELECT EMPLOYEES.EMPLOYEEID,
LASTNAME,
COUNT(*) AS LATEORDERS
FROM EMPLOYEES
JOIN ORDERS ON EMPLOYEES.EMPLOYEEID=ORDERS.EMPLOYEEID
WHERE SHIPPEDDATE >= REQUIREDDATE
GROUP BY EMPLOYEES.EMPLOYEEID, LASTNAME) AS LATE_ORDERS
ON ALL_ORDERS.EMPLOYEEID=LATE_ORDERS.EMPLOYEEID;

--(SOLVED WITH CTEs)
WITH LATE_ORDERS AS
(
SELECT EMPLOYEES.EMPLOYEEID,
LASTNAME,
COUNT(*) AS LATEORDERS
FROM EMPLOYEES
JOIN ORDERS ON EMPLOYEES.EMPLOYEEID=ORDERS.EMPLOYEEID
WHERE SHIPPEDDATE >= REQUIREDDATE
GROUP BY EMPLOYEES.EMPLOYEEID, LASTNAME
)
,
ALL_ORDERS AS
(
SELECT EMPLOYEES.EMPLOYEEID,
EMPLOYEES.LASTNAME,
COUNT(*) AS ALLORDERS
FROM EMPLOYEES
LEFT JOIN ORDERS ON EMPLOYEES.EMPLOYEEID=ORDERS.EMPLOYEEID
GROUP BY EMPLOYEES.EMPLOYEEID, LASTNAME
)
SELECT ALL_ORDERS.EMPLOYEEID AS EMPLOYEE_ID,
ALL_ORDERS.LASTNAME AS LAST_NAME,
ALLORDERS AS ALL_ORDERS,
LATEORDERS AS LATE_ORDERS
FROM ALL_ORDERS 
LEFT JOIN
LATE_ORDERS
ON ALL_ORDERS.EMPLOYEEID=LATE_ORDERS.EMPLOYEEID;

--Q45: LATE ORDERS VS. TOTAL ORDERS - FIX NULL?
--Q45_SOLUTION:
--(SOLVED WITH SUBQUERIES)
SELECT ALL_ORDERS.EMPLOYEEID AS EMPLOYEE_ID,
ALL_ORDERS.LASTNAME AS LAST_NAME,
ALLORDERS AS ALL_ORDERS,
ISNULL(LATEORDERS,0) AS LATE_ORDERS
FROM
(SELECT EMPLOYEES.EMPLOYEEID,
EMPLOYEES.LASTNAME,
COUNT(*) AS ALLORDERS
FROM EMPLOYEES
LEFT JOIN ORDERS ON EMPLOYEES.EMPLOYEEID=ORDERS.EMPLOYEEID
GROUP BY EMPLOYEES.EMPLOYEEID, LASTNAME) AS ALL_ORDERS
LEFT JOIN
(SELECT EMPLOYEES.EMPLOYEEID,
LASTNAME,
COUNT(*) AS LATEORDERS
FROM EMPLOYEES
JOIN ORDERS ON EMPLOYEES.EMPLOYEEID=ORDERS.EMPLOYEEID
WHERE SHIPPEDDATE >= REQUIREDDATE
GROUP BY EMPLOYEES.EMPLOYEEID, LASTNAME) AS LATE_ORDERS
ON ALL_ORDERS.EMPLOYEEID=LATE_ORDERS.EMPLOYEEID;

--(SOLVED WITH CTEs)
WITH LATE_ORDERS AS
(
SELECT EMPLOYEES.EMPLOYEEID,
LASTNAME,
COUNT(*) AS LATEORDERS
FROM EMPLOYEES
JOIN ORDERS ON EMPLOYEES.EMPLOYEEID=ORDERS.EMPLOYEEID
WHERE SHIPPEDDATE >= REQUIREDDATE
GROUP BY EMPLOYEES.EMPLOYEEID, LASTNAME
)
, 
ALL_ORDERS AS 
(
SELECT EMPLOYEES.EMPLOYEEID,
EMPLOYEES.LASTNAME,
COUNT(*) AS ALLORDERS
FROM EMPLOYEES
LEFT JOIN ORDERS ON EMPLOYEES.EMPLOYEEID=ORDERS.EMPLOYEEID
GROUP BY EMPLOYEES.EMPLOYEEID, LASTNAME
)
SELECT ALL_ORDERS.EMPLOYEEID AS EMPLOYEE_ID,
ALL_ORDERS.LASTNAME AS LAST_NAME,
ALLORDERS AS ALL_ORDERS,
ISNULL(LATEORDERS,0) AS LATE_ORDERS
FROM ALL_ORDERS
LEFT JOIN LATE_ORDERS
ON ALL_ORDERS.EMPLOYEEID=LATE_ORDERS.EMPLOYEEID;

--Q46: LATE ORDERS VS. TOTAL ORDERS - PERCENTAGE?
--Q46_SOLUTION:
--(SOLVED WITH SUBQUERIES)
SELECT ALL_ORDERS.EMPLOYEEID AS EMPLOYEE_ID,
ALL_ORDERS.LASTNAME AS LAST_NAME,
ALLORDERS AS ALL_ORDERS,
ISNULL(LATEORDERS,0) AS LATE_ORDERS,
CAST(ISNULL(LATEORDERS,0) AS DECIMAL(11,1)) / 
	CAST(ISNULL(ALLORDERS,0) AS DECIMAL (11,1)) AS PERCENT_LATE
FROM
(SELECT EMPLOYEES.EMPLOYEEID,
EMPLOYEES.LASTNAME,
COUNT(*) AS ALLORDERS
FROM EMPLOYEES
LEFT JOIN ORDERS ON EMPLOYEES.EMPLOYEEID=ORDERS.EMPLOYEEID
GROUP BY EMPLOYEES.EMPLOYEEID, LASTNAME) AS ALL_ORDERS
LEFT JOIN
(SELECT EMPLOYEES.EMPLOYEEID,
LASTNAME,
COUNT(*) AS LATEORDERS
FROM EMPLOYEES
JOIN ORDERS ON EMPLOYEES.EMPLOYEEID=ORDERS.EMPLOYEEID
WHERE SHIPPEDDATE >= REQUIREDDATE
GROUP BY EMPLOYEES.EMPLOYEEID, LASTNAME) AS LATE_ORDERS
ON ALL_ORDERS.EMPLOYEEID=LATE_ORDERS.EMPLOYEEID;

--(SOLVED WITH CTEs)
WITH LATE_ORDERS AS
(
SELECT EMPLOYEES.EMPLOYEEID,
LASTNAME,
COUNT(*) AS LATEORDERS
FROM EMPLOYEES
JOIN ORDERS ON EMPLOYEES.EMPLOYEEID=ORDERS.EMPLOYEEID
WHERE SHIPPEDDATE >= REQUIREDDATE
GROUP BY EMPLOYEES.EMPLOYEEID, LASTNAME
)
,
ALL_ORDERS AS
(
SELECT EMPLOYEES.EMPLOYEEID,
EMPLOYEES.LASTNAME,
COUNT(*) AS ALLORDERS
FROM EMPLOYEES
LEFT JOIN ORDERS ON EMPLOYEES.EMPLOYEEID=ORDERS.EMPLOYEEID
GROUP BY EMPLOYEES.EMPLOYEEID, LASTNAME
)
SELECT ALL_ORDERS.EMPLOYEEID AS EMPLOYEE_ID,
ALL_ORDERS.LASTNAME AS LAST_NAME,
ALLORDERS AS ALL_ORDERS,
ISNULL(LATEORDERS,0) AS LATE_ORDERS,
CAST(ISNULL(LATEORDERS,0) AS DECIMAL(11,1)) / 
	CAST(ISNULL(ALLORDERS,0) AS DECIMAL (11,1)) AS PERCENT_LATE
FROM ALL_ORDERS
LEFT JOIN LATE_ORDERS
ON ALL_ORDERS.EMPLOYEEID=LATE_ORDERS.EMPLOYEEID;

--Q47: LATE ORDERS VS. TOTAL ORDERS - FIX DECIMAL?
--Q47_SOLUTION:
--(SOLVED WITH SUBQUERIES)
SELECT ALL_ORDERS.EMPLOYEEID AS EMPLOYEE_ID,
ALL_ORDERS.LASTNAME AS LAST_NAME,
ALLORDERS AS ALL_ORDERS,
ISNULL(LATEORDERS,0) AS LATE_ORDERS,
CONVERT(DECIMAL(10,2), ((ISNULL(LATEORDERS,0) * 1.00) /
	ISNULL(ALLORDERS,0) * 1.00)) AS PERCENT_LATE
FROM
(SELECT EMPLOYEES.EMPLOYEEID,
EMPLOYEES.LASTNAME,
COUNT(*) AS ALLORDERS
FROM EMPLOYEES
LEFT JOIN ORDERS ON EMPLOYEES.EMPLOYEEID=ORDERS.EMPLOYEEID
GROUP BY EMPLOYEES.EMPLOYEEID, LASTNAME) AS ALL_ORDERS
LEFT JOIN
(SELECT EMPLOYEES.EMPLOYEEID,
LASTNAME,
COUNT(*) AS LATEORDERS
FROM EMPLOYEES
JOIN ORDERS ON EMPLOYEES.EMPLOYEEID=ORDERS.EMPLOYEEID
WHERE SHIPPEDDATE >= REQUIREDDATE
GROUP BY EMPLOYEES.EMPLOYEEID, LASTNAME) AS LATE_ORDERS
ON ALL_ORDERS.EMPLOYEEID=LATE_ORDERS.EMPLOYEEID;

--(SOLVED AS CTEs)
WITH LATE_ORDERS AS
(
SELECT EMPLOYEES.EMPLOYEEID,
LASTNAME,
COUNT(*) AS LATEORDERS
FROM EMPLOYEES
JOIN ORDERS ON EMPLOYEES.EMPLOYEEID=ORDERS.EMPLOYEEID
WHERE SHIPPEDDATE >= REQUIREDDATE
GROUP BY EMPLOYEES.EMPLOYEEID, LASTNAME
)
,
ALL_ORDERS AS
(
SELECT EMPLOYEES.EMPLOYEEID,
EMPLOYEES.LASTNAME,
COUNT(*) AS ALLORDERS
FROM EMPLOYEES
LEFT JOIN ORDERS ON EMPLOYEES.EMPLOYEEID=ORDERS.EMPLOYEEID
GROUP BY EMPLOYEES.EMPLOYEEID, LASTNAME
)
SELECT ALL_ORDERS.EMPLOYEEID AS EMPLOYEE_ID,
ALL_ORDERS.LASTNAME AS LAST_NAME,
ALLORDERS AS ALL_ORDERS,
ISNULL(LATEORDERS,0) AS LATE_ORDERS,
CONVERT(DECIMAL(10,2), ((ISNULL(LATEORDERS,0) * 1.00) /
	ISNULL(ALLORDERS,0) * 1.00)) AS PERCENT_LATE
FROM ALL_ORDERS
JOIN LATE_ORDERS
ON ALL_ORDERS.EMPLOYEEID=LATE_ORDERS.EMPLOYEEID;

--Q48: CUSTOMER GROUPING ('LOW' <= 1000, 'MEDIUM' <= 5000, 'HIGH' <= 10000, 'VERY HIGH' >= 10000) 
-- FOR 2016 SALES?
--Q48_SOLUTION:
SELECT CUSTOMERS.CUSTOMERID AS CUSTOMER_ID,
CUSTOMERS.COMPANYNAME AS COMPANY_NAME,
SUM(UNITPRICE * QUANTITY) AS TOTAL_ORDER_AMOUNT,
CASE 
	WHEN SUM(UNITPRICE * QUANTITY) <= 1000 THEN 'LOW'
	WHEN SUM(UNITPRICE * QUANTITY) <= 5000 THEN 'MEDIUM'
	WHEN SUM(UNITPRICE * QUANTITY) <= 10000 THEN 'HIGH'
	WHEN SUM(UNITPRICE * QUANTITY) >= 10000 THEN 'VERY HIGH'
END AS CUSTOMER_GROUP
FROM CUSTOMERS
JOIN ORDERS ON CUSTOMERS.CUSTOMERID=ORDERS.CUSTOMERID
JOIN ORDERDETAILS ON ORDERS.ORDERID=ORDERDETAILS.ORDERID
WHERE YEAR(ORDERDATE) = 2016
GROUP BY CUSTOMERS.CUSTOMERID, CUSTOMERS.COMPANYNAME
ORDER BY CUSTOMERS.CUSTOMERID;

--Q49: SKIPPED. (I DID NOT HAVE ANY NULLS IN MY Q48 RESULT SET.)

--Q50: CUSTOMER GROUPING WITH PERCENTAGE?
--Q50_SOLUTION:
--(SOLVED WITH SUBQUERIES)
SELECT CUSTOMERGROUP AS CUSTOMER_GROUP, 
TOTALINGROUP AS TOTAL_IN_GROUP,
CONVERT(DECIMAL(10,2), ((ISNULL(TOTALINGROUP,0) * 1.00) /
	ISNULL(GRAND_TOTAL,0) * 1.00)) AS PERCENTAGE_IN_GROUP
FROM
(SELECT GROUP_CUSTOMERS.CUSTOMERGROUP, GROUP_CUSTOMERS.TOTALINGROUP,
SUM(TOTALINGROUP) OVER (PARTITION BY GROUP_CUSTOMERS.GROUP_CODE) AS GRAND_TOTAL
FROM
(SELECT GET_GROUPTOTALS.CUSTOMERGROUP, GROUPTOTALS AS TOTALINGROUP,
'01' AS GROUP_CODE --> FOR USE WITH AN OVER CLAUSE TO GET A GRAND TOTAL BY GROUP CODE.
FROM
(SELECT ASSIGN_GROUPS.CUSTOMERGROUP,
COUNT(*) AS GROUPTOTALS
FROM
(SELECT CUSTOMERS.CUSTOMERID, CUSTOMERS.COMPANYNAME,
SUM(UNITPRICE * QUANTITY) AS TOTALORDERAMOUNT,
CASE 
	WHEN SUM(UNITPRICE * QUANTITY) <= 1000 THEN 'LOW'
	WHEN SUM(UNITPRICE * QUANTITY) <= 5000 THEN 'MEDIUM'
	WHEN SUM(UNITPRICE * QUANTITY) <= 10000 THEN 'HIGH'
	WHEN SUM(UNITPRICE * QUANTITY) >= 10000 THEN 'VERY HIGH'
END AS CUSTOMERGROUP
FROM CUSTOMERS
JOIN ORDERS ON CUSTOMERS.CUSTOMERID=ORDERS.CUSTOMERID
JOIN ORDERDETAILS ON ORDERS.ORDERID=ORDERDETAILS.ORDERID
WHERE YEAR(ORDERDATE) = 2016
GROUP BY CUSTOMERS.CUSTOMERID, CUSTOMERS.COMPANYNAME) AS ASSIGN_GROUPS
GROUP BY CUSTOMERGROUP) AS GET_GROUPTOTALS
GROUP BY GET_GROUPTOTALS.CUSTOMERGROUP,GET_GROUPTOTALS.GROUPTOTALS) AS GROUP_CUSTOMERS
GROUP BY GROUP_CUSTOMERS.CUSTOMERGROUP, GROUP_CUSTOMERS.TOTALINGROUP, 
	GROUP_CUSTOMERS.GROUP_CODE) AS GET_GRANDTOTAL
GROUP BY CUSTOMERGROUP, TOTALINGROUP, GRAND_TOTAL
ORDER BY TOTALINGROUP DESC;

--(SOLVED WITH CTEs)
WITH GROUPS AS
(
SELECT CUSTOMERS.CUSTOMERID, CUSTOMERS.COMPANYNAME,
SUM(UNITPRICE * QUANTITY) AS TOTALORDERAMOUNT,
CASE 
	WHEN SUM(UNITPRICE * QUANTITY) <= 1000 THEN 'LOW'
	WHEN SUM(UNITPRICE * QUANTITY) <= 5000 THEN 'MEDIUM'
	WHEN SUM(UNITPRICE * QUANTITY) <= 10000 THEN 'HIGH'
	WHEN SUM(UNITPRICE * QUANTITY) >= 10000 THEN 'VERY HIGH'
END AS CUSTOMERGROUP
FROM CUSTOMERS
JOIN ORDERS ON CUSTOMERS.CUSTOMERID=ORDERS.CUSTOMERID
JOIN ORDERDETAILS ON ORDERS.ORDERID=ORDERDETAILS.ORDERID
WHERE YEAR(ORDERDATE) = 2016
GROUP BY CUSTOMERS.CUSTOMERID, CUSTOMERS.COMPANYNAME
),
GROUPTOTALS AS 
(
SELECT GROUPS.CUSTOMERGROUP,
COUNT(*) AS GROUPTOTALS
FROM GROUPS
GROUP BY GROUPS.CUSTOMERGROUP
),
GROUPED_CUSTOMERS AS
(
SELECT GROUPTOTALS.CUSTOMERGROUP, GROUPTOTALS AS TOTALINGROUP,
'01' AS GROUP_CODE --> FOR USE WITH AN OVER CLAUSE TO GET A GRAND TOTAL BY GROUP CODE.
FROM
GROUPTOTALS
GROUP BY GROUPTOTALS.CUSTOMERGROUP,GROUPTOTALS.GROUPTOTALS
),
GRANDTOTAL AS 
(
SELECT GROUPED_CUSTOMERS.CUSTOMERGROUP, GROUPED_CUSTOMERS.TOTALINGROUP,
SUM(TOTALINGROUP) OVER (PARTITION BY GROUPED_CUSTOMERS.GROUP_CODE) AS GRAND_TOTAL
FROM GROUPED_CUSTOMERS
GROUP BY GROUPED_CUSTOMERS.CUSTOMERGROUP, GROUPED_CUSTOMERS.TOTALINGROUP, 
	GROUPED_CUSTOMERS.GROUP_CODE
)
SELECT CUSTOMERGROUP AS CUSTOMER_GROUP, 
TOTALINGROUP AS TOTAL_IN_GROUP,
CONVERT(DECIMAL(10,2), ((ISNULL(TOTALINGROUP,0) * 1.00) /
	ISNULL(GRAND_TOTAL,0) * 1.00)) AS PERCENTAGE_IN_GROUP
FROM GRANDTOTAL
GROUP BY CUSTOMERGROUP, TOTALINGROUP, GRAND_TOTAL
ORDER BY TOTALINGROUP DESC;

--(SOLVED WITH SUBQUERY/CTE HYBRID)
WITH GET_FINALTOTALS AS
(
SELECT GROUP_CUSTOMERS.CUSTOMERGROUP, GROUP_CUSTOMERS.TOTALINGROUP,
SUM(TOTALINGROUP) OVER (PARTITION BY GROUP_CUSTOMERS.GROUP_CODE) AS GRAND_TOTAL
FROM
(SELECT GET_GROUPTOTALS.CUSTOMERGROUP, GROUPTOTALS AS TOTALINGROUP,
'01' AS GROUP_CODE --> FOR USE WITH AN OVER CLAUSE TO GET A GRAND TOTAL BY GROUP CODE.
FROM
(SELECT ASSIGN_GROUPS.CUSTOMERGROUP,
COUNT(*) AS GROUPTOTALS
FROM
(SELECT CUSTOMERS.CUSTOMERID, CUSTOMERS.COMPANYNAME,
SUM(UNITPRICE * QUANTITY) AS TOTALORDERAMOUNT,
CASE 
	WHEN SUM(UNITPRICE * QUANTITY) <= 1000 THEN 'LOW'
	WHEN SUM(UNITPRICE * QUANTITY) <= 5000 THEN 'MEDIUM'
	WHEN SUM(UNITPRICE * QUANTITY) <= 10000 THEN 'HIGH'
	WHEN SUM(UNITPRICE * QUANTITY) >= 10000 THEN 'VERY HIGH'
END AS CUSTOMERGROUP
FROM CUSTOMERS
JOIN ORDERS ON CUSTOMERS.CUSTOMERID=ORDERS.CUSTOMERID
JOIN ORDERDETAILS ON ORDERS.ORDERID=ORDERDETAILS.ORDERID
WHERE YEAR(ORDERDATE) = 2016
GROUP BY CUSTOMERS.CUSTOMERID, CUSTOMERS.COMPANYNAME) AS ASSIGN_GROUPS
GROUP BY CUSTOMERGROUP) AS GET_GROUPTOTALS
GROUP BY GET_GROUPTOTALS.CUSTOMERGROUP,GET_GROUPTOTALS.GROUPTOTALS) AS GROUP_CUSTOMERS
GROUP BY GROUP_CUSTOMERS.CUSTOMERGROUP, GROUP_CUSTOMERS.TOTALINGROUP, 
	GROUP_CUSTOMERS.GROUP_CODE
)
SELECT CUSTOMERGROUP AS CUSTOMER_GROUP, 
TOTALINGROUP AS TOTAL_IN_GROUP,
CONVERT(DECIMAL(10,2), ((ISNULL(TOTALINGROUP,0) * 1.00) /
	ISNULL(GRAND_TOTAL,0) * 1.00)) AS PERCENTAGE_IN_GROUP
FROM GET_FINALTOTALS
GROUP BY CUSTOMERGROUP, TOTALINGROUP, GRAND_TOTAL
ORDER BY TOTALINGROUP DESC;

--Q51: CUSTOMER GROUPING - FLEXIBLE?
--Q51_SOLUTION:
--(SOLVED WITH A SUBQUERY)
SELECT GET_CUSTOMERDATA.CUSTOMER_ID,
GET_CUSTOMERDATA.COMPANY_NAME,
GET_CUSTOMERDATA.TOTAL_ORDER_AMOUNT,
UPPER(CUSTOMERGROUPTHRESHOLDS.CUSTOMERGROUPNAME) AS CUSTOMER_GROUP
FROM
(SELECT CUSTOMERS.CUSTOMERID AS CUSTOMER_ID, 
CUSTOMERS.COMPANYNAME AS COMPANY_NAME,
SUM(UNITPRICE * QUANTITY) AS TOTAL_ORDER_AMOUNT
FROM CUSTOMERS
JOIN ORDERS ON CUSTOMERS.CUSTOMERID=ORDERS.CUSTOMERID
JOIN ORDERDETAILS ON ORDERS.ORDERID=ORDERDETAILS.ORDERID
WHERE YEAR(ORDERDATE) = 2016
GROUP BY CUSTOMERS.CUSTOMERID, CUSTOMERS.COMPANYNAME) AS GET_CUSTOMERDATA
JOIN CUSTOMERGROUPTHRESHOLDS ON
TOTAL_ORDER_AMOUNT BETWEEN RANGEBOTTOM AND RANGETOP;

--(SOLVED WITH A CTE)
WITH GET_CUSTOMERDATA AS
(
SELECT CUSTOMERS.CUSTOMERID AS CUSTOMER_ID, 
CUSTOMERS.COMPANYNAME AS COMPANY_NAME,
SUM(UNITPRICE * QUANTITY) AS TOTAL_ORDER_AMOUNT
FROM CUSTOMERS
JOIN ORDERS ON CUSTOMERS.CUSTOMERID=ORDERS.CUSTOMERID
JOIN ORDERDETAILS ON ORDERS.ORDERID=ORDERDETAILS.ORDERID
WHERE YEAR(ORDERDATE) = 2016
GROUP BY CUSTOMERS.CUSTOMERID, CUSTOMERS.COMPANYNAME
)
SELECT GET_CUSTOMERDATA.CUSTOMER_ID,
GET_CUSTOMERDATA.COMPANY_NAME,
GET_CUSTOMERDATA.TOTAL_ORDER_AMOUNT,
UPPER(CUSTOMERGROUPTHRESHOLDS.CUSTOMERGROUPNAME) AS CUSTOMER_GROUP
FROM GET_CUSTOMERDATA
JOIN CUSTOMERGROUPTHRESHOLDS ON
TOTAL_ORDER_AMOUNT BETWEEN RANGEBOTTOM AND RANGETOP;

--Q52: COUNTRIES WITH SUPPLIERS OR CUSTOMERS?
--Q52_SOLUTION:
SELECT DISTINCT COUNTRY
FROM SUPPLIERS
WHERE COUNTRY IS NOT NULL
UNION
SELECT DISTINCT COUNTRY
FROM CUSTOMERS
WHERE COUNTRY IS NOT NULL

--Q53 COUNTRIES WITH SUPPLIERS OR CUSTOMERS, VER. 2?
--Q53_SOLUTION:
--(SOLVED WITH A SUBQUERY)
SELECT SUPPLIER_COUNTRIES.SUPPLIER_COUNTRIES,
CUSTOMER_COUNTRIES.CUSTOMER_COUNTRIES
FROM
(SELECT DISTINCT SUPPLIERS.COUNTRY AS SUPPLIER_COUNTRIES
FROM SUPPLIERS
GROUP BY COUNTRY) AS SUPPLIER_COUNTRIES
FULL OUTER JOIN 
(SELECT DISTINCT CUSTOMERS.COUNTRY AS CUSTOMER_COUNTRIES
FROM CUSTOMERS
GROUP BY COUNTRY) AS CUSTOMER_COUNTRIES
ON SUPPLIER_COUNTRIES.SUPPLIER_COUNTRIES=CUSTOMER_COUNTRIES.CUSTOMER_COUNTRIES

--(SOLVED WITH A CTE)
WITH SUPPLIERS_COUNTRIES AS
(
SELECT DISTINCT COUNTRY
FROM SUPPLIERS
),
CUSTOMER_COUNTRIES AS
(
SELECT DISTINCT COUNTRY
FROM CUSTOMERS
)
SELECT SUPPLIERS_COUNTRIES.COUNTRY AS SUPPLIER_COUNTRY,
CUSTOMER_COUNTRIES.COUNTRY AS CUSTOMER_COUNTRY
FROM
SUPPLIERS_COUNTRIES
FULL OUTER JOIN CUSTOMER_COUNTRIES
ON SUPPLIERS_COUNTRIES.COUNTRY=CUSTOMER_COUNTRIES.COUNTRY

--Q54: COUNTRIES WITH SUPPLIERS OR CUSTOMERS VER. 3?
--Q54_SOLUTION:
--(SOLVED WITH SUBQUERIES)
SELECT 
	ISNULL(SUPPLIER_COUNTRY,CUSTOMER_COUNTRY) AS COUNTRY,
	ISNULL(TOTALSUPPLIERS,0) AS TOTAL_SUPPLIERS,
	ISNULL(TOTALCUSTOMERS,0) AS TOTAL_CUSTOMERS
FROM
(SELECT COUNTRY AS SUPPLIER_COUNTRY,
COUNT(*) AS TOTALSUPPLIERS
FROM SUPPLIERS
GROUP BY COUNTRY) AS SUPPLIER_COUNTRIES
FULL OUTER JOIN
(SELECT COUNTRY AS CUSTOMER_COUNTRY,
COUNT(*) AS TOTALCUSTOMERS
FROM CUSTOMERS
GROUP BY COUNTRY) AS CUSTOMER_COUNTRIES
ON SUPPLIER_COUNTRIES.SUPPLIER_COUNTRY=CUSTOMER_COUNTRIES.CUSTOMER_COUNTRY;

--(SOLVED WITH CTEs)
WITH CUSTOMER_COUNTRIES AS
(
SELECT COUNTRY AS CUSTOMER_COUNTRY,
COUNT(*) AS TOTALCUSTOMERS
FROM CUSTOMERS
GROUP BY COUNTRY
),
SUPPLIER_COUNTRIES AS
(
SELECT COUNTRY AS SUPPLIER_COUNTRY,
COUNT(*) AS TOTALSUPPLIERS
FROM SUPPLIERS
GROUP BY COUNTRY
)
SELECT 
	ISNULL(SUPPLIER_COUNTRY,CUSTOMER_COUNTRY) AS COUNTRY,
	ISNULL(TOTALSUPPLIERS,0) AS TOTAL_SUPPLIERS,
	ISNULL(TOTALCUSTOMERS,0) AS TOTAL_CUSTOMERS
FROM CUSTOMER_COUNTRIES
FULL OUTER JOIN SUPPLIER_COUNTRIES
ON SUPPLIER_COUNTRIES.SUPPLIER_COUNTRY=CUSTOMER_COUNTRIES.CUSTOMER_COUNTRY;

--Q55: FIRST ORDER IN EACH COUNTRY?
--Q55_SOLUTION:
-- (SOLVED WITH SUBQUERY)
SELECT 
SHIPCOUNTRY,
CUSTOMERID,
ORDERID,
ORDER_DATE
FROM 
(SELECT 
ROW_NUMBER() OVER (PARTITION BY SHIPCOUNTRY ORDER BY ORDERDATE) AS ROW_NO,
SHIPCOUNTRY,
CUSTOMERID,
ORDERID,
CONVERT(DATE,ORDERDATE) AS ORDER_DATE
FROM ORDERS
GROUP BY SHIPCOUNTRY, CUSTOMERID, ORDERID, ORDERDATE) AS NUMBERED_ROWS
WHERE ROW_NO = 1
GROUP BY SHIPCOUNTRY, CUSTOMERID, ORDERID, ORDER_DATE;

--Q56: CUSTOMERS WITH MULTIPLE ORDERS IN 5-DAY PERIOD?
--Q56_SOLUTION:
--(SOLVED WITH SUBQUERIES)
SELECT CUSTOMERID,
INITIAL_ORDER_ID,
INITIAL_ORDER_DATE,
NEXT_ORDER_ID,
NEXT_ORDER_DATE,
DAYS_DIFFERENCE
FROM
(SELECT GROUP1.CUSTOMERID,
GROUP1.ORDERID AS INITIAL_ORDER_ID,
CONVERT(DATE, GROUP1.ORDERDATE) AS INITIAL_ORDER_DATE,
CASE WHEN DATEDIFF(DD,GROUP1.OrderDate,GROUP2.ORDERDATE) <=5 THEN 
		GROUP2.ORDERID END AS NEXT_ORDER_ID,
CASE WHEN DATEDIFF(DD,GROUP1.OrderDate,GROUP2.ORDERDATE) <=5 THEN 
		CONVERT(DATE,GROUP2.ORDERDATE) END AS NEXT_ORDER_DATE,
CASE WHEN DATEDIFF(DD,GROUP1.OrderDate,GROUP2.ORDERDATE) <=5 THEN 
		DATEDIFF(DD,GROUP1.OrderDate,GROUP2.ORDERDATE) END AS DAYS_DIFFERENCE
FROM
(SELECT CUSTOMERID,
ORDERID,
ORDERDATE
FROM ORDERS) AS GROUP1
JOIN
(SELECT CUSTOMERID,
ORDERID,
ORDERDATE
FROM ORDERS) AS GROUP2
ON GROUP1.CUSTOMERID=GROUP2.CUSTOMERID 
WHERE GROUP1.ORDERID < GROUP2.ORDERID) AS MULTIPLE_ORDERS_PER_WEEK
WHERE NEXT_ORDER_ID IS NOT NULL AND NEXT_ORDER_DATE IS NOT NULL
ORDER BY CUSTOMERID;

--(SOLVED WITH CTEs)
WITH GROUP1 AS
(
SELECT CUSTOMERID,
ORDERID,
ORDERDATE
FROM ORDERS
),
GROUP2 AS 
(
SELECT CUSTOMERID,
ORDERID,
ORDERDATE
FROM ORDERS
),
JOINED_GROUPS AS
(
SELECT GROUP1.CUSTOMERID,
GROUP1.ORDERID,
GROUP1.ORDERDATE AS GROUP1_ORDERDATE,
GROUP2.ORDERDATE AS GROUP2_ORDERDATE,
GROUP2.OrderID AS NEXT_ORDER_ID
FROM GROUP1 
JOIN GROUP2
ON GROUP1.CUSTOMERID=GROUP2.CUSTOMERID 
WHERE GROUP1.ORDERID < GROUP2.ORDERID
),
DAYS_BETWEEN AS 
(
SELECT JOINED_GROUPS.CUSTOMERID,
JOINED_GROUPS.ORDERID AS INITIAL_ORDER_ID,
CONVERT(DATE, JOINED_GROUPS.GROUP1_ORDERDATE) AS INITIAL_ORDER_DATE,
CASE WHEN DATEDIFF(DD,GROUP1_ORDERDATE,GROUP2_ORDERDATE) <=5 THEN 
	JOINED_GROUPS.NEXT_ORDER_ID END AS NEXT_ORDER_ID,
CASE WHEN DATEDIFF(DD,GROUP1_ORDERDATE,GROUP2_ORDERDATE) <=5 THEN 
	CONVERT(DATE,GROUP2_ORDERDATE) END AS NEXT_ORDER_DATE,
CASE WHEN DATEDIFF(DD,GROUP1_ORDERDATE,GROUP2_ORDERDATE) <=5 THEN 
	DATEDIFF(DD,GROUP1_ORDERDATE,GROUP2_ORDERDATE) END AS DAYS_DIFFERENCE
FROM JOINED_GROUPS
)
SELECT CUSTOMERID,
INITIAL_ORDER_ID,
INITIAL_ORDER_DATE,
NEXT_ORDER_ID,
NEXT_ORDER_DATE,
DAYS_DIFFERENCE
FROM DAYS_BETWEEN
WHERE NEXT_ORDER_ID IS NOT NULL AND NEXT_ORDER_DATE IS NOT NULL
ORDER BY CUSTOMERID;
GO

--Q57: CUSTOMERS WITH MULTIPLE ORDERS IN 5-DAY PERIOD, VER. 2?
--Q57_SOLUTION:
--(SOLVED WITH SUBQUERIES)
SELECT CUSTOMER_ID,
INITIAL_ORDER_ID,
INITIAL_ORDER_DATE,
NEXT_ORDER_ID,
NEXT_ORDER_DATE,
DAYS_DIFFERENCE
FROM
(SELECT CUSTOMER_ID,
INITIAL_ORDER_ID,
INITIAL_ORDER_DATE,
NEXT_ORDER_ID,
NEXT_ORDER_DATE,
DATEDIFF(DAY,INITIAL_ORDER_DATE, NEXT_ORDER_DATE) AS DAYS_DIFFERENCE
FROM
(SELECT
CUSTOMERID AS CUSTOMER_ID,
INITIAL_ORDER_ID,
INITIAL_ORDER_DATE,
LEAD(INITIAL_ORDER_ID, 1) OVER (ORDER BY CUSTOMERID, INITIAL_ORDER_ID) AS NEXT_ORDER_ID,
LEAD(INITIAL_ORDER_DATE, 1) OVER (ORDER BY CUSTOMERID,INITIAL_ORDER_ID) AS NEXT_ORDER_DATE
FROM
(SELECT DISTINCT CUSTOMERID,
ORDERS.ORDERID AS INITIAL_ORDER_ID,
CONVERT(DATE, ORDERS.ORDERDATE) AS INITIAL_ORDER_DATE
FROM ORDERS
JOIN ORDERDETAILS
ON ORDERS.ORDERID=ORDERDETAILS.ORDERID) AS CUSTOMER_ORDERS) AS INITIAL_ORDER_VS_NEXT_ORDER) AS MULTIPLE_ORDERS_PER_WEEK
WHERE DAYS_DIFFERENCE BETWEEN 0 AND 5

--(SOLVED WITH CTEs)
WITH CUSTOMER_ORDERS AS
(
SELECT DISTINCT CUSTOMERID,
ORDERS.ORDERID AS INITIAL_ORDER_ID,
CONVERT(DATE, ORDERS.ORDERDATE) AS INITIAL_ORDER_DATE
FROM ORDERS
JOIN ORDERDETAILS
ON ORDERS.ORDERID=ORDERDETAILS.ORDERID
ORDER BY CUSTOMERID, ORDERS.ORDERID, INITIAL_ORDER_DATE
OFFSET 0 ROWS
),
INITIAL_ORDER_VS_NEXT_ORDER AS
(
SELECT
CUSTOMERID AS CUSTOMER_ID,
INITIAL_ORDER_ID,
INITIAL_ORDER_DATE,
LEAD(INITIAL_ORDER_ID, 1) 
	OVER (ORDER BY CUSTOMERID, INITIAL_ORDER_ID) AS NEXT_ORDER_ID,
LEAD(INITIAL_ORDER_DATE, 1) 
	OVER (ORDER BY CUSTOMERID,INITIAL_ORDER_ID) AS NEXT_ORDER_DATE
FROM CUSTOMER_ORDERS
),
DAYS_COMPARISON AS
(
SELECT CUSTOMER_ID,
INITIAL_ORDER_ID,
INITIAL_ORDER_DATE,
NEXT_ORDER_ID,
NEXT_ORDER_DATE,
DATEDIFF(DAY,INITIAL_ORDER_DATE, NEXT_ORDER_DATE) AS DAYS_DIFFERENCE
FROM INITIAL_ORDER_VS_NEXT_ORDER
)
SELECT CUSTOMER_ID,
INITIAL_ORDER_ID,
INITIAL_ORDER_DATE,
NEXT_ORDER_ID,
NEXT_ORDER_DATE,
DAYS_DIFFERENCE
FROM DAYS_COMPARISON
WHERE DAYS_DIFFERENCE BETWEEN 0 AND 5;
