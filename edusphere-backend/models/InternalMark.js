const mongoose = require("mongoose");

const internalMarkSchema = new mongoose.Schema(
    {
        student: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Student",
            required: true
        },

        subject: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Subject",
            required: true
        },

        semester: {
            type: Number,
            required: true,
            min: 1,
            max: 8
        },

        internal1: {
            type: Number,
            default: 0,
            min: 0
        },

        internal2: {
            type: Number,
            default: 0,
            min: 0
        },

        assignment: {
            type: Number,
            default: 0,
            min: 0
        },

        seminar: {
            type: Number,
            default: 0,
            min: 0
        },

        totalMarks: {
            type: Number,
            default: 0
        }
    },
    {
        timestamps: true
    }
);

internalMarkSchema.index(
    {
        student: 1,
        subject: 1,
        semester: 1
    },
    {
        unique: true
    }
);

internalMarkSchema.pre("save", function () {
    this.totalMarks =
        this.internal1 +
        this.internal2 +
        this.assignment +
        this.seminar;
});

module.exports = mongoose.model(
    "InternalMark",
    internalMarkSchema
);