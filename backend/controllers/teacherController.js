const User = require('../models/User');
const Attendance = require('../models/Attendance');
const Mark = require('../models/Mark');
const Subject = require('../models/Subject');
const Timetable = require('../models/Timetable');

// @desc   Get Teacher's Classes & Students
exports.getMyClasses = async (req, res) => {
  try {
    const subjects = await Subject.find({ teacherId: req.user._id })
      .populate('classId', 'name semester section')
      .distinct('classId');

    const classes = await User.find({ 
      _id: { $in: subjects },
      role: 'student',
      isActive: true 
    })
      .populate('classId', 'name semester section')
      .select('-password');

    res.json({ success: true, data: classes });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Get Students by Class (for attendance/marks)
exports.getStudentsByClass = async (req, res) => {
  try {
    const { classId } = req.params;
    
    const students = await User.find({ 
      classId, 
      role: 'student',
      isActive: true 
    })
      .select('name rollNumber email _id')
      .sort({ name: 1 });

    res.json({ success: true, count: students.length, data: students });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Mark Attendance
exports.markAttendance = async (req, res) => {
  try {
    const { date, subjectId, records } = req.body; // records: [{ studentId, status }]

    if (!records || records.length === 0) {
      return res.status(400).json({ success: false, message: 'No attendance records provided' });
    }

    // Verify teacher teaches this subject
    const subject = await Subject.findOne({ _id: subjectId, teacherId: req.user._id });
    if (!subject) {
      return res.status(403).json({ success: false, message: 'You are not assigned to this subject' });
    }

    const attendanceDate = new Date(date);
    const operations = records.map(record => ({
      updateOne: {
        filter: { studentId: record.studentId, subjectId, date: attendanceDate },
        update: {
          studentId: record.studentId,
          subjectId,
          teacherId: req.user._id,
          date: attendanceDate,
          status: record.status,
          markedAt: new Date()
        },
        upsert: true
      }
    }));

    const result = await Attendance.bulkWrite(operations);

    res.json({ 
      success: true, 
      message: `Attendance marked for ${records.length} students`,
      data: result 
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Upload Marks
exports.uploadMarks = async (req, res) => {
  try {
    const { examType, subjectId, marks } = req.body; // marks: [{ studentId, score, maxScore }]

    const subject = await Subject.findOne({ _id: subjectId, teacherId: req.user._id });
    if (!subject) {
      return res.status(403).json({ success: false, message: 'Access denied for this subject' });
    }

    const markDocuments = marks.map(m => ({
      studentId: m.studentId,
      subjectId,
      examType,
      score: m.score,
      maxScore: m.maxScore || 50,
      semester: subject.semester,
      markedBy: req.user._id
    }));

    const result = await Mark.insertMany(markDocuments, { ordered: false });

    res.status(201).json({ 
      success: true, 
      message: `Marks uploaded for ${result.length} students`,
      data: result 
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Get Teacher's Timetable
exports.getMyTimetable = async (req, res) => {
  try {
    const timetable = await Timetable.find({ teacherId: req.user._id })
      .populate('classId', 'name semester section')
      .populate('subjectId', 'name code type')
      .sort({ day: 1, period: 1 });

    // Group by day
    const grouped = {};
    timetable.forEach(entry => {
      if (!grouped[entry.day]) grouped[entry.day] = [];
      grouped[entry.day].push(entry);
    });

    res.json({ success: true, data: grouped });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};