const mongoose = require('mongoose');

const departmentSchema = new mongoose.Schema({
  name: { type: String, required: true, unique: true },
  code: { type: String, required: true, uppercase: true, unique: true },
  hodId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  description: { type: String },
  totalStudents: { type: Number, default: 0 },
  totalStaff: { type: Number, default: 0 },
  isActive: { type: Boolean, default: true },
  }, { timestamps: true });

module.exports = mongoose.model('Department', departmentSchema);

