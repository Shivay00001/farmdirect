const axios = require('axios');

const API_URL = 'http://localhost:5000/api';

async function runTest() {
    console.log('--- STARTING INTEGRATION TEST ---');

    try {
        const rand = Math.floor(Math.random() * 10000);
        const farmerMobile = '9' + rand.toString().padStart(9, '0');
        const retailerMobile = '8' + rand.toString().padStart(9, '0');

        // 1. Register Farmer
        console.log(`1. Registering Farmer (${farmerMobile})...`);
        let res = await axios.post(`${API_URL}/auth/register/start`, { mobile: farmerMobile });
        const farmerOtp = res.data.otp;
        const farmerOtpId = res.data.otpId;

        res = await axios.post(`${API_URL}/auth/register/complete`, {
            mobile: farmerMobile,
            otp: farmerOtp,
            otpId: farmerOtpId,
            name: 'Test Farmer',
            role: 'FARMER',
            state: 'Punjab',
            district: 'Ludhiana',
            village: 'Test Village',
            farm_size: 10,
            crops: ['Wheat']
        });
        const farmerToken = res.data.token;
        console.log('✅ Farmer Registered. Token:', farmerToken.substring(0, 20) + '...');

        // 2. Add Product
        console.log('2. Adding Product...');
        res = await axios.post(`${API_URL}/products/create`, {
            name: 'Golden Wheat',
            category: 'GRAINS',
            quantity: 1000,
            unit: 'kg',
            price_per_unit: 25,
            min_order_qty: 50,
            description: 'Best wheat in Punjab'
        }, {
            headers: { Authorization: `Bearer ${farmerToken}` }
        });
        const productId = res.data.product.id; // Corrected: product.id not product.rows[0].id
        console.log('✅ Product Added. ID:', productId);

        // 3. Register Retailer
        console.log(`3. Registering Retailer (${retailerMobile})...`);
        res = await axios.post(`${API_URL}/auth/register/start`, { mobile: retailerMobile });
        const retailerOtp = res.data.otp;
        const retailerOtpId = res.data.otpId;

        res = await axios.post(`${API_URL}/auth/register/complete`, {
            mobile: retailerMobile,
            otp: retailerOtp,
            otpId: retailerOtpId,
            name: 'Test Retailer',
            role: 'RETAILER',
            shop_name: 'Gupta Store',
            shop_address: 'Main Market'
        });
        const retailerToken = res.data.token;
        console.log('✅ Retailer Registered.');

        // 4. Search Product
        console.log('4. Searching Product...');
        res = await axios.get(`${API_URL}/products/search?query=Wheat`);
        if (res.data.length > 0) {
            console.log(`✅ Found ${res.data.length} products.`);
        } else {
            throw new Error('Product not found in search');
        }

        // 5. Place Order
        console.log('5. Placing Order...');
        res = await axios.post(`${API_URL}/orders/create`, {
            items: [{ product_id: productId, quantity: 100 }],
            delivery_address: { line1: 'Test Address' },
            payment_method: 'COD'
        }, {
            headers: { Authorization: `Bearer ${retailerToken}` }
        });
        console.log('✅ Order Placed. Order #:', res.data.orders[0].order_number);

        console.log('--- TEST PASSED SUCCESSFULLY ---');
        process.exit(0);

    } catch (error) {
        console.error('❌ TEST FAILED:', error.response ? error.response.data : error.message);
        process.exit(1);
    }
}

// Check if server is up before running
setTimeout(runTest, 2000);
