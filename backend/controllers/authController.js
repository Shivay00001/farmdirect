const db = require('../config/db');
const { generateOTP, verifyOTP } = require('../utils/otpService');
const { generateToken } = require('../utils/tokenUtils');
const { v4: uuidv4 } = require('uuid');
const fs = require('fs');

exports.registerStart = async (req, res) => {
    const { mobile } = req.body;
    try {
        const userCheck = await db.query('SELECT * FROM users WHERE mobile = $1', [mobile]);
        if (userCheck.rows.length > 0) return res.status(400).json({ message: 'User already exists' });

        const { otpId, otp } = generateOTP(mobile);
        res.json({ message: 'OTP sent', otpId, otp });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.registerComplete = async (req, res) => {
    const { otpId, otp, mobile, name, role, language, ...profileData } = req.body;

    try {
        const otpResult = verifyOTP(otpId, otp);
        if (!otpResult.valid || otpResult.mobile !== mobile) {
            return res.status(400).json({ message: 'Invalid or expired OTP' });
        }

        const client = await db.getClient();
        // Uses helper from updated db.js

        try {
            // Always start transaction
            await client.query('BEGIN');

            const userId = uuidv4();
            // Generate ID in app
            const userRes = await client.query(
                'INSERT INTO users (id, mobile, name, role, language, status) VALUES ($1, $2, $3, $4, $5, $6)',
                [userId, mobile, name, role, language || 'en', 'ACTIVE']
            );

            // Handle SQLite not returning rows on INSERT
            const user = userRes.rows && userRes.rows.length > 0 ? userRes.rows[0] : { id: userId, role };

            if (role === 'FARMER') {
                const profileId = uuidv4();
                const { state, district, village, farm_size, crops } = profileData;
                await client.query(
                    'INSERT INTO farmer_profiles (id, user_id, state, district, village, farm_size, crops) VALUES ($1, $2, $3, $4, $5, $6, $7)',
                    [profileId, userId, state, district, village, farm_size, JSON.stringify(crops || [])]
                );
            } else if (role === 'RETAILER') {
                const profileId = uuidv4();
                const { shop_name, shop_address } = profileData;
                await client.query(
                    'INSERT INTO retailer_profiles (id, user_id, shop_name, shop_address) VALUES ($1, $2, $3, $4)',
                    [profileId, userId, shop_name, shop_address]
                );
            } else if (role === 'DELIVERY') {
                const profileId = uuidv4();
                const { vehicle_number, vehicle_type } = profileData;
                await client.query(
                    'INSERT INTO delivery_profiles (id, user_id, vehicle_number, vehicle_type) VALUES ($1, $2, $3, $4)',
                    [profileId, userId, vehicle_number, vehicle_type]
                );
            }

            if (client.release) { // PG Only
                await client.query('COMMIT');
            }

            const token = generateToken(user.id, user.role);
            console.log("User registered successfully:", user.id);
            res.status(201).json({ success: true, token, user });
        } catch (e) {
            console.error("Register transaction failed:", e);
            fs.writeFileSync('error_inner.txt', JSON.stringify(e, Object.getOwnPropertyNames(e)) + '\n' + e.toString());
            if (client.release) await client.query('ROLLBACK');
            throw e;
        } finally {
            if (client.release) client.release();
        }
    } catch (error) {
        console.error(error);
        fs.writeFileSync('error_outer.txt', JSON.stringify(error, Object.getOwnPropertyNames(error)) + '\n' + error.toString());
        res.status(500).json({ message: 'Registration failed' });
    }
};

exports.loginStart = async (req, res) => {
    const { mobile } = req.body;
    try {
        const userResult = await db.query('SELECT * FROM users WHERE mobile = $1', [mobile]);
        if (userResult.rows.length === 0) return res.status(404).json({ message: 'User not found' });
        const { otpId, otp } = generateOTP(mobile);
        res.json({ message: 'OTP sent', otpId, otp });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.loginVerify = async (req, res) => {
    const { otpId, otp, mobile } = req.body;
    try {
        const otpResult = verifyOTP(otpId, otp);
        if (!otpResult.valid || otpResult.mobile !== mobile) return res.status(400).json({ message: 'Invalid OTP' });
        const userResult = await db.query('SELECT * FROM users WHERE mobile = $1', [mobile]);
        const user = userResult.rows[0];
        const token = generateToken(user.id, user.role);
        res.json({ success: true, token, user });
    } catch (error) {
        res.status(500).json({ message: 'Login failed' });
    }
};
