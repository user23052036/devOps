# MySQL Cheatsheet — All Basic Commands

---

## 1. Database Commands

```sql
-- Create a database
CREATE DATABASE mydb;

-- Use / switch to a database
USE mydb;

-- List all databases
SHOW DATABASES;

-- Delete a database
DROP DATABASE mydb;

-- Check current database
SELECT DATABASE();
```

---

## 2. Table Commands

```sql
-- Create a table
CREATE TABLE students (
    id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    PRIMARY KEY (id)
);

-- List all tables in current database
SHOW TABLES;

-- Show structure of a table
DESCRIBE students;

-- Delete a table
DROP TABLE students;

-- Delete table only if it exists (safe)
DROP TABLE IF EXISTS students;

-- Empty a table (delete all data, keep structure)
TRUNCATE TABLE students;

-- Rename a table
RENAME TABLE students TO learners;

-- Copy a table (structure + data)
CREATE TABLE backup AS SELECT * FROM students;
```

---

## 3. Insert Data

```sql
-- Insert one row
INSERT INTO students (name, email)
VALUES ('Souvik', 'souvik@mail.com');

-- Insert multiple rows at once
INSERT INTO students (name, email) VALUES
('Alice', 'alice@mail.com'),
('Bob', 'bob@mail.com'),
('Charlie', 'charlie@mail.com');
```

---

## 4. Read / Select Data

```sql
-- Select all rows and columns
SELECT * FROM students;

-- Select specific columns
SELECT name, email FROM students;

-- Select with a condition
SELECT * FROM students WHERE id = 1;

-- Count total rows
SELECT COUNT(*) FROM students;

-- Select distinct (unique) values
SELECT DISTINCT name FROM students;
```

---

## 5. Update Data

```sql
-- Update a specific row
UPDATE students
SET email = 'newemail@mail.com'
WHERE id = 1;

-- Update multiple columns
UPDATE students
SET name = 'Souvik Das', email = 'new@mail.com'
WHERE id = 1;
```

---

## 6. Delete Data

```sql
-- Delete a specific row
DELETE FROM students WHERE id = 1;

-- Delete all rows (table remains)
DELETE FROM students;
```

---

## 7. Filter & Sort

```sql
-- Filter with WHERE
SELECT * FROM students WHERE name = 'Souvik';

-- AND / OR conditions
SELECT * FROM students WHERE name = 'Alice' AND id > 2;
SELECT * FROM students WHERE name = 'Alice' OR name = 'Bob';

-- Pattern matching with LIKE
SELECT * FROM students WHERE name LIKE 'S%';    -- starts with S
SELECT * FROM students WHERE name LIKE '%uvik'; -- ends with uvik
SELECT * FROM students WHERE name LIKE '%ouv%'; -- contains ouv

-- Range filter with BETWEEN
SELECT * FROM students WHERE id BETWEEN 1 AND 5;

-- Filter from a list with IN
SELECT * FROM students WHERE id IN (1, 3, 5);

-- Check for NULL values
SELECT * FROM students WHERE email IS NULL;
SELECT * FROM students WHERE email IS NOT NULL;

-- Sort results (ASC = A-Z, DESC = Z-A)
SELECT * FROM students ORDER BY name ASC;
SELECT * FROM students ORDER BY id DESC;

-- Limit number of results
SELECT * FROM students LIMIT 10;

-- Limit with offset (for pagination)
-- Page 1: LIMIT 10 OFFSET 0
-- Page 2: LIMIT 10 OFFSET 10
SELECT * FROM students LIMIT 10 OFFSET 20;
```

---

## 8. Alter Table (Modify Structure)

```sql
-- Add a new column
ALTER TABLE students ADD COLUMN age INT;

-- Drop a column
ALTER TABLE students DROP COLUMN age;

-- Rename a column
ALTER TABLE students RENAME COLUMN name TO full_name;

-- Change column data type or size
ALTER TABLE students MODIFY COLUMN email VARCHAR(200);

-- Add a primary key
ALTER TABLE students ADD PRIMARY KEY (id);

-- Add a foreign key
ALTER TABLE orders
ADD FOREIGN KEY (student_id) REFERENCES students(id);

-- Add an index (speeds up search on that column)
ALTER TABLE students ADD INDEX idx_name (name);
```

---

## 9. Aggregate Functions

```sql
-- Count rows
SELECT COUNT(*) FROM students;

-- Sum of a column
SELECT SUM(age) FROM students;

-- Average of a column
SELECT AVG(age) FROM students;

-- Maximum value
SELECT MAX(age) FROM students;

-- Minimum value
SELECT MIN(age) FROM students;
```

---

## 10. Admin & Utility

```sql
-- Show MySQL version
SELECT VERSION();

-- Show current date and time
SELECT NOW();

-- Show warnings after a query
SHOW WARNINGS;

-- Show the CREATE TABLE statement for a table
SHOW CREATE TABLE students;

-- Show all indexes on a table
SHOW INDEX FROM students;

-- Show currently running queries
SHOW PROCESSLIST;
```

---

## Quick Reference Table

| Operation | Command |
|---|---|
| Create DB | `CREATE DATABASE name;` |
| Use DB | `USE name;` |
| Create Table | `CREATE TABLE name (...);` |
| Insert Row | `INSERT INTO name (cols) VALUES (...);` |
| Read All | `SELECT * FROM name;` |
| Update Row | `UPDATE name SET col=val WHERE ...;` |
| Delete Row | `DELETE FROM name WHERE ...;` |
| Drop Table | `DROP TABLE name;` |
| Drop DB | `DROP DATABASE name;` |
| Show Tables | `SHOW TABLES;` |
| Describe Table | `DESCRIBE name;` |

---

> **Tip:** Always use `WHERE` with `UPDATE` and `DELETE` — without it, all rows will be affected!