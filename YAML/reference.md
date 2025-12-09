## **1.YAML, JSON, and Markup Languages**

### 🔹 What is a markup language?

A markup language adds structure or meaning to text by using annotations or tags.
Examples: **HTML, XML, Markdown**.

Purpose: Describe how text is organized or displayed — not just store data.

---

### 🔹 Why YAML isn’t a markup language

YAML originally meant *Yet Another Markup Language*, but was renamed to **YAML Ain’t Markup Language** to emphasize that it **doesn’t describe presentation or structure — it represents data**.

YAML focuses on:

* being human-readable
* storing configuration
* representing structured data without tags

Example YAML:

```yaml
student:
  name: Souvik
  year: 3
```

---

### 🔹 What does “data-focused” mean?

YAML’s goal is to **store and exchange data**, not format text.
It’s commonly used in config files, automation pipelines, and infrastructure tools.

---

### 🔹 JSON and YAML similarity

JSON is also **data-focused**, not a markup language — it stores data using key-value pairs.

Example JSON:

```json
{
  "name": "Souvik",
  "year": 3
}
```

---

### 🔹 Core difference

| Markup Language                       | YAML / JSON                         |
| ------------------------------------- | ----------------------------------- |
| Describes text structure/presentation | Represents data                     |
| Uses tags or annotations              | Uses key:value syntax               |
| Example: HTML, XML                    | Example: config files, API payloads |

---

### ✔ Final takeaway

* **Markup languages annotate text.**
* **YAML and JSON store structured data.**
* YAML is named “YAML Ain’t Markup Language” because it purposely avoids markup behavior and focuses on clean data representation.

* Markup languages structure or format content (like HTML with tags).
**Markdown(.md)** is a lightweight markup language that uses simple symbols instead of complex tags, making text easier to write and read.


---

## **2. `UTF-8` vs `huffman` encoading**

They share a similarity but aren’t the same.

**Similarity:**
Both use *variable-length encoding* — common characters take fewer bytes, rare ones take more.

**Difference:**

* **Huffman encoding** is a compression algorithm built dynamically based on data frequency.
* **UTF-8** is a *fixed standard* for representing Unicode characters, not compression. It doesn’t change its mapping based on text frequency — its rules are predefined.

So, UTF-8 behaves “somewhat like” Huffman in idea, but its purpose and mechanism are different.

---

