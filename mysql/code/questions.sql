-- change column name to full_name
ALTER TABLE table_name
CHANGE name full_name VARCHAR(60) NOT NULL;

-- delete all students who scored < 80
UPDATE FROM table_name
WHERE marks < 80;

-- delete the column for grades
ALTER TABLE table_name
DROP COLUMN grade;

-- rollno, name, marks
-- find all the students who scored more than class average

SELECT name
FROM table_name
WHERE MARKS > ( SELECT AVG(marks)
                FROM table_name )

-- all names with even rollnos

SELECT name
FROM table_name
WHERE rollno/2 = 0;

-- another way WHERE MOD(rollno,2)=0;

SELECT name
FROM table_name
WHERE rollno IN (
    SELECT rollno FROM table_name WHERE MOD(rollno,2)=0
);

/*
subquery can be written in WHERE , FROM , SELECT but WHERE is the most common one
*/

-- rolln,name,marks,city
--find the maximum amrks from students of delhi

SELECT MAX(marks)
FROM table_name
GROUP BY city
HAVING LOWER(city) = 'delhi';   -- the opposite function is UPPER


SELECT MAX(marks)
FROM ( SELECT * FROM table_name WHERE LOWER(city) = 'delhi' ) as temp 
-- look at it like reduced search space





