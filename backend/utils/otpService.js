const otpStore = new Map(); // In-memory store for demo. Use Redis in prod.

const generateOTP = (mobile) => {
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const otpId = Buffer.from(`${mobile}-${Date.now()}`).toString('base64');

    // Store OTP with expiry (5 mins)
    otpStore.set(otpId, { otp, mobile, expires: Date.now() + 5 * 60 * 1000 });

    // In a real app, send sms here via SMS Gateway
    console.log(`[OTP-STUB] OTP for ${mobile} is ${otp} (ID: ${otpId})`);

    return { otpId, otp }; // Return OTP for demo convenience
};

const verifyOTP = (otpId, otp) => {
    const data = otpStore.get(otpId);
    if (!data) return { valid: false, message: 'OTP expired or invalid' };

    if (data.expires < Date.now()) {
        otpStore.delete(otpId);
        return { valid: false, message: 'OTP expired' };
    }

    if (data.otp === otp) {
        otpStore.delete(otpId);
        return { valid: true, mobile: data.mobile };
    }

    return { valid: false, message: 'Incorrect OTP' };
};

module.exports = { generateOTP, verifyOTP };
