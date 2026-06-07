# 🐳 Docker CLI Cheat Sheet
> **Platform:** Windows (Docker Desktop) | For daily revision — commands, explanations & real examples

---

## 📌 Table of Contents
1. [Core Concepts](#core-concepts)
2. [General Commands](#general-commands)
3. [Images](#images)
4. [Containers](#containers)
5. [Docker Hub](#docker-hub)
6. [Volumes](#volumes)
7. [Networks](#networks)
8. [Docker Compose](#docker-compose)
9. [Cleanup Commands](#cleanup-commands)
10. [Windows-Specific Tips](#windows-specific-tips)

---

## 🧠 Core Concepts

| Term | What it means |
|------|---------------|
| **Image** | A read-only blueprint/template. Think of it like a class in OOP. |
| **Container** | A running instance of an image. Like an object created from a class. |
| **Dockerfile** | A script with instructions to build a custom image. |
| **Docker Hub** | A cloud registry to store and share images (like GitHub but for Docker images). |
| **Volume** | Persistent storage that survives container restarts/deletion. |
| **Network** | A virtual network that lets containers communicate with each other. |

---

## ⚙️ General Commands

### Start the Docker daemon
```bash
docker -d
```
> Starts the background Docker daemon process. On Windows with Docker Desktop, this is handled automatically when you launch Docker Desktop.

---

### Get help
```bash
docker --help
docker <subcommand> --help
```
> Shows all available commands. You can also append `--help` to any subcommand for specific help.

**Example:**
```bash
docker run --help
docker build --help
```

---

### Display system-wide information
```bash
docker info
```
> Shows details about your Docker installation — number of containers, images, storage driver, OS, memory, etc.

**Example output (truncated):**
```
Containers: 3
 Running: 1
 Paused: 0
 Stopped: 2
Images: 12
Server Version: 24.0.5
OS/Arch: linux/amd64
```

---

### Check Docker version
```bash
docker --version
docker version
```
> `--version` gives a quick one-liner. `version` gives detailed client + server version info.

---

## 🖼️ Images

### Build an image from a Dockerfile
```bash
docker build -t <image_name> .
```
> Builds a Docker image from the `Dockerfile` in the current directory (`.`). The `-t` flag gives it a name (tag).

**Example:**
```bash
docker build -t my-fastapi-app .
```
Looks for a `Dockerfile` in the current folder and builds an image named `my-fastapi-app`.

---

### Build without cache
```bash
docker build -t <image_name> . --no-cache
```
> Forces Docker to rebuild every layer from scratch, ignoring any cached layers. Useful when dependencies change and Docker's cache is stale.

**Example:**
```bash
docker build -t my-fastapi-app . --no-cache
```

---

### Build with a specific Dockerfile
```bash
docker build -t <image_name> -f <path/to/Dockerfile> .
```

**Example:**
```bash
docker build -t my-app -f docker/Dockerfile.prod .
```

---

### List all local images
```bash
docker images
```
> Lists all images stored locally on your machine with their name, tag, ID, creation time, and size.

**Example output:**
```
REPOSITORY       TAG       IMAGE ID       CREATED        SIZE
my-fastapi-app   latest    a3f9bc12d4e1   2 hours ago    245MB
python           3.11      6a3b5c9d1e2f   3 days ago     1.02GB
```

---

### Tag an image
```bash
docker tag <source_image> <target_image>:<tag>
```
> Assigns a new name/tag to an existing image. Used before pushing to Docker Hub.

**Example:**
```bash
docker tag my-fastapi-app souvik2036/my-fastapi-app:v1
```

---

### Delete an image
```bash
docker rmi <image_name>
```
> Removes a local image. Will fail if a container (even stopped) is still using it — remove the container first.

**Example:**
```bash
docker rmi my-fastapi-app
docker rmi a3f9bc12d4e1      # using image ID
```

---

### Remove all unused images
```bash
docker image prune
```
> Removes all **dangling** images (untagged, not used by any container). Add `-a` to remove all unused images.

```bash
docker image prune -a        # removes ALL unused images (not just dangling)
```

---

### Inspect an image
```bash
docker inspect <image_name>
```
> Returns a detailed JSON object with the image's configuration — layers, environment variables, entrypoint, ports, etc.

---

## 📦 Containers

### Create and run a container (basic)
```bash
docker run <image_name>
```
> Pulls the image (if not local) and starts a container. Exits immediately if no process keeps it running.

---

### Run with a custom name
```bash
docker run --name <container_name> <image_name>
```
> Assigns a human-readable name to the container so you can reference it easily instead of using the auto-generated ID.

**Example:**
```bash
docker run --name sentiment-api my-fastapi-app
```

---

### Run and publish ports (port mapping)
```bash
docker run -p <host_port>:<container_port> <image_name>
```
> Maps a port on your Windows machine (host) to a port inside the container. This is how you access the app in your browser.

**Example:**
```bash
docker run -p 8000:8000 my-fastapi-app
```
Now visit `http://localhost:8000` in your browser to access the FastAPI app running inside the container.

---

### Run in detached (background) mode
```bash
docker run -d <image_name>
```
> Starts the container in the background and returns the container ID. Your terminal is free to use immediately.

**Example:**
```bash
docker run -d -p 8000:8000 --name sentiment-api my-fastapi-app
```

---

### Run with environment variables
```bash
docker run -e <VAR_NAME>=<value> <image_name>
```
> Passes environment variables into the container. Useful for API keys, database URLs, etc.

**Example:**
```bash
docker run -e DATABASE_URL=sqlite:///./test.db -p 8000:8000 my-fastapi-app
```

---

### Run interactively (enter the container)
```bash
docker run -it <image_name> bash
```
> `-i` = interactive, `-t` = allocate a pseudo-TTY. Together they give you a shell inside the container. Use `sh` if `bash` isn't available.

**Example:**
```bash
docker run -it python:3.11 bash
```
Drops you into a Python 3.11 container shell. Type `python` to start the interpreter.

---

### Run with a volume mounted
```bash
docker run -v <host_path>:<container_path> <image_name>
```
> Mounts a folder from your Windows machine into the container so files persist and sync in real time.

**Example (Windows path):**
```bash
docker run -v C:\Users\Souvik\project:/app my-fastapi-app
# Or using forward slashes (also works in PowerShell):
docker run -v /c/Users/Souvik/project:/app my-fastapi-app
```

---

### Start a stopped container
```bash
docker start <container_name>
```

**Example:**
```bash
docker start sentiment-api
```

---

### Stop a running container
```bash
docker stop <container_name>
```
> Sends a SIGTERM signal, gives the container 10 seconds to shut down gracefully, then forces a kill.

**Example:**
```bash
docker stop sentiment-api
```

---

### Force kill a container
```bash
docker kill <container_name>
```
> Immediately sends SIGKILL — no grace period. Use when `docker stop` hangs.

---

### Restart a container
```bash
docker restart <container_name>
```

---

### Remove a stopped container
```bash
docker rm <container_name>
```
> Deletes the container (not the image). The container must be stopped first.

```bash
docker rm -f <container_name>   # force remove even if running
```

---

### Open a shell inside a running container
```bash
docker exec -it <container_name> sh
```
> Runs a new command inside an **already running** container. Great for debugging — you can poke around the filesystem, check logs, run Python, etc.

**Example:**
```bash
docker exec -it sentiment-api sh
# Once inside:
ls /app
cat /app/main.py
python --version
```
Use `bash` instead of `sh` if the image is based on Ubuntu/Debian.

---

### Fetch and follow container logs
```bash
docker logs -f <container_name>
```
> `-f` = follow (stream logs in real time, like `tail -f`). Remove `-f` to just dump the current logs.

**Example:**
```bash
docker logs -f sentiment-api
docker logs --tail 50 sentiment-api    # last 50 lines only
```

---

### Inspect a running container
```bash
docker inspect <container_name>
```
> Returns full JSON metadata — IP address, volumes, environment variables, network config, mounts, restart policy, etc.

**Tip:** Pipe with `findstr` on Windows to filter:
```bash
docker inspect sentiment-api | findstr "IPAddress"
```

---

### List currently running containers
```bash
docker ps
```
> Shows container ID, image, command, created time, status, ports, and name.

---

### List all containers (including stopped)
```bash
docker ps --all
# or shorthand:
docker ps -a
```

---

### View resource usage stats (live)
```bash
docker container stats
```
> Live stream of CPU %, memory usage, network I/O, and disk I/O for all running containers. Like Task Manager but for containers.

```bash
docker container stats <container_name>   # for a specific container
```

---

### Copy files between container and host
```bash
docker cp <container_name>:<container_path> <host_path>
docker cp <host_path> <container_name>:<container_path>
```

**Example:**
```bash
docker cp sentiment-api:/app/output.csv C:\Users\Souvik\Desktop\
```

---

## 🌐 Docker Hub

### Login to Docker Hub
```bash
docker login -u <username>
```
> Prompts for your Docker Hub password. Stores credentials locally so future pushes/pulls don't need re-auth.

**Example:**
```bash
docker login -u souvik2036
```

---

### Logout
```bash
docker logout
```

---

### Publish (push) an image to Docker Hub
```bash
docker push <username>/<image_name>
```
> Uploads your local image to Docker Hub. The image must be tagged with your username first.

**Full workflow:**
```bash
docker build -t my-fastapi-app .
docker tag my-fastapi-app souvik2036/my-fastapi-app:v1
docker push souvik2036/my-fastapi-app:v1
```

---

### Search for an image on Docker Hub
```bash
docker search <image_name>
```

**Example:**
```bash
docker search python
docker search --filter stars=100 python    # filter by stars
```

---

### Pull an image from Docker Hub
```bash
docker pull <image_name>
docker pull <image_name>:<tag>
```
> Downloads the image locally without running it.

**Example:**
```bash
docker pull python:3.11-slim
docker pull ubuntu:22.04
```

---

## 💾 Volumes

Volumes are the preferred way to persist data generated by containers.

### Create a named volume
```bash
docker volume create <volume_name>
```

**Example:**
```bash
docker volume create my-db-data
```

---

### List all volumes
```bash
docker volume ls
```

---

### Inspect a volume
```bash
docker volume inspect <volume_name>
```
> Shows where Docker stores the data on your Windows machine (inside the Docker Desktop VM).

---

### Mount a named volume when running a container
```bash
docker run -v <volume_name>:<container_path> <image_name>
```

**Example:**
```bash
docker run -v my-db-data:/var/lib/postgresql/data postgres:15
```
The database data persists even if the container is deleted.

---

### Remove a volume
```bash
docker volume rm <volume_name>
```

### Remove all unused volumes
```bash
docker volume prune
```

---

## 🔗 Networks

### List all networks
```bash
docker network ls
```
> Docker creates three default networks: `bridge`, `host`, `none`.

---

### Create a custom network
```bash
docker network create <network_name>
```

**Example:**
```bash
docker network create my-app-network
```

---

### Connect a container to a network
```bash
docker network connect <network_name> <container_name>
```

---

### Run a container on a specific network
```bash
docker run --network <network_name> <image_name>
```

**Example — two containers talking to each other:**
```bash
docker network create app-net
docker run -d --name db --network app-net postgres:15
docker run -d --name api --network app-net -p 8000:8000 my-fastapi-app
```
Now `api` can reach `db` using the hostname `db` — no IP needed.

---

### Inspect a network
```bash
docker network inspect <network_name>
```

---

### Remove a network
```bash
docker network rm <network_name>
```

---

## 🧩 Docker Compose

Docker Compose manages multi-container applications using a `docker-compose.yml` file.

### Start all services (build if needed)
```bash
docker compose up
docker compose up -d          # detached mode
docker compose up --build     # force rebuild images
```

---

### Stop all services
```bash
docker compose down
docker compose down -v        # also removes volumes
```

---

### View logs for all services
```bash
docker compose logs -f
docker compose logs -f <service_name>
```

---

### List running services
```bash
docker compose ps
```

---

### Execute a command in a running service
```bash
docker compose exec <service_name> sh
```

---

### Example `docker-compose.yml` for a FastAPI + SQLite app
```yaml
version: "3.9"
services:
  api:
    build: .
    ports:
      - "8000:8000"
    volumes:
      - .:/app
    environment:
      - DEBUG=true
```

---

## 🧹 Cleanup Commands

These keep your Docker environment lean and save disk space.

| Command | What it removes |
|---------|-----------------|
| `docker container prune` | All stopped containers |
| `docker image prune` | Dangling (untagged) images |
| `docker image prune -a` | All unused images |
| `docker volume prune` | All unused volumes |
| `docker network prune` | All unused networks |
| `docker system prune` | Stopped containers + dangling images + unused networks |
| `docker system prune -a` | Everything unused (use with caution!) |

**Example — full cleanup:**
```bash
docker system prune -a --volumes
```
> ⚠️ This will delete all stopped containers, all unused images, all unused networks, and all unused volumes. Run only when you want a clean slate.

---

## 🪟 Windows-Specific Tips

### Use PowerShell or Windows Terminal
Docker Desktop on Windows works best with **PowerShell** or **Windows Terminal**. CMD works too, but PowerShell is more flexible.

### WSL 2 backend (recommended)
Docker Desktop uses WSL 2 (Windows Subsystem for Linux 2) as its backend. Make sure it's enabled:
```powershell
wsl --install
wsl --set-default-version 2
```

### Windows paths in volume mounts
When mounting volumes from Windows into containers, use forward slashes or escape backslashes:
```bash
# These are equivalent in PowerShell:
docker run -v C:/Users/Souvik/project:/app myimage
docker run -v //c/Users/Souvik/project:/app myimage
```

### Line ending issues (CRLF vs LF)
If your scripts fail inside Linux containers, it's likely a Windows line ending issue. Fix with:
```bash
# In your Dockerfile:
RUN apt-get install -y dos2unix && dos2unix /app/entrypoint.sh
```
Or configure Git: `git config --global core.autocrlf input`

### Check Docker Desktop is running
Before running any Docker command, make sure Docker Desktop is open and the whale icon is in the system tray. If Docker daemon isn't running:
```powershell
# This will error if Docker Desktop isn't started:
docker info
```

### Useful Docker Desktop shortcuts
- `Ctrl + ,` → Open Settings
- Check **Resources > WSL Integration** to share Docker with your WSL distros
- Enable **Kubernetes** under Settings if needed later

---

## 🔖 Quick Reference Card

```
# Images
docker build -t <name> .              # Build image
docker images                         # List images
docker rmi <name>                     # Delete image
docker pull <name>                    # Pull from Hub

# Containers
docker run --name <name> -p 8000:8000 -d <image>   # Run detached + port map
docker ps / docker ps -a              # List running / all containers
docker stop <name>                    # Stop container
docker start <name>                   # Start container
docker rm <name>                      # Delete container
docker exec -it <name> sh             # Shell into container
docker logs -f <name>                 # Follow logs
docker inspect <name>                 # Full metadata

# Docker Hub
docker login -u <username>            # Login
docker tag <img> <user>/<img>:<tag>   # Tag for push
docker push <user>/<img>:<tag>        # Push to Hub

# Cleanup
docker system prune -a                # Nuclear cleanup
docker container prune                # Remove stopped containers
docker image prune -a                 # Remove unused images
```

---

*Last updated: June 2026 | Docker Desktop for Windows*