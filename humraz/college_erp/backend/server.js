require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');

// Import routes
const authRoutes = require('./routes/auth');
const adminRoutes = require('./routes/admin');
const studentRoutes = require('./routes/student');
const teacherRoutes = require('./routes/teacher'); // ✅ CORRECT! // ✅ ADD THIS
const hodRoutes = require('./routes/hod');
const principalRoutes = require('./routes/principal');
const libraryRoutes = require('./routes/library');
const eventRoutes = require('./routes/events');

const app = express();

// Security middleware
app.use(helmet());

// ⭐ FIXED CORS - Allow ALL origins during development
app.use(cors({
  origin: '*', // ✅ Allow any origin (Flutter web, mobile, etc.)
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'], // Added OPTIONS for preflight
  allowedHeaders: ['Content-Type', 'Authorization', 'Origin', 'X-Requested-With', 'Accept'],
  exposedHeaders: ['Authorization']
}));

// Handle preflight requests
app.options('*', cors()); // ✅ Enable preflight across all routes

// Rate limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000,
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 200, // Increased limit
  message: {
    success: false,
    message: 'Too many requests from this IP, please try again later'
  },
  standardHeaders: true,
  legacyHeaders: false,
});
app.use('/api/', limiter);

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Logging
if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev'));
}

// Static files for uploads
app.use('/uploads', express.static('uploads'));

// Request logging middleware (helpful for debugging)
app.use((req, res, next) => {
  console.log(`📡 ${new Date().toISOString()} | ${req.method} | ${req.originalUrl}`);
  next();
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/student', studentRoutes);
app.use('/api/teacher', teacherRoutes);
app.use('/api/hod', hodRoutes);
app.use('/api/principal', principalRoutes);
app.use('/api/library', libraryRoutes);
app.use('/api/events', eventRoutes);

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'College ERP API is running',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
    version: '1.0.0'
  });
});

// API documentation endpoint
app.get('/api', (req, res) => {
  res.json({
    success: true,
    message: 'College ERP API',
    version: '1.0.0',
    endpoints: {
      auth: '/api/auth/*',
      admin: '/api/admin/*',
      student: '/api/student/*',
      teacher: '/api/teacher/*',
      hod: '/api/hod/*',
      principal: '/api/principal/*',
      library: '/api/library/*',
      events: '/api/events/*'
    },
    documentation: 'See route files for details'
  });
});

// 404 handler
app.use((req, res, next) => {
  console.log(`❌ 404 Not Found: ${req.method} ${req.originalUrl}`);
  res.status(404).json({
    success: false,
    message: `Route ${req.originalUrl} not found`,
    hint: 'Check the URL and try again'
  });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('💥 Server Error:', err.stack);
  res.status(err.statusCode || 500).json({
    success: false,
    message: err.message || 'Internal Server Error',
    ...(process.env.NODE_ENV === 'development' && { 
      stack: err.stack,
      details: err.toString()
    })
  });
});

// Database connection
const connectDB = async () => {
  try {
    const conn = await mongoose.connect(
      process.env.MONGODB_URI || 'mongodb://localhost:27017/college_erp'
    );
    console.log(`✅ MongoDB Connected: ${conn.connection.host}`);
    
    // Log successful connection
    mongoose.connection.on('error', (err) => {
      console.error('❌ MongoDB Connection Error:', err);
    });
    
    mongoose.connection.on('disconnected', () => {
      console.warn('⚠️  MongoDB Disconnected');
    });
    
  } catch (error) {
    console.error(`❌ MongoDB Connection Error: ${error.message}`);
    console.error('Make sure MongoDB is running on localhost:27017');
    process.exit(1);
  }
};

// Start server
const startServer = () => {
  const PORT = process.env.PORT || 5000;
  
  const server = app.listen(PORT, '0.0.0.0', () => { // Listen on all interfaces
    console.log('');
    console.log('╔════════════════════════════════════════════════════════════════════════════╗');
    console.log('║     🎓 COLLEGE ERP BACKEND SERVER                                          ║');
    console.log('╠════════════════════════════════════════════════════════════════════════════╣');
    console.log(`║  ✅ Server running in ${process.env.NODE_ENV || 'development'} mode        ║`);
    console.log(`║  🚀 Port: ${PORT}                                                          ║`);
    console.log(`║  📡 Local: http://localhost:${PORT}                                        ║`);
    console.log(`║  🔗 Health: http://localhost:${PORT}/api/health                            ║`);
    console.log(`║  📊 Admin: http://localhost:${PORT}/api/admin/dashboard                    ║`);
    console.log('╚════════════════════════════════════════════════════════════════════════════╝');
    console.log('');
  });

  // Handle server errors
  server.on('error', (error) => {
    if (error.code === 'EADDRINUSE') {
      console.error(`❌ Port ${PORT} is already in use`);
      console.error('   Either stop the other process or change PORT in .env');
      process.exit(1);
    } else {
      throw error;
    }
  });
};

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('\n🛑 SIGTERM received. Shutting down gracefully...');
  
  try {
    await mongoose.connection.close();
    console.log('✅ MongoDB connection closed');
    process.exit(0);
  } catch (err) {
    console.error('Error during shutdown:', err);
    process.exit(1);
  }
});

process.on('SIGINT', async () => {
  console.log('\n🛑 SIGINT received. Shutting down gracefully...');
  
  try {
    await mongoose.connection.close();
    console.log('✅ MongoDB connection closed');
    process.exit(0);
  } catch (err) {
    console.error('Error during shutdown:', err);
    process.exit(1);
  }
});

// Initialize
const initializeApp = async () => {
  console.log('');
  console.log('🚀 Starting College ERP Backend...');
  console.log('⏳ Connecting to MongoDB...');
  
  await connectDB();
  startServer();
};

initializeApp();

module.exports = app;