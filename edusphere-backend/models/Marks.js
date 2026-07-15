const mongoose = require("mongoose");

const scoreSchema = new mongoose.Schema(
    {
        student: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Student",
            required: true
        },

        marksObtained: {
            type: Number,
            required: true,
            min: 0
        },

        status: {
            type: String,
            enum: ["Pass", "Fail"],
            default: "Fail"
        },

        grade: {
            type: String,
            default: "F"
        }
    },
    {
        _id: false
    }
);

const marksSchema = new mongoose.Schema(
    {
        subject: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Subject",
            required: true
        },

        examType: {
            type: String,
            enum: [
                "Internal_1",
                "Internal_2",
                "Semester_Final"
            ],
            required: true
        },

        semester: {
            type: Number,
            required: true,
            min: 1,
            max: 8
        },

        maxMarks: {
            type: Number,
            default: 100,
            required: true,
            min: 1
        },

        passMarks: {
            type: Number,
            default: 40,
            required: true,
            min: 0
        },

        scores: [
            scoreSchema
        ]
    },
    {
        timestamps: true
    }
);

marksSchema.index(
    {
        subject: 1,
        examType: 1,
        semester: 1
    },
    {
        unique: true
    }
);

marksSchema.pre("save", function () {

    this.scores.forEach((score) => {

        if (score.marksObtained > this.maxMarks) {
            throw new Error(
                `Marks cannot exceed maximum marks ${this.maxMarks}`
            );
        }

        score.status =
            score.marksObtained >= this.passMarks
                ? "Pass"
                : "Fail";

        const percentage =
            (
                score.marksObtained /
                this.maxMarks
            ) * 100;

        if (percentage >= 90) {
            score.grade = "A+";
        } else if (percentage >= 80) {
            score.grade = "A";
        } else if (percentage >= 70) {
            score.grade = "B+";
        } else if (percentage >= 60) {
            score.grade = "B";
        } else if (percentage >= 50) {
            score.grade = "C";
        } else if (percentage >= 40) {
            score.grade = "D";
        } else {
            score.grade = "F";
        }

    });

});

module.exports = mongoose.model(
    "Marks",
    marksSchema
);