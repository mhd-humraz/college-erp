const express = require('express');
const router = express.Router();
const { body, validationResult } = require('express-validator');
const User = require('../models/User');
const Student = require('../models/Student');
const Teacher = require('../models/Teacher');
const { protect } = require('../middleware/auth');

router.post('/register', [
  body('firstName').trim().notEmpty().withMessage('First name is required'),
  body('lastName').trim().notEmpty().withMessage('Last name is required'),
  body('email').isEmail().normalizeEmail().withMessage('Please provide a valid email'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
  body('role').isIn(['admin', 'student', 'teacher', 'hod', 'principal', 'librarian']).withMessage('Invalid role')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ success: false, errors: errors.array() });

    const { firstName, lastName, email, password, role, phone } = req.body;

    let existingUser = await User.findOne({ email });
    if (existingUser) return res.status(400).json({ success: false, message: 'User already registered with this email' });

    const user = await User.create({ firstName, lastName, email, password, role, phone });
    const token = user.getSignedJwtToken();

    res.status(201).json({
      success: true,
      message: 'User registered successfully',
      data: { token, user: { id: user._id, firstName, lastName, email, role, avatar: user.avatar } }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error during registration' });
  }
});

router.post('/login', [
  body('email').isEmail().normalizeEmail(),
  body('password').notEmpty()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) return res.status(400).json({ success: false, errors: errors.array() });

    const { email, password } = req.body;
    const user = await User.findOne({ email }).select('+password');

    if (!user || !await user.comparePassword(password)) {
      return res.status(401).json({ success: false, message: 'Invalid credentials' });
    }

    if (!user.isActive) {
      return res.status(401).json({ success: false, message: 'Account has been deactivated' });
    }

    user.lastLogin = new Date();
    await user.save({ validateBeforeSave: false });

    const token = user.getSignedJwtToken();
    res.json({ success: true, message: 'Login successful', data: { token, user: { id: user._id, firstName: user.firstName, lastName: user.lastName, email: user.email, role: user.role, avatar: user.avatar } } });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error during login' });
  }
});

router.get('/me', protect, async (req, res) => {
  const user = await User.findById(req.user.id);
  res.json({ success: true, data: user });
});

router.put('/password', [protect, body('currentPassword').notEmpty(), body('newPassword').isLength({ min: 6 })], async (req, res) => {
  const user = await User.findById(req.user.id).select('+password');
  if (!await user.comparePassword(req.body.currentPassword)) {
    return res.status(401).json({ success: false, message: 'Current password is incorrect' });
  }
  user.password = req.body.newPassword;
  await user.save();
  res.json({ success: true, message: 'Password updated successfully' });
});

router.post('/forgot-password', [body('email').isEmail()], async (req, res) => {
  const user = await User.findOne({ email: req.body.email });
  if (!user) return res.status(404).json({ success: false, message: 'No account found with this email' });
  // TODO: Implement email sending
  res.json({ success: true, message: 'Password reset instructions sent to your email' });
});

router.post('/logout', protect, (req, res) => {
  res.json({ success: true, message: 'Logged out successfully' });
});

module.exports = router;