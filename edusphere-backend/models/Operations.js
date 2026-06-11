// models/Operations.js
const mongoose = require('mongoose');

const BookSchema = new mongoose.Schema({
    title: { type: String, required: true, trim: true },
    author: { type: String, required: true },
    isbn: { type: String, required: true, unique: true },
    totalCopies: { type: Number, required: true, default: 1 },
    availableCopies: { type: Number, required: true, default: 1 }
}, { timestamps: true });

const BookTransactionSchema = new mongoose.Schema({
    book: { type: mongoose.Schema.Types.ObjectId, ref: 'Book', required: true },
    student: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    issueDate: { type: Date, default: Date.now },
    dueDate: { type: Date, required: true },
    returnDate: { type: Date, default: null },
    fineAmount: { type: Number, default: 0 }
}, { timestamps: true });

const CampusEventSchema = new mongoose.Schema({
    title: { type: String, required: true },
    description: { type: String },
    venue: { type: String, required: true },
    eventDate: { type: Date, required: true },
    organizer: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true }
}, { timestamps: true });

const EventRegistrationSchema = new mongoose.Schema({
    event: { type: mongoose.Schema.Types.ObjectId, ref: 'CampusEvent', required: true },
    student: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    attended: { type: Boolean, default: false }
}, { timestamps: true });

module.exports = {
    Book: mongoose.model('Book', BookSchema),
    BookTransaction: mongoose.model('BookTransaction', BookTransactionSchema),
    CampusEvent: mongoose.model('CampusEvent', CampusEventSchema),
    EventRegistration: mongoose.model('EventRegistration', EventRegistrationSchema)
};