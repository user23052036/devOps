# Study Notes: Dockerizing a Node.js Application

This document provides a step-by-step guide to creating a Dockerfile for a Node.js Express application and running it in a containerized environment with MongoDB.

---

## 1. The Dockerfile

A `Dockerfile` is a text document that contains all the commands a user could call on the command line to assemble an image.

### 1.1. Minimal Dockerfile for a Node.js App
Create a file named `Dockerfile` (no extension) in your project's root directory.

```dockerfile
# 1. Use an official Node.js runtime as a parent image
FROM node:20-alpine

# 2. Set the working directory in the container
WORKDIR /app

# 3. Copy package.json and package-lock.json
COPY package*.json ./

# 4. Install application dependencies
RUN npm install

# 5. Bundle app source
COPY . .

# 6. Expose the port the app runs on
EXPOSE 5050

# 7. Define the command to run the app
CMD ["node", "server.js"]
```

### 1.2. Explanation of Dockerfile Commands

- **`FROM node:20-alpine`**
  - Specifies the base image for the container.
  - `node:20-alpine` is a lightweight version of the Node.js 20 image, which results in a smaller and more secure final image.

- **`WORKDIR /app`**
  - Sets the working directory for subsequent commands (`RUN`, `CMD`, `COPY`, etc.).
  - If the directory doesn't exist, it will be created.

- **`COPY package*.json ./`**
  - Copies `package.json` and `package-lock.json` from the host to the container's working directory.
  - This is done as a separate step to leverage Docker's layer caching. Dependencies are only re-installed if these files change.

- **`RUN npm install`**
  - Executes the `npm install` command inside the container to install the dependencies defined in `package.json`.

- **`COPY . .`**
  - Copies the rest of the application's source code into the container's working directory.

- **`EXPOSE 5050`**
  - Informs Docker that the container listens on the specified network port at runtime.
  - This is documentation; it does not actually publish the port.

- **`CMD ["node", "server.js"]`**
  - Provides the default command to execute when the container starts.

---

## 2. Building and Running the Docker Container

### 2.1. Build the Docker Image
From your terminal, navigate to your project folder and run:
```bash
docker build -t testapp .
```
- `-t testapp`: Tags the image with the name `testapp`.
- `.`: Specifies the build context (the current directory).

### 2.2. Run the Container
To run the application container and connect it to a running MongoDB container, they must be on the same Docker network.

```bash
docker run -d \
  --name testapp \
  --network mongo-net \
  -p 5050:5050 \
  testapp
```

- **`-d`**: Detached mode (runs the container in the background).
- **`--name testapp`**: Assigns a name to the container.
- **`--network mongo-net`**: Connects the container to the `mongo-net` network.
- **`-p 5050:5050`**: Maps port `5050` on the host to port `5050` in the container.

---

## 3. Connecting to MongoDB from a Docker Container

### 3.1. The MongoDB Connection URL
When your Node.js application is running inside a Docker container, it cannot use `localhost` to connect to the MongoDB container. Instead, you must use the MongoDB container's service name.

**Update the MongoDB URL in `server.js`:**
```js
const MONGO_URL = "mongodb://root:example@mongo:27017/kiit-db?authSource=admin";
```
- **`mongo`**: This is the service name of the MongoDB container. Docker's internal DNS will resolve this name to the MongoDB container's IP address on the shared network.

### 3.2. Visualizing the Workflow
```
[Browser]
    |
    |  Sends HTTP request to http://localhost:5050
    |
[Host Machine (Port 5050)]
    |
    |  Docker forwards the request via port mapping
    |
[Node.js Container (Port 5050)]
    |
    |  App connects to MongoDB using the service name 'mongo'
    |
[MongoDB Container (Port 27017)]
```

---

## 4. Verification and Troubleshooting

### 4.1. Useful Commands
- **Check running containers:**
  ```bash
  docker ps
  ```
- **View container logs:**
  ```bash
  docker logs testapp
  ```
- **Test the API endpoint:**
  ```bash
  curl http://localhost:5050/getUsers
  ```

### 4.2. Common Mistakes to Avoid
- **Using `localhost` for the MongoDB connection** when the app is in a container.
- **Forgetting `?authSource=admin`** in the connection string if the root user was created in the `admin` database.
- **Not placing the Node.js and MongoDB containers on the same Docker network.**
- **Forgetting to map the ports** with the `-p` flag in the `docker run` command.

---

## 5. Key Learnings

- How to write a `Dockerfile` to containerize a Node.js application.
- How Docker containers communicate with each other over a shared network.
- The difference between `EXPOSE` and port publishing (`-p`).
- How to manage database connections in a containerized environment.

```