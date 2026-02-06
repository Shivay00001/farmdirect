const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const authMiddleware = require('../middleware/authMiddleware');

// Add specific Admin Check middleware if possible later
router.get('/stats', adminController.getStats);
router.get('/users', adminController.getUsers);

module.exports = router;
