const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Routes
// Routes - make sure all have .js extension
app.use('/api/auth', require('./routes/auth.js'));
app.use('/api/users', require('./routes/users.js'));
app.use('/api/courses', require('./routes/courses.js'));
app.use('/api/departments', require('./routes/departments.js'));
app.use('/api/notifications', require('./routes/notifications.js'));
app.use('/api/timetable', require('./routes/timetable.js'));
app.use('/api/reports', require('./routes/reports.js'));
app.use('/api/settings', require('./routes/settings.js'));
app.use('/api/attendance', require('./routes/attendance.js'));  // Added .js
app.use('/api/staff', require('./routes/staff.js'));  // Added .js
app.use('/api/upload', require('./routes/upload.js'));  // Added .js
app.use('/api/fees', require('./routes/fees.js'));  // Added .js
app.use('/api/exams', require('./routes/exams.js'));  // Added .js
app.use('/api/events', require('./routes/events.js'));  // Added .js
app.use('/api/library', require('./routes/library.js'));  // Added .js

// Health check
app.get('/', (req, res) => {
  res.json({ message: 'MESCAS ERP API is running!' });
});

// Connect to MongoDB
mongoose.connect(process.env.MONGO_URI)
  .then(async () => {
    console.log('✅ MongoDB connected');
    // seed default admin
    await seedAdmin();
    app.listen(process.env.PORT, () => {
      console.log(`🚀 Server running on http://localhost:${process.env.PORT}`);
    });
  })
  .catch(err => {
    console.error('❌ MongoDB connection error:', err.message);
    process.exit(1);
  });

// Seed default admin account
async function seedAdmin() {
  const User = require('./models/User.js');
  const bcrypt = require('bcryptjs');
  const existing = await User.findOne({ role: 'Admin' });
  if (!existing) {
    const hashed = await bcrypt.hash('admin123', 10);
    await User.create({
      name: 'Super Admin',
      email: 'admin@mescas.com',
      password: hashed,
      role: 'Admin',
    });
    console.log('👤 Default admin created: admin@mescas.com / admin123');
  }
}
