const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");

const User = require("./models/User");

const MONGO_URI =
    "mongodb://localhost:27017/edusphere";

async function resetPassword() {
    try {
        await mongoose.connect(MONGO_URI);

        const email =
            "teacher1@edusphere.edu";

        const newPassword =
            "teacher123";

        const user = await User.findOne({
            email
        });

        if (!user) {
            console.log("Student user not found");
            process.exit(1);
        }

        
        user.password = await bcrypt.hash(
            newPassword,
            10
        );

        await user.save();

        console.log(
            "Student password reset successfully"
        );

        console.log(
            `Email: ${email}`
        );

        console.log(
            `Password: ${newPassword}`
        );

        process.exit(0);
    } catch (error) {
        console.error(error);

        process.exit(1);
    }
}

resetPassword();