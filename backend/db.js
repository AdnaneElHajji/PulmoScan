require('dotenv').config();
const { Pool } = require('pg');

console.log('[db] DATABASE_URL present:', !!process.env.DATABASE_URL);
console.log('[db] DATABASE_URL prefix:', (process.env.DATABASE_URL || '').slice(0, 20));

const pool = process.env.DATABASE_URL
  ? new Pool({
      connectionString: process.env.DATABASE_URL,
      ssl: { rejectUnauthorized: false },
    })
  : new Pool({
      host:     process.env.DB_HOST     || '127.0.0.1',
      port:     parseInt(process.env.DB_PORT || '5433'),
      database: process.env.DB_NAME     || 'PulmoScan',
      user:     process.env.DB_USER     || 'postgres',
      password: process.env.DB_PASSWORD || 'postgres',
    });

pool.on('error', (err) => console.error('Erreur PostgreSQL:', err.message));

module.exports = pool;
