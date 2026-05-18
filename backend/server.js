const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();

app.use(cors());
app.use(express.json());

// ── Routes ──
app.use('/api/auth',          require('./routes/auth'));
app.use('/api/users',         require('./routes/users'));
app.use('/api/staff',         require('./routes/staff'));
app.use('/api/students',      require('./routes/students'));
app.use('/api/departments',   require('./routes/departments'));
app.use('/api/courses',       require('./routes/courses'));
app.use('/api/timetable',     require('./routes/timetable'));
app.use('/api/attendance',    require('./routes/attendance'));
app.use('/api/notifications', require('./routes/notifications'));
app.use('/api/fees',          require('./routes/fees'));
app.use('/api/exams',         require('./routes/exams'));
app.use('/api/events',        require('./routes/events'));
app.use('/api/library',       require('./routes/library'));
app.use('/api/reports',       require('./routes/reports'));
app.use('/api/settings',      require('./routes/settings'));
app.use('/api/roles',         require('./routes/roles'));

// Health check
app.get('/', (req, res) => {
  res.json({ message: '🚀 MESCAS ERP API is running!', version: '1.0.0' });
});

// Connect MongoDB then start server
mongoose.connect(process.env.MONGO_URI)
  .then(async () => {
    console.log('✅ MongoDB connected');
    await seedAdmin();
    app.listen(process.env.PORT, () => {
      console.log(`🚀 Server running on http://localhost:${process.env.PORT}`);
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
