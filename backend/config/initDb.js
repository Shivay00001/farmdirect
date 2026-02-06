const db = require('./db');
const fs = require('fs');
const path = require('path');

const initDB = async () => {
    console.log("Initializing Database...");

    // Schema queries adapted for SQLite (some PG types like JSONB need to be TEXT in sqlite)
    // We will use a simplified schema creation for SQLite here or read a specific sqlite schema file.
    // For now, let's create tables if they don't exist with compatible types.

    const schemaSql = `
    CREATE TABLE IF NOT EXISTS users (
      id TEXT PRIMARY KEY,
      mobile TEXT UNIQUE NOT NULL,
      email TEXT,
      name TEXT NOT NULL,
      role TEXT NOT NULL,
      status TEXT DEFAULT 'PENDING_VERIFICATION',
      language TEXT DEFAULT 'en',
      profile_photo TEXT,
      rating REAL DEFAULT 0,
      total_ratings INTEGER DEFAULT 0,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );

    CREATE TABLE IF NOT EXISTS farmer_profiles (
      id TEXT PRIMARY KEY,
      user_id TEXT,
      state TEXT,
      district TEXT,
      village TEXT,
      aadhaar_number TEXT,
      farm_size REAL,
      crops TEXT, 
      fpo_membership TEXT,
      bank_account_number TEXT,
      bank_ifsc TEXT,
      bank_holder_name TEXT,
      documents TEXT,
      verification_status TEXT DEFAULT 'PENDING',
      verification_notes TEXT,
      verified_by TEXT,
      verified_at DATETIME,
      FOREIGN KEY(user_id) REFERENCES users(id)
    );

    CREATE TABLE IF NOT EXISTS retailer_profiles (
      id TEXT PRIMARY KEY,
      user_id TEXT,
      shop_name TEXT,
      gst_number TEXT,
      shop_address TEXT,
      shop_lat REAL,
      shop_lng REAL,
      shop_photo TEXT,
      business_type TEXT,
      categories_interested TEXT,
      FOREIGN KEY(user_id) REFERENCES users(id)
    );

     CREATE TABLE IF NOT EXISTS delivery_profiles (
      id TEXT PRIMARY KEY,
      user_id TEXT,
      vehicle_type TEXT,
      vehicle_number TEXT,
      driving_license TEXT,
      documents TEXT,
      current_lat REAL,
      current_lng REAL,
      is_online INTEGER DEFAULT 0,
      total_deliveries INTEGER DEFAULT 0,
      total_distance REAL DEFAULT 0,
      FOREIGN KEY(user_id) REFERENCES users(id)
    );

    CREATE TABLE IF NOT EXISTS products (
      id TEXT PRIMARY KEY,
      farmer_id TEXT,
      name TEXT NOT NULL,
      category TEXT,
      quantity REAL NOT NULL,
      unit TEXT,
      price_per_unit REAL NOT NULL,
      min_order_qty REAL,
      harvest_date TEXT,
      quality_grade TEXT,
      is_organic INTEGER DEFAULT 0,
      images TEXT,
      description TEXT,
      status TEXT DEFAULT 'ACTIVE',
      rating REAL DEFAULT 0,
      total_orders INTEGER DEFAULT 0,
      views INTEGER DEFAULT 0,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY(farmer_id) REFERENCES users(id)
    );

    CREATE TABLE IF NOT EXISTS orders (
      id TEXT PRIMARY KEY,
      order_number TEXT UNIQUE NOT NULL,
      farmer_id TEXT,
      retailer_id TEXT,
      delivery_partner_id TEXT,
      product_id TEXT,
      quantity REAL NOT NULL,
      unit_price REAL NOT NULL,
      total_amount REAL NOT NULL,
      platform_commission REAL,
      delivery_fee REAL,
      net_amount_to_farmer REAL,
      status TEXT DEFAULT 'PENDING',
      payment_status TEXT DEFAULT 'PENDING',
      payment_method TEXT,
      pickup_address TEXT,
      delivery_address TEXT,
      pickup_lat REAL,
      pickup_lng REAL,
      delivery_lat REAL,
      delivery_lng REAL,
      distance REAL,
      estimated_delivery DATETIME,
      actual_delivery DATETIME,
      rejection_reason TEXT,
      cancellation_reason TEXT,
      delivery_instructions TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY(farmer_id) REFERENCES users(id),
      FOREIGN KEY(retailer_id) REFERENCES users(id),
      FOREIGN KEY(product_id) REFERENCES products(id)
    );
    `;

    // Execute line by line for SQLite
    const statements = schemaSql.split(';').filter(s => s.trim() !== '');

    // Helper to run sequential queries
    const runQueries = async () => {
        for (const stmt of statements) {
            await db.query(stmt);
        }
    };

    try {
        await runQueries();
        console.log("Database initialized successfully.");
    } catch (e) {
        console.error("Failed to initialize DB:", e);
    }
};

module.exports = initDB;
