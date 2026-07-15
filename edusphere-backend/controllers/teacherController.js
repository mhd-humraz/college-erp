const Student = require("../models/Student");
const Faculty = require("../models/Faculty");

exports.getProfile = async (req, res) => {
    try {

        const faculty = await Faculty.findOne({
            user: req.user.id
        })
        .populate("user", "name email role")
        .populate("department", "name code");

        if (!faculty) {
            return res.status(404).json({
                success: false,
                message: "Faculty profile not found"
            });
        }

        res.json({
            success: true,
            teacher: {
                id: faculty._id,
                employeeId: faculty.employeeId,
                designation: faculty.designation,
                department: faculty.department,
                user: faculty.user
            }
        });

    } catch (err) {
        res.status(500).json({
            success: false,
            message: err.message
        });
    }
};exports.getStudents = async (req, res) => {
    try {
        const faculty = await Faculty.findOne({
            user: req.user.id
        });

        if (!faculty) {
            return res.status(404).json({
                success: false,
                message: "Faculty profile not found"
            });
        }

        const students = await Student.find({
            department: faculty.department
        })
            .populate("user", "name email")
            .populate("course", "name")
            .populate("department", "name code");

        const formattedStudents = students.map((student) => {
            return {
                studentId: student._id,
                name:
                    student.user?.name ??
                    "Unknown Student",
                email:
                    student.user?.email ??
                    "N/A",
                rollNumber:
                    student.rollNumber ?? "N/A",
                semester:
                    student.currentSemester ?? 1,
                course:
                    student.course?.name ??
                    "Course Not Found",
                department:
                    student.department?.name ??
                    "Department Not Found",
                profilePhoto:
                    student.profilePhoto ?? ""
            };
        });

        return res.status(200).json({
            success: true,
            count: formattedStudents.length,
            students: formattedStudents
        });

    } catch (error) {
        console.error(
            "GET TEACHER STUDENTS ERROR:",
            error
        );

        return res.status(500).json({
            success: false,
            message: error.message
        });
    }
};