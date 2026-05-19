const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name:         { type: String, required: true, trim: true },
  email:        { type: String, lowercase: true, trim: true },
  password:     { type: String, required: true },
  phone:        { type: String },
  role:         { type: String, enum: ['Admin', 'Student', 'Teacher', 'HOD', 'Principal', 'Library'], required: true },
  department:   { type: String },
  isActive:     { type: Boolean, default: true },
  isFirstLogin: { type: Boolean, default: true },

  // Student specific
  studentId:    { type: String, unique: true, sparse: true },
  guardianPhone:{ type: String },
  semester:     { type: String },
  batch:        { type: String },

  // Staff specific
  teacherId:    { type: String, unique: true, sparse: true },
  subject:      { type: String },
  designation:  { type: String },

  // OTP for forgot password
  resetOtp:       { type: String },
  resetOtpExpiry: { type: Date },

}, { timestamps: true });

module.exports = mongoose.model('User', userSchema);
