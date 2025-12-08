
# ⭐ When you type a long command again and again

You can create a **shortcut** for it in Linux.
This shortcut is called an **alias**.

There are **two types**:

* **Temporary alias** → works only until you close terminal
* **Permanent alias** → stays forever

And there is **PATH**, which is used for running your own script files.

I’ll explain all 3 properly now.

<br>
<br>

# ✅ 1. Temporary Alias (works only for current session)

### Example

You keep typing this long command:

```
sudo apt update && sudo apt upgrade -y
```

You can create a shortcut:

```
alias up='sudo apt update && sudo apt upgrade -y'
```

Now type just:

```
up
```

This works **only until you close the terminal**.
Perfect for quick one-time shortcuts.

<br>
<br>

# ✅ 2. Permanent Alias (works forever)

To make the alias work **every time**, you need to save it in your `.bashrc` file.

### Step 1: Open `.bashrc`

```
nano ~/.bashrc
```

### Step 2: Add your alias at the bottom

```
alias up='sudo apt update && sudo apt upgrade -y'
alias ll='ls -lah'
alias gs='git status'
```

### Step 3: Reload `.bashrc`

```
source ~/.bashrc
```

Now these shortcuts will work always, even after reboot.

<br>

# ⭐ Example to understand permanently

Instead of typing:

```
python3 -m http.server 8000
```

Create a permanent alias:

```
alias serve='python3 -m http.server 8000'
```

Now:

```
serve
```

Boom.

<br>
<br>

# ✅ 3. PATH → When you want to make your own command

If you want to run your **own script** like a real Linux command:

Example: you create a file called `myscript`.

### Step 1: Create a folder for personal commands

(If it already exists, skip.)

```bash
mkdir -p ~/bin
```

### Step 2: Create your script

```bash
nano ~/bin/myscript
```

Write:

```bash
#!/bin/bash
echo "Hello Souvik!"
```

Save.

### Step 3: Make it executable

```bash
chmod +x ~/bin/myscript
```

### Step 4: Add that folder to your PATH

Add this to your `~/.bashrc`:

```bash
# prefer not to override system commands:
export PATH="$PATH:$HOME/bin"

# OR put ~/bin before system dirs if you want your scripts to override:
# export PATH="$HOME/bin:$PATH"
```

Reload it:

```bash
source ~/.bashrc
```

### Now run:

```bash
myscript
```

This makes your own custom commands work just like Linux commands.

---

# ⚠️ `~/bin` vs system `/bin` — what’s the difference (clear & short)

* `/bin`, `/usr/bin`, `/sbin` are **system directories** containing OS commands (e.g. `ls`, `bash`, `cp`).
  -> **Don’t put personal scripts here** unless you are a sysadmin and understand system-wide implications.

* `~/bin` is **your personal command folder** (`/home/youruser/bin`).
  -> **Use this** for scripts you want to run by name without sudo. Safe and per-user.

* `/usr/local/bin` is used for **system-wide tools installed by administrators** (not managed by package manager).
  -> Use this only if you want your script available to all users and you have root access.

---

# ✅ What you SHOULD do

* Create `~/bin` and put your scripts there.
* Always add `#!/bin/bash` (or other shell) at the top of scripts (the shebang).
* `chmod +x script` to make it executable.
* Keep `~/bin` in your PATH (via `.bashrc`).
* Use descriptive names and avoid overwriting system command names (e.g., don’t name your script `ls` or `cp`).
* If you want system-wide use and you’re admin, use `/usr/local/bin` (with caution).

---

# ❌ What you should NOT do

* Don’t copy personal scripts into `/bin` or `/usr/bin` (requires root and can break the system).
* Don’t name your scripts the same as common system commands unless you **intentionally** want to override them.
* Don’t put secret credentials inside scripts.
* Don’t forget to make scripts executable (`chmod +x`) — otherwise typing the name won’t run them.
* Don’t put untrusted scripts in `~/bin` (treat anything you download as untrusted unless verified).

---

# 🧰 Helpful commands (inspect & debug)

* See current PATH:

```bash
echo "$PATH"
```

* See which file runs for a command:

```bash
which myscript
# or
command -v myscript
# or to list all matches:
type -a myscript
```

* If your script name conflicts with a system command and you want to prefer your script, either:

  * Put `export PATH="$HOME/bin:$PATH"` in `.bashrc` **(your bin first)**, OR
  * Rename your script to a unique name.

* Remove a script:

```bash
rm ~/bin/myscript
```

---

# 🧾 Quick example flow (copy/paste friendly)

```bash
mkdir -p ~/bin
cat > ~/bin/hello <<'EOF'
#!/bin/bash
echo "hello from ~/bin"
EOF
chmod +x ~/bin/hello
# add to .bashrc if not already:
echo 'export PATH="$PATH:$HOME/bin"' >> ~/.bashrc
source ~/.bashrc
hello
```
