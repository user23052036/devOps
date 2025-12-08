
# **Linux Command Basics – Quick Manual**

## **1. Test Network Connectivity**

```bash
ping google.com
```

Sends network packets to verify internet connection.


## **2. View Network Interfaces**

**Old command (deprecated):**

```bash
ifconfig
```

**Modern command:**

```bash
ip a
```

Shows interface names, IP addresses, MAC address, etc.


## **3. Show Current Date & Time**

```bash
date
```


## **4. Exit Terminal / Program**

```bash
exit
```


## **5. Print Working Directory**

```bash
pwd
```

Displays your current location in the filesystem.


## **6. Change Directory**

```bash
cd <directory_path>
```

Supports:

* **Absolute path**: `/home/user/Documents`
* **Relative path**: `Documents/Projects`


## **7. Create Empty File**

```bash
touch file_name
```


## **8. Move Backward in Directories**

```bash
cd ..
```

Moves one level up.

```bash
cd ../..
```

Moves two levels up.


## **9. List Files and Directories**

```bash
ls
```

List contents of any directory:

```bash
ls /path/to/directory
```

`/` at the beginning refers to the **root directory**.


## **10. ls command flags**

| Command | Description |
|--------|-------------|
| `ls -a` | show hidden files |
| `ls -l` | long listing |
| `ls -h` | human-readable sizes |
| `ls -R` | recursive |
| `ls -t` | sort by time |
| `ls -S` | sort by size |
| `ls -lah` | everything + readable sizes |


## **11. File Types in Linux**

Linux treats **everything as a file**:

* **Regular files**
* **Directories**
* **Device files** (`/dev/sda`, etc.)

Check file type:

```bash
file <name>
```


## **12. Understanding File Permissions**

Example:
`drwxr-xr-x`

| Symbol  | Meaning                               |
| ------- | ------------------------------------- |
| **d**   | Directory (regular file would be `-`) |
| **rwx** | Owner → read, write, execute          |
| **r-x** | Group → read, execute                 |
| **r-x** | Others → read, execute                |


## **13. View File Contents (No Editing)**

### **`cat` — Print Entire File**

```
cat filename
```

**Use when:**

* File is small
* You just want to see everything quickly

**Notes:**

* Prints whole file at once
* No scrolling
* Not ideal for big files

---

### **`less` — Interactive Viewer (Best for Large Files)**

```
less filename
```

**Features:**

* Scroll with ↑ ↓ PgUp PgDn
* Search with `/text`
* Next match: `n`
* Quit: `q`

**Use when:**

* File is large
* You want to navigate smoothly

---

### **`more` — Basic Pager**

```
more filename
```

**Use when:**

* You want a simple, top-to-bottom view
* Minimal navigation

**Notes:**

* Older and more limited than `less`
* Cannot scroll backwards

---

### **`head` — Show First Lines**

```
head filename
head -n 20 filename
```

**Use when:**

* You need only the start of a file
* Default shows first 10 lines

---

### **`tail` — Show Last Lines**

```
tail filename
tail -n 20 filename
```

**Use when:**

* You need only the end of a file

### Live monitoring (logs):

```
tail -f filename
```

Shows new lines as they are written.


## **14. Locate Executable**

### **which**

```bash
which python3
```

Shows the exact binary that runs when you type `python3`
(only checks `$PATH`).

### **whereis**

```bash
whereis python3
```

Shows all locations:
binary, config, libraries, man pages.


## **15. Open a Path Graphically**

```bash
open <path>
```


## **16. Terminal Emulator vs True TTY**

### Terminal Emulator

* Runs inside GUI
* Examples: Parrot Terminal, GNOME Terminal
* More comfortable

### True TTY

* TeleType Terminal
* Full-screen console without GUI
* Connected directly to kernel
* More raw and powerful


##  **17. touch file1 vs touch file1.txt**

Creates a file literally named **file1** (no extension).
Creates a file named **file1.txt** with a `.txt` extension.
Linux **does not require** extensions.
`file1` and `file1.txt` are both valid files. The OS treats them the same way—just names.
Only if **you already have a file named exactly `file1.txt`**, then:


##  **18. echo $PATH**
shows all directories your shell searches when you type a command.
It prints a list of folder paths separated by `:` that the system checks to find executables.
<br>Commands are just like executable files which the os cheaks in the path variable and if its not their or the correct path variables are not said ... it outputs command not found.

Here's the corrected and complete explanation in one clean block — accurate, concise, and easy to remember:


## **19. Redirection: `>` vs `>>`**

### **`>` — overwrite (replace the file)**

* If the file exists → **its entire content is replaced**.
* If the file doesn’t exist → **it is created**.

Examples:

* **Create/overwrite**:

  ```bash
  cat > out.txt
  ```

  Opens `out.txt` for writing (overwrite). Whatever you type replaces its content.

* **Overwrite with a string**:

  ```bash
  echo "hello" > romeo.txt
  ```

  `romeo.txt` now contains only `hello`.

* **Merge files and overwrite the result**:

  ```bash
  cat file1.txt file2.txt > total.txt
  ```

  `total.txt` gets **file1 + file2**, replacing any old content.


### **`>>` — append (add to the end)**

* If the file exists → **adds new content at the bottom**.
* If the file doesn’t exist → **it is created**.

Examples:

* Append text:

  ```bash
  echo "hello" >> notes.txt
  ```
* Append multiple files:

  ```bash
  cat file1.txt file2.txt >> total.txt
  ```

### **Extra useful variants**

* Append a separator:

  ```bash
  (cat file1.txt; echo "-----"; cat file2.txt) > total.txt
  ```

* Combine all `.txt` files:

  ```bash
  cat *.txt > all.txt
  ```

* Safe append without touching earlier content:

  ```bash
  echo "new line" >> log.txt
  ```

  ## **20. `man` command**
  manual page for the specific command.