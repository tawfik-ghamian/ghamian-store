const mongoose = require('mongoose');

// Jewelry Schema
const jewelrySchema = new mongoose.Schema({
  name: { type: String, required: true },
  category: { type: String, required: true },
  material: { type: String, required: true },
  weight: { type: Number },
  price: { type: Number, required: true },
  quantity: { type: Number, default: 1 },
  description: { type: String },
  branchId: { type: mongoose.Schema.Types.ObjectId, ref: 'Branch', required: true },
  imageUrl: { type: String }
});

const Jewelry = mongoose.model('Jewelry', jewelrySchema);

module.exports = Jewelry;
