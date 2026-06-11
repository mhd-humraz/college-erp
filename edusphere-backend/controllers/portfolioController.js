// controllers/portfolioController.js
const Achievement = require('../models/Achievement');
const Student = require('../models/Student');

// 1. ADD NEW ACCORDE TO PROFILE
exports.addAchievement = async (req, res) => {
    try {
        const studentProfile = await Student.findOne({ user: req.user.id });
        if (!studentProfile) return res.status(404).json({ error: "Profile profile matching user reference not found." });

        const accolade = await Achievement.create({
            ...req.body,
            student: studentProfile._id
        });

        res.status(201).json({ success: true, data: accolade });
    } catch (err) { res.status(500).json({ error: err.message }); }
};

// 2. COMPILE PORTFOLIO SUMMARY PROFILE REPORT
exports.getPortfolioSummary = async (req, res) => {
    try {
        const { studentId } = req.params;

        const [profileDetails, accolades] = await Promise.all([
            Student.findById(studentId).populate({ path: 'user', select: 'email' }).populate('department course'),
            Achievement.find({ student: studentId }).sort({ dateEarned: -1 })
        ]);

        if (!profileDetails) return res.status(404).json({ error: "Target student entry missing." });

        // Compiles a profile mapping dataset ready for frontend visualization or raw text layouts
        res.status(200).json({
            success: true,
            summary: {
                profile: {
                    rollNumber: profileDetails.rollNumber,
                    department: profileDetails.department.name,
                    course: profileDetails.course.name,
                    semester: profileDetails.currentSemester
                },
                achievements: accolades
            }
        });
    } catch (err) { res.status(500).json({ error: err.message }); }
};