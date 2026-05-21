const mongoose = require('mongoose');

const libraryBookSchema = new mongoose.Schema({
  title: { type: String, required: true, trim: true },
  authors: [{ type: String, required: true }],
  isbn: { type: String, unique: true },
  publisher: String,
  edition: String,
  publishedYear: Number,
  category: { type: String, required: true, enum: ['engineering', 'sciences', 'arts', 'commerce', 'management', 'literature', 'reference', 'journal', 'magazine', 'other'] },
  subcategory: String,
  language: { type: String, default: 'English' },
  totalPages: Number,
  price: Number,
  barcode: { type: String, unique: true },
  rackNumber: String,
  shelfNumber: String,
  copies: { total: { type: Number, default: 1, required: true }, available: { type: Number, default: 1 } },
  location: { building: String, floor: String, section: String },
  status: { type: String, enum: ['available', 'issued', 'lost', 'damaged', 'maintenance', 'reserved'], default: 'available' },
  addedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  addedDate: { type: Date, default: Date.now },
  lastIssuedDate: Date,
  tags: [String],
  imageUrl: String,
  description: String,
  isReferenceOnly: { type: Boolean, default: false }
}, { timestamps: true, toJSON: { virtuals: true }, toObject: { virtuals: true } });

libraryBookSchema.index({ title: 'text', authors: 'text' });
// libraryBookSchema.index({ isbn: 1 });
// libraryBookSchema.index({ barcode: 1 });
libraryBookSchema.index({ category: 1 });

module.exports = mongoose.model('LibraryBook', libraryBookSchema);