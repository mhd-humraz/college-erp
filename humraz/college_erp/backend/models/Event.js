const mongoose = require('mongoose');

const eventSchema = new mongoose.Schema({
  title: { type: String, required: true, trim: true },
  description: { type: String, required: true },
  type: { type: String, enum: ['academic', 'cultural', 'sports', 'technical', 'workshop', 'seminar', 'conference', 'competition', 'other'], required: true },
  category: { type: String, enum: ['national', 'state', 'inter-college', 'intra-college', 'department', 'open'], required: true },
  startDate: { type: Date, required: true },
  endDate: { type: Date, required: true },
  venue: { type: String, required: true },
  organizer: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  department: { type: mongoose.Schema.Types.ObjectId, ref: 'Department' },
  coordinators: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  maxParticipants: Number,
  registeredCount: { type: Number, default: 0 },
  registrationFee: { type: Number, default: 0 },
  registrationDeadline: Date,
  registrationOpen: { type: Boolean, default: true },
  participants: [{
    student: { type: mongoose.Schema.Types.ObjectId, ref: 'Student' },
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    registeredAt: { type: Date, default: Date.now },
    attended: { type: Boolean, default: false },
    certificateIssued: { type: Boolean, default: false },
    position: String,
    remarks: String
  }],
  prizes: [{ position: String, prize: String, value: Number }],
  sponsors: [{ name: String, logo: String, amount: Number }],
  attachments: [{ fileName: String, fileUrl: String, fileType: String }],
  status: { type: String, enum: ['upcoming', 'ongoing', 'completed', 'cancelled', 'postponed'], default: 'upcoming' },
  isFeatured: { type: Boolean, default: false },
  createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  rules: [String]
}, { timestamps: true, toJSON: { virtuals: true }, toObject: { virtuals: true } });

eventSchema.index({ startDate: -1 });
eventSchema.index({ type: 1 });
eventSchema.index({ status: 1 });
eventSchema.index({ 'participants.student': 1 });

module.exports = mongoose.model('Event', eventSchema);