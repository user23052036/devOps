Actually, you **do** need Docker Desktop running first.

Docker Desktop is the engine that makes containers possible on Windows. If it's not running, `docker start mysql-db` will just throw an error like:

```
error during connect: ... Is the Docker daemon running?
```

**However** — you don't have to open it manually every time. You can set Docker Desktop to **start automatically with Windows**:

Docker Desktop Settings → **General** → check **"Start Docker Desktop when you log in"**

After that, by the time you open your terminal and type `docker start mysql-db`, the engine is already running in the background. You'll never consciously think about it again — it just works like any other background service (like your antivirus or audio drivers).

So the corrected mental model is:

| | |
|---|---|
| Docker Desktop | Must be running, but can auto-start with Windows |
| `docker run ...` | One time only — creates the container |
| `docker start mysql-db` | Every session after that |

---

Yes, exactly.

Docker Desktop on Windows uses WSL2 as its backend — meaning when you run any container, Docker Desktop is secretly spinning it up inside a lightweight Linux VM that WSL2 manages. You never see it directly, it just happens under the hood.

The full chain is:

```
Your terminal (Windows)
  └── Docker Desktop
        └── WSL2 (Linux VM running silently in background)
              └── Your MySQL container
                    └── MySQL server process
```

WSL2 is necessary because **containers are a Linux-native technology**. They rely on Linux kernel features (namespaces, cgroups) that Windows simply doesn't have. So Docker Desktop ships with WSL2 as a compatibility layer — it gives containers a real Linux kernel to run on, without you having to install Linux yourself.

You can actually see this if you open WSL in your terminal:

```cmd
wsl --list --running
```

When Docker Desktop is running, you'll see something like `docker-desktop` listed as a running WSL distro. That's the VM Docker is using behind the scenes.

So you never interact with WSL2 directly — Docker Desktop manages it completely. It's just good to know it's there, because it explains *why* Docker on Windows behaves the way it does.

---