/**
 * Script to fix existing users with plain text passwords
 * Run: node fix-existing-passwords.js
 */

const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('./models/User');

async function fixPasswords() {
  try {
    // Connect to MongoDB
    await mongoose.connect('mongodb://localhost:27017/college_erp2');
    console.log('✅ Connected to MongoDB\n');

    // Find all users with plain text passwords (not starting with $2b$, $2a$, or $2y$)
    const usersWithPlainTextPasswords = await User.find({
      password: { 
        $not: /^\$2[aby]\$\d+\$/ 
      },
      isActive: true
    });

    console.log(`📊 Found ${usersWithPlainTextPasswords.length} users with plain text passwords\n`);

    if (usersWithPlainTextPasswords.length === 0) {
      console.log('✨ All passwords are already properly hashed!');
      process.exit(0);
    }

    let fixedCount = 0;
    let errorCount = 0;

    for (const user of usersWithPlainTextPasswords) {
      try {
        console.log(`🔧 Fixing: ${user.email}`);
        console.log(`   Current password (plain): "${user.password}"`);
        
        // Hash the current plain text password
        const hashedPassword = await bcrypt.hash(user.password, 10);
        
        // Update user
        user.password = hashedPassword;
        await user.save();
        
        console.log(`   ✅ Fixed! New hash: ${hashedPassword.substring(0, 30)}...\n`);
        
        fixedCount++;
        
      } catch (err) {
        console.error(`   ❌ Error fixing ${user.email}: ${err.message}\n`);
        errorCount++;
      }
    }

    console.log('\n' + '='.repeat(50));
    console.log('🎉 PASSWORD FIX COMPLETE!');
    console.log('='.repeat(50));
    console.log(`✅ Successfully fixed: ${fixedCount} users`);
    console.log(`❌ Errors: ${errorCount} users`);
    console.log(`📊 Total processed: ${usersWithPlainTextPasswords.length} users\n`);

    // List all fixed users
    console.log('Fixed users:');
    const fixedUsers = await User.find({
      _id: { $in: usersWithPlainTextPasswords.map(u => u._id) }
    }).select('email name role createdAt');
    
    fixedUsers.forEach(user => {
      console.log(`  ✓ ${user.email} (${user.role})`);
    });

    process.exit(0);

  } catch (error) {
    console.error('💥 Fatal error:', error);
    process.exit(1);
  }
}

// Run the script
fixPasswords();