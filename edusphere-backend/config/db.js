const mongoose = require('mongoose');

const connectDB = async () => {
    try {
        const conn = await mongoose.connect(process.env.MONGO_URI);
        console.log(`\x1b[32m%s\x1b[0m`, `✅ EduSphere MongoDB Engine Hooked: ${conn.connection.host}`);
    } catch (error) {
        console.error(`\x1b[31m%s\x1b[0m`, `❌ Database initialization failed: ${error.message}`);
        process.exit(1); // Crash the runtime immediately to protect integrity
    }
};

module.exports = connectDB;