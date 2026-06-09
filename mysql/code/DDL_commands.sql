CREATE TABLE employee 
( 
    employee_id char(2) PRIMARY KEY, 
    first_name varchar(30) NOT NULL, 
    mobile int
);


-- ALTER TABLE - ADD COLUMN
ALTER TABLE table_name 
ADD column_name_1 datatype....
ADD COLUMN column_name_n datatype; 

ALTER TABLE table_name 
ADD COLUMN column_name_1 datatype....
ADD COLUMN column_name_n datatype;


-- ALTER TABLE - ALTER COLUMN
ALTER TABLE table_name 
MODIFY column_name_1 new_data_type;


-- ALTER TABLE - DROP COLUMN
ALTER TABLE table_name 
DROP COLUMN column_name_1 ;


-- ALTER TABLE - RENAME COLUMN
ALTER TABLE table_name 
CHANGE COLUMN current_column_name new_column_name datatype [optional keywords];

ALTER TABLE employee 
CHANGE COLUMN first_name name VARCHAR(255);


-- TRUNCATE TABLE
TRUNCATE TABLE table_name;


-- DROP TABLE
DROP TABLE table_name ;


-- LIKE
SELECT column1, column2, ... 
FROM table_name 
WHERE columnN LIKE pattern; 

SELECT f_name , l_name 
FROM employees 
WHERE address LIKE '%Elgin,IL%';


-- BETWEEN
SELECT column_name(s) 
FROM table_name 
WHERE column_name BETWEEN value1 AND value2;


-- ORDER BY
SELECT column1, column2, ... 
FROM table_name 
ORDER BY column1, column2, ... ASC|DESC; 


-- GROUP BY
SELECT column_name(s) 
FROM table_name 
GROUP BY column_name(s) 


-- HAVING
SELECT column_name(s) 
FROM table_name 
GROUP BY column_name(s) 
HAVING condition 

SELECT DEP_ID, COUNT(*) AS "NUM_EMPLOYEES", AVG(SALARY) AS "AVG_SALARY" 
FROM EMPLOYEES 
GROUP BY DEP_ID 
HAVING count(*) < 4 
ORDER BY AVG_SALARY;

