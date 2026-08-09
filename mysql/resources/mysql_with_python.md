# MySQL with Python — Complete Notes
### Python DB-API · Connection & Cursor Objects · Jupyter Magic Commands · SQL Magic

---

## Table of Contents

1. [Why Python DB-API Matters](#1-why-python-db-api-matters)
2. [The Big Picture — How Python Talks to MySQL](#2-the-big-picture--how-python-talks-to-mysql)
3. [Connection Objects](#3-connection-objects)
4. [Cursor Objects](#4-cursor-objects)
5. [The Full DB-API Workflow (Step by Step)](#5-the-full-db-api-workflow-step-by-step)
6. [Practical CRUD Examples with MySQL](#6-practical-crud-examples-with-mysql)
7. [Transactions — commit() and rollback()](#7-transactions--commit-and-rollback)
8. [Error Handling & Best Practices](#8-error-handling--best-practices)
9. [Jupyter Notebook Magic Commands](#9-jupyter-notebook-magic-commands)
10. [SQL Magic (ipython-sql) — Running SQL Directly in Jupyter](#10-sql-magic-ipython-sql--running-sql-directly-in-jupyter)
11. [Putting It All Together — Mini Walkthrough](#11-putting-it-all-together--mini-walkthrough)
12. [Quick Reference Cheat Sheet](#12-quick-reference-cheat-sheet)
13. [Common Errors & Fixes](#13-common-errors--fixes)

---

## 1. Why Python DB-API Matters

Python doesn't talk to MySQL "directly" — it talks through a **standard interface** called the **Python DB-API** (defined in PEP 249).

**Why this matters to you:**
- Every database driver (MySQL, SQLite, PostgreSQL, Oracle, etc.) follows the **same set of rules**.
- The objects and methods you learn here (`connect()`, `.cursor()`, `.execute()`, `.fetchall()`...) work **almost identically** whether you're using:
  - `mysql.connector` (MySQL)
  - `pymysql` (MySQL, pure Python alternative)
  - `sqlite3` (SQLite, built into Python)
  - `psycopg2` (PostgreSQL)

You're very close, but the key idea is slightly different.

**DB-API is NOT a separate API that connects Python to databases.**

Think of it as a **rulebook or standard** that database driver developers agree to follow.

### Without DB-API

Imagine every database library had its own syntax:

```python
# MySQL
db.open()
db.run_query()

# PostgreSQL
database.connect_db()
database.execute_sql()

# Oracle
oracle.start()
oracle.query()
```

You would have to learn a completely different interface for every database.

---

### With DB-API

Python says:

> "If you create a database driver, provide methods like `connect()`, `cursor()`, `execute()`, `fetchone()`, `fetchall()`."

So most database drivers expose very similar methods:

```python
# MySQL
import mysql.connector

conn = mysql.connector.connect(...)
cur = conn.cursor()
cur.execute("SELECT * FROM employee")
rows = cur.fetchall()
```

```python
# PostgreSQL
import psycopg2

conn = psycopg2.connect(...)
cur = conn.cursor()
cur.execute("SELECT * FROM employee")
rows = cur.fetchall()
```

```python
# SQLite
import sqlite3

conn = sqlite3.connect(...)
cur = conn.cursor()
cur.execute("SELECT * FROM employee")
rows = cur.fetchall()
```

Notice that only the library name changes. The workflow remains almost identical.

---

## Bigger Picture

There are actually **three layers**:

```
Python Application
        |
        v
Database Driver
(mysql.connector, psycopg2, sqlite3)
        |
        v
Database Server
(MySQL, PostgreSQL, SQLite, Oracle)
```

Example:

```
Your Python Code
        |
        v
mysql.connector
        |
        v
MySQL Database
```

or

```
Your Python Code
        |
        v
psycopg2
        |
        v
PostgreSQL Database
```

The **driver** does the actual communication with the database.

The **DB-API** only defines how that driver should look from Python's perspective.

---

### Analogy

Think of:

* **Database** = Different car brands (Toyota, Honda, BMW)
* **Driver library** = Specific car model
* **DB-API** = Standardized steering wheel, brake, accelerator layout

Because the controls are standardized, you can drive different cars without relearning everything.

Similarly, because drivers follow DB-API, you can switch databases with minimal code changes.

---

### One correction to your statement

> "db-api is an api connecting different databases like oracle, ibm, mysql, nosql with python using similar commands"

More accurate:

> **DB-API is a Python standard (PEP 249) that database driver libraries implement, allowing Python code to interact with many relational databases using a common set of methods such as `connect()`, `cursor()`, `execute()`, and `fetchall()`.**

Also note that **NoSQL databases generally do not follow DB-API**. MongoDB, Redis, Cassandra, etc. usually have their own Python libraries and APIs.

So DB-API is mainly associated with **SQL/relational databases** such as:

* MySQL
* PostgreSQL
* Oracle Database
* SQLite
* IBM Db2

A good interview answer is:

> "Python DB-API (PEP 249) is a specification that standardizes how Python database drivers expose connections, cursors, query execution, and result fetching. It allows developers to work with different relational databases using nearly the same programming interface."


---

## 2. The Big Picture — How Python Talks to MySQL

There are **two core objects** you must understand:

| Object | Role |
|---|---|
| **Connection Object** | The "phone line" between your Python program and the MySQL server |
| **Cursor Object** | The "messenger" that carries your SQL commands to the database and brings results back |

### Diagram: Overall Architecture

```
 ┌─────────────────────┐        ┌─────────────────────┐        ┌─────────────────────┐
 │                      │        │                      │        │                      │
 │   Your Python App    │ -----> │   Connection Object   │ -----> │   MySQL Server       │
 │   (script/notebook)  │        │  (manages session,    │        │   (the database)     │
 │                      │        │   commit/rollback)    │        │                      │
 └─────────────────────┘        └─────────────────────┘        └─────────────────────┘
            │                               │
            │                               │
            ▼                               ▼
   connection.cursor()  ------>  ┌─────────────────────┐
                                  │     Cursor Object     │
                                  │  (run queries, fetch  │
                                  │      results)         │
                                  └─────────────────────┘
```

**Mental model:**
- You **open a Connection** to "log in" to the database.
- From that Connection, you create one or more **Cursors** — each Cursor is like a separate "workspace" for sending queries and reading results.
- When you're done, you **close the Cursor**, then **close the Connection**.

---

## 3. Connection Objects

### 3.1 What it does

A **Connection Object** represents your active session with the MySQL server. It is responsible for:
- Establishing the **database connection** (host, username, password, database name).
- **Managing transactions** — deciding whether changes (INSERT/UPDATE/DELETE) are permanently saved (`commit`) or undone (`rollback`).

### 3.2 Connection Methods

| Method | Purpose |
|---|---|
| `.cursor()` | Creates and returns a new **Cursor object**, used to run queries |
| `.commit()` | Permanently saves all changes made since the last commit |
| `.rollback()` | Undoes/cancels all changes made since the last commit |
| `.close()` | Closes the connection and frees the resources it was using |

### 3.3 Creating a Connection (MySQL Example)

```python
import mysql.connector

connection = mysql.connector.connect(
    host="localhost",       # or "127.0.0.1", or your Docker container's host
    user="root",            # MySQL username
    password="your_password",
    database="company_db"   # name of the database/schema
)

print(connection)   # Confirms the connection object was created
```

> **Tip:** If you're running MySQL inside Docker, `host` is usually `"localhost"` (if the port is mapped to your machine) or the container name (if connecting from another container on the same Docker network).

---

## 4. Cursor Objects

### 4.1 What is a Database Cursor?

Think of the **Cursor** as a **remote control** that sits between your application and the database. Your application never talks to the database table directly — it sends instructions *through* the cursor, and the cursor brings results back.

### Diagram: Cursor as the Middleman

```
 ┌─────────────────────┐        ┌─────────────────────┐        ┌─────────────────────┐
 │                      │        │                      │        │                      │
 │     Your             │        │       Cursor          │        │                      │
 │     Application       │ <----> │   .execute()          │ <----> │      Database         │
 │                      │        │   .fetchall()         │        │   (tables, rows)      │
 │                      │        │   .close()            │        │                      │
 └─────────────────────┘        └─────────────────────┘        └─────────────────────┘
```

**Step-by-step flow:**
1. Your app calls `cursor.execute("SELECT ...")` → request goes **to** the database.
2. MySQL runs the query and prepares a **result set**.
3. Your app calls `cursor.fetchall()` (or `fetchone()` / `fetchmany()`) → results come **back** through the cursor.
4. Your app calls `cursor.close()` when done.

### 4.2 Cursor Methods

| Method | Purpose |
|---|---|
| `.callproc(name, args)` | Calls a **stored procedure** stored in the database |
| `.execute(query, params)` | Executes a **single** SQL statement |
| `.executemany(query, seq_of_params)` | Executes the **same** SQL statement repeatedly with different parameter sets (great for bulk inserts) |
| `.fetchone()` | Returns the **next single row** from the result set (or `None` if no more rows) |
| `.fetchmany(size)` | Returns the **next `size` rows** as a list |
| `.fetchall()` | Returns **all remaining rows** as a list |
| `.nextset()` | Moves to the **next result set**, if the operation produced multiple |
| `.arraysize` | An attribute (default `1`) that controls how many rows `.fetchmany()` returns by default |
| `.close()` | Closes the cursor and frees its resources |


only `fetchall()` and `fetchmany()` return a **list of tuples**. `fetchone()` returns just a **single tuple** (or `None`), not wrapped in a list.

| Method | Returns |
|---|---|
| `fetchone()` | `(533,)` — one tuple |
| `fetchmany(n)` | `[(533,), (...)]` — list of tuples |
| `fetchall()` | `[(533,), (...)]` — list of tuples |
| `for row in cursor:` | each `row` is one tuple, one at a time |

So: **each row is always a tuple** — but it's only wrapped in a **list** when you fetch multiple rows at once (`fetchall`/`fetchmany`).

### 4.3 Creating a Cursor

```python
cursor = connection.cursor()
```

---

## 5. The Full DB-API Workflow (Step by Step)

Every program that talks to MySQL using the DB-API follows the **same 5 steps**:

```
 Step 1: Import the driver
 Step 2: Create a Connection object
 Step 3: Create a Cursor object from the connection
 Step 4: Use the cursor to execute() queries and fetch() results
 Step 5: Close the cursor, then close the connection
```

### 5.1 Complete Working Example

```python
import mysql.connector

# ---------------------------------------------------
# Step 1 & 2: Create the connection object
# ---------------------------------------------------
connection = mysql.connector.connect(
    host="localhost",
    user="root",
    password="your_password",
    database="company_db"
)

# ---------------------------------------------------
# Step 3: Create a cursor object
# ---------------------------------------------------
cursor = connection.cursor()

# ---------------------------------------------------
# Step 4: Run a query and fetch results
# ---------------------------------------------------
cursor.execute("SELECT * FROM employees")
results = cursor.fetchall()

for row in results:
    print(row)

# ---------------------------------------------------
# Step 5: Free resources
# ---------------------------------------------------
cursor.close()
connection.close()
```

**Output (example):**
```
(1, 'Alice', 'HR', 55000)
(2, 'Bob', 'Engineering', 72000)
(3, 'Carol', 'Marketing', 60000)
```

---

## 6. Practical CRUD Examples with MySQL

CRUD = **C**reate, **R**ead, **U**pdate, **D**elete. Below are examples for each, using `employees` table:

```sql
CREATE TABLE employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50),
    department VARCHAR(50),
    salary INT
);
```

### 6.1 Insert a Single Row

```python
cursor.execute(
    "INSERT INTO employees (name, department, salary) VALUES (%s, %s, %s)",
    ("David", "Sales", 50000)
)
connection.commit()   # don't forget to commit after writes!

print("Rows inserted:", cursor.rowcount)
```

> **Important:** `%s` is used as the placeholder for **all** data types in `mysql.connector` (even numbers/dates) — not just strings. This is the **parameterized query** style and protects against SQL injection.

### 6.2 Insert Multiple Rows — `.executemany()`

```python
employees_data = [
    ("Eve", "Finance", 65000),
    ("Frank", "IT", 70000),
    ("Grace", "Legal", 80000)
]

cursor.executemany(
    "INSERT INTO employees (name, department, salary) VALUES (%s, %s, %s)",
    employees_data
)
connection.commit()

print("Rows inserted:", cursor.rowcount)
```

### 6.3 Read Data — `fetchone()`, `fetchmany()`, `fetchall()`

```python
cursor.execute("SELECT * FROM employees")

# Get just the first row
first_row = cursor.fetchone()
print("First row:", first_row)

# Get the next 2 rows
next_two = cursor.fetchmany(2)
print("Next two rows:", next_two)

# Get everything that's left
remaining = cursor.fetchall()
print("Remaining rows:", remaining)
```

**How fetch methods relate:**

```
 cursor.execute("SELECT ...")
        │
        ▼
 ┌───────────────────────────────────────────────┐
 │  Result Set (held by MySQL server / cursor)     │
 │  Row 1 | Row 2 | Row 3 | Row 4 | Row 5 | ...     │
 └───────────────────────────────────────────────┘
        │
        ├── fetchone()   → returns Row 1, moves pointer to Row 2
        ├── fetchmany(2) → returns Row 2, Row 3, moves pointer to Row 4
        └── fetchall()   → returns Row 4, Row 5, ... (everything left)
```

### 6.4 Update Data

```python
cursor.execute(
    "UPDATE employees SET salary = %s WHERE name = %s",
    (75000, "Frank")
)
connection.commit()

print("Rows affected:", cursor.rowcount)
```

### 6.5 Delete Data

```python
cursor.execute(
    "DELETE FROM employees WHERE name = %s",
    ("Eve",)
)
connection.commit()

print("Rows deleted:", cursor.rowcount)
```

> **Note:** Notice the trailing comma in `("Eve",)` — this makes it a **tuple** with one element. Without the comma, Python treats `("Eve")` as just a string, which causes errors.

---

## 7. Transactions — commit() and rollback()

MySQL changes (INSERT/UPDATE/DELETE) made through a Python connection are **not permanent** until you call `connection.commit()`. If something goes wrong, you can call `connection.rollback()` to undo everything since the last commit.

### Diagram: Transaction Lifecycle

```
 BEGIN  ──>  execute()  ──>  execute()  ──>  execute()
                                                 │
                          ┌──────────────────────┴───────────────────────┐
                          │                                                │
                  Everything OK?                                  Something went wrong?
                          │                                                │
                          ▼                                                ▼
                  connection.commit()                          connection.rollback()
              (changes saved permanently)                    (all changes undone)
```

### Example: Safe Transaction with Rollback

```python
try:
    cursor.execute(
        "UPDATE employees SET salary = salary - 5000 WHERE name = %s",
        ("Alice",)
    )
    cursor.execute(
        "UPDATE employees SET salary = salary + 5000 WHERE name = %s",
        ("Bob",)
    )
    connection.commit()
    print("Transaction successful — changes saved.")

except Exception as e:
    connection.rollback()
    print("Something went wrong — changes undone:", e)
```

---

## 8. Error Handling & Best Practices

### 8.1 Always Use try / except / finally

```python
import mysql.connector

try:
    connection = mysql.connector.connect(
        host="localhost",
        user="root",
        password="your_password",
        database="company_db"
    )
    cursor = connection.cursor()
    cursor.execute("SELECT * FROM employees")
    print(cursor.fetchall())

except mysql.connector.Error as err:
    print("Database error:", err)

finally:
    # This block always runs, even if an error occurred
    if 'cursor' in locals():
        cursor.close()
    if 'connection' in locals() and connection.is_connected():
        connection.close()
```

### 8.2 Best Practice Checklist

| Practice | Why |
|---|---|
| Use `%s` placeholders, never f-strings, for query values | Prevents **SQL injection** attacks |
| Call `.commit()` after INSERT/UPDATE/DELETE | Without it, changes may not be saved |
| Always `.close()` cursors and connections | Frees up server resources and connection slots |
| Wrap database code in `try/except` | Handles connection drops, bad queries gracefully |
| Use `.executemany()` for bulk inserts | Much faster than looping `.execute()` one row at a time |

---

## 9. Jupyter Notebook Magic Commands

### 9.1 What Are Magic Commands?

**Magic commands** are special Jupyter Notebook commands that:
- Are **not valid Python code** on their own, but they change how the notebook behaves.
- Are designed to solve **common, everyday tasks** (checking your folder, timing code, writing files, running shell commands, etc.).

### 9.2 Types of Magics — Line vs Cell

```
 ┌──────────────────────────────┐         ┌──────────────────────────────┐
 │          Line Magics            │         │          Cell Magics            │
 │                                │         │                                │
 │   Prefixed with a SINGLE %      │         │   Prefixed with DOUBLE %%       │
 │   Affects only ONE line          │         │   Affects the ENTIRE cell       │
 └──────────────────────────────┘         └──────────────────────────────┘
```

| | Line Magic (`%`) | Cell Magic (`%%`) |
|---|---|---|
| Prefix | Single `%` | Double `%%` |
| Scope | One line of input | The whole cell (all lines below it) |
| Example | `%pwd` | `%%writefile myfile.txt` |

### 9.3 Common Line Magics

| Line Magic | Use |
|---|---|
| `%pwd` | Prints the current working directory |
| `%ls` | Lists all files in the current directory |
| `%history` | Shows the command history |
| `%reset` | Resets the namespace by removing all user-defined names |
| `%who` | Lists all variables in the namespace |
| `%whos` | Shows detailed info about all variables in the namespace |
| `%matplotlib inline` | Makes matplotlib plots appear inside the notebook |
| `%timeit` | Times the execution of a single statement |
| `%lsmagic` | Lists all available magic commands |

### 9.4 Line Magic Examples

```python
%pwd
%ls
```
*→ Both line magics run independently, even in the same cell.*

```python
%timeit sum(range(1000))
```
*→ Times how long it takes to execute `sum(range(1000))`, running it multiple times for accuracy.*

### 9.5 Cell Magic Examples

#### `%%writefile` — Write the cell's contents to a file

```python
%%writefile myfile.txt
This is line 1
This is line 2
This is line 3
```
*→ Writes all 3 lines into `myfile.txt`, instead of running them as Python code.*

#### `%%timeit` — Time the entire cell

```python
%%timeit
total = 0
for i in range(1000):
    total += i
```
*→ Times how long the **whole cell** takes to run (vs. `%timeit` which times only one line).*

#### `%%HTML` — Render HTML inside the notebook

```python
%%HTML
<h1>Hello World</h1>
```
*→ Displays "Hello World" as a rendered HTML heading instead of plain text.*

#### `%%javascript` — Run JavaScript code

```python
%%javascript
alert('Hello, World!');
```
*→ Triggers a browser pop-up alert (since notebooks run in your browser).*

#### `%%bash` — Run shell/bash commands

```python
%%bash
echo "Hello world!"
```
**Output:**
```
Hello, World!
```

---

## 10. SQL Magic (ipython-sql) — Running SQL Directly in Jupyter

`ipython-sql` is an extension that lets you write **SQL queries directly inside Jupyter cells** using `%sql` (line magic) and `%%sql` (cell magic) — no need to write `cursor.execute()` every time.

### 10.1 Step 1: Install the Extension

```python
!pip install --user ipython-sql
```
> The `!` prefix runs a shell command directly from the notebook (similar to `%%bash`, but for a single line).

### 10.2 Step 2: Load the SQL Extension

```python
%load_ext sql
```

### 10.3 Step 3: Connect to Your Database

The connection string format is:

```
%sql dialect+driver://username:password@host:port/database_name
```

**SQLite example (from slides):**
```python
import sqlite3
conn = sqlite3.connect('HR.db')

%load_ext sql
%sql sqlite:///HR.db
```

**MySQL example** (using `pymysql` as the driver):
```python
%load_ext sql
%sql mysql+pymysql://root:your_password@localhost/company_db
```
> **Note:** For MySQL connection strings, you typically need `pymysql` installed (`pip install pymysql`), since `ipython-sql` uses **SQLAlchemy** under the hood, and SQLAlchemy needs a compatible driver.

### 10.4 Step 4: Run Queries

**Line magic — single-line query:**
```python
%sql SELECT * FROM employees
```

**Cell magic — multi-line query:**
```python
%%sql
SELECT department, AVG(salary) AS avg_salary
FROM employees
GROUP BY department
ORDER BY avg_salary DESC;
```

### 10.5 Saving SQL Results into a Python Variable

```python
result = %sql SELECT * FROM employees WHERE department = 'Engineering'

# Convert to a pandas DataFrame for further analysis
df = result.DataFrame()
df
```

---

## 11. Putting It All Together — Mini Walkthrough

This section shows the **same task** done two ways: (A) the manual DB-API way, and (B) the SQL Magic shortcut.

### Goal: Create a table, insert data, and read it back

#### Method A — Pure Python DB-API

```python
import mysql.connector

connection = mysql.connector.connect(
    host="localhost", user="root", password="your_password", database="company_db"
)
cursor = connection.cursor()

# Create table
cursor.execute("""
    CREATE TABLE IF NOT EXISTS students (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(50),
        marks INT
    )
""")

# Insert data
cursor.executemany(
    "INSERT INTO students (name, marks) VALUES (%s, %s)",
    [("Alice", 85), ("Bob", 78), ("Carol", 92)]
)
connection.commit()

# Read data
cursor.execute("SELECT * FROM students")
for row in cursor.fetchall():
    print(row)

cursor.close()
connection.close()
```

#### Method B — SQL Magic in Jupyter

```python
%load_ext sql
%sql mysql+pymysql://root:your_password@localhost/company_db
```

```python
%%sql
CREATE TABLE IF NOT EXISTS students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50),
    marks INT
);

INSERT INTO students (name, marks) VALUES
('Alice', 85), ('Bob', 78), ('Carol', 92);
```

```python
%sql SELECT * FROM students
```

> **When to use which?**
> - **DB-API (Method A)** → when building applications, scripts, automation, or anything that needs error handling and logic.
> - **SQL Magic (Method B)** → when exploring/analyzing data quickly inside a Jupyter notebook.

---

## 12. Quick Reference Cheat Sheet

### Connection Object Methods
| Method | Purpose |
|---|---|
| `.cursor()` | Create a cursor |
| `.commit()` | Save changes |
| `.rollback()` | Undo changes |
| `.close()` | Close connection |

### Cursor Object Methods
| Method | Purpose |
|---|---|
| `.execute(q, params)` | Run one query |
| `.executemany(q, list)` | Run query for each item in a list |
| `.fetchone()` | Get next row |
| `.fetchmany(n)` | Get next `n` rows |
| `.fetchall()` | Get all remaining rows |
| `.callproc(name, args)` | Call a stored procedure |
| `.close()` | Close cursor |

### Jupyter Magics
| Magic | Purpose |
|---|---|
| `%pwd` | Show current directory |
| `%ls` | List files |
| `%timeit <stmt>` | Time one statement |
| `%%timeit` | Time entire cell |
| `%%writefile file.txt` | Write cell content to a file |
| `%%bash` | Run shell commands |
| `%load_ext sql` | Enable SQL magic |
| `%sql <query>` | Run one SQL line |
| `%%sql` | Run multi-line SQL |

---

## 13. Common Errors & Fixes

| Error Message | Likely Cause | Fix |
|---|---|---|
| `mysql.connector.errors.ProgrammingError: 1045 (28000): Access denied` | Wrong username/password | Double-check credentials, ensure user has privileges |
| `mysql.connector.errors.InterfaceError: 2003: Can't connect to MySQL server` | MySQL server not running, or wrong host/port | Check Docker container is running, verify `host`/`port` |
| `TypeError: not all arguments converted during string formatting` | Forgot the trailing comma in a single-value tuple, e.g. `("Eve")` instead of `("Eve",)` | Add the comma: `("Eve",)` |
| Changes not appearing in MySQL Workbench | Forgot `connection.commit()` | Call `.commit()` after INSERT/UPDATE/DELETE |
| `ModuleNotFoundError: No module named 'pymysql'` (with SQL magic) | `ipython-sql` needs a SQLAlchemy-compatible driver for MySQL | `pip install pymysql` |
| `sqlalchemy.exc.ArgumentError` on `%sql` connection string | Typo in connection string format | Format: `mysql+pymysql://user:pass@host/dbname` |

---

## Summary

- **Connection Object** = your session with MySQL (manages commit/rollback/close).
- **Cursor Object** = your tool for sending queries and fetching results.
- The **DB-API workflow** is always: *connect → cursor → execute → fetch → close*.
- **Jupyter Magic Commands** (`%` for line, `%%` for cell) give you shortcuts for everyday tasks.
- **SQL Magic** (`%sql` / `%%sql`) lets you write raw SQL directly in notebook cells — great for quick exploration, while DB-API is better for full applications.