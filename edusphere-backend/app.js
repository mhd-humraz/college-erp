// app.js
const express = require('express');
const cors = require('cors');
const swaggerUi = require('swagger-ui-express');
const swaggerSpecs = require('./config/swagger'); // Import specification compiler config

const app = express();

// ==========================================
// 1. GLOBAL MIDDLEWARES
// ==========================================
app.use(cors()); 
app.use(express.json()); 
app.use(express.urlencoded({ extended: true }));

// 🚀 CRITICAL INFRASTRUCTURE: Mount Live Interactive Swagger Dashboard Interface Route
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpecs));

// ==========================================
// 2. ROUTING MOUNTS
// ==========================================
app.use('/api/admin', require('./routes/adminRoutes'));
app.use('/api/auth', require('./routes/authRoutes'));
app.use('/api/academic', require('./routes/academicRoutes'));
app.use('/api/tickets', require('./routes/ticketRoutes'));
app.use('/api/qr-ops', require('./routes/qrOperationRoutes'));
app.use('/api/portfolio', require('./routes/portfolioRoutes'));
app.use('/api/ai', require('./routes/aiRoutes'));
app.use('/api/uploads', require('./routes/uploadRoutes'));
app.use('/api/fee', require('./routes/feeRoutes'));
app.use('/api/hod', require('./routes/hodRoutes'));
app.use('/api/principal', require('./routes/principalRoutes'));
app.use('/api-v2', require('./routes/aiV2Routes'));
app.use('/api/timetable', require('./routes/timetableRoutes'));
// ==========================================
// 3. BASE SANITY TEST ROUTE
// ==========================================
app.get('/api/test', (req, res) => {
    res.status(200).json({ status: "Server Running smoothly" });
});

module.exports = app;