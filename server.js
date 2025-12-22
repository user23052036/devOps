// Import Express framework (used to create server and routes)
const express = require("express");

// Create an Express application
const app = express();

// Import path module (used for file paths – not used here yet)
const path = require("path");

// Import MongoDB client from mongodb package
const MongoClient = require("mongodb").MongoClient;

// Port number where server will run
const PORT = 5050;

// Middleware to read form data (from POST requests)
app.use(express.urlencoded({ extended: true }));

// Serve static files (HTML, CSS, JS) from "public" folder
// Example: public/index.html will be available at http://localhost:5050
app.use(express.static("public"));

// MongoDB connection URL
// root = username
// example = password
// localhost = MongoDB running on same machine
// 27017 = default MongoDB port

// mongo = service name in compose.yml
// Docker provides internal DNS automatically only when you define app: inside the compose.yaml

/*
  app:
    build: .
    container_name: testApp
    ports: 
     - "5050:5050"
    environment:
      MONGO_URL : mongodb://root:example@mongo:27017
    depends_on:
     - mongo
*/

const MONGO_URL = "mongodb://root:example@localhost:27017";

// Create MongoDB client object
const client = new MongoClient(MONGO_URL);



// ========================
// GET all users from DB
// ========================
app.get("/getUsers", async (req, res) => {

    // Connect to MongoDB server
    // connect() does NOT take a URL when already passed in constructor.
    await client.connect();
    console.log("Connected successfully to MongoDB");

    // Select database
    const db = client.db("kiit-db");

    // Get all documents from "users" collection
    const data = await db.collection("users").find({}).toArray();

    // Close DB connection
    await client.close();

    // Send users data as response (JSON)
    res.send(data);
});



// ========================
// POST new user to DB
// ========================
app.post("/addUser", async (req, res) => {

    // Data sent from form (or frontend)
    const userObj = req.body;
    console.log("User data received:", userObj);

    // Connect to MongoDB
    await client.connect(MONGO_URL);
    console.log("Connected successfully to MongoDB");

    // Select database
    const db = client.db("kiit-db");

    // Insert user data into "users" collection
    const result = await db.collection("users").insertOne(userObj);

    console.log("User inserted:", result.insertedId);

    // Close DB connection
    await client.close();

    // Send response to frontend
    res.send("User added successfully");
});



// ========================
// Start the server
// ========================
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
