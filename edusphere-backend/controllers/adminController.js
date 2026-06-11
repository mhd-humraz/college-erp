// edusphere-backend/controllers/adminController.js snippet
const User = require('../models/User');
const Faculty = require('../models/Faculty');
const Student = require('../models/Student');
const Department = require('../models/Department');
const Course = require('../models/Course');
const Subject = require('../models/Subject');
const Attendance = require('../models/Attendance');
const bcrypt = require('bcryptjs');


exports.getDashboardMetrics = async (req, res) => {
    try {
        const totalStudents = await Student.countDocuments();
        const totalFaculty = await Faculty.countDocuments();
        const totalDepartments = await Department.countDocuments();

        const attendanceLogs = await Attendance.find();

        let totalRecords = 0;
        let presentRecords = 0;

        attendanceLogs.forEach(log => {
            log.records.forEach(record => {
                totalRecords++;
                if (record.isPresent) presentRecords++;
            });
        });

        const globalAttendance =
            totalRecords > 0
                ? Number(((presentRecords / totalRecords) * 100).toFixed(2))
                : 0;

        res.status(200).json({
            success: true,
            metrics: {
                totalStudents,
                totalFaculty,
                totalDepartments,
                globalAttendance
            }
        });

    } catch (err) {
        res.status(500).json({
            error: err.message
        });
    }
};

exports.uploadStaffCSV = async (req, res) => {
    try {
        if (!req.file) return res.status(400).json({ error: "CSV data attachment payload missing." });

        // Convert the raw multer buffer stream to a readable text layout string
        const csvDataString = req.file.buffer.toString('utf8');
        const rows = csvDataString.split('\n').filter(row => row.trim().length > 0);

        // Skip headers line (e.g., name,email,designation,phone,role,password)
        for (let i = 1; i < rows.length; i++) {
            const [name, email, designation, phone, role, password] = rows[i].split(',');

            if (!email || !role || !password) continue;

            // 1. Provision Auth Core Entity Account profile
            const userExists = await User.findOne({ email: email.trim().toLowerCase() });
            if (userExists) continue;

            const salt = await bcrypt.genSalt(10);
            const hashedPassword = await bcrypt.hash(password.trim(), salt);

            const newUser = await User.create({
                email: email.trim().toLowerCase(),
                password: hashedPassword,
                role: role.trim() // 'HOD', 'Teacher', 'Library Staff'
            });

            // 2. Map structural profile down to operational Faculty Collections
            await Faculty.create({
                user: newUser._id,
                employeeId: `EMP-${Date.now()}-${i}`,
                department: req.body.departmentId, // Passed along form metadata fields
                designation: designation.trim()
            });
        }

        res.status(201).json({ success: true, message: "Staff directory provisioned successfully." });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};
 

exports.createDepartment = async (req, res) => {
    try {
        const { name, code } = req.body;

        const department = await Department.create({
            name,
            code
        });

        res.status(201).json({
            success: true,
            department
        });
    } catch (err) {
        res.status(500).json({
            error: err.message
        });
    }
};

exports.getDepartments = async (req, res) => {
    try {
        const departments = await Department.find().sort({ createdAt: -1 });

        res.status(200).json({
            success: true,
            departments
        });
    } catch (err) {
        res.status(500).json({
            error: err.message
        });
    }
};
exports.createCourse = async (req, res) => {
    try {
        const { name, departmentId, totalSemesters } = req.body;

        const course = await Course.create({
            name,
            department: departmentId,
            totalSemesters
        });

        res.status(201).json({
            success: true,
            course
        });
    } catch (err) {
        res.status(500).json({
            error: err.message
        });
    }
};

exports.getCourses = async (req, res) => {
    try {
        const courses = await Course.find()
            .populate('department', 'name code');

        res.status(200).json({
            success: true,
            courses
        });
    } catch (err) {
        res.status(500).json({
            error: err.message
        });
    }
};


exports.createSubject = async (req, res) => {
    try {
        const { name, code, courseId, semester } = req.body;

        const subject = await Subject.create({
            name,
            code,
            course: courseId,
            semester
        });

        res.status(201).json({
            success: true,
            subject
        });

    } catch (err) {
        res.status(500).json({
            error: err.message
        });
    }
};

exports.getSubjects = async (req, res) => {
    try {
        const subjects = await Subject.find()
            .populate('course', 'name');

        res.status(200).json({
            success: true,
            subjects
        });

    } catch (err) {
        res.status(500).json({
            error: err.message
        });
    }
};

exports.createFaculty = async (req, res) => {
    try {
        const {
            email,
            password,
            employeeId,
            departmentId,
            designation
        } = req.body;

        const existingUser = await User.findOne({ email });

        if (existingUser) {
            return res.status(400).json({
                error: "Faculty account already exists."
            });
        }

        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        const user = await User.create({
            email,
            password: hashedPassword,
            role: "Teacher"
        });

        const faculty = await Faculty.create({
            user: user._id,
            employeeId,
            department: departmentId,
            designation
        });

        res.status(201).json({
            success: true,
            faculty
        });

    } catch (err) {
        res.status(500).json({
            error: err.message
        });
    }
};
exports.getFaculty = async (req, res) => {
    try {
        const faculty = await Faculty.find()
            .populate("user", "email role")
            .populate("department", "name code");

        res.status(200).json({
            success: true,
            faculty
        });

    } catch (err) {
        res.status(500).json({
            error: err.message
        });
    }
};

exports.createStudent = async (req, res) => {
    try {
        const {
            email,
            password,
            rollNumber,
            departmentId,
            courseId,
            currentSemester
        } = req.body;

        const existingUser = await User.findOne({ email });

        if (existingUser) {
            return res.status(400).json({
                error: "Student account already exists."
            });
        }

        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        const user = await User.create({
            email,
            password: hashedPassword,
            role: "Student"
        });

        const student = await Student.create({
            user: user._id,
            rollNumber,
            department: departmentId,
            course: courseId,
            currentSemester
        });

        res.status(201).json({
            success: true,
            student
        });

    } catch (err) {
        res.status(500).json({
            error: err.message
        });
    }
};

exports.getStudents = async (req, res) => {
    try {
        const students = await Student.find()
            .populate("user", "email role")
            .populate("department", "name code")
            .populate("course", "name");

        res.status(200).json({
            success: true,
            students
        });

    } catch (err) {
        res.status(500).json({
            error: err.message
        });
    }
};