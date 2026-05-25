
 
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
// @desc   Upload Staff CSV (FIXED - With Bcrypt Hashing!)
exports.uploadStaffCSV = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'Please upload a CSV file' });
    }

    const results = [];
    const errors = [];
    let createdCount = 0;

    console.log('📁 Starting Staff CSV Upload...');
    console.log('📄 File:', req.file.originalname);

    fs.createReadStream(req.file.path)
      .pipe(csv())
      .on('data', (data) => results.push(data))
      .on('end', async () => {

        console.log(`📊 Total rows in CSV: ${results.length}`);

        for (let i = 0; i < results.length; i++) {
          try {
            const row = results[i];
            
            console.log(`\n📝 Processing row ${i + 1}:`, row);

            const name = `${row["First Name"] || ''} ${row["Last Name"] || ''}`.trim();
            const email = row["Email"]?.trim().toLowerCase();
            const department_code = row["Department"];
            const role = row["Role"];
            
            // Validation
            if (!name || !email || !department_code || !role) {
              console.warn(`⚠️ Skipping row ${i+1}: Missing fields`);
              errors.push(`Missing fields in row ${i+1}: ${JSON.stringify(row)}`);
              continue;
            }

            // Find department
            const dept = await Department.findOne({
              $or: [
                { code: department_code.toUpperCase() },
                { name: department_code }
              ]
            });

            if (!dept) {
              console.error(`❌ Department not found: ${department_code}`);
              errors.push(`Department "${department_code}" not found for ${email}`);
              continue;
            }

            // Check duplicate
            const existingUser = await User.findOne({ email });
            if (existingUser) {
              console.warn(`⚠️ User already exists: ${email}`);
              errors.push(`User with email ${email} already exists`);
              continue;
            }

            // ✅ FIXED: Generate & HASH password with bcrypt!
            const plainPassword = row["Password"] || `${email.split('@')[0]}@123`;
            const hashedPassword = await bcrypt.hash(plainPassword, 10);
            
            console.log(`🔐 Hashing password for ${email}`);
            console.log(`   Original: ${plainPassword}`);
            console.log(`   Hashed: ${hashedPassword.substring(0, 20)}...`);

            // Validate role
            const validRoles = ['admin', 'hod', 'teacher', 'class_teacher', 'student'];
            const userRole = validRoles.includes(role.toLowerCase()) ? role.toLowerCase() : 'teacher';

            // ✅ Create user with HASHED password
            const newUser = await User.create({
              name: name,
              email: email,
              password: hashedPassword, // ✅ HASHED NOW!
              role: userRole,
              phone: row["Phone"],
              employeeId: row["Employee ID"],
              departmentId: dept._id
            });

            console.log(`✅ SUCCESS: Created user ${email} (ID: ${newUser._id})`);
            createdCount++;

          } catch (err) {
            console.error(`❌ ERROR processing row ${i+1}:`, err.message);
            errors.push(`Error processing row ${i+1}: ${err.message}`);
          }
        }

        // Cleanup temp file
        fs.unlinkSync(req.file.path);

        console.log(`\n🎉 CSV Upload Complete:`);
        console.log(`   ✅ Successfully created: ${createdCount}`);
        console.log(`   ❌ Errors: ${errors.length}`);

        res.json({
          success: true,
          message: `✅ Staff uploaded successfully: ${createdCount} users created`,
          data: { 
            createdCount, 
            totalRows: results.length, 
            errors: errors.slice(0, 10) // Show first 10 errors
          }
        });
      });

  } catch (error) {
    console.error('💥 Fatal error in uploadStaffCSV:', error);
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