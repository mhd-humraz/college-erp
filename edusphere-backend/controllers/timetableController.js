// controllers/timetableController.js
const Timetable = require('../models/Timetable');

// ==========================================
// 1. GENERATE AND COMMIT TIMETABLE SLOT
// ==========================================
exports.createSlot = async (req, res) => {
    try {
        const { course, semester, dayOfWeek, hour, subject, faculty, roomNumber } = req.body;

        // Conflict Guard 1: Verify if the specific Room is already occupied at this exact hour/day
        const roomConflict = await Timetable.findOne({ dayOfWeek, hour, roomNumber });
        if (roomConflict) {
            return res.status(400).json({ error: `Room ${roomNumber} is already occupied by another class at this time.` });
        }

        // Conflict Guard 2: Verify if the assigned Faculty is already teaching another class at this exact hour/day
        const facultyConflict = await Timetable.findOne({ dayOfWeek, hour, faculty });
        if (facultyConflict) {
            return res.status(400).json({ error: `This faculty member is already scheduled to teach another course during this period.` });
        }

        const newSlot = await Timetable.create({
            course,
            semester,
            dayOfWeek,
            hour,
            subject,
            faculty,
            roomNumber
        });

        res.status(201).json({ success: true, data: newSlot });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// ==========================================
// 2. READ VIEW FOR SPECIFIC COURSE / SEMESTER
// ==========================================
exports.getScheduleForClass = async (req, res) => {
    try {
        const { courseId, semesterNum } = req.params;

        const schedule = await Timetable.find({ course: courseId, semester: semesterNum })
            .populate('subject', 'name code')
            .populate({
                path: 'faculty',
                populate: { path: 'user', select: 'name' } // Pulls the faculty's name from user collection
            })
            .sort({ hour: 1 }); // Sort chronologically by class period

        res.status(200).json({ success: true, data: schedule });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};