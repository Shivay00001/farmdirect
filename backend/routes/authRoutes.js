const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const authMiddleware = require('../middleware/authMiddleware');
const db = require('../config/db');

const { validate, schemas } = require('../middleware/validationMiddleware');

router.post('/register/start', validate(schemas.registerStart), authController.registerStart);
router.post('/register/complete', validate(schemas.registerComplete), authController.registerComplete);
router.post('/login/start', authController.loginStart);
router.post('/login/verify', authController.loginVerify);

// Me endpoint
router.get('/me', authMiddleware, async (req, res) => {
    try {
        const userRes = await db.query('SELECT * FROM users WHERE id = $1', [req.user.id]);
        res.json(userRes.rows[0]);
    } catch (error) {
        res.status(500).json({ message: 'Server Error' });
    }
});

module.exports = router;
