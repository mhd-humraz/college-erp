const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  role: { 
    type: String, 
    enum: ['admin', 'hod', 'teacher', 'class_teacher', 'student'], 
    default: 'student' 
  },
  departmentId: { type: mongoose.Schema.Types.ObjectId, ref: 'Department' },
  classId: { type: mongoose.Schema.Types.ObjectId, ref: 'Class' },
  rollNumber: { type: String },
  phone: { type: String },
  isActive: { type: Boolean, default: true },
}, { timestamps: true });

// Hash password before saving
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
  next();
});

// Compare password method
userSchema.methods.matchPassword = async function(enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

// Generate JWT Token
userSchema.methods.generateToken = function() {
  return jwt.sign(
    { id: this._id, email: this.email, role: this.role, departmentId: this.departmentId, classId: this.classId },
    process.env.JWT_SECRET || 'college_erp_secret_key_2024',
    { expiresIn: '7d' }
  );
};

module.exports = mongoose.model('User', userSchema);