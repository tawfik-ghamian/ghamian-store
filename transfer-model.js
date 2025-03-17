const mongoose = require('mongoose');

// Transfer Request Schema
const transferRequestSchema = new mongoose.Schema({
  jewelryId: { type: mongoose.Schema.Types.ObjectId, ref: 'Jewelry', required: true },
  fromBranchId: { type: mongoose.Schema.Types.ObjectId, ref: 'Branch', required: true },
  toBranchId: { type: mongoose.Schema.Types.ObjectId, ref: 'Branch', required: true },
  quantity: { type: Number, required: true, default: 1 },
  status: { type: String, enum: ['pending', 'approved', 'rejected'], default: 'pending' },
  requestedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  requestedAt: { type: Date, default: Date.now },
  respondedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  respondedAt: { type: Date }
});

const TransferRequest = mongoose.model('TransferRequest', transferRequestSchema);

module.exports = TransferRequest;
