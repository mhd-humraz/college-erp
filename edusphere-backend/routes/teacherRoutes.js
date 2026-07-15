const express = require("express");
const router = express.Router();

const teacherController = require("../controllers/teacherController");

const {
    verifyToken,
    authorizeRoles,
} = require("../middleware/authMiddleware");

// Teacher Profile
router.get(
    "/profile",
    verifyToken,
    authorizeRoles("Teacher", "HOD"),
    teacherController.getProfile
);

// Student List
router.get(
    "/students",
    verifyToken,
    authorizeRoles("Teacher", "HOD"),
    teacherController.getStudents
);

module.exports = router;