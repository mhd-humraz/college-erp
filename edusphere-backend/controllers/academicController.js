// controllers/academicController.js

const Department = require("../models/Department");
const Course = require("../models/Course");
const Subject = require("../models/Subject");
const Student = require("../models/Student");
const Attendance = require("../models/Attendance");
const Marks = require("../models/Marks");

const AcademicAggregator = require(
    "../services/academicAggregator"
);

// ==========================================
// 1. ADMINISTRATIVE INFRASTRUCTURE MANAGERS
// ==========================================

exports.createDepartment = async (req, res) => {
    try {

        const { name, code } = req.body;

        const dept = await Department.create({
            name,
            code
        });

        res.status(201).json({
            success: true,
            data: dept
        });

    } catch (err) {

        res.status(400).json({
            success: false,
            message: err.message
        });

    }
};


exports.createCourse = async (req, res) => {
    try {

        const {
            name,
            departmentId,
            totalSemesters
        } = req.body;

        const course = await Course.create({
            name,
            department: departmentId,
            totalSemesters
        });

        res.status(201).json({
            success: true,
            data: course
        });

    } catch (err) {

        res.status(400).json({
            success: false,
            message: err.message
        });

    }
};


exports.createSubject = async (req, res) => {
    try {

        const {
            name,
            code,
            courseId,
            semester
        } = req.body;

        const subject = await Subject.create({
            name,
            code,
            course: courseId,
            semester
        });

        res.status(201).json({
            success: true,
            data: subject
        });

    } catch (err) {

        res.status(400).json({
            success: false,
            message: err.message
        });

    }
};


exports.getSubjects = async (req, res) => {
    try {

        const subjects = await Subject.find()
            .populate(
                "course",
                "name"
            )
            .sort({
                semester: 1,
                name: 1
            });

        res.status(200).json({
            success: true,
            count: subjects.length,
            subjects
        });

    } catch (err) {

        res.status(500).json({
            success: false,
            message: err.message
        });

    }
};


// ==========================================
// 2. TEACHER OPERATION MANAGERS
// ==========================================

exports.submitAttendance = async (req, res) => {
    try {

        const operationalLog =
            await AcademicAggregator
                .verifyAndRecordAttendance(
                    req,
                    req.body
                );

        res.status(201).json({
            success: true,
            message:
                "Attendance ledger committed successfully, constraints verified, alerts sent.",
            data: operationalLog
        });

    } catch (err) {

        res.status(400).json({
            success: false,
            message: err.message
        });

    }
};


exports.submitMarks = async (req, res) => {
    try {

        const {
            subjectId,
            examType,
            maxMarks,
            passMarks,
            scores
        } = req.body;

        const subject = await Subject.findById(
            subjectId
        );

        if (!subject) {

            return res.status(404).json({
                success: false,
                message: "Subject not found"
            });

        }

        if (
            !scores ||
            !Array.isArray(scores) ||
            scores.length === 0
        ) {

            return res.status(400).json({
                success: false,
                message: "Scores are required"
            });

        }

        const studentIds = scores.map(
            score => score.student
        );

        const students = await Student.find({
            _id: {
                $in: studentIds
            }
        });

        if (
            students.length !==
            studentIds.length
        ) {

            return res.status(400).json({
                success: false,
                message:
                    "One or more students not found"
            });

        }

        for (const student of students) {

            if (
                student.course.toString() !==
                subject.course.toString()
            ) {

                return res.status(400).json({
                    success: false,
                    message:
                        `Student ${student.rollNumber} does not belong to subject course`
                });

            }

            if (
                student.currentSemester !==
                subject.semester
            ) {

                return res.status(400).json({
                    success: false,
                    message:
                        `Student ${student.rollNumber} is not in subject semester`
                });

            }

        }

        const existingMarks = await Marks.findOne({
            subject: subjectId,
            examType,
            semester: subject.semester
        });

        if (existingMarks) {

            return res.status(400).json({
                success: false,
                message:
                    "Marks already submitted for this subject and exam"
            });

        }

        const gradeSheet = await Marks.create({
            subject: subjectId,
            examType,
            semester: subject.semester,
            maxMarks,
            passMarks,
            scores
        });

        const populatedGradeSheet =
            await Marks.findById(
                gradeSheet._id
            )
                .populate(
                    "subject",
                    "name code semester"
                )
                .populate({
                    path: "scores.student",
                    populate: {
                        path: "user",
                        select: "email"
                    }
                });

        res.status(201).json({
            success: true,
            message:
                "Exam marks submitted successfully",
            data: populatedGradeSheet
        });

    } catch (err) {

        res.status(500).json({
            success: false,
            message: err.message
        });

    }
};


// ==========================================
// 3. STUDENT INSIGHT ENGINE
// ==========================================

exports.getStudentPerformanceSummary = async (
    req,
    res
) => {

    try {

        const { studentId } = req.params;

        const attendanceLogs =
            await Attendance.find({
                "records.student": studentId
            })
                .populate(
                    "subject",
                    "name code"
                );

        const totalClasses =
            attendanceLogs.length;

        let presentCount = 0;

        attendanceLogs.forEach((log) => {

            const match = log.records.find(
                (record) =>
                    record.student.toString() ===
                    studentId
            );

            if (
                match &&
                match.isPresent
            ) {
                presentCount++;
            }

        });

        const marksLogs =
            await Marks.find({
                "scores.student": studentId
            })
                .populate(
                    "subject",
                    "name code"
                );

        res.status(200).json({

            success: true,

            attendance: {

                totalSlots: totalClasses,

                presentSlots: presentCount,

                percentage:
                    totalClasses > 0
                        ? Number(
                            (
                                (
                                    presentCount /
                                    totalClasses
                                ) * 100
                            ).toFixed(2)
                        )
                        : 100

            },

            grades: marksLogs

        });

    } catch (err) {

        res.status(500).json({
            success: false,
            message: err.message
        });

    }

};


// ==========================================
// 4. STUDENT SEMESTER RESULT
// ==========================================

exports.getStudentSemesterResult = async (
    req,
    res
) => {

    try {

        const { studentId } = req.params;

        const semester = Number(
            req.query.semester
        );

        if (
            !semester ||
            semester < 1 ||
            semester > 8
        ) {

            return res.status(400).json({
                success: false,
                message: "Valid semester is required"
            });

        }

        // FIND STUDENT FIRST

        const student = await Student.findById(
            studentId
        )
            .populate(
                "course",
                "name"
            )
            .populate(
                "department",
                "name"
            );

        if (!student) {

            return res.status(404).json({
                success: false,
                message: "Student not found"
            });

        }

        // STUDENT SELF-ACCESS SECURITY

        if (req.user.role === "Student") {

            const loggedInStudent =
                await Student.findOne({
                    user: req.user.id
                });

            if (!loggedInStudent) {

                return res.status(404).json({
                    success: false,
                    message: "Student profile not found"
                });

            }

            if (
                loggedInStudent._id.toString() !==
                student._id.toString()
            ) {

                return res.status(403).json({
                    success: false,
                    message:
                        "You can only view your own result"
                });

            }

        }

        const marksLogs =
            await Marks.find({

                semester,

                examType: "Semester_Final",

                "scores.student": student._id

            })
                .populate(
                    "subject",
                    "name code semester"
                )
                .sort({
                    createdAt: 1
                });

        // KEEP YOUR EXISTING CODE BELOW
         

        const results = [];

        let totalObtained = 0;
        let totalMaximum = 0;

        let passedSubjects = 0;
        let failedSubjects = 0;

        marksLogs.forEach(
            (markLog) => {

                const studentScore =
                    markLog.scores.find(
                        (score) =>
                            score.student
                                .toString() ===
                            student._id
                                .toString()
                    );

                if (!studentScore) {
                    return;
                }

                const percentage =
                    markLog.maxMarks === 0
                        ? 0
                        : Number(
                            (
                                (
                                    studentScore
                                        .marksObtained /
                                    markLog.maxMarks
                                ) * 100
                            ).toFixed(2)
                        );

                totalObtained +=
                    studentScore.marksObtained;

                totalMaximum +=
                    markLog.maxMarks;

                if (
                    studentScore.status ===
                    "Pass"
                ) {

                    passedSubjects++;

                } else {

                    failedSubjects++;

                }

                results.push({

                    subjectId:
                        markLog.subject._id,

                    subjectName:
                        markLog.subject.name,

                    subjectCode:
                        markLog.subject.code,

                    marksObtained:
                        studentScore
                            .marksObtained,

                    maxMarks:
                        markLog.maxMarks,

                    percentage,

                    grade:
                        studentScore.grade,

                    status:
                        studentScore.status

                });

            }
        );

        const overallPercentage =
            totalMaximum === 0
                ? 0
                : Number(
                    (
                        (
                            totalObtained /
                            totalMaximum
                        ) * 100
                    ).toFixed(2)
                );

        const overallStatus =
            results.length === 0
                ? "No Result"
                : failedSubjects > 0
                    ? "Fail"
                    : "Pass";

        res.status(200).json({

            success: true,

            student: {

                id: student._id,

                rollNumber:
                    student.rollNumber,

                course:
                    student.course,

                department:
                    student.department,

                currentSemester:
                    student.currentSemester

            },

            semester,

            summary: {

                totalSubjects:
                    results.length,

                passedSubjects,

                failedSubjects,

                totalObtained,

                totalMaximum,

                overallPercentage,

                overallStatus

            },

            results

        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }

};