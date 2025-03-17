const mongoose = require('mongoose');
const bcrypt = require('bcrypt');

// User Schema (Staff and Admin)
const userSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  name: { type: String, required: true },
  role: { type: String, enum: ['staff', 'admin'], required: true },
  branchId: { type: mongoose.Schema.Types.ObjectId, ref: 'Branch' }
});

// Add password hash method
userSchema.methods.comparePassword = async function(candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

const User = mongoose.model('User', userSchema);

module.exports = User;
