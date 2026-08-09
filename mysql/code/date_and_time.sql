-- =====================================================
-- MySQL DATE FUNCTIONS — REFERENCE & EXAMPLES
-- =====================================================
-- Sections (in logical order):
--   1. CURRENT_DATE
--   2. DAY()
--   3. DATEDIFF()
--   4. FROM_DAYS()
--   5. DATE_ADD()
--   6. DATE_SUB()
-- =====================================================


-- =====================================================
-- 1. CURRENT_DATE
-- Returns today's date in YYYY-MM-DD format.
-- No arguments required.
-- =====================================================

SELECT CURRENT_DATE;
-- Result (example): 2025-06-10

-- Example: Find employees whose contract expires today
SELECT EMP_ID, CONTRACT_END
FROM EMPLOYEES
WHERE CONTRACT_END = CURRENT_DATE;


-- =====================================================
-- 2. DAY()
-- Extracts the day of the month (1–31) from a date.
-- Syntax: DAY(date)
-- =====================================================

SELECT DAY('2025-06-10');
-- Result: 10

-- Example 1: Get the birth-day (day of month) of a specific employee
SELECT DAY(b_date) FROM employees WHERE emp_id = 'E1002';
-- Result: whichever day-of-month is stored in b_date

-- Example 2: Find all employees born on the 15th of any month
SELECT EMP_ID, b_date
FROM employees
WHERE DAY(b_date) = 15;


-- =====================================================
-- 3. DATEDIFF()
-- Returns the number of days between two dates.
-- Syntax: DATEDIFF(date1, date2)  → date1 - date2
-- Positive result → date1 is later than date2.
-- =====================================================

SELECT DATEDIFF('2025-06-10', '2025-06-01');
-- Result: 9

-- Example 1: Days since each employee joined
SELECT EMP_ID,
       JOIN_DATE,
       DATEDIFF(CURRENT_DATE, JOIN_DATE) AS DAYS_SINCE_JOINING
FROM EMPLOYEE;

-- Example 2: Find employees who joined more than 365 days ago
SELECT EMP_ID, JOIN_DATE
FROM EMPLOYEE
WHERE DATEDIFF(CURRENT_DATE, JOIN_DATE) > 365;


-- =====================================================
-- 4. FROM_DAYS()
-- Converts a day-count (from MySQL's internal epoch)
-- into a YYYY-MM-DD date.
-- Syntax: FROM_DAYS(n)
-- Note: Day 1 = 0000-01-01 in MySQL's internal calendar.
--       Mainly useful when chained with DATEDIFF().
-- =====================================================

SELECT FROM_DAYS(10);
-- Result: 0000-01-10

SELECT FROM_DAYS(738000);
-- Result: 2020-11-28  (roughly — varies by build)

-- Example: Convert a DATEDIFF result back to a date-like duration
-- Useful for extracting years/months/days from a day-count
SELECT EMP_ID,
       FROM_DAYS(DATEDIFF(CURRENT_DATE, JOIN_DATE)) AS TENURE_AS_DATE
FROM EMPLOYEE;
-- The YYYY part ≈ full years, MM ≈ remaining months, DD ≈ remaining days
-- e.g. 0002-03-15 → 2 years, 3 months, 15 days of tenure


-- =====================================================
-- 5. DATE_ADD()
-- Adds a time interval to a date.
-- Syntax: DATE_ADD(date, INTERVAL n UNIT)
-- Units: DAY, MONTH, YEAR, HOUR, MINUTE, SECOND, etc.
-- =====================================================

-- Example 1: Add 3 days
SELECT DATE_ADD('2025-06-10', INTERVAL 3 DAY);
-- Result: 2025-06-13

-- Example 2: Add 2 months
SELECT DATE_ADD('2025-06-10', INTERVAL 2 MONTH);
-- Result: 2025-08-10

-- Example 3: Add 1 year
SELECT DATE_ADD('2025-06-10', INTERVAL 1 YEAR);
-- Result: 2026-06-10

-- Example 4: Add 90 days to every employee's JOIN_DATE
--
-- Table: EMPLOYEE
-- +--------+------------+
-- | EMP_ID | JOIN_DATE  |
-- +--------+------------+
-- | 1      | 2025-01-15 |
-- | 2      | 2025-03-01 |
-- +--------+------------+

SELECT EMP_ID,
       JOIN_DATE,
       DATE_ADD(JOIN_DATE, INTERVAL 30 DAY)  AS AFTER_30_DAYS,
       DATE_ADD(JOIN_DATE, INTERVAL 90 DAY)  AS PROBATION_END
FROM EMPLOYEE;

-- Result:
-- EMP_ID | JOIN_DATE  | AFTER_30_DAYS | PROBATION_END
-- -------+------------+---------------+--------------
-- 1      | 2025-01-15 | 2025-02-14    | 2025-04-15
-- 2      | 2025-03-01 | 2025-03-31    | 2025-05-30

-- Example 5: Find employees whose probation ends within the next 7 days
SELECT EMP_ID, JOIN_DATE,
       DATE_ADD(JOIN_DATE, INTERVAL 90 DAY) AS PROBATION_END
FROM EMPLOYEE
WHERE PROBATION_END BETWEEN CURRENT_DATE AND DATE_ADD(CURRENT_DATE, INTERVAL 7 DAY);



-- =====================================================
-- 6. DATE_SUB()
-- Subtracts a time interval from a date.
-- Syntax: DATE_SUB(date, INTERVAL n UNIT)
-- Units: DAY, MONTH, YEAR, HOUR, MINUTE, SECOND, etc.
-- =====================================================

-- Example 1: Subtract 3 days
SELECT DATE_SUB('2025-06-10', INTERVAL 3 DAY);
-- Result: 2025-06-07

-- Example 2: Subtract 2 months
SELECT DATE_SUB('2025-06-10', INTERVAL 2 MONTH);
-- Result: 2025-04-10

-- Example 3: Subtract 1 year
SELECT DATE_SUB('2025-06-10', INTERVAL 1 YEAR);
-- Result: 2024-06-10

-- Example 4: Show what each JOIN_DATE was 30 days before (e.g. offer-letter date)
SELECT EMP_ID,
       JOIN_DATE,
       DATE_SUB(JOIN_DATE, INTERVAL 30 DAY) AS OFFER_LETTER_DATE
FROM EMPLOYEE;

-- Result:
-- EMP_ID | JOIN_DATE  | OFFER_LETTER_DATE
-- -------+------------+------------------
-- 1      | 2025-01-15 | 2024-12-16
-- 2      | 2025-03-01 | 2025-01-30

-- Example 5: Find records created in the last 30 days
SELECT EMP_ID, JOIN_DATE
FROM EMPLOYEE
WHERE JOIN_DATE >= DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY);





-- =====================================================
-- QUICK REFERENCE CARD
-- =====================================================
--
-- Function          | Returns             | Key use-case
-- ------------------+---------------------+---------------------------
-- CURRENT_DATE      | today's date        | baseline for comparisons
-- DAY(date)         | integer 1–31        | extract day component
-- DATEDIFF(d1, d2)  | integer (days)      | age / gap in days
-- FROM_DAYS(n)      | YYYY-MM-DD          | day-count → readable date
-- DATE_ADD(d, I)    | date                | deadlines, future windows
-- DATE_SUB(d, I)    | date                | lookbacks, past windows
--
-- =====================================================