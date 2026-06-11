// edusphere-backend/controllers/hodController.js snippet
const User = require('../models/User');
const Student = require('../models/Student');
const bcrypt = require('bcryptjs');

exports.uploadDepartmentStudentsCSV = async (req, res) => {
    try {
        if (!req.file) return res.status(400).json({ error: "Student matrix document dataset absent." });

        const csvDataString = req.file.buffer.toString('utf8');
        const rows = csvDataString.split('\n').filter(row => row.trim().length > 0);

        // Skip headers (e.g., name,email,rollNumber,batchYear,password)
        for (let i = 1; i < rows.length; i++) {
            const [name, email, rollNumber, batchYear, password] = rows[i].split(',');

            if (!email || !rollNumber || !password) continue;

            const userExists = await User.findOne({ email: email.trim().toLowerCase() });
            if (userExists) continue;

            const salt = await bcrypt.genSalt(10);
            const hashedPassword = await bcrypt.hash(password.trim(), salt);

            // Create base student authorization account card profile
            const newUser = await User.create({
                email: email.trim().toLowerCase(),
                password: hashedPassword,
                role: 'Student'
            });

            // Associate down into core Student operational tables
            await Student.create({
                user: newUser._id,
                rollNumber: rollNumber.trim().toUpperCase(),
                department: req.body.departmentId, // Read from form context criteria parameters
                course: req.body.courseId,
                currentSemester: 1 // Baseline assignment default
            });
        }

        res.status(201).json({ success: true, message: "Department student enrollment matrix sync absolute." });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};