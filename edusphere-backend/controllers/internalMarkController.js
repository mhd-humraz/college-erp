const InternalMark = require("../models/InternalMark");
const Student = require("../models/Student");
const Subject = require("../models/Subject");

// CREATE INTERNAL MARK

exports.createInternalMark = async (req, res) => {
    try {
        const {
            student,
            subject,
            internal1,
            internal2,
            assignment,
            seminar
        } = req.body;

        const studentData = await Student.findById(student);

        if (!studentData) {
            return res.status(404).json({
                success: false,
                message: "Student not found"
            });
        }

        const subjectData = await Subject.findById(subject);

        if (!subjectData) {
            return res.status(404).json({
                success: false,
                message: "Subject not found"
            });
        }

        if (
            studentData.course.toString() !==
            subjectData.course.toString()
        ) {
            return res.status(400).json({
                success: false,
                message: "Subject does not belong to student's course"
            });
        }

        if (
            studentData.currentSemester !==
            subjectData.semester
        ) {
            return res.status(400).json({
                success: false,
                message: "Subject does not belong to student's current semester"
            });
        }

        const existingMark = await InternalMark.findOne({
            student,
            subject,
            semester: studentData.currentSemester
        });

        if (existingMark) {
            return res.status(400).json({
                success: false,
                message: "Internal mark already exists"
            });
        }

        const internalMark = await InternalMark.create({
            student,
            subject,
            semester: studentData.currentSemester,
            internal1,
            internal2,
            assignment,
            seminar
        });

        res.status(201).json({
            success: true,
            message: "Internal mark created successfully",
            internalMark
        });

    } catch (error) {
        res.status(500).json({
            success: false,
            message: error.message
        });
    }
};


// GET ALL INTERNAL MARKS

exports.getInternalMarks = async (req, res) => {
    try {
        const marks = await InternalMark.find()
            .populate({
                path: "student",
                populate: {
                    path: "user",
                    select: "name email"
                }
            })
            .populate(
                "subject",
                "name code semester"
            )
            .sort({
                createdAt: -1
            });

        res.status(200).json({
            success: true,
            count: marks.length,
            marks
        });

    } catch (error) {
        res.status(500).json({
            success: false,
            message: error.message
        });
    }
};


// GET STUDENT INTERNAL MARKS

exports.getStudentInternalMarks = async (req, res) => {
    try {
        const marks = await InternalMark.find({
            student: req.params.studentId
        })
            .populate(
                "subject",
                "name code semester"
            )
            .sort({
                semester: 1
            });

        res.status(200).json({
            success: true,
            marks
        });

    } catch (error) {
        res.status(500).json({
            success: false,
            message: error.message
        });
    }
};


// GET SUBJECT INTERNAL MARKS

exports.getSubjectInternalMarks = async (req, res) => {
    try {
        const marks = await InternalMark.find({
            subject: req.params.subjectId
        })
            .populate({
                path: "student",
                populate: {
                    path: "user",
                    select: "name email"
                }
            })
            .sort({
                createdAt: -1
            });

        res.status(200).json({
            success: true,
            marks
        });

    } catch (error) {
        res.status(500).json({
            success: false,
            message: error.message
        });
    }
};


// UPDATE INTERNAL MARK

exports.updateInternalMark = async (req, res) => {
    try {
        const mark = await InternalMark.findById(
            req.params.id
        );

        if (!mark) {
            return res.status(404).json({
                success: false,
                message: "Internal mark not found"
            });
        }

        const allowedFields = [
            "internal1",
            "internal2",
            "assignment",
            "seminar"
        ];

        allowedFields.forEach((field) => {
            if (req.body[field] !== undefined) {
                mark[field] = req.body[field];
            }
        });

        await mark.save();

        res.status(200).json({
            success: true,
            message: "Internal mark updated successfully",
            internalMark: mark
        });

    } catch (error) {
        res.status(500).json({
            success: false,
            message: error.message
        });
    }
};


// DELETE INTERNAL MARK

exports.deleteInternalMark = async (req, res) => {
    try {
        const mark = await InternalMark.findByIdAndDelete(
            req.params.id
        );

        if (!mark) {
            return res.status(404).json({
                success: false,
                message: "Internal mark not found"
            });
        }

        res.status(200).json({
            success: true,
            message: "Internal mark deleted successfully"
        });

    } catch (error) {
        res.status(500).json({
            success: false,
            message: error.message
        });
    }
};