const express = require('express');
const router = express.Router();
const orderController = require('../controllers/orderController');
const authMiddleware = require('../middleware/authMiddleware');

const { validate, schemas } = require('../middleware/validationMiddleware');

router.post('/create', authMiddleware, validate(schemas.createOrder), orderController.placeOrder);
router.get('/my-orders', authMiddleware, orderController.getMyOrders);
router.put('/:orderId/status', authMiddleware, orderController.updateOrderStatus);
// router.post('/:orderId/ready', authMiddleware, orderController.markReady);

module.exports = router;
