const User = require('../models/User');
const Class = require('../models/Class');
const Subject = require('../models/Subject');
const Timetable = require('../models/Timetable');
const Request = require('../models/Request');
const csv = require('csv-parser');
const fs = require('fs');

// @desc   Upload Students CSV (HOD only - filtered by department)
exports.uploadStudentsCSV = async (req, res) => {
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
            const { name, roll_number, semester, section, email } = row;
            
            if (!name || !roll_number || !semester) {
              errors.push(`Missing fields in row`);
              continue;
            }

            // Generate classId format: DEPT-SEM-SECTION
            const deptCode = req.user.departmentId?.code || 'UNKNOWN';
            const classIdStr = `${deptCode}-${semester}-${section || 'A'}`;

            // Find or create Class
            let classDoc = await Class.findOne({ name: classIdStr });
            if (!classDoc) {
              classDoc = await Class.create({
                name: classIdStr,
                departmentId: req.user.departmentId,
                semester: parseInt(semester),
                section: section || 'A'
              });
            }

            // Check duplicate
            const existingStudent = await User.findOne({ 
              $or: [{ email }, { rollNumber: roll_number }],
              role: 'student'
            });
            
            if (existingStudent) {
              errors.push(`Student ${name} (${roll_number}) already exists`);
              continue;
            }

            // Create Student
            const password = roll_number + '@erp';
            
            await User.create({
              name: name.trim(),
              email: (email || `${roll_number}@college.edu`).trim().toLowerCase(),
              password,
              role: 'student',
              departmentId: req.user.departmentId,
              classId: classDoc._id,
              rollNumber: roll_number.toString()
            });

            // Update class strength
            classDoc.strength += 1;
            await classDoc.save();

            createdCount++;
          } catch (err) {
            errors.push(err.message);
          }
        }

        fs.unlinkSync(req.file.path);

        res.json({
          success: true,
          message: `✅ Students uploaded: ${createdCount}`,
          data: { createdCount, totalRows: results.length, errors }
        });
      });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Get Department Students (HOD View)
exports.getDepartmentStudents = async (req, res) => {
  try {
    const students = await User.find({ 
      departmentId: req.user.departmentId, 
      role: 'student',
      isActive: true 
    })
      .select('-password')
      .populate('classId', 'name semester section')
      .sort({ classId: 1, name: 1 });

    res.json({ success: true, count: students.length, data: students });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Assign Teacher / Class Teacher
exports.assignTeacher = async (req, res) => {
  try {
    const { teacherId, classId, subjectIds, isClassTeacher } = req.body;

    const teacher = await User.findById(teacherId);
    if (!teacher || !['teacher', 'class_teacher'].includes(teacher.role)) {
      return res.status(404).json({ success: false, message: 'Teacher not found' });
    }

    // Verify teacher belongs to HOD's department
    if (teacher.departmentId?.toString() !== req.user.departmentId?.toString()) {
      return res.status(403).json({ success: false, message: 'Teacher does not belong to your department' });
    }

    const classDoc = await Class.findById(classId);
    if (!classDoc) {
      return res.status(404).json({ success: false, message: 'Class not found' });
    }

    // Update teacher
    teacher.classId = classId;
    if (isClassTeacher) {
      teacher.role = 'class_teacher';
      classDoc.classTeacherId = teacherId;
      await classDoc.save();
    }
    await teacher.save();

    // Link subjects if provided
    if (subjectIds && subjectIds.length > 0) {
      await Subject.updateMany(
        { _id: { $in: subjectIds } },
        { teacherId: teacherId }
      );
    }

    res.json({ 
      success: true, 
      message: `Teacher ${teacher.name} assigned successfully${isClassTeacher ? ' as Class Teacher' : ''}`,
      data: teacher
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Create Timetable
exports.createTimetable = async (req, res) => {
  try {
    const { classId, entries } = req.body;

    if (!entries || entries.length === 0) {
      return res.status(400).json({ success: false, message: 'No timetable entries provided' });
    }

    // Verify class belongs to HOD's department
    const classDoc = await Class.findById(classId);
    if (!classDoc || classDoc.departmentId?.toString() !== req.user.departmentId?.toString()) {
      return res.status(403).json({ success: false, message: 'Class not found or access denied' });
    }

    // Clear existing timetable for this class
    await Timetable.deleteMany({ classId });

    // Create new entries
    const timetableEntries = entries.map(entry => ({
      ...entry,
      classId
    }));

    const created = await Timetable.insertMany(timetableEntries);

    res.status(201).json({ 
      success: true, 
      message: `Timetable created with ${created.length} entries`,
      data: created 
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Get Timetable by Class
exports.getTimetable = async (req, res) => {
  try {
    const { classId } = req.params;
    
    const timetable = await Timetable.find({ classId })
      .populate('subjectId', 'name code type')
      .populate('teacherId', 'name')
      .sort({ day: 1, period: 1 });

    // Group by day
    const grouped = {};
    timetable.forEach(entry => {
      if (!grouped[entry.day]) grouped[entry.day] = [];
      grouped[entry.day].push(entry);
    });

    res.json({ success: true, data: grouped });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Get Pending Requests (Missing students etc.)
exports.getRequests = async (req, res) => {
  try {
    const requests = await Request.find({ 
      status: 'pending',
      requestedBy: { $in: await User.find({ departmentId: req.user.departmentId }).distinct('_id') }
    })
      .populate('requestedBy', 'name email role')
      .populate('classId', 'name')
      .sort({ createdAt: -1 });

    res.json({ success: true, count: requests.length, data: requests });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc   Add Student Manually (Resolve Request)
exports.addStudentManually = async (req, res) => {
  try {
    const { name, email, rollNumber, semester, section, requestId, classId } = req.body;

    // Find or create class
    const deptCode = req.user.departmentId?.code || 'UNKNOWN';
    const targetClassId = classId || `${deptCode}-${semester}-${section || 'A'}`;
    
    let classDoc = await Class.findOne({ name: targetClassId });
    if (!classDoc) {
      classDoc = await Class.create({
        name: targetClassId,
        departmentId: req.user.departmentId,
        semester: parseInt(semester),
        section: section || 'A'
      });
    }

    // Create student
    const password = rollNumber + '@erp';
    const student = await User.create({
      name,
      email: email || `${rollNumber}@college.edu`,
      password,
      role: 'student',
      departmentId: req.user.departmentId,
      classId: classDoc._id,
      rollNumber
    });

    // Update request status if provided
    if (requestId) {
      await Request.findByIdAndUpdate(requestId, {
        status: 'resolved',
        resolvedAt: new Date(),
        resolvedBy: req.user._id
      });
    }

    // Update class strength
    classDoc.strength += 1;
    await classDoc.save();

    res.status(201).json({ 
      success: true, 
      message: `Student ${name} added successfully`,
      data: student 
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};