// server.js
require('dotenv').config();
const http = require('http');
const app = require('./app');
const connectDB = require('./config/db');
const { Server } = require('socket.io');

// Wrap the Express 'app' instance inside a standard Node HTTP Server
const server = http.createServer(app);

// Initialize the Socket.IO Engine Instance on top of the HTTP Server
const io = new Server(server, {
    cors: { 
        origin: "*" // Permits flexible cross-platform device sockets connections (e.g., Flutter client)
    } 
});

// Bind the socket engine initialization context globally.
// This allows background tracking services (like notificationEngine.js) to push events cleanly.
global.io = io;

// Context Middleware: Passes the Socket.IO instance into every request object
app.use((req, res, next) => {
    req.io = io;
    next();
});

// Handle Real-Time Event Communication Hooks
io.on('connection', (socket) => {
    console.log(`🔌 New client connected to stream: ${socket.id}`);
    
    socket.on('disconnect', () => {
        console.log(`🔌 Client socket stream terminated: ${socket.id}`);
    });
});

const PORT = process.env.PORT || 5000;

// Sequential System Boot Execution Lifecycle
const startServer = async () => {
    try {
        // 1. Establish Secure Persistent Pool Connection with MongoDB
        await connectDB();

        // 2. Open Network Portal Port to intercept incoming HTTP/WS Traffic
        server.listen(PORT, () => {
            console.log(`\x1b[36m%s\x1b[0m`, `🚀 EduSphere Server running on port ${PORT}`);
        });
    } catch (error) {
        console.error(`❌ System boot failed to execute: ${error.message}`);
        process.exit(1);
    }
};

startServer();