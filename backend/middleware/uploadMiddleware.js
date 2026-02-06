const multer = require('multer');
const supabase = require('../config/supabase');
const path = require('path');

// Memory Storage (Keep file in memory to upload to cloud)
const storage = multer.memoryStorage();

// File Filter
const fileFilter = (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
        cb(null, true);
    } else {
        cb(new Error('Not an image! Please upload an image.'), false);
    }
};

const upload = multer({
    storage: storage,
    limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
    fileFilter: fileFilter
});

// Helper to upload file to Supabase
upload.uploadToSupabase = async (file) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const filename = `products/${file.fieldname}-${uniqueSuffix}${path.extname(file.originalname)}`;

    // Upload
    const { data, error } = await supabase.storage
        .from('product-images')
        .upload(filename, file.buffer, {
            contentType: file.mimetype,
            upsert: false
        });

    if (error) {
        console.error("Supabase Upload Error:", error);
        throw error;
    }

    // Get Public URL
    const { data: { publicUrl } } = supabase.storage
        .from('product-images')
        .getPublicUrl(filename);

    return publicUrl;
};

module.exports = upload;
