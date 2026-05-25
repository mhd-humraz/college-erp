require('dotenv').config();
const mongoose = require('mongoose');
const User = require('./models/User');
const Department = require('./models/Department');
const Class = require('./models/Class'); // ✅ Added Class model import

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/college_erp2';

// Demo Data - ✅ UPDATED WITH CLASS TEACHERS
const demoData = {
  admin: {
    name: 'Super Admin',
    email: 'admin@college.com',
    password: 'admin123',
    role: 'admin'
  },
  departments: [
    { name: 'Computer Science', code: 'BCA', description: 'Bachelor of Computer Applications' },
    { name: 'Commerce', code: 'BCom', description: 'Bachelor of Commerce' },
    { name: 'English', code: 'BA_Eng', description: 'Bachelor of Arts English' },
    { name: 'Mathematics', code: 'BSc_Maths', description: 'Bachelor of Science Maths' }
  ],
  hods: [
    { name: 'Rahul Krishnan', email: 'rahul.hod@college.com', departmentCode: 'BCA', password: 'hod123' },
    { name: 'Priya Sharma', email: 'priya.hod@college.com', departmentCode: 'BCom', password: 'hod123' }
  ],
  // ✅ CLASS TEACHERS ADDED!
  classTeachers: [
    { 
      name: 'Meera Devi', 
      email: 'meera.classteacher@college.com', 
      departmentCode: 'BCA', 
      assignedClass: 'BCA-3-A',  // Which class they manage
      password: 'cta123'
    },
    { 
      name: 'Rajesh Kumar', 
      email: 'rajesh.classteacher@college.com', 
      departmentCode: 'BCom', 
      assignedClass: 'BCom-1-A',
      password: 'cta123'
    }
  ],
  teachers: [
    { name: 'Shiyas VK', email: 'shiyas@college.com', departmentCode: 'BCA', password: 'teacher123' },
    { name: 'Anjali Nair', email: 'anjali@college.com', departmentCode: 'BCA', password: 'teacher123' },
    { name: 'Vijay Kumar', email: 'vijay@college.com', departmentCode: 'BCom', password: 'teacher123' },
    { name: 'Deepa Rajan', email: 'deepa@college.com', departmentCode: 'BCom', password: 'teacher123' }
  ],
  students: [
    { name: 'Ameen Hassan', rollNumber: '2401', semester: 3, section: 'A', departmentCode: 'BCA' },
    { name: 'Faris Khan', rollNumber: '2402', semester: 3, section: 'A', departmentCode: 'BCA' },
    { name: 'Sara Fathima', rollNumber: '2403', semester: 3, section: 'A', departmentCode: 'BCA' },
    { name: 'Arjun Menon', rollNumber: '2404', semester: 1, section: 'A', departmentCode: 'BCA' },
    { name: 'Divya Lakshmi', rollNumber: '2501', semester: 1, section: 'A', departmentCode: 'BCom' },
    { name: 'Karthik Raj', rollNumber: '2502', semester: 1, section: 'A', departmentCode: 'BCom' },
    // ✅ EXTRA STUDENTS FOR BCA-3-A (Meera's class)
    { name: 'Nikhil Raj', rollNumber: '2405', semester: 3, section: 'A', departmentCode: 'BCA' },
    { name: 'Priya Menon', rollNumber: '2406', semester: 3, section: 'A', departmentCode: 'BCA' },
    { name: 'Alan John', rollNumber: '2407', semester: 3, section: 'A', departmentCode: 'BCA' },
    // ✅ EXTRA STUDENTS FOR BCom-1-A (Rajesh's class)
    { name: 'Swathi Krishnan', rollNumber: '2503', semester: 1, section: 'A', departmentCode: 'BCom' },
    { name: 'Mohammed Fasil', rollNumber: '2504', semester: 1, section: 'A', departmentCode: 'BCom' }
  ]
};

async function seedDatabase() {
  console.log('\n🌱 Seeding College ERP Database...\n');

  try {
    // Connect to MongoDB
    await mongoose.connect(MONGODB_URI);
    console.log('✅ Connected to MongoDB\n');

    // Clear existing data
    await User.deleteMany({});
    await Department.deleteMany({});
    await Class.deleteMany({}); // ✅ Clear classes too
    console.log('🗑️ Cleared existing data\n');

    // 1. Create Admin
    const admin = await User.create({
      name: demoData.admin.name,
      email: demoData.admin.email,
      password: demoData.admin.password,
      role: demoData.admin.role,
      isActive: true
    });
    console.log(`✅ Admin Created:`);
    console.log(`   📧 Email: ${demoData.admin.email}`);
    console.log(`   🔑 Password: ${demoData.admin.password}\n`);

    // 2. Create Departments & Store in array
    const createdDepts = [];
    for (const dept of demoData.departments) {
      const newDept = await Department.create(dept);
      createdDepts.push(newDept);
      console.log(`🏛️ Department Created: ${dept.name} (${dept.code})`);
    }

    // 3. Create HODs & Assign to Departments
    const hodUsers = [];
    for (let i = 0; i < demoData.hods.length; i++) {
      const hod = demoData.hods[i];
      const dept = createdDepts.find(d => d.code === hod.departmentCode);
      
      if (dept) {
        const hodUser = await User.create({
          name: hod.name,
          email: hod.email,
          password: hod.password,
          role: 'hod',
          departmentId: dept._id,
          isActive: true
        });
        
        dept.hodId = hodUser._id;
        await dept.save();
        hodUsers.push({ user: hodUser, dept });
        
        console.log(`\n🎓 HOD Created:`);
        console.log(`   👤 Name: ${hod.name}`);
        console.log(`   📧 Email: ${hod.email}`);
        console.log(`   🔑 Password: ${hod.password}`);
        console.log(`   🏛️ Department: ${dept.name}`);
      }
    }

    // ✅ 4. Create CLASS TEACHERS & Assign to Classes
    const ctUsers = []; // Store class teacher users
    const createdClasses = []; // Store created classes
    
    for (let i = 0; i < demoData.classTeachers.length; i++) {
      const ct = demoData.classTeachers[i];
      const dept = createdDepts.find(d => d.code === ct.departmentCode);
      
      if (dept) {
        // Create or Find Class
        let classDoc = await Class.findOne({ name: ct.assignedClass });
        
        if (!classDoc) {
          // Parse class info from name "BCA-3-A"
          const parts = ct.assignedClass.split('-'); // ['BCA', '3', 'A']
          const semester = parseInt(parts[1]) || 3;
          const section = parts[2] || 'A';
          
          classDoc = await Class.create({
            name: ct.assignedClass,
            departmentId: dept._id,
            semester: semester,
            section: section,
            strength: 0, // Will be updated when students are added
            classTeacherId: null // Will be set below
          });
          
          createdClasses.push(classDoc);
          console.log(`\n📚 Class Created: ${ct.assignedClass} (Semester: ${semester}, Section: ${section})`);
        }

        // Create Class Teacher User
        const ctUser = await User.create({
          name: ct.name,
          email: ct.email,
          password: ct.password,
          role: 'class_teacher', // ✅ IMPORTANT: Role is class_teacher
          departmentId: dept._id,
          classId: classDoc._id, // ✅ Link to their assigned class
          isActive: true
        });

        // Assign as Class Teacher to the class
        classDoc.classTeacherId = ctUser._id;
        await classDoc.save();
        
        ctUsers.push({ user: ctUser, class: classDoc, dept });
        
        console.log(`\n👩‍🏫 CLASS TEACHER Created:`);
        console.log(`   👤 Name: ${ct.name}`);
        console.log(`   📧 Email: ${ct.email}`);
        console.log(`   🔑 Password: ${ct.password}`);
        console.log(`   🏛️ Department: ${dept.name}`);
        console.log(`   📚 Assigned Class: ${ct.assignedClass}`);
        console.log(`   🆔 ID: ${ctUser._id.toString().slice(-6).toUpperCase()}`);
      }
    }

    // 5. Create Regular Teachers
    const teacherUsers = [];
    for (const teacher of demoData.teachers) {
      const dept = createdDepts.find(d => d.code === teacher.departmentCode);
      
      if (dept) {
        const teacherUser = await User.create({
          name: teacher.name,
          email: teacher.email,
          password: teacher.password,
          role: 'teacher',
          departmentId: dept._id,
          isActive: true
        });
        teacherUsers.push(teacherUser);
        console.log(`\n👨‍🏫 Teacher Created: ${teacher.name} (${teacher.departmentCode})`);
      }
    }

    // 6. Create Students & Auto-assign to Classes
    let studentCount = 0;
    for (const student of demoData.students) {
      const dept = createdDepts.find(d => d.code === student.departmentCode);
      
      if (dept) {
        // Generate classId format
        const classIdStr = `${student.departmentCode}-${student.semester}-${student.section}`;
        
        // Find or create class
        let classDoc = await Class.findOne({ name: classIdStr });
        if (!classDoc) {
          classDoc = await Class.create({
            name: classIdStr,
            departmentId: dept._id,
            semester: student.semester,
            section: student.section,
            strength: 0
          });
          createdClasses.push(classDoc);
        }

        // Create Student
        const studentUser = await User.create({
          name: student.name,
          email: `${student.rollNumber.toLowerCase()}@student.college.edu`,
          password: student.rollNumber + '@erp',
          role: 'student',
          departmentId: dept._id,
          classId: classDoc._id, // ✅ Link to class
          rollNumber: student.rollNumber,
          isActive: true
        });

        // Update class strength
        classDoc.strength += 1;
        await classDoc.save();
        
        studentCount++;
        console.log(`🎓 Student Created: ${student.name} (Roll: ${student.rollNumber}) → ${classIdStr}`);
      }
    }

    // Print Summary
    console.log('\n' + '='.repeat(60));
    console.log('🎉 SEEDING COMPLETED SUCCESSFULLY!');
    console.log('='.repeat(60));
    
    console.log(`\n📊 STATISTICS:`);
    console.log(`   Total Users Created: ${await User.countDocuments()}`);
    console.log(`   Total Departments: ${createdDepts.length}`);
    console.log(`   Total Classes: ${createdClasses.length}`);
    console.log(`   Total Students: ${studentCount}\n`);

    console.log('📋 LOGIN CREDENTIALS:\n');
    console.log('┌─────────────────────────────────────────────────────────────┐');
    console.log('│              🔑 ALL DEMO ACCOUNTS                        │');
    console.log('├─────────────────────────────────────────────────────────────┤');
    
    console.log('│  👑 ADMIN                                                   │');
    console.log('│     ┌───────────────────────────────────────────────────┐     │');
    console.log('│     │ Email:    admin@college.com                      │     │');
    console.log('│     │ Password: admin123                               │     │');
    console.log('│     └───────────────────────────────────────────────────┘     │');
    console.log('├─────────────────────────────────────────────────────────────┤');
    
    console.log('│  🎓 HEADS OF DEPARTMENT (HODs)                              │');
    console.log('│     ┌───────────────────────────────────────────────────┐     │');
    console.log('│     │ rahul.hod@college.com       / hod123              │     │');
    console.log('│     │ priya.hod@college.com       / hod123              │     │');
    console.log('│     └───────────────────────────────────────────────────┘     │');
    console.log('├─────────────────────────────────────────────────────────────┤');

    // ✅ NEW: Class Teacher Section
    console.log('│  👩‍🏫 CLASS TEACHERS (NEW!)                                 │');
    console.log('│     ┌───────────────────────────────────────────────────┐     │');
    console.log('│     │ meera.classteacher@college.com / cta123           │     │');
    console.log('│     │   → Manages: BCA-3-A                            │     │');
    console.log('│     ├───────────────────────────────────────────────────┤     │');
    console.log('│     │ rajesh.classteacher@college.com / cta123          │     │');
    console.log('│     │   → Manages: BCom-1-A                           │     │');
    console.log('│     └───────────────────────────────────────────────────┘     │');
    console.log('├─────────────────────────────────────────────────────────────┤');

    console.log('│  👨‍🏫 REGULAR TEACHERS                                       │');
    console.log('│     ┌───────────────────────────────────────────────────┐     │');
    console.log('│     │ shiyas@college.com         / teacher123          │     │');
    console.log('│     │ anjali@college.com         / teacher123          │     │');
    console.log('│     │ vijay@college.com          / teacher123          │     │');
    console.log('│     │ deepa@college.com         / teacher123          │     │');
    console.log('│     └───────────────────────────────────────────────────┘     │');
    console.log('├─────────────────────────────────────────────────────────────┤');

    console.log('│  🎓 STUDENTS (Password = RollNo@erp)                       │');
    console.log('│     ┌───────────────────────────────────────────────────┐     │');
    console.log('│     │ 2401@student.college.edu / 2401@erp             │     │');
    console.log('│     │ 2402@student.college.edu / 2402@erp             │     │');
    console.log('│     │ 2403@student.college.edu / 2403@erp             │     │');
    console.log('│     │ 2404@student.college.edu / 2404@erp             │     │');
    console.log('│     │ 2501@student.college.edu / 2501@erp             │     │');
    console.log('│     │ 2502@student.college.edu / 2502@erp             │     │');
    console.log('│     │ 2405@student.college.edu / 2405@erp             │     │');
    console.log('│     │ 2406@student.college.edu / 2406@erp             │     │');
    console.log('│     │ 2407@student.college.edu / 2407@erp             │     │');
    console.log('│     │ 2503@student.college.edu / 2503@erp             │     │');
    console.log('│     │ 2504@student.college.edu / 2504@erp             │     │');
    console.log('│     └───────────────────────────────────────────────────┘     │');
    console.log('└─────────────────────────────────────────────────────────────┘\n');

    // ✅ Additional Info
    console.log('💡 QUICK REFERENCE:');
    console.log('   • Class Teacher Role: Can manage entire class');
    console.log('   • CT Password Format: ct123 (common for all CTs)');
    console.log('   • Meera manages BCA-S3-A students');
    console.log('   • Rajesh manages BCom-S1-A students');
    console.log('');

    process.exit(0);

  } catch (error) {
    console.error('❌ Seeding Error:', error.message);
    process.exit(1);
  }
}

seedDatabase();