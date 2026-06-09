# Cardinality of Relationships

---

## What is Cardinality?

Cardinality in database relationships refers to the **number of occurrences of an entity in a relationship with another entity**.

In simple terms: it defines **how many instances of one table can be associated with instances of another table**.

---

## Types of Cardinality

There are 3 main types:

| Type | Notation | Meaning |
|------|----------|---------|
| One-to-One | 1:1 | One row in Table A links to exactly one row in Table B |
| One-to-Many | 1:N | One row in Table A links to many rows in Table B |
| Many-to-Many | M:N | Many rows in Table A link to many rows in Table B |

---

## 1. One-to-One (1:1)

### What it means
One record in Table A is associated with **exactly one** record in Table B, and vice versa.

### Real World Examples
- One **person** has one **passport**
- One **employee** has one **salary account**
- One **user** has one **profile**
- One **country** has one **capital city**

### How to implement in MySQL
```sql
CREATE TABLE users (
    user_id INT NOT NULL AUTO_INCREMENT,
    name    VARCHAR(100) NOT NULL,
    PRIMARY KEY (user_id)
);

CREATE TABLE profiles (
    profile_id INT NOT NULL AUTO_INCREMENT,
    user_id    INT NOT NULL UNIQUE,       -- UNIQUE enforces 1:1
    bio        TEXT,
    avatar_url VARCHAR(255),
    PRIMARY KEY (profile_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE
);
```

### Example Data
```
users                        profiles
+--------+----------+        +------------+--------+------------------+
| user_id| name     |        | profile_id | user_id| bio              |
+--------+----------+        +------------+--------+------------------+
|   1    | Souvik   |  <-->  |     1      |   1    | CS undergrad...  |
|   2    | Alice    |  <-->  |     2      |   2    | Data engineer... |
+--------+----------+        +------------+--------+------------------+
                                               ^
                                          UNIQUE + FOREIGN KEY = 1:1
```

> **Key point:** The `UNIQUE` constraint on the foreign key column is what enforces a 1:1 relationship.

---

## 2. One-to-Many (1:N)

### What it means
One record in Table A can be associated with **many records** in Table B. But each record in Table B belongs to only **one** record in Table A.

This is the **most common** relationship in databases.

### Real World Examples
- One **customer** places many **orders**
- One **teacher** teaches many **students**
- One **department** has many **employees**
- One **post** has many **comments**
- One **country** has many **cities**

### How to implement in MySQL
```sql
CREATE TABLE customers (
    customer_id INT NOT NULL AUTO_INCREMENT,
    name        VARCHAR(100) NOT NULL,
    PRIMARY KEY (customer_id)
);

CREATE TABLE orders (
    order_id    INT NOT NULL AUTO_INCREMENT,
    customer_id INT NOT NULL,             -- many orders can have same customer_id
    product     VARCHAR(100),
    amount      DECIMAL(10, 2),
    PRIMARY KEY (order_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE CASCADE
);
```

### Example Data
```
customers                      orders
+-------------+----------+     +---------+-------------+---------+--------+
| customer_id | name     |     | order_id| customer_id | product | amount |
+-------------+----------+     +---------+-------------+---------+--------+
|      1      | Souvik   |<-+  |    1    |      1      | Laptop  | 55000  |
|      2      | Alice    |  |  |    2    |      1      | Mouse   |   800  |
+-------------+----------+  |  |    3    |      1      | Keyboard|  1500  |
                            |  |    4    |      2      | Phone   | 20000  |
                            +--+---------+             (Souvik has 3 orders)
```

> **Key point:** No `UNIQUE` on the foreign key — multiple rows in the child table can point to the same parent row.

---

## 3. Many-to-Many (M:N)

### What it means
Many records in Table A can be associated with many records in Table B, and vice versa.

This **cannot be directly implemented** with just two tables — it requires a **junction table** (also called a bridge table or associative table) in between.

### Real World Examples
- **Students** enroll in many **courses**, and each course has many students
- **Authors** write many **books**, and a book can have multiple authors
- **Doctors** treat many **patients**, and patients can see many doctors
- **Products** belong to many **categories**, and categories have many products
- **Actors** appear in many **movies**, and movies have many actors

### How to implement in MySQL
```sql
-- Table A
CREATE TABLE students (
    student_id INT NOT NULL AUTO_INCREMENT,
    name       VARCHAR(100) NOT NULL,
    PRIMARY KEY (student_id)
);

-- Table B
CREATE TABLE courses (
    course_id   INT NOT NULL AUTO_INCREMENT,
    course_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (course_id)
);

-- Junction / Bridge Table (resolves M:N into two 1:N relationships)
CREATE TABLE enrollments (
    student_id  INT NOT NULL,
    course_id   INT NOT NULL,
    enrolled_on DATE,
    grade       VARCHAR(5),
    PRIMARY KEY (student_id, course_id),        -- Composite Key
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id)  REFERENCES courses(course_id)   ON DELETE CASCADE
);
```

### Example Data
```
students                   enrollments                    courses
+-----------+--------+     +-----------+-----------+     +-----------+-------------+
| student_id| name   |     | student_id| course_id |     | course_id | course_name |
+-----------+--------+     +-----------+-----------+     +-----------+-------------+
|     1     | Souvik |     |     1     |    101    |     |    101    | ML          |
|     2     | Alice  |     |     1     |    102    |     |    102    | DBMS        |
|     3     | Bob    |     |     2     |    101    |     |    103    | DSA         |
+-----------+--------+     |     2     |    103    |     +-----------+-------------+
                           |     3     |    102    |
                           +-----------+-----------+

Souvik  → ML, DBMS
Alice   → ML, DSA
Bob     → DBMS

ML   → Souvik, Alice
DBMS → Souvik, Bob
DSA  → Alice
```

> **Key point:** A M:N relationship is always broken into two 1:N relationships using a junction table. The junction table holds the foreign keys of both tables as a composite primary key.

---

## Crow's Foot Notation (ERD Symbols)

Used in Entity Relationship Diagrams (ERDs) to visually represent cardinality.

```
One-to-One (1:1)
  A |o———o| B
    Exactly one on each side

One-to-Many (1:N)
  A |o———<  B
    One on left, many (crow's foot) on right

Many-to-Many (M:N)
  A  >———<  B
    Many on both sides (crow's foot on both)
```

---

## Choosing the Right Relationship

| Scenario | Relationship | Solution |
|----------|-------------|----------|
| User ↔ Passport | 1:1 | FK + UNIQUE in child table |
| Customer → Orders | 1:N | FK in child table (no UNIQUE) |
| Student ↔ Course | M:N | Junction table with two FKs |
| Department → Employees | 1:N | FK in employees table |
| Actor ↔ Movie | M:N | Junction table |
| Employee ↔ Salary Account | 1:1 | FK + UNIQUE |

---

## Summary

```
1:1  →  Use FOREIGN KEY + UNIQUE constraint in the child table
         One parent row ←→ One child row

1:N  →  Use FOREIGN KEY (without UNIQUE) in the child table
         One parent row ←→ Many child rows

M:N  →  Create a junction table with two FOREIGN KEYs
         Many parent rows ←→ Many child rows
         Junction table has a COMPOSITE PRIMARY KEY
```

---

> **Remember:** Every M:N relationship in the real world is implemented as two 1:N relationships in the database using a junction table!