Correct. **Aggregate functions cannot be used directly in the `WHERE` clause**.

For example, this is **invalid**:

```sql
SELECT *
FROM PETRESCUE
WHERE MAX(QUANTITY) > 10;
```

Why?

Because SQL execution order is roughly:

1. `FROM`
2. `WHERE`
3. `GROUP BY`
4. Aggregate functions (`MAX`, `MIN`, `SUM`, `AVG`, `COUNT`)
5. `HAVING`
6. `SELECT`
7. `ORDER BY`

When `WHERE` is being evaluated, `MAX(QUANTITY)` has not been calculated yet.

### Use `HAVING` instead

```sql
SELECT ANIMAL, SUM(QUANTITY)
FROM PETRESCUE
GROUP BY ANIMAL
HAVING SUM(QUANTITY) > 10;
```

`HAVING` filters **groups after aggregation**.

### Comparison

Filter rows before aggregation:

```sql
SELECT *
FROM PETRESCUE
WHERE QUANTITY > 10;
```

Filter groups after aggregation:

```sql
SELECT ANIMAL, COUNT(*)
FROM PETRESCUE
GROUP BY ANIMAL
HAVING COUNT(*) > 2;
```

A useful rule:

* **WHERE** → works on individual rows.
* **HAVING** → works on aggregated results (`MAX`, `MIN`, `SUM`, `AVG`, `COUNT`).

There is one exception: you can use an aggregate in a **subquery** inside `WHERE`:

```sql
SELECT *
FROM PETRESCUE
WHERE QUANTITY = (
    SELECT MAX(QUANTITY)
    FROM PETRESCUE
);
```

This is valid because the subquery computes `MAX(QUANTITY)` first, and then `WHERE` compares each row against that result.

---

The first query is wrong because it mixes **aggregate data** and **non-aggregate columns** without a `GROUP BY`.

```sql
SELECT EMP_ID, SALARY, AVG(SALARY) AS AVG_SALARY
FROM employees;
```

Ask yourself:

* `EMP_ID` → one value per employee
* `SALARY` → one value per employee
* `AVG(SALARY)` → one value for the entire table

Suppose the table is:

| EMP_ID | SALARY |
| ------ | ------ |
| 1      | 1000   |
| 2      | 2000   |
| 3      | 3000   |

The average salary is 2000.

What should SQL return?

| EMP_ID | SALARY | AVG_SALARY |
| ------ | ------ | ---------- |
| ?      | ?      | 2000       |

There are multiple `EMP_ID` and `SALARY` values, but only one average. SQL doesn't know which employee row to show, so most databases reject the query.

---

The second query works:

```sql
SELECT EMP_ID,
       SALARY,
       (SELECT AVG(SALARY) FROM employees) AS AVG_SALARY
FROM employees;
```

because the subquery:

```sql
(SELECT AVG(SALARY) FROM employees)
```

is executed first and returns a single value:

```sql
2000
```

Then SQL treats it like a constant:

```sql
SELECT EMP_ID,
       SALARY,
       2000 AS AVG_SALARY
FROM employees;
```

Result:

| EMP_ID | SALARY | AVG_SALARY |
| ------ | ------ | ---------- |
| 1      | 1000   | 2000       |
| 2      | 2000   | 2000       |
| 3      | 3000   | 2000       |

---

There is another valid way using a window function:

```sql
SELECT EMP_ID,
       SALARY,
       AVG(SALARY) OVER () AS AVG_SALARY
FROM employees;
```

This is the modern SQL way to show the table average alongside every row.

---

The correct answer is:

✅ **Sub-queries, Implicit joins, JOIN operators**

Why?

There are three common ways to work with multiple tables:

1. **Subqueries**

   ```sql
   SELECT *
   FROM Employees
   WHERE Dept_ID IN (
       SELECT Dept_ID FROM Departments
   );
   ```

2. **Implicit Joins**

   ```sql
   SELECT *
   FROM Employees E, Departments D
   WHERE E.Dept_ID = D.Dept_ID;
   ```

3. **JOIN Operators** (explicit joins)

   ```sql
   SELECT *
   FROM Employees E
   INNER JOIN Departments D
   ON E.Dept_ID = D.Dept_ID;
   ```

The other options are incorrect because:

* **APPEND** is not a standard SQL method for combining tables in a query.
* **Normalization** is a database design concept, not a query technique.
* **Built-in functions** are unrelated to combining multiple tables.

**Answer: Option 4 — Sub-queries, Implicit joins, JOIN operators.** ✅
