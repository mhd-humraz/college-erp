const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const auth = require('../middleware/auth');

// POST /api/auth/login
router.post('/login', async (req, res) => {
  try {
    const { identifier, password, role } = req.body;
    if (!identifier || !password) {
      return res.status(400).json({ message: 'Credentials are required' });
    }

    let user;
    if (role === 'Student') {
      user = await User.findOne({ studentId: identifier, role: 'Student' });
    } else if (role === 'Teacher' || role === 'HOD' || role === 'Principal' || role === 'Library') {
      user = await User.findOne({ teacherId: identifier, role });
      if (!user) user = await User.findOne({ email: identifier.toLowerCase(), role });
    } else {
      user = await User.findOne({ email: identifier.toLowerCase() });
    }

    if (!user) return res.status(401).json({ message: 'Invalid credentials' });
    if (role && user.role !== role) return res.status(401).json({ message: `This account is not registered as ${role}` });

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(401).json({ message: 'Invalid credentials' });
    if (!user.isActive) return res.status(403).json({ message: 'Account deactivated. Contact admin.' });

    const token = jwt.sign(
      { id: user._id, role: user.role, name: user.name, email: user.email, studentId: user.studentId, teacherId: user.teacherId },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN }
    );

    res.json({
      token,
      isFirstLogin: user.isFirstLogin,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
        studentId: user.studentId,
        teacherId: user.teacherId,
        department: user.department,
        phone: user.phone,
      },
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST /api/auth/change-password
router.post('/change-password', auth, async (req, res) => {
  try {
    const { oldPassword, newPassword } = req.body;
    const user = await User.findById(req.user.id);
    const isMatch = await bcrypt.compare(oldPassword, user.password);
    if (!isMatch) return res.status(400).json({ message: 'Current password is incorrect' });
    user.password = await bcrypt.hash(newPassword, 10);
    user.isFirstLogin = false;
    await user.save();
    res.json({ message: 'Password changed successfully' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST /api/auth/forgot-password
router.post('/forgot-password', async (req, res) => {
  try {
    const { email } = req.body;
    const user = await User.findOne({ email: email.toLowerCase() });
    if (!user) return res.status(404).json({ message: 'Email not found' });

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    user.resetOtp = otp;
    user.resetOtpExpiry = new Date(Date.now() + 10 * 60 * 1000);
    await user.save();

    const nodemailer = require('nodemailer');
    const transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: { user: process.env.EMAIL_USER, pass: process.env.EMAIL_PASS },
    });

    await transporter.sendMail({
      from: `"MESCAS ERP" <${process.env.EMAIL_USER}>`,
      to: user.email,
      subject: 'Password Reset OTP - MESCAS ERP',
      html: `
        <div style="font-family:Arial;max-width:400px;margin:auto;padding:24px;background:#222831;border-radius:12px;color:#EEEEEE;">
          <h2 style="color:#00ADB5;">MESCAS ERP</h2>
          <p>Your OTP for password reset:</p>
          <h1 style="color:#00ADB5;font-size:40px;letter-spacing:8px;">${otp}</h1>
          <p>Expires in <strong>10 minutes</strong>.</p>
        </div>
      `,
    });

    res.json({ message: 'OTP sent to your email' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST /api/auth/verify-otp
router.post('/verify-otp', async (req, res) => {
  try {
    const { email, otp } = req.body;
    const user = await User.findOne({ email: email.toLowerCase() });
    if (!user || user.resetOtp !== otp) return res.status(400).json({ message: 'Invalid OTP' });
    if (new Date() > user.resetOtpExpiry) return res.status(400).json({ message: 'OTP expired' });
    res.json({ message: 'OTP verified', verified: true });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST /api/auth/reset-password
router.post('/reset-password', async (req, res) => {
  try {
    const { email, otp, newPassword } = req.body;
    const user = await User.findOne({ email: email.toLowerCase() });
    if (!user || user.resetOtp !== otp) return res.status(400).json({ message: 'Invalid OTP' });
    if (new Date() > user.resetOtpExpiry) return res.status(400).json({ message: 'OTP expired' });
    user.password = await bcrypt.hash(newPassword, 10);
    user.resetOtp = undefined;
    user.resetOtpExpiry = undefined;
    user.isFirstLogin = false;
    await user.save();
    res.json({ message: 'Password reset successfully' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;
