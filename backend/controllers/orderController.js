const db = require('../config/db');
const { v4: uuidv4 } = require('uuid');

exports.placeOrder = async (req, res) => {
    const { items, delivery_address, contact_number, payment_method } = req.body;
    if (req.user.role !== 'RETAILER') return res.status(403).json({ message: 'Only retailers' });

    const client = await db.getClient();
    try {
        await client.query('BEGIN');

        const orders = [];
        for (const item of items) {
            // In SQLite, FOR UPDATE is not supported, simplified to SELECT
            const productRes = await client.query('SELECT * FROM products WHERE id = $1', [item.product_id]);
            const product = productRes.rows[0];

            if (!product || product.quantity < item.quantity) throw new Error('Product unavailable');

            const total = product.price_per_unit * item.quantity;
            const orderId = uuidv4();

            await client.query(
                `INSERT INTO orders (id, order_number, farmer_id, retailer_id, product_id, quantity, unit_price, total_amount, platform_commission, delivery_fee, net_amount_to_farmer, status, payment_status, payment_method, delivery_address, created_at)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, 0, 0, $9, 'PENDING', 'PENDING', $10, $11, CURRENT_TIMESTAMP)`,
                [orderId, 'ORD-' + Math.floor(Math.random() * 10000), product.farmer_id, req.user.id, product.id, item.quantity, product.price_per_unit, total, total, payment_method, JSON.stringify(delivery_address)]
            );

            // Update inventory
            await client.query('UPDATE products SET quantity = quantity - $1 WHERE id = $2', [item.quantity, product.id]);

            orders.push({ id: orderId, order_number: 'ORD-...' });
        }

        if (client.release) await client.query('COMMIT');
        res.status(201).json({ success: true, orders });
    } catch (error) {
        if (client.release) await client.query('ROLLBACK');
        console.error(error);
        res.status(400).json({ message: error.message });
    } finally {
        if (client.release) client.release();
    }
};

exports.getMyOrders = async (req, res) => {
    try {
        let sql = 'SELECT o.*, p.name as product_name FROM orders o JOIN products p ON o.product_id = p.id';
        const params = [req.user.id];
        if (req.user.role === 'FARMER') sql += ' WHERE o.farmer_id = $1';
        else sql += ' WHERE o.retailer_id = $1';

        sql += ' ORDER BY o.created_at DESC';
        const result = await db.query(sql, params);
        res.json(result.rows);
    } catch (e) {
        console.error(e);
        res.status(500).json({ message: 'Error' });
    }
};

exports.updateOrderStatus = async (req, res) => {
    const { status } = req.body;
    const { id } = req.params;
    try {
        await db.query('UPDATE orders SET status = $1 WHERE id = $2', [status, id]);

        // Also update tracking
        const trackingId = uuidv4();
        await db.query(
            'INSERT INTO order_tracking (id, order_id, status, updated_at) VALUES ($1, $2, $3, CURRENT_TIMESTAMP)',
            [trackingId, id, status]
        );

        res.json({ success: true, status });
    } catch (e) {
        console.error(e);
        res.status(500).json({ message: 'Update failed' });
    }
};

exports.getAvailableDeliveryOrders = async (req, res) => {
    try {
        const result = await db.query(
            "SELECT o.* FROM orders o WHERE o.status IN ('READY_FOR_PICKUP', 'OUT_FOR_DELIVERY') ORDER BY o.created_at DESC"
        );
        res.json(result.rows);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Failed to fetch delivery orders' });
    }
};
