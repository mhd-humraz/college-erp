const express = require('express');
const router = express.Router();
const Attendance = require('../models/Attendance');
const auth = require('../middleware/auth');

// GET /api/attendance - Get all attendance records
router.get('/', auth, async (req, res) => {
  try {
    const { date, course, student } = req.query;
    let filter = {};
    if (date) filter.date = new Date(date);
    if (course) filter.course = course;
    if (student) filter.student = student;
    
    const records = await Attendance.find(filter)
      .populate('student', 'name email')
      .populate('course', 'name code')
      .sort({ date: -1 });
    res.json(records);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// POST /api/attendance - Mark attendance
router.post('/', auth, async (req, res) => {
  try {
    const { student, course, date, status, remarks } = req.body;
    
    // Check if attendance already marked for this student/course/date
    const existing = await Attendance.findOne({ student, course, date: new Date(date) });
    if (existing) {
      return res.status(400).json({ message: 'Attendance already marked for this date' });
    }
    
    const attendance = await Attendance.create({
      student,
      course,
      date,
      status,
      remarks,
      markedBy: req.user.id
    });
    
    res.status(201).json(attendance);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// PUT /api/attendance/:id - Update attendance
router.put('/:id', auth, async (req, res) => {
  try {
    const { status, remarks } = req.body;
    const attendance = await Attendance.findByIdAndUpdate(
      req.params.id,
      { status, remarks, updatedBy: req.user.id },
      { new: true }
    );
    res.json(attendance);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// GET /api/attendance/report - Generate attendance report
router.get('/report', auth, async (req, res) => {
  try {
    const { course, startDate, endDate } = req.query;
    const report = await Attendance.aggregate([
      {
        $match: {
          course: mongoose.Types.ObjectId(course),
          date: { $gte: new Date(startDate), $lte: new Date(endDate) }
        }
      },
      {
        $group: {
          _id: '$student',
          total: { $sum: 1 },
          present: { $sum: { $cond: [{ $eq: ['$status', 'Present'] }, 1, 0] } },
          absent: { $sum: { $cond: [{ $eq: ['$status', 'Absent'] }, 1, 0] } },
          late: { $sum: { $cond: [{ $eq: ['$status', 'Late'] }, 1, 0] } }
        }
      }
    ]);
    res.json(report);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;