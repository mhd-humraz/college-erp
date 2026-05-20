const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const multer = require('multer');
const path = require('path');

// ── MULTER STORAGE CONFIG ──
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/'); // Make sure this folder exists in your backend root!
  },
  filename: function (req, file, cb) {
    // Generate unique filename: fieldname-timestamp.extension
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

// File filter to only allow images
const fileFilter = (req, file, cb) => {
  if (file.mimetype.startsWith('image/')) {
    cb(null, true);
  } else {
    cb(new Error('Not an image! Please upload an image.'), false);
  }
};

const upload = multer({ 
  storage: storage,
  fileFilter: fileFilter,
  limits: { fileSize: 5 * 1024 * 1024 } // 5MB limit
});

// ── ROUTES ──

// POST /api/upload/profile
router.post('/profile', auth, upload.single('profileImage'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'No file uploaded' });
    }

    // This is the URL path that gets saved to the User model
    const imageUrl = `/uploads/${req.file.filename}`;

    // Optional: Update the user's profileImage in the database automatically
    const User = require('../models/User');
    await User.findByIdAndUpdate(req.user.id, { profileImage: imageUrl });

    res.json({ 
      success: true, 
      message: 'Image uploaded successfully',
      imageUrl: imageUrl 
    });

  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
});

module.exports = router;