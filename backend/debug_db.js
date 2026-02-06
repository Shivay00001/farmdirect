const db = require('./config/db');
const { v4: uuidv4 } = require('uuid');

async function testDB() {
    console.log("Testing DB Adapter...");
    try {
        const client = await db.getClient();
        console.log("Client acquired");

        const id = uuidv4();
        const mobile = '9999999999';

        console.log("Inserting user...");
        await client.query(
            'INSERT INTO users (id, mobile, name, role, language, status) VALUES ($1, $2, $3, $4, $5, $6) RETURNING id, role',
            [id, mobile, 'Test User', 'FARMER', 'en', 'ACTIVE']
        );
        console.log("User inserted!");

        const res = await client.query('SELECT * FROM users WHERE mobile = $1', [mobile]);
        console.log("User found:", res.rows[0]);

    } catch (e) {
        console.error("DB Test Failed:", e);
    }
}

testDB();
