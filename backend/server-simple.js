const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();

app.use(cors());
app.use(express.json());

// Only use routes that exist and are properly structured
app.use('/api/auth', require('./routes/auth.js'));
app.use('/api/users', require('./routes/users.js'));

// Health check
app.get('/', (req, res) => {
  res.json({ message: 'MESCAS ERP API is running!' });
});

// Connect to MongoDB
mongoose.connect(process.env.MONGO_URI)
  .then(async () => {
    console.log('✅ MongoDB connected');
    
    // Create default admin if none exists
    const User = require('./models/User.js');
    const bcrypt = require('bcryptjs');
    const adminExists = await User.findOne({ email: 'admin@mescas.com' });
    if (!adminExists) {
      const hashed = await bcrypt.hash('admin123', 10);
      await User.create({
        name: 'Super Admin',
        email: 'admin@mescas.com',
        password: hashed,
        role: 'Admin',
        isActive: true
      });
      console.log('👤 Default admin created: admin@mescas.com / admin123');
    }
    
    const PORT = process.env.PORT || 3000;
    app.listen(PORT, () => {
      console.log(`🚀 Server running on http://localhost:${PORT}`);
    });
  })
  .catch(err => {
    console.error('❌ MongoDB connection error:', err.message);
    process.exit(1);
  });

  
// eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjZhMDVhYzAyMGU0MjY2YTNmMDc3MmEwZiIsImVtYWlsIjoiYWRtaW5AbWVzY2FzLmNvbSIsInJvbGUiOiJBZG1pbiIsImlhdCI6MTc3OTAzMTA5MCwiZXhwIjoxNzc5NjM1ODkwfQ.MmVaXz-LMfmvjGneNutvvMRoUFGEpd7J_W6UHexdqrw

// eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjZhMDVhYzAyMGU0MjY2YTNmMDc3MmEwZiIsImVtYWlsIjoiYWRtaW5AbWVzY2FzLmNvbSIsInJvbGUiOiJBZG1pbiIsImlhdCI6...


 