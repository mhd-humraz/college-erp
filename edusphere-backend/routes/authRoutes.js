// routes/authRoutes.js
const express = require('express');
const router = express.Router();

const authController = require('../controllers/authController');
const { verifyToken } = require('../middleware/authMiddleware');

// Login
router.post('/login', authController.login);

// Change Password
router.put(
  '/change-password',
  verifyToken,
  authController.changePassword
);

module.exports = router;