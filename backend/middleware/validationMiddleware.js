const Joi = require('joi');

const validate = (schema) => {
    return (req, res, next) => {
        const { error } = schema.validate(req.body, { abortEarly: false });
        if (error) {
            const errors = error.details.map(detail => detail.message);
            return res.status(400).json({ message: 'Validation Error', errors });
        }
        next();
    };
};

const schemas = {
    registerStart: Joi.object({
        mobile: Joi.string().pattern(/^[0-9]{10}$/).required().messages({ 'string.pattern.base': 'Mobile number must be 10 digits' })
    }),
    registerComplete: Joi.object({
        mobile: Joi.string().pattern(/^[0-9]{10}$/).required(),
        otp: Joi.string().length(6).required(),
        otpId: Joi.string().required(),
        name: Joi.string().min(2).required(),
        role: Joi.string().valid('FARMER', 'RETAILER', 'DELIVERY').required(),
        language: Joi.string().valid('en', 'hi', 'pa').default('en')
    }).unknown(true), // Allow profile fields

    createProduct: Joi.object({
        name: Joi.string().required(),
        category: Joi.string().valid('GRAINS', 'VEGETABLES', 'FRUITS').required(),
        quantity: Joi.number().min(1).required(),
        unit: Joi.string().required(),
        price_per_unit: Joi.number().min(1).required(),
        min_order_qty: Joi.number().min(1).default(1),
        description: Joi.string().optional().allow(''),
        harvest_date: Joi.date().iso().optional(),
        quality_grade: Joi.string().optional(),
        is_organic: Joi.boolean().default(false)
    }),

    createOrder: Joi.object({
        items: Joi.array().items(Joi.object({
            product_id: Joi.string().uuid().required(),
            quantity: Joi.number().min(1).required()
        })).min(1).required(),
        delivery_address: Joi.object().required().unknown(),
        payment_method: Joi.string().valid('COD', 'ONLINE').required()
    })
};

module.exports = { validate, schemas };
