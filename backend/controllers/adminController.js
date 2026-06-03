
 
const User = require('../models/User');
const Department = require('../models/Department');
const csv = require('csv-parser');
const fs = require('fs');
const bcrypt = require('bcryptjs');

// @desc   Create Department
exports.createDepartment = async (req, res) => {
  try {
    const { name, code, description } = req.body;

    const existingDept = await Department.findOne({ $or: [{ name }, { code }] });
    if (existingDept) {
      return res.status(400).json({ success: false, message: 'Department already exists' });
    }

    const department = await Department.create({ name, code: code.toUpperCase(), description });

    res.status(201).json({ success: true, data: department, message: 'Department created successfully' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Get All Departments
exports.getDepartments = async (req, res) => {
  try {
    const departments = await Department.find({ isActive: true })
      .populate('hodId', 'name email phone')
      .sort({ createdAt: -1 });

    res.json({ success: true, count: departments.length, data: departments });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Assign HOD to Department
exports.assignHOD = async (req, res) => {
  try {
    const { userId, departmentId } = req.body;

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const department = await Department.findById(departmentId);
    if (!department) {
      return res.status(404).json({ success: false, message: 'Department not found' });
    }

    // Update user to HOD role
    user.role = 'hod';
    user.departmentId = departmentId;
    await user.save();

    // Update department HOD reference
    department.hodId = userId;
    await department.save();

    res.json({ 
      success: true, 
      data: user, 
      message: `${user.name} assigned as HOD of ${department.name}` 
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Upload Staff CSV
exports.uploadStaffCSV = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'Please upload a CSV file' });
    }

    const results = [];
    const errors = [];
    let createdCount = 0;

    fs.createReadStream(req.file.path)
      .pipe(csv())
      .on('data', (data) => results.push(data))
      .on('end', async () => {
        for (const row of results) {
          try {
            const { name, email, department_code, role } = row;
            
            if (!name || !email || !department_code || !role) {
              errors.push(`Missing fields in row: ${JSON.stringify(row)}`);
              continue;
            }

            // Find department by code
            const dept = await Department.findOne({ code: department_code.toUpperCase() });
            if (!dept) {
              errors.push(`Department "${department_code}" not found for ${email}`);
              continue;
            }

            // Check if user exists
            const existingUser = await User.findOne({ email });
            if (existingUser) {
              errors.push(`User with email ${email} already exists`);
              continue;
            }

            // Create password from email or generate random
            const password = email.split('@')[0] + '@123';

            const validRoles = ['admin', 'hod', 'teacher', 'class_teacher', 'student'];
            const userRole = validRoles.includes(role.toLowerCase()) ? role.toLowerCase() : 'teacher';

            await User.create({
              name: name.trim(),
              email: email.trim().toLowerCase(),
              password,
              role: userRole,
              departmentId: dept._id
            });

            createdCount++;
          } catch (err) {
            errors.push(`Error processing ${row.email}: ${err.message}`);
          }
        }

        // Delete temp file
        fs.unlinkSync(req.file.path);

        res.json({
          success: true,
          message: `CSV processed! Created: ${createdCount} users`,
          data: { createdCount, totalRows: results.length, errors }
        });
      });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Get All Users (Admin Dashboard)
exports.getAllUsers = async (req, res) => {
  try {
    const users = await User.find({ isActive: true })
      .select('-password')
      .populate('departmentId', 'name code')
      .populate('classId', 'name')
      .sort({ createdAt: -1 });

    res.json({ success: true, count: users.length, data: users });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};