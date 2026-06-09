# Database Keys — Complete Reference

---

## What are Keys?

Keys are constraints applied to columns in a table to:
- **Uniquely identify** rows
- **Establish relationships** between tables
- **Maintain data integrity** (no duplicates, no orphan records)

---

## 1. Primary Key

### What it is
A column (or combination of columns) that **uniquely identifies every row** in a table.
- Cannot be NULL
- Must be unique
- Only one primary key per table

### Syntax
```sql
-- Option 1: Inline
CREATE TABLE students (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

-- Option 2: At the end (preferred for clarity)
CREATE TABLE students (
    id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    PRIMARY KEY (id)
);

-- Add to existing table
ALTER TABLE students ADD PRIMARY KEY (id);
```

### Example
```
students table
+----+----------+----------------------+
| id | name     | email                |
+----+----------+----------------------+
|  1 | Souvik   | souvik@mail.com      |
|  2 | Alice    | alice@mail.com       |
|  3 | Bob      | bob@mail.com         |
+----+----------+----------------------+
     ^
     PRIMARY KEY — each value is unique and never NULL
```

### Use Cases
- `student_id` in a students table
- `order_id` in an orders table
- `product_id` in a products table
- `employee_id` in an HR system

---

## 2. Foreign Key

### What it is
A column in one table that **refers to the Primary Key of another table**.
- Used to link two tables together
- Prevents inserting a value that doesn't exist in the referenced table
- Maintains **referential integrity**

### Syntax
```sql
-- Child table references parent table
CREATE TABLE orders (
    order_id INT NOT NULL AUTO_INCREMENT,
    student_id INT NOT NULL,
    product VARCHAR(100),
    PRIMARY KEY (order_id),
    FOREIGN KEY (student_id) REFERENCES students(id)
);

-- Add to existing table
ALTER TABLE orders
ADD FOREIGN KEY (student_id) REFERENCES students(id);
```

### Example
```
students (parent)          orders (child)
+----+----------+          +---------+------------+---------+
| id | name     |          | order_id| student_id | product |
+----+----------+          +---------+------------+---------+
|  1 | Souvik   |  <-----  |    1    |     1      | Laptop  |
|  2 | Alice    |  <-----  |    2    |     2      | Phone   |
|  3 | Bob      |          |    3    |     1      | Tablet  |
+----+----------+          +---------+------------+---------+
                                          ^
                                   FOREIGN KEY — must exist in students.id
```

### What Foreign Keys prevent
```sql
-- This will FAIL — student_id 99 does not exist in students table
INSERT INTO orders (student_id, product) VALUES (99, 'Laptop');
-- ERROR: Cannot add or update a child row: a foreign key constraint fails
```

### Use Cases
- `student_id` in orders table → references students
- `department_id` in employees table → references departments
- `category_id` in products table → references categories
- `author_id` in posts table → references users

### ON DELETE / ON UPDATE options
```sql
FOREIGN KEY (student_id) REFERENCES students(id)
    ON DELETE CASCADE    -- if student deleted, delete their orders too
    ON UPDATE CASCADE    -- if student id changes, update orders too

ON DELETE SET NULL       -- set foreign key to NULL if parent is deleted
ON DELETE RESTRICT       -- prevent deleting parent if child rows exist (default)
```

---

## 3. Unique Key

### What it is
Ensures all values in a column are **unique across the table**.
- Unlike Primary Key, it **can contain NULL** (only one NULL allowed per column)
- A table can have **multiple Unique Keys**

### Syntax
```sql
CREATE TABLE students (
    id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,       -- inline
    phone VARCHAR(15),
    PRIMARY KEY (id),
    UNIQUE KEY unique_phone (phone)  -- named unique key
);

-- Add to existing table
ALTER TABLE students ADD UNIQUE (email);
```

### Example
```
students table
+----+----------+------------------+
| id | name     | email            |
+----+----------+------------------+
|  1 | Souvik   | souvik@mail.com  |
|  2 | Alice    | alice@mail.com   |
|  3 | Bob      | NULL             |  <-- NULL is allowed
+----+----------+------------------+

-- This will FAIL — email already exists
INSERT INTO students (name, email) VALUES ('Dave', 'souvik@mail.com');
-- ERROR: Duplicate entry 'souvik@mail.com' for key 'email'
```

### Use Cases
- `email` column — no two users should share the same email
- `username` column — must be unique per user
- `phone_number` — one account per phone
- `national_id` or `aadhar_number`

---

## 4. Composite Key

### What it is
A Primary Key made up of **two or more columns combined**.
Used when no single column alone can uniquely identify a row, but the **combination** of columns can.

### Syntax
```sql
-- Student can enroll in many courses, a course has many students
-- But a student can only enroll in the same course ONCE
CREATE TABLE enrollments (
    student_id INT NOT NULL,
    course_id  INT NOT NULL,
    enrolled_on DATE,
    PRIMARY KEY (student_id, course_id)   -- composite key
);
```

### Example
```
enrollments table
+------------+-----------+-------------+
| student_id | course_id | enrolled_on |
+------------+-----------+-------------+
|     1      |    101    | 2024-01-15  |
|     1      |    102    | 2024-01-16  |  -- same student, different course: OK
|     2      |    101    | 2024-01-17  |  -- different student, same course: OK
|     1      |    101    | 2024-02-01  |  -- FAILS: duplicate (1, 101) pair
+------------+-----------+-------------+
           ^          ^
           Both together = PRIMARY KEY
```

### Use Cases
- `(student_id, course_id)` in an enrollments table
- `(employee_id, project_id)` in a project assignments table
- `(user_id, product_id)` in a wishlist table
- `(flight_id, seat_number)` in a seat bookings table

---

## 5. Candidate Key

### What it is
Any column (or set of columns) that **could qualify as a Primary Key** — it is unique and not null.
- A table can have multiple candidate keys
- One of them is chosen as the Primary Key
- The rest become **Alternate Keys**

### Example
```
students table
+------------+----------+------------------+------------+
| student_id | name     | email            | phone      |
+------------+----------+------------------+------------+
|    S001    | Souvik   | souvik@mail.com  | 9876543210 |
|    S002    | Alice    | alice@mail.com   | 9123456780 |
+------------+----------+------------------+------------+

Candidate Keys:
  - student_id  → unique, not null ✓
  - email       → unique, not null ✓
  - phone       → unique, not null ✓

Chosen Primary Key: student_id
Alternate Keys:     email, phone
```

### Use Cases
- Identifying which columns are "worthy" of being a primary key during schema design
- `passport_number`, `aadhar_number`, `email` — all are candidate keys for a user

---

## 6. Alternate Key

### What it is
A **Candidate Key that was NOT chosen** as the Primary Key.
- Still unique and not null
- Often implemented using a `UNIQUE` constraint

### Example
```sql
CREATE TABLE students (
    student_id VARCHAR(10) NOT NULL,  -- chosen as Primary Key
    email VARCHAR(100) NOT NULL,      -- alternate key
    phone VARCHAR(15) NOT NULL,       -- alternate key
    name VARCHAR(50),
    PRIMARY KEY (student_id),
    UNIQUE (email),                   -- enforcing alternate key
    UNIQUE (phone)                    -- enforcing alternate key
);
```

---

## 7. Super Key

### What it is
Any column or **combination of columns** that can uniquely identify a row.
- Every Primary Key is a Super Key
- Not every Super Key is a Primary Key (may have extra/redundant columns)

### Example
```
students table columns: student_id, name, email, phone

Super Keys (all combinations that give uniqueness):
  - {student_id}
  - {email}
  - {phone}
  - {student_id, name}         -- redundant, but still unique
  - {student_id, email}        -- redundant, but still unique
  - {student_id, name, email}  -- redundant, but still unique
  ... and so on

Candidate Keys (minimal super keys — no redundant columns):
  - {student_id}
  - {email}
  - {phone}
```

---

## 8. Index (not a key, but closely related)

### What it is
An index is a **data structure that speeds up SELECT queries** on a column.
- Not a constraint like keys, but often created alongside them
- Primary Keys and Unique Keys automatically create an index

### Syntax
```sql
-- Create an index
CREATE INDEX idx_name ON students (name);

-- Create a composite index
CREATE INDEX idx_name_email ON students (name, email);

-- Show all indexes on a table
SHOW INDEX FROM students;

-- Drop an index
DROP INDEX idx_name ON students;
```

### Use Cases
- Speed up search on `name` if you frequently do `WHERE name = '...'`
- Speed up JOIN operations on foreign key columns
- Speed up ORDER BY on frequently sorted columns

---

## Summary Table

| Key Type      | Unique | Allows NULL | Count per Table | Purpose |
|---------------|--------|-------------|-----------------|---------|
| Primary Key   | Yes    | No          | Only 1          | Uniquely identify each row |
| Foreign Key   | No     | Yes         | Multiple        | Link to another table's PK |
| Unique Key    | Yes    | Yes (1 NULL)| Multiple        | Enforce uniqueness on a column |
| Composite Key | Yes    | No          | Only 1          | PK made of 2+ columns |
| Candidate Key | Yes    | No          | Multiple        | Columns eligible to be PK |
| Alternate Key | Yes    | No          | Multiple        | Candidate keys not chosen as PK |
| Super Key     | Yes    | —           | Many            | Any combo that gives uniqueness |

---

## Real World Schema Example (using all key types)

```sql
-- Parent table
CREATE TABLE departments (
    dept_id   INT NOT NULL AUTO_INCREMENT,
    dept_name VARCHAR(100) NOT NULL UNIQUE,   -- Unique Key (Alternate Key)
    PRIMARY KEY (dept_id)                     -- Primary Key
);

-- Child table
CREATE TABLE employees (
    emp_id    INT NOT NULL AUTO_INCREMENT,
    email     VARCHAR(100) NOT NULL UNIQUE,   -- Unique Key (Alternate Key)
    phone     VARCHAR(15) NOT NULL UNIQUE,    -- Unique Key (Alternate Key)
    name      VARCHAR(100) NOT NULL,
    dept_id   INT,
    PRIMARY KEY (emp_id),                     -- Primary Key
    FOREIGN KEY (dept_id)                     -- Foreign Key
        REFERENCES departments(dept_id)
        ON DELETE SET NULL
);

-- Junction table (many-to-many)
CREATE TABLE projects (
    project_id INT NOT NULL AUTO_INCREMENT,
    title      VARCHAR(200) NOT NULL,
    PRIMARY KEY (project_id)
);

CREATE TABLE employee_projects (
    emp_id     INT NOT NULL,
    project_id INT NOT NULL,
    role       VARCHAR(50),
    PRIMARY KEY (emp_id, project_id),         -- Composite Key
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id) ON DELETE CASCADE,
    FOREIGN KEY (project_id) REFERENCES projects(project_id) ON DELETE CASCADE
);
```

---

> **Key Rule to Remember:**
> - Use **Primary Key** to identify rows within a table
> - Use **Foreign Key** to connect rows across tables
> - Use **Unique Key** to prevent duplicates on non-PK columns
> - Use **Composite Key** when no single column is enough to identify a row