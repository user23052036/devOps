Yes. For SQL interviews, **nested queries (subqueries)** are worth practicing because questions like *second highest salary*, *employees earning more than average*, *highest salary in each department*, etc. are very common.

I'll use this table throughout:

### `employees`

| emp_id | name   | salary | department |
| -----: | ------ | -----: | ---------- |
|      1 | Amit   |  50000 | IT         |
|      2 | Rahul  |  70000 | IT         |
|      3 | Priya  |  90000 | IT         |
|      4 | Souvik |  60000 | HR         |
|      5 | Neha   |  80000 | HR         |
|      6 | Ankit  |  45000 | HR         |
|      7 | Riya   |  95000 | Finance    |
|      8 | Karan  |  75000 | Finance    |

---

# 1. Second highest salary overall

```sql
SELECT MAX(salary)
FROM employees
WHERE salary < (
    SELECT MAX(salary)
    FROM employees
);
```

### How it works

Inner query:

```sql
SELECT MAX(salary)
FROM employees;
```

returns:

```text
95000
```

Then the outer query asks:

> Give me the maximum salary that is less than 95000.

Result:

```text
90000
```

This is one of the most common subquery questions.

---

# 2. Second highest salary in IT

This is exactly the type of question you mentioned.

```sql
SELECT MAX(salary)
FROM employees
WHERE department = 'IT'
AND salary < (
    SELECT MAX(salary)
    FROM employees
    WHERE department = 'IT'
);
```

Inner query:

```sql
SELECT MAX(salary)
FROM employees
WHERE department = 'IT';
```

returns:

```text
90000
```

Then:

```sql
salary < 90000
```

leaves:

```text
50000
70000
```

and `MAX()` gives:

```text
70000
```

---

# 3. Employee who has the second highest salary

Notice the difference.

Previously we wanted the **salary**.

Now we want the **employee**.

```sql
SELECT name, salary
FROM employees
WHERE salary = (
    SELECT MAX(salary)
    FROM employees
    WHERE salary < (
        SELECT MAX(salary)
        FROM employees
    )
);
```

Result:

```text
Priya   90000
```

There are **two nested subqueries** here.

Think from inside out:

```text
        MAX(salary)
             ↓
       highest salary
             ↓
     salary < highest
             ↓
      MAX(of those)
             ↓
   second highest salary
             ↓
      find employee
```

---

# 4. Employees earning more than the average salary

Very common interview question.

```sql
SELECT name, salary
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
);
```

The subquery calculates the average:

```sql
SELECT AVG(salary)
FROM employees;
```

Then the outer query finds employees whose salary is greater than that average.

### Mental model

> First calculate the average → then filter employees using that value.

---

# 5. Employees earning less than the average salary

Same idea:

```sql
SELECT name, salary
FROM employees
WHERE salary < (
    SELECT AVG(salary)
    FROM employees
);
```

---

# 6. Employee with the highest salary

```sql
SELECT name, salary
FROM employees
WHERE salary = (
    SELECT MAX(salary)
    FROM employees
);
```

Result:

```text
Riya    95000
```

---

# 7. Employees having the highest salary in IT

```sql
SELECT name, salary
FROM employees
WHERE department = 'IT'
AND salary = (
    SELECT MAX(salary)
    FROM employees
    WHERE department = 'IT'
);
```

Result:

```text
Priya    90000
```

This pattern is extremely important:

```sql
WHERE column = (
    SELECT aggregate_function(column)
    FROM table
    WHERE condition
)
```

---

# 8. Highest salary in each department

This is a **more difficult** question.

> Find the highest-paid employee from every department.

A correlated subquery is useful here:

```sql
SELECT name, department, salary
FROM employees e
WHERE salary = (
    SELECT MAX(salary)
    FROM employees
    WHERE department = e.department
);
```

Result:

| name  | department | salary |
| ----- | ---------- | -----: |
| Priya | IT         |  90000 |
| Neha  | HR         |  80000 |
| Riya  | Finance    |  95000 |

### The important part

```sql
WHERE department = e.department
```

The inner query depends on the **current row of the outer query**.

For example, when the outer query is processing:

```text
Amit | IT | 50000
```

the inner query effectively becomes:

```sql
SELECT MAX(salary)
FROM employees
WHERE department = 'IT';
```

Then when processing an HR employee, it becomes:

```sql
SELECT MAX(salary)
FROM employees
WHERE department = 'HR';
```

This is called a **correlated subquery**.

---

# 9. Second highest salary in each department

This is a very good interview-level question.

```sql
SELECT name, department, salary
FROM employees e
WHERE salary = (
    SELECT MAX(salary)
    FROM employees
    WHERE department = e.department
      AND salary < (
          SELECT MAX(salary)
          FROM employees
          WHERE department = e.department
      )
);
```

For our data:

| name   | department | salary |
| ------ | ---------- | -----: |
| Rahul  | IT         |  70000 |
| Souvik | HR         |  60000 |
| Karan  | Finance    |  75000 |

### Think about IT

IT salaries:

```text
90000
70000
50000
```

Highest:

```text
90000
```

Then:

```text
salary < 90000
```

Remaining:

```text
70000
50000
```

Maximum:

```text
70000
```

So Rahul is selected.

---

# 10. Employees working in the department with the highest average salary

This is a little harder.

First calculate average salary for every department:

```sql
SELECT department, AVG(salary)
FROM employees
GROUP BY department;
```

Then find the department with the highest average.

One way:

```sql
SELECT department, AVG(salary) AS avg_salary
FROM employees
GROUP BY department
HAVING AVG(salary) = (
    SELECT MAX(avg_salary)
    FROM (
        SELECT AVG(salary) AS avg_salary
        FROM employees
        GROUP BY department
    ) AS dept_avg
);
```

Notice something important here:

```sql
FROM (
    SELECT AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department
) AS dept_avg
```

A **subquery inside `FROM`** creates a temporary result set that the outer query can treat almost like a table.

---

# 11. Find employees who earn more than their department's average

Another **very important correlated subquery** question.

```sql
SELECT name, department, salary
FROM employees e
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
    WHERE department = e.department
);
```

For each employee, the subquery calculates the average salary of **that employee's department**.

For example, for an IT employee:

```sql
SELECT AVG(salary)
FROM employees
WHERE department = 'IT';
```

Then the outer query checks:

```text
employee salary > IT average?
```

---

# 12. Find departments having at least one employee earning above 90000

```sql
SELECT department
FROM employees
WHERE salary > 90000;
```

But if you specifically want to practice a subquery:

```sql
SELECT department
FROM employees
WHERE department IN (
    SELECT department
    FROM employees
    WHERE salary > 90000
);
```

The inner query returns:

```text
Finance
```

Then the outer query finds employees belonging to those departments.

---

# 13. Find employees who belong to the IT or HR departments

Using a subquery:

```sql
SELECT name, department
FROM employees
WHERE department IN (
    SELECT department
    FROM employees
    WHERE department IN ('IT', 'HR')
);
```

This particular example is somewhat artificial because we're querying the same table. In a real database, you'd normally have a separate `departments` table.

---

# 14. Find employees whose salary is greater than every HR employee

This is where `ALL` becomes useful.

```sql
SELECT name, salary
FROM employees
WHERE salary > ALL (
    SELECT salary
    FROM employees
    WHERE department = 'HR'
);
```

HR salaries:

```text
60000
80000
45000
```

So the employee must earn more than:

```text
60000 AND 80000 AND 45000
```

Effectively, more than the **maximum HR salary**.

Result:

```text
Priya   90000
Riya    95000
```

---

# 15. Find employees whose salary is greater than at least one HR employee

Use `ANY`:

```sql
SELECT name, salary
FROM employees
WHERE salary > ANY (
    SELECT salary
    FROM employees
    WHERE department = 'HR'
);
```

This means:

> Salary should be greater than **at least one** HR salary.

Since the smallest HR salary is `45000`, almost everyone earning above `45000` qualifies.

---

# The 7 subquery patterns I would practice for interviews

Don't randomly memorize queries. Master these patterns:

### Level 1 — Basic

**1. Highest salary**

```sql
WHERE salary = (SELECT MAX(salary) ...)
```

**2. Second highest salary**

```sql
WHERE salary < (SELECT MAX(salary) ...)
```

**3. Above average salary**

```sql
WHERE salary > (SELECT AVG(salary) ...)
```

---

### Level 2 — Department-based

**4. Highest salary in each department**

```sql
WHERE salary = (
    SELECT MAX(salary)
    FROM employees
    WHERE department = e.department
)
```

**5. Employees earning above department average**

```sql
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
    WHERE department = e.department
)
```

---

### Level 3 — Advanced

**6. Second highest salary in each department**

Nested + correlated subquery.

**7. `IN`, `ANY`, `ALL`**

These test whether you understand how a subquery returning **multiple rows** is handled.

---

## One crucial distinction for interviews

There are three places you'll commonly see a subquery:

### Subquery in `WHERE`

```sql
SELECT *
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
);
```

Used mainly for **filtering**.

### Subquery in `FROM`

```sql
SELECT *
FROM (
    SELECT department, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department
) AS x;
```

Used when you want to treat the subquery's result as a **temporary table**.

### Subquery in `SELECT`

```sql
SELECT 
    name,
    salary,
    (SELECT AVG(salary) FROM employees) AS company_avg
FROM employees;
```

Used when you want to **calculate a value and display it as a column**.

For an SDET/automation interview, I would especially drill **second highest salary, Nth highest salary, highest/second-highest per department, above-average salary, correlated subqueries, `IN`, `EXISTS`, `ANY`, and `ALL`**. These are much more useful than memorizing obscure JOIN variations.
