const db = require('../config/db');

exports.getStats = async (req, res) => {
    try {
        const usersRes = await db.query('SELECT COUNT(*) as count FROM users');
        const ordersRes = await db.query('SELECT COUNT(*) as count FROM orders');
        const productsRes = await db.query('SELECT COUNT(*) as count FROM products WHERE status = \'ACTIVE\'');
        // Revenue (sum of total_amount)
        // Ensure to handle null if no orders
        const revRes = await db.query('SELECT SUM(total_amount) as total FROM orders WHERE payment_status = \'PAID\''); // Only count paid orders ideally, but for now all

        const users = parseInt(usersRes.rows[0].count);
        const orders = parseInt(ordersRes.rows[0].count);
        const products = parseInt(productsRes.rows[0].count);
        const revenue = revRes.rows[0].total || 0;

        res.json({ users, orders, products, revenue });
    } catch (e) {
        console.error(e);
        res.status(500).json({ message: 'Stats failed' });
    }
};

exports.getUsers = async (req, res) => {
    try {
        const result = await db.query('SELECT id, name, role, mobile, created_at FROM users ORDER BY created_at DESC');
        res.json(result.rows);
    } catch (e) {
        console.error(e);
        res.status(500).json({ message: 'Failed to fetch users' });
    }
};

