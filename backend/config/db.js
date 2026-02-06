const { Pool } = require('pg');
const sqlite3 = require('sqlite3').verbose();
const fs = require('fs');
const path = require('path');
require('dotenv').config();

// Config
const IS_PRODUCTION = process.env.NODE_ENV === 'production';
const USE_SQLITE = process.env.DB_TYPE === 'sqlite' || !IS_PRODUCTION; // Default to sqlite for dev

let dbClient;

if (USE_SQLITE) {
  const dbPath = path.resolve(__dirname, '../farmdirect_v2.sqlite');
  console.log(`Using SQLite database at ${dbPath}`);

  dbClient = new sqlite3.Database(dbPath, (err) => {
    if (err) console.error('SQLite connection error:', err.message);
    else console.log('Connected to SQLite database.');
  });
} else {
  // Postgres Pool
  dbClient = new Pool({
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DB_NAME,
    password: process.env.DB_PASSWORD,
    port: process.env.DB_PORT || 5432,
  });
}

// Unified Query Interface
const query = (text, params = []) => {
  return new Promise((resolve, reject) => {
    if (USE_SQLITE) {
      // Convert PG parameterized query ($1, $2) to SQLite (?, ?)
      let sqliteText = text;
      // Strip RETURNING clause for SQLite compatibility
      sqliteText = sqliteText.replace(/RETURNING\s+.*$/i, '');

      let paramIndex = 1;
      // Robust replacement: match $ followed by digits, ensure we replace robustly
      // Assuming params are in order of appearance which they are in our queries.
      sqliteText = sqliteText.replace(/\$\d+/g, '?');

      // Basic detection for SELECT vs INSERT/UPDATE
      const isSelect = /^\s*SELECT/i.test(sqliteText);
      const isInsert = /^\s*INSERT/i.test(sqliteText) && sqliteText.includes('RETURNING');

      // SQLite doesn't support RETURNING in older versions, but widely supported now. 
      // NOTE: node-sqlite3 exec doesn't return rows for insert easily with returning.
      // We will handle basic queries. Complex RETURNING clauses might fallback to separate SELECT.

      dbClient.all(sqliteText, params, function (err, rows) {
        if (err) return reject(err);

        // Emulate PG Result Structure
        resolve({
          rows: rows,
          rowCount: this.changes, // only for update/insert
          // Insert ID if needed: this.lastID
        });
      });
    } else {
      // Postgres
      dbClient.query(text, params)
        .then(res => resolve(res))
        .catch(err => reject(err));
    }
  });
};

// Transaction wrapper (Simplified)
const getClient = async () => {
  if (USE_SQLITE) {
    // SQLite didn't support concurrent connections in this simple driver mode broadly
    // We mock the client release for logic compatibility
    return {
      query: query,
      release: () => { },
    };
  } else {
    return await dbClient.connect();
  }
};

module.exports = {
  query,
  pool: USE_SQLITE ? null : dbClient,
  getClient
};
