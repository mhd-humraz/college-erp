// config/cloudinary.js
const cloudinary = require('cloudinary').v2;
const multer = require('multer');
const multerStorageCloudinary = require('multer-storage-cloudinary');

// Safe Extraction: Handle both destructured and default class instances across version trees
const CloudinaryStorage = multerStorageCloudinary.CloudinaryStorage 
    || multerStorageCloudinary 
    || require('multer-storage-cloudinary').CloudinaryStorage;

if (typeof CloudinaryStorage !== 'function' && (!CloudinaryStorage || typeof CloudinaryStorage.default !== 'function')) {
    throw new TypeError("Failed to extract a valid CloudinaryStorage constructor from multer-storage-cloudinary.");
}

// Select the raw constructor function safely
const ConstructorInstance = typeof CloudinaryStorage === 'function' ? CloudinaryStorage : CloudinaryStorage.default;

cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET
});

const storagePipeline = new ConstructorInstance({
    cloudinary: cloudinary,
    params: {
        folder: 'edusphere_erp_assets',
        allowed_formats: ['jpg', 'png', 'pdf', 'docx'],
        resource_type: 'auto' 
    }
});

const uploadParser = multer({ storage: storagePipeline });

module.exports = uploadParser;