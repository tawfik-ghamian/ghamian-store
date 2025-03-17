const mongoose = require('mongoose');

// Branch Schema
const branchSchema = new mongoose.Schema({
  name: { type: String, required: true },
  location: { type: String, required: true },
  contactNumber: { type: String },
  manager: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }
});

const Branch = mongoose.model('Branch', branchSchema);

module.exports = Branch;
