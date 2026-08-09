Good instinct — credentials in notebooks are one of the most common things people accidentally leak on GitHub. Here's how to handle it properly.

## Option 1: Environment Variables + `.env` file (most common approach)

**Step 1:** Install `python-dotenv`
```python
!pip install python-dotenv
```

**Step 2:** Create a file called `.env` in your project folder (NOT in the notebook):
```
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_real_password
DB_NAME=company_db
```

**Step 3:** In your notebook:
```python
import os
from dotenv import load_dotenv
import mysql.connector

load_dotenv()  # loads variables from .env into the environment

connection = mysql.connector.connect(
    host=os.getenv("DB_HOST"),
    user=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    database=os.getenv("DB_NAME")
)

print(connection)
```

**Step 4:** Add `.env` to `.gitignore` so Git never tracks it:
```
# .gitignore
.env
```

Now your notebook contains **zero real credentials** — only `os.getenv(...)` calls. You can safely push it to GitHub.

---
