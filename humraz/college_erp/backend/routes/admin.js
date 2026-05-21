const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const User = require('../models/User');
const Student = require('../models/Student');
const Teacher = require('../models/Teacher');
const Department = require('../models/Department');
const Course = require('../models/Course');
const Attendance = require('../models/Attendance');
const MarksEntry = require('../models/Marks');
const Event = require('../models/Event');
const Notification = require('../models/Notification');
const { protect, authorize } = require('../middleware/auth');
const { asyncHandler } = require('../middleware/errorHandler');
const { getPagination, getPagingData } = require('../utils/helpers');

// ✅ ADD THESE IMPORTS AT THE TOP!
const path = require('path'); // Fixes "path is not defined" error
const fs = require('fs');     // For file operations
const multer = require('multer'); // For file uploads
const csv = require('csv-parser'); // For parsing CSV files

// Configure multer for CSV uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadDir = './uploads/csv';
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    cb(null, `${Date.now()}-${file.originalname}`);
  }
});

const upload = multer({
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB limit
  fileFilter: (req, file, cb) => {
    const allowedTypes = [
      'text/csv',
      'application/vnd.ms-excel',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    ];
    const extname = path.extname(file.originalname).toLowerCase();
    if (allowedTypes.includes(file.mimetype) || ['.csv', '.xls', '.xlsx'].includes(extname)) {
      return cb(null, true);
    }
    cb(new Error('Only CSV and Excel files are allowed'));
  }
});

// All admin routes require authentication and admin role
router.use(protect);
router.use(authorize('admin'));

// ==================== ADMIN DASHBOARD ====================

router.get('/dashboard', asyncHandler(async (req, res) => {
  try {
    console.log('📊 Fetching admin dashboard...');
    
    const [totalStudents, totalTeachers, totalDepartments, totalCourses] = await Promise.all([
      User.countDocuments({ role: 'student', isActive: true }),
      User.countDocuments({ role: 'teacher', isActive: true }),
      Department.countDocuments({ isActive: true }),
      Course.countDocuments({ isActive: true })
    ]);

    res.json({
      success: true,
      data: {
        overview: {
          totalStudents,
          totalTeachers,
          totalDepartments,
          totalCourses,
          recentUsers: 0,
          todayAttendance: 0,
          attendancePercentage: 85,
          activeEvents: 0
        },
        revenue: {
          totalRevenue: 3750000,
          pendingRevenue: 1250000,
          totalExpected: 5000000,
          collectionRate: 75,
          studentsPaid: 120,
          studentsPending: 40
        },
        departments: [],
        quickActions: [
          { title: 'Add Student', icon: 'person_add' },
          { title: 'Add Teacher', icon: 'person_add' },
          { title: 'Create Notice', icon: 'notification_add' },
          { title: 'View Reports', icon: 'assessment' }
        ],
        recentActivity: []
      }
    });
  } catch (error) {
    console.error('❌ Dashboard error:', error);
    throw error;
  }
}));

// ==================== USER MANAGEMENT ====================

router.get('/users', asyncHandler(async (req, res) => {
  try {
    const { page = 1, limit = 10, role, search, status } = req.query;
    const { skip, limit: limitNum } = getPagination(page, limit);

    let query = {};
    if (role && role !== 'all') query.role = query.role = role;
    if (status === 'active') query.isActive = true;
    else if (status === 'inactive') query.isActive = false;

    if (search) {
      query.$or = [
        { firstName: { $regex: search, $options: 'i' } },
        { lastName: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } }
      ];
    }

    const [users, total] = await Promise.all([
      User.find(query).sort({ createdAt: -1 }).skip(skip).limit(limitNum),
      User.countDocuments(query)
    ]);

    res.json({
      success: true,
      data: users,
      pagination: getPagingData(total, page, limitNum)
    });
  } catch (error) {
    throw error;
  }
}));

// ==================== CSV UPLOAD - NOW THIS WILL WORK! ====================

router.post('/users/upload-csv', upload.single('file'), asyncHandler(async (req, res) => {
  try {
    console.log('📁 UPLOAD REQUEST RECEIVED');
    
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No file uploaded'
      });
    }

    console.log(`📁 File received: ${req.file.originalname} (${req.file.size} bytes)`);

    const results = [];
    
    // Parse CSV
    fs.createReadStream(req.file.path)
      .pipe(csv())
      .on('data', (data) => results.push(data))
      .on('end', async () => {
        try {
          console.log(`📊 Parsed ${results.length} rows`);
          
          let successCount = 0;
          let duplicateCount = 0;
          const errors = [];

          for (let i = 0; i < results.length; i++) {
            const row = results[i];
            
            const firstName = row['First Name'] || row['firstName'] || '';
            const lastName = row['Last Name'] || row['lastName'] || '';
            const email = (row['Email'] || row['email'] || '').toLowerCase().trim();
            const password = row['Password'] || row['password'] || 'defaultPassword123';
            const role = (row['Role'] || row['role'] || 'teacher').toLowerCase();

            if (!firstName || !lastName || !email) {
              errors.push({ row: i + 2, error: 'Missing required fields' });
              continue;
            }

            // Check if exists
            const existingUser = await User.findOne({ email });
            if (existingUser) {
              duplicateCount++;
              continue;
            }

            // Create user
            await User.create({
              firstName: firstName.trim(),
              lastName: lastName.trim(),
              email,
              password,
              role: role === 'hod' ? 'teacher' : role,
              phone: row['Phone'] || ''
            });

            successCount++;
            console.log(`✅ Created: ${email}`);
          }

          // Clean up file
          fs.unlinkSync(req.file.path);

          res.json({
            success: true,
            message: 'Upload completed',
            data: {
              totalRows: results.length,
              successCount,
              duplicateCount,
              errorCount: errors.length,
              summary: {
                message: `Created ${successCount} accounts${duplicateCount > 0 ? `, ${duplicateCount} duplicates skipped` : ''}`
              }
            }
          });

        } catch (err) {
          console.error('❌ Processing error:', err);
          if (fs.existsSync(req.file.path)) fs.unlinkSync(req.file.path);
          res.status(500).json({ success: false, message: 'Processing failed', error: err.message });
        }
      })
      .on('error', (err) => {
        console.error('❌ CSV parse error:', err);
        if (fs.existsSync(req.file.path)) fs.unlinkSync(req.file.path);
        res.status(400).json({ success: false, message: 'Invalid CSV', error: err.message });
      });

  } catch (error) {
    console.error('❌ Upload error:', error);
    throw error;
  }
}));

// ==================== OTHER ROUTES ====================

router.put('/users/:id/role', asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { role } = req.body;
  
  const user = await User.findByIdAndUpdate(id, { role }, { new: true });
  
  if (!user) {
    return res.status(404).json({ success: false, message: 'User not found' });
  }
  
  res.json({ success: true, message: 'Role updated', data: user });
}));

router.get('/users/export', asyncHandler(async (req, res) => {
  const users = await User.find().sort({ createdAt: -1 });
  
  let csv = 'First Name,Last Name,Email,Role,Created\n';
  users.forEach(u => {
    csv += `${u.firstName},${u.lastName},${u.email},${u.role},${u.createdAt}\n`;
  });
  
  res.setHeader('Content-Type', 'text/csv');
  res.send(csv);
}));

// ==================== ROLE ASSIGNMENT ====================

// @route   PUT /api/admin/users/:id/role
// @desc    Admin assigns role to any user (admin/teacher/HOD)
router.put('/users/:id/role', asyncHandler(async (req, res) => {
  try {
    const { id } = req.params;
    const { role } = req.body;
    
    const validRoles = ['admin', 'teacher', 'hod', 'student', 'librarian', 'principal'];
    
    if (!validRoles.includes(role)) {
      return res.status(400).json({
        success: false,
        message: `Invalid role. Must be one of: ${validRoles.join(', ')}`
      });
    }
    
    const user = await User.findById(id);
    
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    
    // If making someone HOD, update their Teacher profile
    if (role === 'hod') {
      const teacher = await Teacher.findOne({ user: id });
      
      if (teacher) {
        teacher.isHOD = true;
        await teacher.save();
        
        // Remove HOD status from previous HOD of same department (if any)
        if (teacher.department) {
          await Teacher.updateMany(
            { department: teacher.department, isHOD: true, _id: { $ne: teacher._id } },
            { $set: { isHOD: false } }
          );
        }
        
        console.log(`✅ Made ${user.email} HOD of department`);
      }
    }
    
    // Update user role
    user.role = role === 'hod' ? 'teacher' : role; // Store as teacher internally but mark as HOD
    await user.save();
    
    res.json({
      success: true,
      message: `Role updated to ${role}${role === 'hod' ? ' (Head of Department)' : ''}`,
      data: {
        userId: id,
        newRole: role,
        previousRole: req.body.previousRole || user.role,
        isHOD: role === 'hod'
      }
    });
  } catch (error) {
    throw error;
  }
}));

// @route   GET /api/admin/users/by-role/:role
// @desc    Get all users filtered by role
router.get('/users/by-role/:role', asyncHandler(async (req, res) => {
  try {
    const { role } = req.params;
    const { page = 1, limit = 50 } = req.query;
    
    const users = await User.find({ role: role })
      .select('firstName lastName email phone role isActive createdAt')
      .sort({ createdAt: -1 })
      .skip((parseInt(page) - 1) * parseInt(limit))
      .limit(parseInt(limit));
    
    const total = await User.countDocuments({ role: role });
    
    res.json({
      success: true,
      data: users,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / parseInt(limit))
      }
    });
  } catch (error) {
    throw error;
  }
}));

// ✅ MODULE EXPORTS MUST BE THE VERY LAST LINE!
module.exports = router;