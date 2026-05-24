# Study Notes: Advanced Docker Concepts

This guide covers advanced Docker topics based on our conversation, including publishing images, mastering volumes and networking, and understanding key development workflows.

---

## 1. Publishing Images to Docker Hub

Publishing an image makes it available for others (or your servers) to use.

### 1.1. The Complete Workflow (Local to Public)

1. **Create a `Dockerfile`**: Your repository must contain a `Dockerfile` at its root. This is the blueprint for the image.

2. **Login to Docker Hub**:

    ```bash
    docker login
    ```

    Enter your Docker Hub username and password. This only needs to be done once per session.

3. **Build and Tag the Image**: The tag format `username/repo-name:version` is crucial. It tells Docker where to push the image later.

    ```bash
    # Syntax: docker build -t <dockerhub_username>/<repo_name>:<tag> .
    docker build -t nomad2036/testapp:latest .
    ```

    At this point, the image exists **only on your local machine**. Nothing has been sent to Docker Hub.

4. **Push the Image**: This is the step that uploads your image.

    ```bash
    docker push nomad2036/testapp:latest
    ```

    Docker finds the locally tagged image and uploads it to the specified repository on Docker Hub.

### 1.2. Decoding the `docker push` Output

When you push, you see output like this:

```
f48775984692: Pushed 
02db37fef94b: Pushed 
...
latest: digest: sha256:2056e50c596e...
```

- **`f4877...: Pushed`**: Each line represents an **image layer**. Docker is smart and only uploads layers that don't already exist on Docker Hub, making subsequent pushes much faster.
- **`digest: sha256:...`**: This is the **immutable, true identity** of your image. While tags like `latest` can be moved, the digest guarantees the image's content is exactly the same, every time.

### 1.3. Best Practice: Versioned Tags vs. `latest`

The `latest` tag is mutable and can be overwritten. This is risky for production because you can't be sure which version of the code you're deploying.

**Always use semantic version tags (`v1.0.0`, `v1.0.1`, etc.).**

```bash
# Tag your image with a version
docker tag nomad2036/testapp:latest nomad2036/testapp:v1.0.0

# Push the new, specific tag
docker push nomad2036/testapp:v1.0.0
```

---

## 2. Mastering Docker Volumes

Volumes solve the problem of data persistence. Containers are temporary; if a container is removed, its internal data is lost. Volumes store data on the host machine, outside the container's lifecycle.

### 2.1. Anonymous vs. Named Volumes (Crucial Distinction)

This is a common point of confusion.

- **Named Volumes (✅ You create these)**
  - **Creation**: `docker volume create my-data` or defined in `docker-compose.yml`.
  - **Name**: You give it a clear, human-readable name (e.g., `mongo_data`).
  - **Usage**: Explicitly mounted, e.g., `-v mongo_data:/data/db`.
  - **Best For**: Production, databases, any stateful data you care about. They are predictable and easy to manage.

- **Anonymous Volumes (⚠️ Docker creates these)**
  - **Creation**: Automatically created by Docker if a `VOLUME` instruction exists in an image's `Dockerfile` (like the official `mongo` and `mysql` images) and you don't explicitly mount a named volume to that path.
  - **Name**: A long, random hash (e.g., `c7a414bc58ee...`).
  - **Problem**: Hard to identify, hard to reuse, and easy to forget, leading to "dangling" volumes that consume disk space.

**Mental Model:** Anonymous volumes are Docker being helpful to prevent data loss. Named volumes are you being intentional and controlling your system.

### 2.2. Cleaning Up Volumes

1. **Exited Containers Protect Their Volumes**: `docker volume prune` only removes volumes that are not referenced by **any** container, even stopped ones. An "exited" container is not a "removed" container.

2. **The Safe Cleanup Process**:

    ```bash
    # Step 1: Remove stopped containers that you no longer need.
    # This will release their claim on any anonymous volumes.
    docker container prune
    
    # Step 2: Now, prune the unused volumes.
    # This will now correctly find and delete the dangling anonymous volumes.
    docker volume prune
    ```

### 2.3. Bind Mounts vs. Volumes

| Feature      | Bind Mount (`./code:/app`)                               | Named Volume (`my-data:/data/db`)                        |
|--------------|----------------------------------------------------------|----------------------------------------------------------|
| **What is it?**  | A direct link to a folder on your host machine.          | A directory managed by Docker on the host.               |
| **Location**   | You specify the exact path (e.g., `/home/user/code`).      | Docker controls the path (e.g., `/var/lib/docker/volumes/...`). |
| **Best For**   | **Code development**. Syncing source code for hot-reloading. | **Data persistence**. Databases, file uploads, logs.      |
| **Safety**     | Risky for data; host permissions and OS can cause issues. | Safe for data; optimized for Docker's engine.            |
| **Golden Rule**| **Use bind mounts for code. Use named volumes for data.**  |                                                          |

### 2.4. Fixing `compose.yml` for Persistent Data

**Incorrect (leads to anonymous volumes):**

```yaml
# services:
#   mongo:
#     image: mongo:latest
#     # No volume mount specified
```

**Correct (uses a named volume):**

```yaml
services:
  mongo:
    image: mongo:latest
    volumes:
      - mongo_data:/data/db # Mounts the named volume 'mongo_data' to the correct path

# Top-level 'volumes' key defines the named volume
volumes:
  mongo_data:
```

---

## 3. Understanding Docker Networking

Docker networking answers: "How do containers talk to each other and the outside world?"

### 3.1. The Main Network Types

1. **`bridge` (Default Bridge)**
    - **How it works**: An automatic, private network. Containers can communicate via their internal IP addresses.
    - **Limitation**: **No automatic DNS resolution**. You cannot use container names (e.g., `ping mongo` fails). You must use IPs, which can change.
    - **Verdict**: Avoid for multi-container applications.

2. **Custom `bridge` (✅ The Standard)**
    - **How it works**: A user-created bridge network (`docker network create my-net`).
    - **Key Feature**: **Built-in DNS service**. Containers can discover and communicate with each other using their service names (e.g., `ping mongo` works).
    - **`docker-compose`**: When you run `docker compose up`, it automatically creates a custom bridge network for your project, which is why service names work as hostnames in your connection URLs (e.g., `mongodb://mongo:27017`).

3. **`host`**
    - **How it works**: No network isolation. The container shares the host machine's network stack directly.
    - **Pros**: Maximum performance, no port mapping needed (`-p`).
    - **Cons**: Risky. Port conflicts are possible, and there's no isolation.
    - **Use Case**: Niche scenarios like low-level network monitoring tools. Not for standard applications.

4. **`none`**
    - **How it works**: Complete network isolation. The container has no network interface, no IP address, and cannot communicate with the outside world or other containers.
    - **Use Case**: For security-sensitive tasks like running a batch job or a code-signing process that needs to be sandboxed.

### 3.2. Networking Rule of Thumb

| Scenario              | Network to Use        |
|-----------------------|-----------------------|
| Multi-container App   | Custom `bridge`       |
| `docker-compose`      | (Automatic) Custom `bridge` |
| High-speed networking | `host` (with caution) |
| Secure/Offline Tasks  | `none`                |

---

## 4. Key Development Workflow Insights

### 4.1. `compose up` vs. `compose up --build`

This choice depends on what you have changed.

- **`docker compose up -d`**
  - **When to use**: You changed `compose.yml` (e.g., added a volume, changed a port, updated an environment variable).
  - **What it does**: Recreates containers if their configuration has changed but **reuses the existing images**.

- **`docker compose up --build -d`**
  - **When to use**: You changed source code or a `Dockerfile`.
  - **What it does**: **Forces a rebuild of the image** from the `Dockerfile` before starting the containers.

**The Rule:** Build when code changes. `up` when wiring changes.

### 4.2. Image vs. Runtime Configuration

A common confusion is thinking that changes to `compose.yml` should be reflected on Docker Hub.

- **Image (`Dockerfile` + source code)**: This is a static, self-contained package. It gets built and pushed to Docker Hub.
- **Runtime Configuration (`compose.yml`)**: This is a local file that tells Docker **how to run** the image—what volumes to attach, which ports to map, and what networks to use.

Changing the runtime configuration does not change the image itself. Therefore, you **do not need to rebuild or push your image** after modifying `compose.yml`. You only need to apply the new runtime configuration locally with `docker compose up -d`.
