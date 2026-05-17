require('dotenv').config();
const { Pool } = require('pg');

const connStr = process.env.PG_URL || process.env.DATABASE_URL;
console.log('==============================');
console.log('PG_URL:', (process.env.PG_URL || 'NOT SET').slice(0, 40));
console.log('DATABASE_URL:', (process.env.DATABASE_URL || 'NOT SET').slice(0, 40));
console.log('==============================');

const pool = connStr
  ? new Pool({
      connectionString: connStr,
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
