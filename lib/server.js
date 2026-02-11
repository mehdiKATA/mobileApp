const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const cors = require('cors');
const bcrypt = require('bcrypt');

const app = express();
app.use(cors());
app.use(bodyParser.json());

// MySQL connection POOL (instead of single connection)
const db = mysql.createPool({
    host: 'localhost',
    user: 'root',
    password: 'KATTARINA2015m',
    database: 'LF',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    enableKeepAlive: true,
    keepAliveInitialDelay: 0
});

// Test the connection
db.getConnection((err, connection) => {
    if (err) {
        console.error("Error connecting to MySQL:", err);
        return;
    }
    console.log("✅ Connected to MySQL successfully");
    connection.release();
});

// Signup route
app.post('/signup', async (req, res) => {
    try {
        const { full_name, email, phone, password } = req.body;
        
        // Validate input
        if (!full_name || !email || !phone || !password) {
            return res.status(400).json({ error: "All fields are required" });
        }

        const hashedPassword = await bcrypt.hash(password, 10);
        const query = `INSERT INTO users (full_name, email, phone, password) VALUES (?, ?, ?, ?)`;
        
        db.query(query, [full_name, email, phone, hashedPassword], (err, result) => {
            if (err) {
                console.error("Signup error:", err);
                return res.status(400).json({ error: err.message });
            }
            res.json({ message: "User created successfully" });
        });
    } catch (error) {
        console.error("Signup error:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Login route
app.post('/login', (req, res) => {
    try {
        const { email, password } = req.body;
        
        if (!email || !password) {
            return res.status(400).json({ error: "Email and password are required" });
        }

        db.query(`SELECT * FROM users WHERE email = ?`, [email], async (err, results) => {
            if (err) {
                console.error("Login error:", err);
                return res.status(500).json({ error: err.message });
            }
            if (results.length === 0) {
                return res.status(400).json({ error: "User not found" });
            }

            const user = results[0];
            const match = await bcrypt.compare(password, user.password);
            if (!match) {
                return res.status(400).json({ error: "Incorrect password" });
            }

            res.json({ 
                message: "Login successful", 
                user: { id: user.id, full_name: user.full_name, email: user.email } 
            });
        });
    } catch (error) {
        console.error("Login error:", error);
        res.status(500).json({ error: "Internal server error" });
    }
});

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ status: 'Server is running', timestamp: new Date() });
});

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`🚀 Server running on http://localhost:${PORT}`);
});