const mongoose = require('mongoose');

const leaveSchema = new mongoose.Schema({
  // Who applied for the leave
  applicant: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User', 
    required: true 
  },
  applicantRole: { 
    type: String, 
    enum: ['Student', 'Teacher'], 
    required: true 
  },
  
  // Who should approve this leave
  approverRole: { 
    type: String, 
    enum: ['Teacher', 'HOD'], 
    required: true 
  },
  
  // Common details
  department: { type: String, required: true },
  semester: { type: String },           // Only for students
  fromDate: { type: String, required: true },
  toDate: { type: String, required: true },
  reason: { type: String, required: true },
  
  // Approval status
  status: { 
    type: String, 
    enum: ['Pending', 'Approved', 'Rejected'], 
    default: 'Pending' 
  }
}, { timestamps: true });

module.exports = mongoose.model('Leave', leaveSchema);