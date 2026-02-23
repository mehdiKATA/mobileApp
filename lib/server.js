const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const cors = require('cors');
const bcrypt = require('bcrypt');

const app = express();
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
app.use(bodyParser.json({ limit: '50mb' }));
app.use(bodyParser.urlencoded({ limit: '50mb', extended: true }));

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

db.getConnection((err, connection) => {
  if (err) { console.error("Error connecting to MySQL:", err); return; }
  console.log("✅ Connected to MySQL successfully");
  connection.release();
});

// ============================================
// AUTH ROUTES
// ============================================

app.post('/signup', async (req, res) => {
  try {
    const { full_name, email, phone, password } = req.body;
    if (!full_name || !email || !phone || !password)
      return res.status(400).json({ error: "All fields are required" });

    const hashedPassword = await bcrypt.hash(password, 10);
    db.query(
      `INSERT INTO users (full_name, email, phone, password, credit_score) VALUES (?, ?, ?, ?, 0)`,
      [full_name, email, phone, hashedPassword],
      (err) => {
        if (err) return res.status(400).json({ error: err.message });
        res.json({ message: "User created successfully" });
      }
    );
  } catch (error) {
    res.status(500).json({ error: "Internal server error" });
  }
});

app.post('/login', (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password)
      return res.status(400).json({ error: "Email and password are required" });

    db.query(`SELECT * FROM users WHERE email = ?`, [email], async (err, results) => {
      if (err) return res.status(500).json({ error: err.message });
      if (results.length === 0) return res.status(400).json({ error: "User not found" });

      const user = results[0];
      const match = await bcrypt.compare(password, user.password);
      if (!match) return res.status(400).json({ error: "Incorrect password" });

      res.json({
        message: "Login successful",
        user: {
          id: user.id,
          full_name: user.full_name,
          email: user.email,
          credit_score: user.credit_score
        }
      });
    });
  } catch (error) {
    res.status(500).json({ error: "Internal server error" });
  }
});

// ============================================
// CREDIT SCORE ROUTES
// ============================================

app.post('/user/credit-score/add', (req, res) => {
  const { user_id } = req.body;
  if (!user_id) return res.status(400).json({ error: "User ID is required" });

  db.query(`UPDATE users SET credit_score = credit_score + 10 WHERE id = ?`, [user_id], (err) => {
    if (err) return res.status(500).json({ error: err.message });
    db.query(`SELECT credit_score FROM users WHERE id = ?`, [user_id], (err, results) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json({ message: "Credit score updated", credit_score: results[0].credit_score });
    });
  });
});

app.get('/user/credit-score/:user_id', (req, res) => {
  db.query(`SELECT credit_score FROM users WHERE id = ?`, [req.params.user_id], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    if (results.length === 0) return res.status(404).json({ error: "User not found" });
    res.json({ credit_score: results[0].credit_score });
  });
});

// ============================================
// LOST ITEMS ROUTES
// ============================================

app.post('/api/lost-items', (req, res) => {
  try {
    const { user_id, lost_date, lost_place, description, photo } = req.body;
    if (!user_id || !lost_date || !lost_place || !description)
      return res.status(400).json({ error: "user_id, lost_date, lost_place and description are required" });

    // Step 1: Insert the lost item
    db.query(
      `INSERT INTO lost_item (user_id, lost_date, lost_place, description, photo) VALUES (?, ?, ?, ?, ?)`,
      [user_id, lost_date, lost_place, description, photo || null],
      (err, result) => {
        if (err) return res.status(500).json({ error: err.message });

        // Step 2: Update credit score and WAIT for it to finish
        db.query(
          `UPDATE users SET credit_score = credit_score + 10 WHERE id = ?`,
          [user_id],
          (scoreErr) => {
            if (scoreErr) {
              console.error("Credit score update error:", scoreErr);
              return res.status(201).json({ message: "Lost item reported successfully", id: result.insertId, credit_score: null });
            }

            // Step 3: Fetch updated score only AFTER update is confirmed done
            db.query(`SELECT credit_score FROM users WHERE id = ?`, [user_id], (fetchErr, scoreResults) => {
              if (fetchErr || !scoreResults.length) {
                return res.status(201).json({ message: "Lost item reported successfully", id: result.insertId, credit_score: null });
              }
              console.log(`✅ Lost item saved. User ${user_id} new credit score: ${scoreResults[0].credit_score}`);
              res.status(201).json({
                message: "Lost item reported successfully",
                id: result.insertId,
                credit_score: scoreResults[0].credit_score
              });
            });
          }
        );
      }
    );
  } catch (error) {
    res.status(500).json({ error: "Internal server error" });
  }
});

app.get('/api/lost-items', (req, res) => {
  db.query(
    `SELECT id, user_id, lost_date, lost_place, description, status, created_at FROM lost_item ORDER BY created_at DESC`,
    (err, results) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json(results);
    }
  );
});

app.get('/api/lost-items/user/:user_id', (req, res) => {
  db.query(
    `SELECT id, user_id, lost_date, lost_place, description, photo, status, created_at 
     FROM lost_item WHERE user_id = ? ORDER BY created_at DESC`,
    [req.params.user_id],
    (err, results) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json(results);
    }
  );
});

app.put('/api/lost-items/:id/status', (req, res) => {
  const { status } = req.body;
  const validStatuses = ['active', 'found', 'cancelled'];

  if (!validStatuses.includes(status))
    return res.status(400).json({ error: 'Invalid status' });

  db.query(
    `UPDATE lost_item SET status = ? WHERE id = ?`,
    [status, req.params.id],
    (err, result) => {
      if (err) return res.status(500).json({ error: err.message });
      if (result.affectedRows === 0) return res.status(404).json({ error: 'Item not found' });
      res.json({ message: 'Status updated successfully', status });
    }
  );
});

// ============================================
// FOUND ITEMS ROUTES
// ============================================

app.post('/api/found-items', (req, res) => {
  try {
    const { user_id, found_date, found_place, description, photo } = req.body;
    if (!user_id || !found_date || !found_place || !description || !photo)
      return res.status(400).json({ error: "All fields including photo are required" });

    // Step 1: Insert the found item
    db.query(
      `INSERT INTO found_item (user_id, found_date, found_place, description, photo) VALUES (?, ?, ?, ?, ?)`,
      [user_id, found_date, found_place, description, photo],
      (err, result) => {
        if (err) return res.status(500).json({ error: err.message });

        // Step 2: Update credit score and WAIT for it to finish
        db.query(
          `UPDATE users SET credit_score = credit_score + 10 WHERE id = ?`,
          [user_id],
          (scoreErr) => {
            if (scoreErr) {
              console.error("Credit score update error:", scoreErr);
              return res.status(201).json({ message: "Found item reported successfully", id: result.insertId, credit_score: null });
            }

            // Step 3: Fetch updated score only AFTER update is confirmed done
            db.query(`SELECT credit_score FROM users WHERE id = ?`, [user_id], (fetchErr, scoreResults) => {
              if (fetchErr || !scoreResults.length) {
                return res.status(201).json({ message: "Found item reported successfully", id: result.insertId, credit_score: null });
              }
              console.log(`✅ Found item saved. User ${user_id} new credit score: ${scoreResults[0].credit_score}`);
              res.status(201).json({
                message: "Found item reported successfully",
                id: result.insertId,
                credit_score: scoreResults[0].credit_score
              });
            });
          }
        );
      }
    );
  } catch (error) {
    res.status(500).json({ error: "Internal server error" });
  }
});

app.get('/api/found-items', (req, res) => {
  db.query(
    `SELECT id, user_id, found_date, found_place, description, created_at FROM found_item ORDER BY created_at DESC`,
    (err, results) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json(results);
    }
  );
});

app.get('/api/found-items/user/:user_id', (req, res) => {
  db.query(
    `SELECT id, user_id, found_date, found_place, description, photo, created_at 
     FROM found_item WHERE user_id = ? ORDER BY created_at DESC`,
    [req.params.user_id],
    (err, results) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json(results);
    }
  );
});

// ============================================
// STATS ROUTE
// ============================================

app.get('/api/stats/:user_id', (req, res) => {
  const userId = req.params.user_id;

  const queries = {
    totalLost: `SELECT COUNT(*) as count FROM lost_item WHERE user_id = ?`,
    totalFound: `SELECT COUNT(*) as count FROM found_item WHERE user_id = ?`,
    lostByStatus: `SELECT status, COUNT(*) as count FROM lost_item WHERE user_id = ? GROUP BY status`,
    topLostPlace: `SELECT lost_place as place, COUNT(*) as count FROM lost_item WHERE user_id = ? GROUP BY lost_place ORDER BY count DESC LIMIT 1`,
    topFoundPlace: `SELECT found_place as place, COUNT(*) as count FROM found_item WHERE user_id = ? GROUP BY found_place ORDER BY count DESC LIMIT 1`,
    lostByMonth: `SELECT DATE_FORMAT(lost_date, '%Y-%m') as month, COUNT(*) as count FROM lost_item WHERE user_id = ? GROUP BY month ORDER BY month DESC LIMIT 6`,
    foundByMonth: `SELECT DATE_FORMAT(found_date, '%Y-%m') as month, COUNT(*) as count FROM found_item WHERE user_id = ? GROUP BY month ORDER BY month DESC LIMIT 6`,
    returnedToOwner: `SELECT COUNT(*) as count FROM lost_item WHERE user_id = ? AND status = 'found'`,
  };

  const results = {};
  let completed = 0;
  const total = Object.keys(queries).length;

  for (const [key, query] of Object.entries(queries)) {
    db.query(query, [userId], (err, rows) => {
      results[key] = err ? null : rows;
      completed++;
      if (completed === total) res.json(results);
    });
  }
});

// ============================================
// HEALTH CHECK
// ============================================

app.get('/health', (req, res) => {
  res.json({ status: 'Server is running', timestamp: new Date() });
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});