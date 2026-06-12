-- DAY
-- The DAY function returns the day of the month for a given date.
SELECT DAY(b_date) FROM employees where emp_id = 'E1002';

-- CURRENT_DATE
SELECT CURRENT_DATE;

-- DATEDIFF()
SELECT DATEDIFF(date1, date2);

SELECT DATEDIFF(CURRENT_DATE, date_column) FROM table;

-- FROM_DAYS()
-- FROM_DAYS() is used to convert a given number of days to YYYY-MM-DD format.
-- takes number of days as input and converts it into a date starting from MYSQL's internal count
SELECT FROM_DAYS(number_of_days);

SELECT FROM_DAYS(DATEDIFF(CURRENT_DATE, date_column)) FROM table;

-- the above becomes
FROM_DAYS(10) ---> 0000-01-10 YYYY-MM-DD format




-- =====================================================
-- DATE_ADD()
-- Adds a specified interval to a date
-- Syntax:
-- DATE_ADD(date, INTERVAL n DAY)
-- =====================================================

-- Example 1: Add 3 days to a date

SELECT DATE_ADD('2025-06-10', INTERVAL 3 DAY);

-- Result:
-- 2025-06-13


-- Example 2: Add 2 months to a date

SELECT DATE_ADD('2025-06-10', INTERVAL 2 MONTH);

-- Result:
-- 2025-08-10


-- Example 3: Add 1 year to a date

SELECT DATE_ADD('2025-06-10', INTERVAL 1 YEAR);

-- Result:
-- 2026-06-10



-- =====================================================
-- DATE_SUB()
-- Subtracts a specified interval from a date
-- Syntax:
-- DATE_SUB(date, INTERVAL n DAY)
-- =====================================================

-- Example 1: Subtract 3 days from a date

SELECT DATE_SUB('2025-06-10', INTERVAL 3 DAY);

-- Result:
-- 2025-06-07


-- Example 2: Subtract 2 months from a date

SELECT DATE_SUB('2025-06-10', INTERVAL 2 MONTH);

-- Result:
-- 2025-04-10


-- Example 3: Subtract 1 year from a date

SELECT DATE_SUB('2025-06-10', INTERVAL 1 YEAR);

-- Result:
-- 2024-06-10


-- =====================================================
-- USING A TABLE COLUMN
-- =====================================================

-- Table:
--
-- EMPLOYEE
-- +--------+------------+
-- | EMP_ID | JOIN_DATE  |
-- +--------+------------+
-- | 1      | 2025-01-15 |
-- | 2      | 2025-03-01 |
-- +--------+------------+

-- Add 30 days to every JOIN_DATE

SELECT EMP_ID,
       JOIN_DATE,
       DATE_ADD(JOIN_DATE, INTERVAL 30 DAY) AS AFTER_30_DAYS
FROM EMPLOYEE;

-- Result:
--
-- EMP_ID | JOIN_DATE  | AFTER_30_DAYS
-- -------+------------+--------------
-- 1      | 2025-01-15 | 2025-02-14
-- 2      | 2025-03-01 | 2025-03-31


-- Subtract 30 days from every JOIN_DATE

SELECT EMP_ID,
       JOIN_DATE,
       DATE_SUB(JOIN_DATE, INTERVAL 30 DAY) AS BEFORE_30_DAYS
FROM EMPLOYEE;

-- Result:
--
-- EMP_ID | JOIN_DATE  | BEFORE_30_DAYS
-- -------+------------+---------------
-- 1      | 2025-01-15 | 2024-12-16
-- 2      | 2025-03-01 | 2025-01-30