In MySQL, a **JOIN** is used to combine rows from two or more tables based on a related column.

Suppose we have:

**employees**

| id | name   | dept_id |
| -- | ------ | ------- |
| 1  | Souvik | 10      |
| 2  | Rahul  | 20      |
| 3  | Amit   | 30      |
| 4  | Priya  | NULL    |

**departments**

| dept_id | dept_name |
| ------- | --------- |
| 10      | IT        |
| 20      | HR        |
| 40      | Finance   |

---

## 1. INNER JOIN

Returns **only rows where there is a match in both tables**.

```sql
SELECT e.name, d.dept_name
FROM employees e
INNER JOIN departments d
ON e.dept_id = d.dept_id;
```

Result:

| name   | dept_name |
| ------ | --------- |
| Souvik | IT        |
| Rahul  | HR        |

### Use

When you only care about records that have a corresponding record in **both tables**.

**Mental model:**

> "Give me employees who belong to a department that actually exists."

---

## 2. LEFT JOIN / LEFT OUTER JOIN

Returns **all rows from the left table**, and matching rows from the right table.

If there is no match, the right-side columns become `NULL`.

```sql
SELECT e.name, d.dept_name
FROM employees e
LEFT JOIN departments d
ON e.dept_id = d.dept_id;
```

Result:

| name   | dept_name |
| ------ | --------- |
| Souvik | IT        |
| Rahul  | HR        |
| Amit   | NULL      |
| Priya  | NULL      |

### Use

When the **left table is your main table** and you don't want to lose its records.

For example:

> "Show me every employee, even if their department is missing."

This is probably the **most important JOIN after INNER JOIN** to understand.

---

## 3. RIGHT JOIN / RIGHT OUTER JOIN

Opposite of `LEFT JOIN`.

Returns **all rows from the right table**, plus matching rows from the left table.

```sql
SELECT e.name, d.dept_name
FROM employees e
RIGHT JOIN departments d
ON e.dept_id = d.dept_id;
```

Result:

| name   | dept_name |
| ------ | --------- |
| Souvik | IT        |
| Rahul  | HR        |
| NULL   | Finance   |

Finance exists in the department table but has no employee.

### Use

When you want **every record from the right table**, regardless of whether a match exists.

In practice, many developers prefer rewriting a `RIGHT JOIN` as a `LEFT JOIN` by swapping the table order because it is easier to read.

---

## 4. FULL OUTER JOIN

Returns **everything from both tables**:

* Matching rows → combined
* Unmatched left rows → right side `NULL`
* Unmatched right rows → left side `NULL`

Conceptually:

```text
LEFT JOIN + RIGHT JOIN
```

For our example:

| name   | dept_name |
| ------ | --------- |
| Souvik | IT        |
| Rahul  | HR        |
| Amit   | NULL      |
| Priya  | NULL      |
| NULL   | Finance   |

### Important MySQL point

**MySQL does NOT directly support `FULL OUTER JOIN`.**

You can simulate it using `UNION`:

```sql
SELECT e.name, d.dept_name
FROM employees e
LEFT JOIN departments d
ON e.dept_id = d.dept_id

UNION

SELECT e.name, d.dept_name
FROM employees e
RIGHT JOIN departments d
ON e.dept_id = d.dept_id;
```

### Use

When you need **all records from both sides**, including unmatched records.

---

## 5. CROSS JOIN

Produces the **Cartesian product**.

Every row from the first table is combined with **every row** from the second table.

```sql
SELECT e.name, d.dept_name
FROM employees e
CROSS JOIN departments d;
```

We have 4 employees × 3 departments:

$$4 \times 3 = 12$$

So we get 12 rows.

### Use

When you intentionally want **every possible combination**.

Example:

> 5 shirt colors × 4 sizes = 20 possible product variants.

### Warning

A `CROSS JOIN` can generate a **huge number of rows**, so don't use it accidentally.

---

## 6. SELF JOIN

A table is joined **with itself**.

Suppose employees has:

| id | name   | manager_id |
| -- | ------ | ---------- |
| 1  | Souvik | NULL       |
| 2  | Rahul  | 1          |
| 3  | Amit   | 1          |
| 4  | Priya  | 2          |

We want:

> Employee → Manager

```sql
SELECT 
    e.name AS employee,
    m.name AS manager
FROM employees e
LEFT JOIN employees m
ON e.manager_id = m.id;
```

Result:

| employee | manager |
| -------- | ------- |
| Souvik   | NULL    |
| Rahul    | Souvik  |
| Amit     | Souvik  |
| Priya    | Rahul   |

### Use

When rows in the **same table have relationships with each other**.

Common examples:

* Employee → Manager
* Person → Parent
* Category → Parent Category
* Friend → Friend

---

# The easiest way to remember JOINs

Think of two circles:

```text
        TABLE A              TABLE B

INNER      →      only intersection

LEFT       →      all A + matching B

RIGHT      →      matching A + all B

FULL       →      everything from A + B

CROSS      →      every A × every B

SELF       →      A joined with A
```

### Interview cheat sheet

| JOIN                | What it returns                           | Typical use                       |
| ------------------- | ----------------------------------------- | --------------------------------- |
| **INNER JOIN**      | Matching rows only                        | Records existing in both tables   |
| **LEFT JOIN**       | Everything from left + matches from right | Keep all records from main table  |
| **RIGHT JOIN**      | Everything from right + matches from left | Keep all records from right table |
| **FULL OUTER JOIN** | Everything from both                      | Compare two complete datasets     |
| **CROSS JOIN**      | Every possible combination                | Generate combinations             |
| **SELF JOIN**       | Table joined with itself                  | Hierarchies/relationships         |

### One interview question you should absolutely know

**"What is the difference between INNER JOIN and LEFT JOIN?"**

A clean answer:

> **INNER JOIN only returns rows where a matching record exists in both tables. LEFT JOIN returns every row from the left table, and if a matching row doesn't exist in the right table, it still keeps the left row and puts NULL for the right-table columns.**

That distinction is far more important than memorizing six JOIN definitions.
