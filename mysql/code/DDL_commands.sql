-- =====================================================
-- MySQL DDL & QUERY CLAUSES — REFERENCE & EXAMPLES
-- =====================================================
-- Sections (in logical order):
--   1. CREATE TABLE
--   2. ALTER TABLE
--      2a. ADD COLUMN
--      2b. MODIFY COLUMN (change datatype)
--      2c. DROP COLUMN
--      2d. RENAME COLUMN (CHANGE COLUMN)
--   3. TRUNCATE TABLE
--   4. DROP TABLE
--   5. LIKE
--   6. BETWEEN
--   7. ORDER BY
--   8. GROUP BY
--   9. HAVING
-- =====================================================


CREATE DATABASE campusx;
DROP DATABASE campusx;

CREATE DATABASE IF NOT EXISTS campusx;
DROP DATABASE IF EXISTS campusx;

-- =====================================================
-- 1. CREATE TABLE
-- Defines a new table with its columns and constraints.
-- Syntax: CREATE TABLE table_name ( col datatype [constraints], ... );
-- Common constraints: PRIMARY KEY, NOT NULL, UNIQUE, DEFAULT
-- =====================================================

CREATE TABLE employee
(
    employee_id CHAR(2)      PRIMARY KEY,
    first_name  VARCHAR(30)  NOT NULL,
    mobile      INT
);

-- Example: A more complete table with DEFAULT and UNIQUE
CREATE TABLE department
(
    dept_id     INT          PRIMARY KEY AUTO_INCREMENT,
    dept_name   VARCHAR(50)  NOT NULL UNIQUE,
    location    VARCHAR(100) DEFAULT 'HQ'
);


-- =====================================================
-- 2. ALTER TABLE
-- Modifies the structure of an existing table.
-- =====================================================


-- -----------------------------------------------------
-- 2a. ADD COLUMN
-- Adds one or more new columns to an existing table.
-- Syntax: ALTER TABLE table_name
--           ADD COLUMN col1 datatype,
--           ADD COLUMN col2 datatype;
-- -----------------------------------------------------

ALTER TABLE employee
ADD COLUMN email      VARCHAR(100),
ADD COLUMN hire_date  DATE;

-- Example: Add salary and department columns
ALTER TABLE employee
ADD COLUMN salary     DECIMAL(10, 2) DEFAULT 0.00,
ADD COLUMN dept_id    INT;


-- -----------------------------------------------------
-- 2b. MODIFY COLUMN  (change datatype / constraints)
-- Syntax: ALTER TABLE table_name
--           MODIFY column_name new_datatype [constraints];
-- Note: Data already stored must be compatible with the new type.
-- -----------------------------------------------------

ALTER TABLE employee
MODIFY mobile BIGINT;
-- Changed INT → BIGINT to support longer phone numbers

-- Example: Tighten a column to NOT NULL after backfilling data
ALTER TABLE employee
MODIFY email VARCHAR(100) NOT NULL;


-- -----------------------------------------------------
-- 2c. DROP COLUMN
-- Permanently removes a column and all its data.
-- Syntax: ALTER TABLE table_name DROP COLUMN column_name;
-- WARNING: This cannot be undone. Back up first.
-- -----------------------------------------------------

ALTER TABLE employee
DROP COLUMN mobile;

-- Example: Remove a deprecated notes column
ALTER TABLE employee
DROP COLUMN legacy_notes;


-- -----------------------------------------------------
-- 2d. RENAME COLUMN  (CHANGE COLUMN)
-- Renames a column; the datatype must be re-specified.
-- Syntax: ALTER TABLE table_name
--           CHANGE COLUMN old_name new_name datatype [keywords];
-- -----------------------------------------------------

ALTER TABLE employee
CHANGE COLUMN first_name name VARCHAR(255);
-- Renamed first_name → name, expanded width to 255

-- Example: Rename hire_date to joining_date, keeping the same type
ALTER TABLE employee
CHANGE COLUMN hire_date joining_date DATE NOT NULL;


-- =====================================================
-- 3. TRUNCATE TABLE
-- Deletes ALL rows from a table instantly but keeps
-- the table structure (columns, constraints) intact.
-- Faster than DELETE with no WHERE; resets AUTO_INCREMENT.
-- Syntax: TRUNCATE TABLE table_name;
-- WARNING: Cannot be rolled back in most MySQL configs.
-- =====================================================

TRUNCATE TABLE employee;

-- Example: Clear a staging/import table before a fresh data load
TRUNCATE TABLE staging_imports;


-- =====================================================
-- 4. DROP TABLE
-- Permanently deletes the table AND all its data.
-- Syntax: DROP TABLE table_name;
-- Use IF EXISTS to avoid an error when the table is absent.
-- =====================================================

DROP TABLE employee;

-- Example: Safely drop a temp table that may or may not exist
DROP TABLE IF EXISTS temp_salary_report;


-- =====================================================
-- DDL COMPARISON: TRUNCATE vs DROP vs DELETE
-- =====================================================
--
-- Command              | Removes rows | Removes structure | Rollback-safe
-- ---------------------+--------------+-------------------+--------------
-- DELETE (no WHERE)    | Yes          | No                | Yes
-- TRUNCATE             | Yes          | No                | No (usually)
-- DROP                 | Yes          | Yes               | No
--
-- =====================================================


-- =====================================================
-- 5. LIKE
-- Filters rows using pattern matching on strings.
-- Wildcards:
--   %  → zero or more characters
--   _  → exactly one character
-- Syntax: WHERE column LIKE 'pattern'
-- =====================================================

-- Example 1: Names starting with 'Al'
SELECT first_name, last_name
FROM employees
WHERE first_name LIKE 'Al%';
-- Matches: Alice, Albert, Alex, ...

-- Example 2: Addresses containing a specific city
SELECT f_name, l_name
FROM employees
WHERE address LIKE '%Elgin,IL%';
-- Matches any address that includes the substring "Elgin,IL"

-- Example 3: Exactly 4-letter first names
SELECT first_name
FROM employees
WHERE first_name LIKE '____';
-- _ _ _ _ = 4 wildcards → matches John, Sara, ...

-- Example 4: Email addresses from a specific domain
SELECT first_name, email
FROM employees
WHERE email LIKE '%@company.com';


-- =====================================================
-- 6. BETWEEN
-- Filters rows where a value falls within an inclusive range.
-- Works on numbers, dates, and strings.
-- Syntax: WHERE column BETWEEN value1 AND value2
-- Note: Both endpoints are included (>=, <=).
-- =====================================================

-- Example 1: Employees with salary in a range
SELECT first_name, salary
FROM employees
WHERE salary BETWEEN 50000 AND 80000;

-- Example 2: Rows within a date range
SELECT emp_id, joining_date
FROM employee
WHERE joining_date BETWEEN '2023-01-01' AND '2023-12-31';

-- Example 3: NOT BETWEEN — exclude a range
SELECT first_name, salary
FROM employees
WHERE salary NOT BETWEEN 50000 AND 80000;


-- =====================================================
-- 7. ORDER BY
-- Sorts the result set by one or more columns.
-- ASC (default) = smallest/earliest first.
-- DESC = largest/latest first.
-- Syntax: ORDER BY col1 [ASC|DESC], col2 [ASC|DESC];
-- =====================================================

-- Example 1: Sort employees by last name alphabetically
SELECT first_name, last_name
FROM employees
ORDER BY last_name ASC;

-- Example 2: Highest salary first
SELECT first_name, salary
FROM employees
ORDER BY salary DESC;

-- Example 3: Multi-column sort — department first, then salary descending
SELECT dept_id, first_name, salary
FROM employees
ORDER BY dept_id ASC, salary DESC;

-- Example 4: Sort by a computed/aliased column
SELECT first_name, salary * 12 AS annual_salary
FROM employees
ORDER BY annual_salary DESC;


-- =====================================================
-- 8. GROUP BY
-- Collapses rows that share the same value in the
-- specified column(s) into a single summary row.
-- Typically used with aggregate functions:
--   COUNT(), SUM(), AVG(), MIN(), MAX()
-- Syntax: GROUP BY column_name(s)
-- =====================================================

-- Example 1: Count employees per department
SELECT dept_id, COUNT(*) AS num_employees
FROM employees
GROUP BY dept_id;

-- Example 2: Total salary spend per department
SELECT dept_id, SUM(salary) AS total_salary
FROM employees
GROUP BY dept_id;

-- Example 3: Average salary per job role
SELECT job_role, AVG(salary) AS avg_salary
FROM employees
GROUP BY job_role;

-- Example 4: Group by multiple columns
SELECT dept_id, job_role, COUNT(*) AS headcount
FROM employees
GROUP BY dept_id, job_role;


-- =====================================================
-- 9. HAVING
-- Filters groups produced by GROUP BY.
-- Equivalent to WHERE, but WHERE cannot reference
-- aggregate functions — HAVING can.
-- Syntax: GROUP BY ... HAVING condition
-- Execution order: WHERE → GROUP BY → HAVING → ORDER BY
-- =====================================================

-- Example 1: Departments with fewer than 4 employees
SELECT DEP_ID,
       COUNT(*)      AS NUM_EMPLOYEES,
       AVG(SALARY)   AS AVG_SALARY
FROM EMPLOYEES
GROUP BY DEP_ID
HAVING COUNT(*) < 4
ORDER BY AVG_SALARY;

-- Example 2: Departments where average salary exceeds 60000
SELECT dept_id, AVG(salary) AS avg_salary
FROM employees
GROUP BY dept_id
HAVING AVG(salary) > 60000;

-- Example 3: Job roles with total salary over 200000
SELECT job_role, SUM(salary) AS total_salary
FROM employees
GROUP BY job_role
HAVING SUM(salary) > 200000
ORDER BY total_salary DESC;

-- Example 4: WHERE + GROUP BY + HAVING together
-- "Among full-time employees, find departments
--  with more than 2 people and average salary above 55000"
SELECT dept_id,
       COUNT(*)    AS headcount,
       AVG(salary) AS avg_salary
FROM employees
WHERE employment_type = 'FULL_TIME'      -- filters rows before grouping
GROUP BY dept_id
HAVING COUNT(*) > 2                      -- filters groups after grouping
   AND AVG(salary) > 55000
ORDER BY avg_salary DESC;


-- =====================================================
-- QUICK REFERENCE CARD
-- =====================================================
--
-- Clause / Command  | Purpose                          | Key note
-- ------------------+----------------------------------+-----------------------------
-- CREATE TABLE      | Define a new table               | Set PKs and constraints here
-- ALTER TABLE       | Change table structure           | ADD / MODIFY / DROP / CHANGE
-- TRUNCATE          | Delete all rows, keep structure  | Faster than DELETE; no undo
-- DROP TABLE        | Delete table + structure         | Use IF EXISTS to be safe
-- LIKE              | Pattern match strings            | % = many chars, _ = one char
-- BETWEEN           | Inclusive range filter           | Works on numbers & dates
-- ORDER BY          | Sort result rows                 | Default ASC; multi-col ok
-- GROUP BY          | Aggregate rows by column value   | Pair with COUNT/SUM/AVG etc.
-- HAVING            | Filter aggregated groups         | Use instead of WHERE + agg
--
-- Clause execution order:
-- FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY
-- =====================================================