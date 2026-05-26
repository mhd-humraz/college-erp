/**
 * BULLETPROOF VERSION: Fixes empty classId issue
 * Uses raw MongoDB operations to avoid casting errors
 */

const mongoose = require('mongoose');
const User = require('./models/User');
const Class = require('./models/Class');

async function fixStudents() {
  try {
    await mongoose.connect('mongodb://localhost:27017/college_erp2');
    console.log('✅ Connected to MongoDB\n');

    // ==========================================
    // STEP 1: Get all classes
    // ==========================================
    const allClasses = await Class.find({}).lean();
    
    console.log(`📚 Found ${allClasses.length} classes:\n`);
    allClasses.forEach((cls, idx) => {
      console.log(`${idx + 1}. ${cls.name} (${cls._id})`);
      console.log(`   Semester: ${cls.semester} | Section: ${cls.section} | Strength: ${cls.strength}\n`);
    });

    if (allClasses.length === 0) {
      console.log('❌ No classes found! Create classes first.');
      process.exit(1);
    }

    // ==========================================
    // STEP 2: Get ALL students first (no filter)
    // Then filter in JavaScript to avoid MongoDB cast errors
    // ==========================================
    console.log('📊 Fetching all students...\n');
    
    const allStudents = await User.find({ role: 'student' }).lean();
    console.log(`   Total students in DB: ${allStudents.length}\n`);

    // Filter in JS (avoids MongoDB cast issues!)
    const studentsNeedingFix = allStudents.filter(student => {
      return !student.classId || 
             student.classId === null || 
             student.classId === '' ||
             student.classId === undefined;
    });

    console.log(`========================================`);
    console.log(`🔧 Found ${studentsNeedingFix.length} students needing classId fix\n`);

    if (studentsNeedingFix.length === 0) {
      console.log('✅ PERFECT! All students already have valid classId!\n');
      
      // Show current distribution
      for (const cls of allClasses) {
        const count = allStudents.filter(s => 
          s.classId && s.classId.toString() === cls._id.toString()
        ).length;
        const hasCT = cls.classTeacherId ? '✅' : '❌';
        console.log(`   ${hasCT} ${cls.name}: ${count} students`);
      }
      
      process.exit(0);
    }

    // ==========================================
    // STEP 3: Assign students to classes
    // ==========================================
    let updatedCount = 0;
    const defaultClass = allClasses[0]; // Fallback

    console.log(`🔄 Assigning classIds to ${studentsNeedingFix.length} students...\n`);

    for (let i = 0; i < studentsNeedingFix.length; i++) {
      const student = studentsNeedingFix[i];
      
      // Simple round-robin assignment based on index
      let targetClass;
      if (i < Math.ceil(studentsNeedingFix.length / 3)) {
        targetClass = allClasses.find(c => c.name.includes('BCA-3')) || allClasses[0];
      } else if (i < Math.ceil(studentsNeedingFix.length * 2 / 3)) {
        targetClass = allClasses.find(c => c.name.includes('BCA-1')) || allClasses[1] || allClasses[0];
      } else {
        targetClass = allClasses.find(c => c.name.includes('CSE-1')) || allClasses[2] || allClasses[0];
      }
      
      if (!targetClass) targetClass = defaultClass;

      // Update using findByIdAndUpdate (avoids cast issues)
      await User.findByIdAndUpdate(
        student._id,
        { $set: { classId: targetClass._id } },
        { new: true }
      );
      
      updatedCount++;
      
      if (i < 8) { // Show first 8
        const name = student.name || student.email || `Student#${i+1}`;
        console.log(`   ✅ ${i+1}. ${name.padEnd(30)} → ${targetClass.name}`);
      }
    }

    // ==========================================
    // STEP 4: Update class strengths
    // ==========================================
    console.log('\n📊 Updating class strengths...\n');

    for (const cls of allClasses) {
      // Count again after updates
      const count = await User.countDocuments({
        role: 'student',
        classId: cls._id
      });
      
      await Class.findByIdAndUpdate(cls._id, { $set: { strength: count } });
      
      const hasCT = cls.classTeacherId ? '✅' : '❌';
      console.log(`   ${hasCT} ${cls.name.padEnd(12)} → ${count} students`);
    }

    // ==========================================
    // STEP 5: Final Summary
    // ==========================================
    console.log('\n' + '='.repeat(60));
    console.log('🎉 FIX COMPLETE!');
    console.log('='.repeat(60));
    console.log(`\n✅ Successfully updated: ${updatedCount} students\n`);

    console.log('📋 Final Distribution:');
    for (const cls of allClasses) {
      const hasCT = cls.classTeacherId ? '✅' : '❌';
      const count = await User.countDocuments({ role: 'student', classId: cls._id });
      console.log(`   ${hasCT} ${cls.name.padEnd(12)} ${count.toString().padStart(2)} students (Sem ${cls.semester})`);
    }

    console.log('\n💡 Now:');
    console.log('   1. Hot restart Flutter app (press R)');
    console.log('   2. Login as Class Teacher');
    console.log('   3. Check dashboard - should show students!\n');

    process.exit(0);

  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

fixStudents();