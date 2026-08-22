-- emp_id,emp_name,dept,sal,manager_id

-- sort based on sal (heightst -> lowest) order for all engineering employee
SELECT *
FROM Employee
WHERE LOWER(dept) = 'Engineering'
ORDER BY sal DEC;


-- no of employees in each department
SELECT COUNT(*) as no_of_employee, dept
FROM Employee
GROUP BY dept;


-- second heighest salary
SELECT MAX(sal)
FROM Employee
WHERE sal < (SELECT MAX(sal) FROM Employee); 

SELECT MAX(sal)
FROM Employee
WHERE sal NOT IN (SELECT MAX(sal) FROM Employee);

SELECT MAX(sal)
FROM Employee
WHERE sal <> (SELECT MAX(sal) FROM Employee);


-- third heighest salary
SELECT MAX(sal)
FROM Employee
WHERE sal < (   SELECT MAX(sal) 
                FROM Employee 
                WHERE sal < ( 
                                SELECT MAX(sal) 
                                FROM Employee ));

SELECT emp_id,sal
FROM Employee e1
WHERE 3 = (
            SELECT COUNT(DISTINCT(sal))
            FROM Employee e2
            WHERE e2.sal > e1.sal
            )


-- earning more than companys avg salary
SELECT emp_name,sal
FROM Employee
WHERE  sal > (SELECT AVG(sal) FROM Employee);


-- heighest salary in each department
SELECT MAX(sal), dept
FROM Employee
GROUP BY dept;


-- employees whose salary is heigher than their managers salary
SELECT e.emp_name, e.sal
FROM Employee e
WHERE sal > (SELECT m.sal FROM Employee m WHERE m.emp_id = e.manager_id);

SELECT e.emp_name,e.sal,f.emp_name,f.sal
FROM Employee e
JOIN Employee f
ON e.manager_id = f.emp_id
WHERE e.sal > f.sal;

-------------------------------------------------------------------------------- 
-- simple join is called as inner join

-- Customer(cust_id,cust_name,city)
-- Order(order_id,cust_id,amount,status)

-- display each order with the customer name
SELECT O.order_id, o.cust_id, c.cust_name, o.amount, o.status
FROM Custmer c JOIN Order o
ON c.cust_id = o.cust_id;


-- customer who have never placed an order
FROM Customer c LEFT JOIN Order o
ON c.cust_id = o.cust_id
WHERE o.cust_id is NULL;


-- customer who placed more than one order
SELECT c.cust_id
FROM Customer c JOIN Order o
ON c.cust_id = o.cust_id
GROUP BY c.cust_id
HAVING COUNT(*) > 1


-- heighest spending customer based on delivered order

SELECT c.cust_id, c.cust_name, SUM(o.amount) AS total_spend
FROM Customer c JOIN Order o
ON c.cust_id = o.cust_id
WHERE LOWER(o.status) = 'delivered'
GROUP BY c.cust_id, c.cust_name
ORDER BY total_spend DESC
LIMIT 1;


/*
a table has 100M records we want to remove all rows as quickly as possible while keeping the table
which command to use ?

can use TRUNCATE instead of DELETE FROM, as it is faster and also structured is kept intack

as DELETE is a DML statement so we can rollback to get the original database after delete
but TRUNCATE is a DDL statement so we wount be able to rollback as DDL statement are allways auto-commited

--------------------------------------------------------------------------------------------------

a new intern shuld only be able to view the Employee table but should not modify it. Which SQL command should he use

GRANT SELECT ON Employee
TO Intern_user;

REVOKE FROM Intern_user;

- we can use grant to give just specific access and block INSERT,UPDATE,DELETE permissions
DCL(Data Control Language) 1. Grant 2. Revoke

A view becomes particularly useful when you want to restrict which columns or rows the intern can see.
CREATE VIEW view1 as
SELECT *
FROM Employee;

this is like a dummy database access no matter how many queries we perform here the real database is not
affacted

later we can do 
DROP VIEW view1;

------------------------------------------------------------------------------------------------------

SELECT salary*12 as Annual_Sal
FROM Employee
WHERE Annual_Sal > 600000;

an alias created on this SELECT list can not be referenced in the WHERE clause of the same query. How does SQL 
logical execution order explain this.

This will not execute because of the order of execution

FROM ---> WHERE ---> GROUP BY ---> HAVING ---> SELECT ---> ORDER BY ---> LIMIT
so our WHERE statement sees Annual_Sal before it is defined

------------------------------------------------------------------------------------------------------

a ranking query contains duplicate salaryies. How can ROW_NUMBER(), RANK(), DENSE_RANK() assign values differently



------------------------------------------------------------------------------------------------------

*/