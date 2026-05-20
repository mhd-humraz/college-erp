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
const roleAuth = require('./middleware/roleAuth'); // 🆕 IMPORT NEW MIDDLEWARE

// ── Public Routes (no auth required) ──
app.use('/api/auth', require('./routes/auth'));

// ── General Protected Routes (any authenticated user) ──
app.use('/api/users', auth, require('./routes/users'));
app.use('/api/dashboard', auth, require('./routes/dashboard'));
app.use('/api/approvals', auth, require('./routes/approvals'));
app.use('/api/upload', auth, require('./routes/upload'));

// ── Admin ONLY Routes (Strictly adminAuth) ──
// Core system structures that Teachers/Principals shouldn't change
app.use('/api/departments', auth, adminAuth, require('./routes/departments'));
app.use('/api/courses', auth, adminAuth, require('./routes/courses'));
app.use('/api/fees', auth, adminAuth, require('./routes/fees'));
app.use('/api/events', auth, adminAuth, require('./routes/events'));
app.use('/api/library', auth, adminAuth, require('./routes/library'));
app.use('/api/reports', auth, adminAuth, require('./routes/reports'));
app.use('/api/settings', auth, adminAuth, require('./routes/settings'));
app.use('/api/roles', auth, adminAuth, require('./routes/roles'));

// ── Admin & Principal Routes ──
// Admin and Principal can create/manage Teachers (Staff)
app.use('/api/staff', auth, roleAuth(['Admin', 'Principal']), require('./routes/staff'));

// ── Admin, Principal & Teacher Routes ──
// Teachers need access to these to do their job (view/add students, mark attendance, etc.)
app.use('/api/students', auth, roleAuth(['Admin', 'Principal', 'Teacher']), require('./routes/students'));
app.use('/api/timetable', auth, roleAuth(['Admin', 'Principal', 'Teacher']), require('./routes/timetable'));
app.use('/api/attendance', auth, roleAuth(['Admin', 'Principal', 'Teacher']), require('./routes/attendance'));
app.use('/api/notifications', auth, roleAuth(['Admin', 'Principal', 'Teacher']), require('./routes/notifications'));
app.use('/api/exams', auth, roleAuth(['Admin', 'Principal', 'Teacher']), require('./routes/exams'));

// 🆕 NEW: Teacher-specific features
app.use('/api/marks', auth, roleAuth(['Admin', 'Principal', 'Teacher']), require('./routes/marks'));
app.use('/api/assignments', auth, roleAuth(['Admin', 'Principal', 'Teacher']), require('./routes/assignments'));
app.use('/api/materials', auth, roleAuth(['Admin', 'Principal', 'Teacher']), require('./routes/materials'));

// ── Admin, Principal, Teacher & Student Routes ──
// Students apply for leave, Teachers approve student leave / apply for their own, HOD approves Teacher leave
app.use('/api/leave', auth, roleAuth(['Admin', 'Principal', 'HOD', 'Teacher', 'Student']), require('./routes/leaves'));
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