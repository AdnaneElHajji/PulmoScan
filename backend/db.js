require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
  host:     '127.0.0.1',
  port:     5433,
  database: process.env.DB_NAME     || 'PulmoScan',
  user:     process.env.DB_USER     || 'postgres',
  password: process.env.DB_PASSWORD || 'postgres',
});

pool.on('error', (err) => console.error('Erreur PostgreSQL:', err.message));

module.exports = pool;
