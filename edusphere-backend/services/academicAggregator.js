// services/academicAggregator.js
const Timetable = require('../models/Timetable');
const Attendance = require('../models/Attendance');
const AuditLogger = require('./auditLogger'); // Formed in Phase 7
const NotificationEngine = require('./notificationEngine'); // Formed in Phase 6

class AcademicAggregator {
    /**
     * Orchestrates cross-module integrity validation before allowing a teacher to submit attendance
     */
    async verifyAndRecordAttendance(req, attendancePayload) {
        const { subjectId, facultyId, date, hour, records } = attendancePayload;
        const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
        const currentDay = dayNames[new Date(date).getDay()];

        // 1. Cross-Check with Timetable Master Scheduler Module
        const scheduledSlot = await Timetable.findOne({
            subject: subjectId,
            faculty: facultyId,
            dayOfWeek: currentDay,
            hour: hour
        });

        if (!scheduledSlot) {
            throw new Error(`Scheduling Violation: Faculty member is not assigned to this subject at this hour on ${currentDay}.`);
        }

        // 2. Commit Record to Attendance Collection 
        const freshAttendanceLog = await Attendance.create({
            subject: subjectId,
            faculty: facultyId,
            date,
            hour,
            records
        });

        // 3. Post-Hook: Trigger Audit Log Transaction Trail
        await AuditLogger.logAction({
            user: req.user.id,
            role: req.user.role,
            action: 'SUBMIT_ATTENDANCE',
            target: `Subject: ${subjectId} | Hour: ${hour}`,
            status: 'Success'
        });

        // 4. Post-Hook: Cascade Real-Time Push Notifications to At-Risk Absent Students
        const absentStudentIDs = records
            .filter(record => !record.isPresent)
            .map(record => record.student);

        if (absentStudentIDs.length > 0) {
            await NotificationEngine.dispatchMultiCastNotification({
                recipients: absentStudentIDs,
                title: "Absence Alert Matrix",
                body: `You were marked ABSENT for period #${hour} today. Check your analytics dashboard immediately.`,
                category: "Academic"
            });
        }

        return freshAttendanceLog;
    }
}

module.exports = new AcademicAggregator();