const express = require('express');
const router = express.Router();
const productController = require('../controllers/productController');
const authMiddleware = require('../middleware/authMiddleware');

// Public route (or simplified for now)
router.get('/search', productController.searchProducts);

const upload = require('../middleware/uploadMiddleware');

const { validate, schemas } = require('../middleware/validationMiddleware');

// Protected routes
router.post('/create', authMiddleware, upload.array('images', 5), validate(schemas.createProduct), productController.createProduct);
router.get('/my-products', authMiddleware, productController.getMyProducts);

module.exports = router;
