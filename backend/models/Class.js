const mongoose = require('mongoose');

const classSchema = new mongoose.Schema({
  name: { type: String, required: true }, // e.g., "BCA-S3-A"
  departmentId: { type: mongoose.Schema.Types.ObjectId,ref: 'Department', required: true },
    classTeacherId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    semester: { type: Number, required: true },
    section: { type: String, enum: ['A', 'B', 'C'] },
    strength: { type: Number, default: 0 },
    academicYear: { type: String, default: '2024-25' }
    }, { timestamps: true });

module.exports = mongoose.model('Class', classSchema);