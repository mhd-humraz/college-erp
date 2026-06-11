// edusphere-backend/seed.js snippet
const mongoose = require('mongoose');
const User = require('./models/User');
const bcrypt = require('bcryptjs');

const initializeMasterAdmin = async () => {
    try {
        await mongoose.connect('mongodb://localhost:27017/edusphere');
        
        // Wipe old records to prevent duplicate key crashes during local testing
        await User.deleteMany({ role: 'Admin' });

        const salt = await bcrypt.genSalt(10);
        const hashedMasterPassword = await bcrypt.hash('admin123', salt);

        await User.create({
            email: 'admin@edusphere.edu',
            password: hashedMasterPassword,
            role: 'Admin',
            isActive: true
        });

        console.log("🏆 INITIALIZATION COMPLETE: Master Admin seeded -> admin@edusphere.edu / admin123");
        process.exit(0);
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
};

initializeMasterAdmin();