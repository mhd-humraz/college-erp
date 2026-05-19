const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();

app.use(cors());
app.use(express.json());

// 👇 Serve uploaded files (profile images, etc.)
app.use('/uploads', express.static('uploads'));

// Import middlewares
const auth = require('./middleware/auth');
const adminAuth = require('./middleware/adminAuth');

// ── Public Routes (no auth required) ──
app.use('/api/auth', require('./routes/auth'));

// ── Protected Routes (any authenticated user) ──
app.use('/api/users', auth, require('./routes/users'));

// 🆕 HOD Dashboard Routes (NEW!)
app.use('/api/dashboard', auth, require('./routes/dashboard'));
app.use('/api/approvals', auth, require('./routes/approvals'));
app.use('/api/upload', auth, require('./routes/upload'));

// ── Admin Only Routes ──
app.use('/api/staff', adminAuth, require('./routes/staff'));
app.use('/api/students', adminAuth, require('./routes/students'));
app.use('/api/departments', adminAuth, require('./routes/departments'));
app.use('/api/courses', adminAuth, require('./routes/courses'));
app.use('/api/timetable', adminAuth, require('./routes/timetable'));
app.use('/api/attendance', adminAuth, require('./routes/attendance'));
app.use('/api/notifications', adminAuth, require('./routes/notifications'));
app.use('/api/fees', adminAuth, require('./routes/fees'));
app.use('/api/exams', adminAuth, require('./routes/exams'));
app.use('/api/events', adminAuth, require('./routes/events'));
app.use('/api/library', adminAuth, require('./routes/library'));
app.use('/api/reports', adminAuth, require('./routes/reports'));
app.use('/api/settings', adminAuth, require('./routes/settings'));
app.use('/api/roles', adminAuth, require('./routes/roles'));

// Health check (public)
app.get('/', (req, res) => {
  res.json({ message: '🚀 MESCAS ERP API is running!', version: '1.0.0' });
});

// Connect MongoDB then start server
mongoose.connect(process.env.MONGO_URI)
  .then(async () => {
    console.log('✅ MongoDB connected');
    await seedAdmin();
    const PORT = process.env.PORT || 3000;
    app.listen(PORT, () => {
      console.log(`🚀 Server running on http://localhost:${PORT}`);
    });
  })
  .catch(err => {
    console.error('❌ MongoDB error:', err.message);
    process.exit(1);
  });

// Seed default admin
async function seedAdmin() {
  const User = require('./models/User');
  const bcrypt = require('bcryptjs');
  const existing = await User.findOne({ role: 'Admin' });
  if (!existing) {
    const hashed = await bcrypt.hash('admin123', 10);
    await User.create({
      name: 'Super Admin',
      email: 'admin@mescas.com',
      password: hashed,
      role: 'Admin',
      isFirstLogin: false,
      isActive: true,
    });
    console.log('👤 Admin created → email: admin@mescas.com | password: admin123');
  }
}