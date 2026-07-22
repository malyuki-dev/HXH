const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const sqlite3 = require('sqlite3').verbose();
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3001;
const JWT_SECRET = 'aldebaran_alpha_secret_key_2026';

app.use(cors());
app.use(express.json());

// Initialize SQLite database
const dbPath = path.join(__dirname, 'database.sqlite');
const db = new sqlite3.Database(dbPath);

db.serialize(() => {
    db.run(`CREATE TABLE IF NOT EXISTS accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        email TEXT UNIQUE,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )`);
});

// Middleware to verify JWT token
const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) return res.status(401).json({ error: 'Acesso negado. Token não fornecido.' });

    jwt.verify(token, JWT_SECRET, (err, user) => {
        if (err) return res.status(403).json({ error: 'Token inválido ou expirado.' });
        req.user = user;
        next();
    });
};

// Routes
app.post('/api/register', async (req, res) => {
    const { username, password, email } = req.body;

    if (!username || !password) {
        return res.status(400).json({ error: 'Usuário e senha são obrigatórios.' });
    }

    try {
        const hashedPassword = await bcrypt.hash(password, 10);
        
        db.run(`INSERT INTO accounts (username, password, email) VALUES (?, ?, ?)`, 
            [username, hashedPassword, email], 
            function(err) {
                if (err) {
                    if (err.message.includes('UNIQUE')) {
                        return res.status(400).json({ error: 'Usuário ou e-mail já existe.' });
                    }
                    return res.status(500).json({ error: 'Erro no banco de dados.' });
                }
                res.status(201).json({ message: 'Conta criada com sucesso!', id: this.lastID });
        });
    } catch (err) {
        res.status(500).json({ error: 'Erro interno do servidor.' });
    }
});

app.post('/api/login', (req, res) => {
    const { username, password } = req.body;

    db.get(`SELECT * FROM accounts WHERE username = ?`, [username], async (err, row) => {
        if (err) return res.status(500).json({ error: 'Erro no banco de dados.' });
        if (!row) return res.status(400).json({ error: 'Usuário não encontrado.' });

        const validPassword = await bcrypt.compare(password, row.password);
        if (!validPassword) return res.status(400).json({ error: 'Senha incorreta.' });

        const token = jwt.sign({ id: row.id, username: row.username }, JWT_SECRET, { expiresIn: '24h' });
        res.json({ message: 'Login realizado com sucesso', token, username: row.username });
    });
});

app.get('/api/profile', authenticateToken, (req, res) => {
    db.get(`SELECT id, username, email, created_at FROM accounts WHERE id = ?`, [req.user.id], (err, row) => {
        if (err || !row) return res.status(404).json({ error: 'Conta não encontrada.' });
        res.json(row);
    });
});

// Mock telemetry stats
app.get('/api/stats', (req, res) => {
    res.json({
        activePlayers: Math.floor(Math.random() * 50) + 10,
        serverStatus: 'Online',
        uptime: '24h 12m'
    });
});

app.listen(PORT, () => {
    console.log(`🚀 Aldebaran API Server running on http://localhost:${PORT}`);
});
