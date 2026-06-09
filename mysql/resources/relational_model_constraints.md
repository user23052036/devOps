# Relational Model Constraints

Constraints are **rules enforced on data** in a relational database to ensure accuracy, consistency, and integrity.

---

## Sample Tables Used in Examples

**BookShop**
| BOOK_ID | TITLE                  | AUTHOR_ID |
|---------|------------------------|-----------|
| 1       | The Silent Patient     | 101       |
| 2       | Educated               | 102       |
| 3       | 1984                   | 103       |
| 4       | To Kill a Mockingbird  | 104       |
| 5       | The Great Gatsby       | 105       |

**BookShop_AuthorDetails**
| AUTHOR_ID | AUTHOR_NAME       |
|-----------|-------------------|
| 101       | Alex Michaelides  |
| 102       | Tara Westover     |
| 103       | George Orwell     |

---

## 1. Entity Integrity Constraint

### What it means
Every table **must have a Primary Key**, and that primary key:
- Must be **unique** across all rows
- Must **never be NULL**

This guarantees that every row is distinct and identifiable — no duplicates, no missing identifiers.

### Example
```sql
CREATE TABLE BookShop (
    BOOK_ID   INT PRIMARY KEY,   -- must be unique, never NULL
    TITLE     VARCHAR(100),
    AUTHOR_ID INT
);
```

### Why BOOK_ID is the right primary key here
- No two books can have the same `BOOK_ID`
- Every book must have a `BOOK_ID` (cannot be left empty)

> **Rule:** Every table in a relational database should have a primary key to satisfy entity integrity.

---

## 2. Referential Integrity Constraint

### What it means
A **foreign key** in one table must always refer to a **valid primary key** in another table.
This prevents "orphaned" records — rows that reference something that doesn't exist.

### Example
```sql
-- Parent table (must be created first)
CREATE TABLE BookShop_AuthorDetails (
    AUTHOR_ID   INT PRIMARY KEY,
    AUTHOR_NAME VARCHAR(100)
);

-- Child table references the parent
CREATE TABLE BookShop (
    BOOK_ID   INT PRIMARY KEY,
    TITLE     VARCHAR(100),
    AUTHOR_ID INT,
    FOREIGN KEY (AUTHOR_ID) REFERENCES BookShop_AuthorDetails(AUTHOR_ID)
);
```

### What this enforces
- Every `AUTHOR_ID` in `BookShop` must exist in `BookShop_AuthorDetails`
- You cannot insert a book with an `AUTHOR_ID` that doesn't exist in the author table

```sql
-- This will FAIL — AUTHOR_ID 999 does not exist in BookShop_AuthorDetails
INSERT INTO BookShop (BOOK_ID, TITLE, AUTHOR_ID)
VALUES (6, 'Unknown Book', 999);
-- ERROR: Cannot add or update a child row: a foreign key constraint fails
```

> **Rule:** Foreign key values must always match an existing primary key value in the referenced table, or be NULL.

---

## 3. Domain Integrity Constraint

### What it means
All values stored in a column must fall within a **defined domain** — meaning they must follow rules about:
- Data type (INT, VARCHAR, DATE, etc.)
- Format
- Allowed values
- Nullability

This ensures data in a column is **valid, logical, and consistent** with its intended use.

### Two main mechanisms to enforce domain integrity

#### CHECK Constraint
Enforces rules about the **range or pattern** of acceptable values. The data entered must meet a specific logical condition.

#### NOT NULL Constraint
Ensures a column **cannot be left empty** — a value must always be provided.

### Example
```sql
CREATE TABLE BookShop (
    BOOK_ID        INT PRIMARY KEY,
    TITLE          VARCHAR(100) NOT NULL,              -- NOT NULL: title is mandatory
    PRICE          DECIMAL(5, 2) CHECK (PRICE >= 0),  -- CHECK: price cannot be negative
    PUBLISHED_DATE DATE
);
```

### Explanation
- `TITLE NOT NULL` — every book must have a title; it cannot be left blank
- `PRICE CHECK (PRICE >= 0)` — price must be 0 or more; negative prices are rejected

```sql
-- This will FAIL — title cannot be NULL
INSERT INTO BookShop (BOOK_ID, TITLE, PRICE) VALUES (1, NULL, 500);

-- This will FAIL — price cannot be negative
INSERT INTO BookShop (BOOK_ID, TITLE, PRICE) VALUES (2, '1984', -50);
```

---

## Summary

| Constraint | Enforces | Mechanism |
|---|---|---|
| Entity Integrity | Every row is unique and identifiable | PRIMARY KEY (NOT NULL + UNIQUE) |
| Referential Integrity | Relationships between tables are valid | FOREIGN KEY |
| Domain Integrity | Column values are valid and within rules | NOT NULL, CHECK, data types |

---

## All Three Together — Full Example

```sql
CREATE TABLE BookShop_AuthorDetails (
    AUTHOR_ID   INT PRIMARY KEY,          -- Entity Integrity
    AUTHOR_NAME VARCHAR(100) NOT NULL     -- Domain Integrity (NOT NULL)
);

CREATE TABLE BookShop (
    BOOK_ID        INT PRIMARY KEY,                             -- Entity Integrity
    TITLE          VARCHAR(100) NOT NULL,                       -- Domain Integrity (NOT NULL)
    PRICE          DECIMAL(5, 2) CHECK (PRICE >= 0),           -- Domain Integrity (CHECK)
    PUBLISHED_DATE DATE,
    AUTHOR_ID      INT,
    FOREIGN KEY (AUTHOR_ID)                                     -- Referential Integrity
        REFERENCES BookShop_AuthorDetails(AUTHOR_ID)
);
```

> **Remember:**
> - **Entity** → Is each row uniquely identifiable? (Primary Key)
> - **Referential** → Do all foreign key values point to real rows? (Foreign Key)
> - **Domain** → Are all column values valid and within allowed rules? (NOT NULL, CHECK)