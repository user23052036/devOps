# MySQL + Docker + MySQL Workbench — How It All Fits Together

---

## What Actually Happens When You Run This Command

```bash
docker run --name mysql-db \
  -e MYSQL_ROOT_PASSWORD=yourpassword \
  -p 3333:3306 \
  -d mysql:latest
```

Docker starts a **real Linux container** inside Docker Desktop (via WSL2), and inside that container, a **real MySQL server process** boots up and starts listening for connections.

This is not a fake environment. Not an emulator. Not a simulation.
You have an actual MySQL database server running on your machine.

---

## Your Full Architecture

```
Windows (your PC)
  └── Docker Desktop
        └── WSL2 Linux VM
              └── MySQL Container
                    └── MySQL Server Process (listening on port 3306)
```

And once you connect MySQL Workbench:

```
MySQL Workbench (Windows app)
  └── connects to localhost:3333
        └── Docker port forwarding
              └── MySQL inside container (port 3306)
```

---

## What Port Mapping Means

When you wrote `-p 3333:3306`, this is what it means:

```
Your Windows machine  →  port 3333
        ↓
  Docker forwards traffic
        ↓
MySQL inside container  →  port 3306
```

- **3306** is the default port MySQL always listens on *inside* the container.
- **3333** is the port you chose to expose on your Windows machine.

So any app or tool on your PC that wants to talk to MySQL connects to:

```
localhost:3333
```

Docker silently handles the routing from 3333 → 3306 internally. MySQL never knows the difference.

> You could have mapped it as `-p 3306:3306` too and it would work the same —
> using a different host port like 3333 is just to avoid conflicts if MySQL is
> also installed natively on Windows.

---

## Terminology Correction — "Docker Workbench" Does Not Exist

These are two completely separate, unrelated products:

| Product | What it is |
|---------|------------|
| **Docker** | A container runtime — it runs and manages containers |
| **MySQL Workbench** | A GUI desktop client for connecting to and managing MySQL databases |

Docker did not make MySQL Workbench. MySQL (owned by Oracle) did.

The correct relationship between the three components is:

```
Docker container
  └── MySQL Server running inside it
        └── MySQL Workbench connects to it from outside
```

MySQL Workbench doesn't care whether MySQL is inside a Docker container,
installed natively on Windows, or running on a remote server.
It just connects to whatever host and port you give it.

---

## The Right Mental Model — Client vs Server

Think of it this way:

| Role | In this setup |
|------|--------------|
| **Backend engine** (does the actual work) | MySQL Server inside the Docker container |
| **GUI client** (lets you see and interact with it) | MySQL Workbench on Windows |

This is the same pattern everywhere in software:

| Server / Engine | GUI Client |
|-----------------|------------|
| MySQL | MySQL Workbench |
| PostgreSQL | pgAdmin |
| Python interpreter | VS Code |
| Web server (nginx) | Your browser |

The client connects *to* the server. The server does the actual work.
The client is just a window into the server.

---

## Why This is NOT Like Git / GitHub

Git and GitHub are a poor analogy here. Here's why:

```
Git     = version control tool (software)
GitHub  = cloud hosting platform for Git repos
```

These are two things from the same ecosystem solving related problems.

Whereas:

```
Docker      = container runtime (how MySQL is packaged and run)
MySQL       = the actual database server (the real product)
Workbench   = a separate GUI client to interact with MySQL
```

These are three things from *different* ecosystems serving *different* roles.

A better analogy:

```
Running Python in VS Code:
  VS Code     ≈  MySQL Workbench  (the client/interface you look at)
  Python      ≈  MySQL Server     (the engine that does the work)
  pyenv/venv  ≈  Docker           (the environment manager)
```

---

## How MySQL Workbench Connects — Step by Step

1. You open **MySQL Workbench** on Windows.
2. You create a new connection with these settings:
   - **Hostname:** `localhost` or `127.0.0.1`
   - **Port:** `3333` ← the host port you mapped
   - **Username:** `root`
   - **Password:** whatever you set via `MYSQL_ROOT_PASSWORD`
3. Workbench sends a connection request to `localhost:3333`.
4. Docker intercepts it and forwards to port `3306` inside the container.
5. MySQL server inside the container responds and the connection is established.
6. Workbench now shows you all databases, tables, and lets you run SQL queries.

---

## This Is a Professional Setup

Many real developers run databases in Docker containers and connect to them
with GUI tools from outside. It gives you:

- **Isolation** — MySQL doesn't pollute your Windows installation
- **Reproducibility** — anyone can spin up the same DB with one `docker run`
- **Portability** — swap MySQL version by just changing the image tag
- **Clean teardown** — `docker stop mysql-db` and it's gone, no uninstall needed

---

## Step-by-Step Commands — Full Workflow

### STEP 1 — Start Docker Desktop

Open Docker Desktop from the Start Menu and wait until the whale icon in the
system tray stops animating. Docker must be running before any `docker` command
will work in the terminal.

---

### STEP 2 — Start the MySQL Container

Open **PowerShell** or **Command Prompt** and run:

```bash
docker run --name mysql-db \
  -e MYSQL_ROOT_PASSWORD=yourpassword \
  -p 3333:3306 \
  -d mysql:latest
```

> **On Windows CMD** (no backslash continuation), write it on one line:
> ```cmd
> docker run --name mysql-db -e MYSQL_ROOT_PASSWORD=yourpassword -p 3333:3306 -d mysql:latest
> ```

What each flag does:

| Flag | Meaning |
|------|---------|
| `--name mysql-db` | Names the container so you can refer to it by name later |
| `-e MYSQL_ROOT_PASSWORD=yourpassword` | Sets the root password inside MySQL |
| `-p 3333:3306` | Maps your machine's port 3333 → container's port 3306 |
| `-d` | Runs the container in the background (detached mode) |
| `mysql:latest` | The Docker image to use (pulls from Docker Hub if not cached) |

**Verify it's running:**

```bash
docker ps
```

You should see `mysql-db` in the list with status `Up`.

---

### STEP 3 — Connect MySQL Workbench

1. Open **MySQL Workbench**
2. Click the **+** icon next to "MySQL Connections"
3. Fill in:
   - **Connection Name:** anything (e.g. `Docker MySQL`)
   - **Hostname:** `127.0.0.1`
   - **Port:** `3333`
   - **Username:** `root`
4. Click **Store in Vault** and enter your password (`yourpassword`)
5. Click **Test Connection** → should say "Successfully made the MySQL connection"
6. Click **OK** and then double-click the connection to open it

---

### STEP 4 — Work Inside MySQL (Optional CLI Access)

If you ever want to access MySQL directly from the terminal without Workbench:

```bash
# Open a bash shell inside the container
docker exec -it mysql-db bash

# Then inside the container, run the MySQL client
mysql -u root -p
# Enter your password when prompted
```

To exit the MySQL client:
```sql
exit
```

To exit the container shell:
```bash
exit
```

---

### STEP 5 — Pausing vs Stopping (Know the Difference)

#### Pause the container (temporary — data is preserved, container still exists)

```bash
docker stop mysql-db
```

The container stops but is **not deleted**. MySQL data is still there.
Use this when you're done for the day.

#### Restart a stopped container

```bash
docker start mysql-db
```

This brings the same container back up — same data, same password, same port mapping.
You do **not** need to `docker run` again.

---

### STEP 6 — Full Teardown (Delete Everything)

Use this only when you want to completely remove the container and start fresh.

```bash
# Step 1: Stop the container first (if it's running)
docker stop mysql-db

# Step 2: Remove the container
docker rm mysql-db

# Step 3 (optional): Remove the MySQL image too
docker rmi mysql:latest
```

After `docker rm mysql-db`, **all data inside the container is gone**.
If you had databases and tables, they are deleted. (See the persistence note below.)

---

## Quick Reference — Commands Cheat Sheet

| What you want to do | Command |
|---------------------|---------|
| Start a new MySQL container | `docker run --name mysql-db -e MYSQL_ROOT_PASSWORD=yourpassword -p 3333:3306 -d mysql:latest` |
| Check if it's running | `docker ps` |
| See all containers (including stopped) | `docker ps -a` |
| Stop the container (keep data) | `docker stop mysql-db` |
| Start it again after stopping | `docker start mysql-db` |
| Open MySQL CLI inside container | `docker exec -it mysql-db mysql -u root -p` |
| Open bash inside container | `docker exec -it mysql-db bash` |
| Delete the container permanently | `docker stop mysql-db && docker rm mysql-db` |
| View container logs (debug issues) | `docker logs mysql-db` |

---

## Important — Data Persistence Warning

By default, all MySQL data lives **inside the container**. If you `docker rm` the
container, that data is gone permanently.

To persist data across container deletions, use a **volume**:

```bash
docker run --name mysql-db \
  -e MYSQL_ROOT_PASSWORD=yourpassword \
  -p 3333:3306 \
  -v mysql_data:/var/lib/mysql \
  -d mysql:latest
```

The `-v mysql_data:/var/lib/mysql` flag tells Docker to store MySQL's data files
in a named volume (`mysql_data`) on your machine. Even if you `docker rm` the
container, the data survives and you can attach the same volume to a new container.

---

## Summary

```
What's running:     A real MySQL server inside a Linux container
Where it lives:     Docker Desktop → WSL2 VM → MySQL container
How to reach it:    localhost:3333 (Docker forwards to 3306 inside)
Who connects to it: MySQL Workbench (a separate GUI client, nothing to do with Docker)
The pattern:        Server (MySQL) + Client (Workbench) — same as pgAdmin/PostgreSQL

Start fresh:        docker run --name mysql-db -e MYSQL_ROOT_PASSWORD=... -p 3333:3306 -d mysql:latest
Daily stop:         docker stop mysql-db
Daily resume:       docker start mysql-db
Nuke everything:    docker stop mysql-db && docker rm mysql-db
```

---

`docker run` = **creates** a brand new container from the image. One time only.

`docker start mysql-db` = **restarts the existing container** you already created. Every day after that.

Think of `docker run` like installing an app, and `docker start` like opening it. You don't reinstall every time you want to use it.

The guide already mentions this but I'll make it more prominent — the way it's written currently could still confuse someone skimming it. Want me to update that section so the one-time vs daily distinction is impossible to miss?