const mongoose = require("mongoose");

const UserSchema = new mongoose.Schema({

    name: {
        type: String,
        required: true,
        trim: true
    },

    email: {
        type: String,
        required: true,
        unique: true,
        lowercase: true,
        trim: true
    },

    password: {
        type: String,
        required: true
    },

    role: {
        type: String,
        required: true,
        enum: [
            "Admin",
            "Student",
            "Teacher",
            "HOD",
            "Principal",
            "Library Staff"
        ]
    },

    isActive: {
        type: Boolean,
        default: true
    },

    refreshToken: {
        type: String,
        default: null
    }

}, {
    timestamps: true
});

module.exports = mongoose.model("User", UserSchema);