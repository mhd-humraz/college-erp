// routes/uploadRoutes.js
const express = require('express');
const router = express.Router();
const uploadParser = require('../config/cloudinary');
const { verifyToken } = require('../middleware/authMiddleware');
const AuditLogger = require('../services/auditLogger');

router.post('/document', verifyToken, uploadParser.single('attachedFile'), async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ error: "File asset transmission payload absent." });
        }

        // Commit track records to audit logging engine
        await AuditLogger.logAction({
            user: req.user.id,
            role: req.user.role,
            action: 'UPLOAD_DOCUMENT',
            target: `Cloud Storage URL: ${req.file.path}`,
            status: 'Success'
        });

        res.status(200).json({
            success: true,
            secureUrl: req.file.path, // Use this response URL to save in your databases later
            assetPublicId: req.file.filename
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;