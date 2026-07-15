const mongoose = require('mongoose');

const TimetableSchema = new mongoose.Schema({
    course: { type: mongoose.Schema.Types.ObjectId, ref: 'Course', required: true },
    semester: { type: Number, required: true },
    dayOfWeek: { type: String, enum: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'], required: true },
    hour: { type: Number, required: true }, // Slot 1, 2, 3, etc.
    subject: { type: mongoose.Schema.Types.ObjectId, ref: 'Subject', required: true },
    faculty: { type: mongoose.Schema.Types.ObjectId, ref: 'Faculty', required: true },
    roomNumber: { type: String, required: true, trim: true }
}, { timestamps: true });

module.exports = mongoose.model('Timetable', TimetableSchema);