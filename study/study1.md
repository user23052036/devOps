# Study Notes: Web Development Concepts

This document covers fundamental concepts related to Node.js development, including package management with npm, database technologies like MongoDB, and comparisons with SQL.

---

## 1. Understanding npm (Node Package Manager)

### 1.1. What is npm?
**npm is a tool that downloads and manages ready-made code for JavaScript projects.** It's the default package manager for Node.js.

### 1.2. The Problem npm Solves
Instead of writing everything from scratch (like web servers, database connections, etc.), you can use code that other developers have already written. **npm lets you reuse this code safely and easily.**

### 1.3. Real-World Analogy
Think of npm like the **Google Play Store or Apple App Store**, but for code:
- **Apps** → **Packages** (libraries)
- **Play Store** → **npm Registry** (where packages are hosted)
- **Install button** → `npm install` command

### 1.4. Core Functions of npm
- **Download libraries:** Fetches packages from the npm registry.
- **Track versions:** Manages different versions of packages to prevent issues.
- **Avoid conflicts:** Ensures that package dependencies are compatible.
- **Run scripts:** Allows you to define and run project-specific commands (e.g., `npm start`).
- **Reinstall everything:** Easily sets up a project on any machine with a single command.

### 1.5. What is a "Package"?
A **package** is a folder of JavaScript code written by someone else. Examples include:
- `express`: A popular web server framework.
- `mongodb`: The official driver for interacting with a MongoDB database.
- `react`: A library for building user interfaces.

### 1.6. The `package.json` File
This file is your project’s **shopping list**. It contains metadata about the project and lists all the packages it depends on.

**Example `package.json`:**
```json
{
  "dependencies": {
    "express": "^4.21.2",
    "mongodb": "^6.13.0"
  }
}
```
This tells npm: “My project needs Express and MongoDB.”

### 1.7. The `npm install` Command
When you run `npm install`:
1. npm reads the `dependencies` in `package.json`.
2. It downloads the required packages from the npm registry.
3. It stores them in a folder called `node_modules`.
4. It creates or updates the `package-lock.json` file to lock down the exact versions of every package installed.

**Note:** You should **never** manually edit the code inside the `node_modules` folder.

### 1.8. Why is the `node_modules` Folder So Large?
Each package often depends on other packages. npm installs these "dependencies of dependencies," which is why the folder can grow very large. This is normal.

### 1.9. npm vs. Node.js
| Tool    | Role                  |
|---------|-----------------------|
| Node.js | The JavaScript runtime (it runs the code). |
| npm     | The package manager (it gets the code).    |

npm is included with every Node.js installation.

### 1.10. Common npm Commands
```bash
# Create a new package.json file
npm init -y

# Install a package and save it to dependencies
npm install express

# Install all dependencies listed in package.json
npm install

# Run a custom script defined in package.json
npm run dev
```

### 1.11. Summary: Why Professionals Use npm
- **Consistency:** Ensures every developer on a team has the same setup.
- **Efficiency:** A single command (`npm install`) sets up the entire project.
- **Collaboration:** Makes it possible to share and reuse code across a team or the world.

> **Key takeaway:** npm is a dependency manager that lets you reuse other people’s JavaScript code instead of rewriting it.

---

## 2. Running a Node.js Project in VS Code

### 2.1. Step 1: Open the Terminal
- Press **Ctrl + `** (backtick).
- Or go to the menu: **Terminal → New Terminal**.

### 2.2. Step 2: Install Dependencies
Run this command once to install all the packages listed in `package.json`:
```bash
npm install
```

### 2.3. Step 3: Run the Server
Your main application file is `server.js`. Start it with:
```bash
node server.js
```
Or, if a "start" script is defined in `package.json`:
```bash
npm start
```
You should see a message like `Server running on port 3000`.

### 2.4. Step 4: View in Browser
Check `server.js` for the port number (e.g., `app.listen(3000)`). Open your browser and go to `http://localhost:3000`.

### 2.5. Optional: Auto-Restart with Nodemon
For a better development experience, use `nodemon` to automatically restart the server when you make code changes.
```bash
# Install nodemon as a development dependency
npm install --save-dev nodemon

# Run the server with nodemon
npx nodemon server.js
```

### 2.6. Common Problems
- **`node: command not found`**: Means Node.js is not installed. Verify with `node -v`.
- **`Port already in use`**: Change the port number in `server.js`.
- **`Nothing opens in browser`**: Make sure your server is running, you're using the correct port, and you've configured Express to serve static files if needed (e.g., `app.use(express.static("public"))`).

---

## 3. Understanding Databases: MongoDB and Mongo Express

### 3.1. MongoDB (The Database Engine)
- **What it is:** The **actual database** where your data is stored.
- **Role:** It stores, retrieves, and manages data (like users, products, etc.). It runs as a background service.
- **Without it:** Your application has no long-term memory.

### 3.2. Mongo Express (The Database UI)
- **What it is:** A **web-based user interface** to view and manage the data inside MongoDB.
- **Role:** It helps you visually inspect, create, edit, and delete data, which is useful for debugging.
- **Important:** Mongo Express **does not store any data itself**. It is just a client that talks to MongoDB.

### 3.3. Analogy: Warehouse vs. Control Panel
| Real-World      | Technology      |
|-----------------|-----------------|
| Warehouse       | **MongoDB**     |
| Control Panel   | **Mongo Express** |

You must have the warehouse (MongoDB). The control panel (Mongo Express) is a helpful but optional tool.

### 3.4. How They Interact
```
Your App  ───▶  MongoDB  ◀─── Mongo Express
                    ▲
            (Data lives here)
```
Both your application and Mongo Express connect to the same MongoDB database.

### 3.5. Key Takeaway
> **MongoDB stores your data. Mongo Express is a tool that only shows it.**

---

## 4. SQL vs. NoSQL: A Comparison

### 4.1. Core Idea
> **SQL databases (like MySQL) store data in rigid tables. MongoDB (a NoSQL database) stores data in flexible JSON-like documents.**

### 4.2. Structure: Rigid vs. Flexible
- **SQL:**
    - Data is stored in **tables** with predefined **rows and columns**.
    - The schema is **fixed**. To add a new field (e.g., a "skills" column to a user table), you must run a migration to alter the table structure (`ALTER TABLE`).
- **MongoDB:**
    - Data is stored in **collections** of **documents**, which are like JSON objects.
    - The schema is **flexible**. One document in a collection can have different fields from another. This makes it easy to evolve your data structure over time.

### 4.3. Relationships: Joins vs. Embedding
- **SQL:**
    - Data is often normalized and spread across multiple tables.
    - **JOINs** are used to combine data from different tables in a query. This is powerful but can be complex.
    - Ideal for highly structured data like financial records.
- **MongoDB:**
    - Related data can be **embedded** within a single document.
    - For example, a user document can contain an array of their skills or projects. This often eliminates the need for complex joins.
    - Great for use cases like user profiles, content management, and applications where data structures evolve rapidly.

### 4.4. Query Language
- **SQL:** Uses Structured Query Language (`SELECT * FROM users WHERE age > 20;`).
- **MongoDB:** Uses a JSON-based query language (`db.users.find({ age: { $gt: 20 } })`).

### 4.5. When to Choose Which
| Use Case                    | Better Choice |
|-----------------------------|---------------|
| Complex Transactions & Joins| SQL           |
| Rapid Prototyping           | MongoDB       |
| Flexible User Data          | MongoDB       |
| Financial Systems           | SQL           |
| Modern AI / LLM Apps        | MongoDB       |

### 4.6. Mental Model
| SQL             | MongoDB        |
|-----------------|----------------|
| Excel Sheets    | JSON Files     |
| Strict Rules    | Flexible Rules |
| Structured Data | Evolving Data  |

**Advice for this project:** Given the focus on full-stack development, LLM projects, and rapidly changing requirements, **MongoDB is a better fit than SQL.**

---

## 5. Working with Docker and MongoDB Credentials

### 5.1. Checking Credentials
- **Check MongoDB Credentials:**
  ```bash
  docker inspect mongo | grep MONGO_INITDB
  ```
- **Check Mongo Express Credentials:**
  ```bash
  docker inspect mongo-express | grep ME_CONFIG
  ```

### 5.2. Verifying the Connection
You can directly test your MongoDB credentials with this command:
```bash
docker exec -it mongo mongosh -u admin -p pass --authenticationDatabase admin
```
If you get a `>` prompt, your credentials are correct.

### 5.3. Important: The Docker Network
For containers to communicate, they must be on the same Docker network. You can inspect your network with:
```bash
docker network inspect mongo-net
```

### 5.4. Common Mistake: Frozen Credentials
If a Docker volume for MongoDB already exists, changing the environment variables in your `docker-compose.yml` or `docker run` command will have no effect. The database is initialized with credentials only the first time it starts with an empty volume. To perform a clean reset (for development only):
```bash
docker stop mongo mongo-express
docker rm mongo mongo-express
docker volume prune
```

### 5.5. Node.js Connection Strings
- **If your Node.js app is running on your host machine:**
  ```js
  mongodb://admin:pass@localhost:27017/?authSource=admin
  ```
- **If your Node.js app is running inside a Docker container (on the same network):**
  ```js
  mongodb://admin:pass@mongo:27017/?authSource=admin
  ```
  Here, `mongo` is the service name of the MongoDB container. Important: include `?authSource=admin` if you created the `root` user with `MONGO_INITDB_ROOT_USERNAME` (otherwise auth may be attempted against the DB name and fail).

---

## 6. Testing API Endpoints from the Command Line

### 6.1. Using `curl`
`curl` is a powerful command-line tool for making HTTP requests.

- **Add a user (POST request):**
  ```bash
  curl -X POST http://localhost:5050/addUser \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "name=Souvik&email=souvik@gmail.com"
  ```
- **Get all users (GET request):**
  ```bash
  curl http://localhost:5050/getUsers
  ```
- **Pretty-print JSON output (requires `jq`):**
  ```bash
  curl http://localhost:5050/getUsers | jq
  ```

### 6.2. Using `httpie` (A more user-friendly alternative)
- **Install `httpie`:**
  ```bash
  sudo apt install httpie
  ```
- **POST request:**
  ```bash
  http POST localhost:5050/addUser name=Souvik email=souvik@gmail.com
  ```
- **GET request:**
  ```bash
  http GET localhost:5050/getUsers
  ```

### 6.3. Testing Directly with the MongoDB Shell
You can bypass your API to interact with the database directly. This is useful for verifying if data was saved correctly.
```bash
# Connect to the MongoDB container
docker exec -it mongo mongosh -u root -p example --authenticationDatabase admin

# Switch to your database and query a collection
use kiit-db
db.users.find()
```