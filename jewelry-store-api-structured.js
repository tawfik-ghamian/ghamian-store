// ========== IMPORTS AND SETUP ==========
const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');

const app = express();
app.use(bodyParser.json());

// Database connection
mongoose.connect('mongodb://localhost:27017/ghamian_jewelry_store', {
  useNewUrlParser: true,
  useUnifiedTopology: true
});

// ========== MODELS ==========
// User Schema (Staff and Admin)
const userSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  name: { type: String, required: true },
  role: { type: String, enum: ['staff', 'admin'], required: true },
  branchId: { type: mongoose.Schema.Types.ObjectId, ref: 'Branch' }
});

// Branch Schema
const branchSchema = new mongoose.Schema({
  name: { type: String, required: true },
  location: { type: String, required: true },
  contactNumber: { type: String },
  manager: { type: mongoose.Schema.Types.ObjectId, ref: 'User' }
});

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

// Create models
const User = mongoose.model('User', userSchema);
const Branch = mongoose.model('Branch', branchSchema);
const Jewelry = mongoose.model('Jewelry', jewelrySchema);
const TransferRequest = mongoose.model('TransferRequest', transferRequestSchema);

// ========== MIDDLEWARE ==========
// Authentication middleware
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  
  if (!token) return res.status(401).json({ message: 'Authentication required' });
  
  jwt.verify(token, 'GHAMIAN_SECRET_KEY', (err, user) => {
    if (err) return res.status(403).json({ message: 'Invalid or expired token' });
    req.user = user;
    next();
  });
};

// Admin authorization middleware
const isAdmin = (req, res, next) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ message: 'Admin access required' });
  }
  next();
};

// Branch authorization middleware
const isSameBranch = async (req, res, next) => {
  const jewelry = await Jewelry.findById(req.params.id);
  if (!jewelry) {
    return res.status(404).json({ message: 'Jewelry not found' });
  }
  
  if (req.user.role === 'admin' || jewelry.branchId.toString() === req.user.branchId.toString()) {
    req.jewelry = jewelry;
    next();
  } else {
    return res.status(403).json({ message: 'You can only modify jewelry from your branch' });
  }
};

// ========== ROUTES ==========
// ----- Authentication Routes -----
// Register a new user (admin only)
app.post('/api/register', authenticateToken, isAdmin, async (req, res) => {
  try {
    const { username, password, name, role, branchId } = req.body;
    
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);
    
    const newUser = new User({
      username,
      password: hashedPassword,
      name,
      role,
      branchId
    });
    
    await newUser.save();
    res.status(201).json({ message: 'User created successfully' });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// Login
app.post('/api/login', async (req, res) => {
  try {
    const { username, password } = req.body;
    
    const user = await User.findOne({ username });
    if (!user) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }
    
    const validPassword = await bcrypt.compare(password, user.password);
    if (!validPassword) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }
    
    const token = jwt.sign(
      { id: user._id, username: user.username, role: user.role, branchId: user.branchId },
      'GHAMIAN_SECRET_KEY',
      { expiresIn: '1d' }
    );
    
    res.json({ 
      token, 
      user: { 
        id: user._id, 
        username: user.username, 
        name: user.name, 
        role: user.role, 
        branchId: user.branchId 
      } 
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ----- Branch Routes -----
// Get all branches
app.get('/api/branches', authenticateToken, async (req, res) => {
  try {
    const branches = await Branch.find().populate('manager', 'name');
    res.json(branches);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Create branch (admin only)
app.post('/api/branches', authenticateToken, isAdmin, async (req, res) => {
  try {
    const { name, location, contactNumber, managerId } = req.body;
    
    const newBranch = new Branch({
      name,
      location,
      contactNumber,
      manager: managerId
    });
    
    await newBranch.save();
    res.status(201).json(newBranch);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// Get branch by ID
app.get('/api/branches/:id', authenticateToken, async (req, res) => {
  try {
    const branch = await Branch.findById(req.params.id).populate('manager', 'name');
    if (!branch) {
      return res.status(404).json({ message: 'Branch not found' });
    }
    res.json(branch);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Update branch (admin only)
app.put('/api/branches/:id', authenticateToken, isAdmin, async (req, res) => {
  try {
    const { name, location, contactNumber, managerId } = req.body;
    
    const updatedBranch = await Branch.findByIdAndUpdate(
      req.params.id,
      { name, location, contactNumber, manager: managerId },
      { new: true }
    );
    
    if (!updatedBranch) {
      return res.status(404).json({ message: 'Branch not found' });
    }
    
    res.json(updatedBranch);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// Delete branch (admin only)
app.delete('/api/branches/:id', authenticateToken, isAdmin, async (req, res) => {
  try {
    const branch = await Branch.findByIdAndDelete(req.params.id);
    
    if (!branch) {
      return res.status(404).json({ message: 'Branch not found' });
    }
    
    // Delete all jewelry in this branch
    await Jewelry.deleteMany({ branchId: req.params.id });
    
    // Update users from this branch
    await User.updateMany({ branchId: req.params.id }, { branchId: null });
    
    res.json({ message: 'Branch deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ----- Jewelry Routes -----
// Get all jewelry (filtered by branch if staff)
app.get('/api/jewelry', authenticateToken, async (req, res) => {
  try {
    let query = {};
    
    // Filter by branch if specified
    if (req.query.branchId) {
      query.branchId = req.query.branchId;
    } 
    // If staff user with no branch filter, only show their branch items
    else if (req.user.role === 'staff') {
      query.branchId = req.user.branchId;
    }
    
    // Additional filters
    if (req.query.category) query.category = req.query.category;
    if (req.query.material) query.material = req.query.material;
    
    const jewelry = await Jewelry.find(query).populate('branchId', 'name location');
    res.json(jewelry);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Create jewelry (in user's branch or admin for any branch)
app.post('/api/jewelry', authenticateToken, async (req, res) => {
  try {
    const { name, category, material, weight, price, quantity, description, imageUrl } = req.body;
    
    // Determine branch ID
    let branchId = req.body.branchId;
    
    // Staff can only add to their branch
    if (req.user.role === 'staff') {
      branchId = req.user.branchId;
    }
    
    // Verify branch exists
    const branch = await Branch.findById(branchId);
    if (!branch) {
      return res.status(404).json({ message: 'Branch not found' });
    }
    
    const newJewelry = new Jewelry({
      name,
      category,
      material,
      weight,
      price,
      quantity: quantity || 1,
      description,
      branchId,
      imageUrl
    });
    
    await newJewelry.save();
    res.status(201).json(newJewelry);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// Get jewelry by ID
app.get('/api/jewelry/:id', authenticateToken, async (req, res) => {
  try {
    const jewelry = await Jewelry.findById(req.params.id).populate('branchId', 'name location');
    
    if (!jewelry) {
      return res.status(404).json({ message: 'Jewelry not found' });
    }
    
    res.json(jewelry);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Update jewelry (in user's branch or admin for any)
app.put('/api/jewelry/:id', authenticateToken, isSameBranch, async (req, res) => {
  try {
    const { name, category, material, weight, price, quantity, description, imageUrl } = req.body;
    
    const jewelry = req.jewelry;
    
    // Update fields
    jewelry.name = name || jewelry.name;
    jewelry.category = category || jewelry.category;
    jewelry.material = material || jewelry.material;
    jewelry.weight = weight !== undefined ? weight : jewelry.weight;
    jewelry.price = price !== undefined ? price : jewelry.price;
    jewelry.quantity = quantity !== undefined ? quantity : jewelry.quantity;
    jewelry.description = description || jewelry.description;
    jewelry.imageUrl = imageUrl || jewelry.imageUrl;
    
    await jewelry.save();
    res.json(jewelry);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// Delete jewelry (from user's branch or admin for any)
app.delete('/api/jewelry/:id', authenticateToken, isSameBranch, async (req, res) => {
  try {
    await Jewelry.findByIdAndDelete(req.params.id);
    res.json({ message: 'Jewelry deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ----- Transfer Request Routes -----
// Create transfer request
app.post('/api/transfer-requests', authenticateToken, async (req, res) => {
  try {
    const { jewelryId, quantity, toBranchId } = req.body;
    
    // Verify jewelry exists
    const jewelry = await Jewelry.findById(jewelryId);
    if (!jewelry) {
      return res.status(404).json({ message: 'Jewelry not found' });
    }
    
    // Verify branch exists
    const toBranch = await Branch.findById(toBranchId);
    if (!toBranch) {
      return res.status(404).json({ message: 'Destination branch not found' });
    }
    
    // Check if quantity is available
    if (quantity > jewelry.quantity) {
      return res.status(400).json({ message: 'Requested quantity exceeds available quantity' });
    }
    
    // Create transfer request
    const transferRequest = new TransferRequest({
      jewelryId,
      fromBranchId: jewelry.branchId,
      toBranchId,
      quantity,
      requestedBy: req.user.id
    });
    
    await transferRequest.save();
    
    res.status(201).json(transferRequest);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// Get all transfer requests (branch-specific for staff)
app.get('/api/transfer-requests', authenticateToken, async (req, res) => {
  try {
    let query = {};
    
    // Filter by status if provided
    if (req.query.status) {
      query.status = req.query.status;
    }
    
    // For staff, only show requests involving their branch
    if (req.user.role === 'staff') {
      query.$or = [
        { fromBranchId: req.user.branchId },
        { toBranchId: req.user.branchId }
      ];
    }
    
    const transferRequests = await TransferRequest.find(query)
      .populate('jewelryId', 'name category price')
      .populate('fromBranchId', 'name location')
      .populate('toBranchId', 'name location')
      .populate('requestedBy', 'name username')
      .populate('respondedBy', 'name username');
    
    res.json(transferRequests);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Respond to transfer request (approve/reject)
app.put('/api/transfer-requests/:id', authenticateToken, async (req, res) => {
  try {
    const { status } = req.body;
    
    // Find the request
    const transferRequest = await TransferRequest.findById(req.params.id);
    if (!transferRequest) {
      return res.status(404).json({ message: 'Transfer request not found' });
    }
    
    // Check permissions (admin or from branch staff)
    if (req.user.role !== 'admin' && req.user.branchId.toString() !== transferRequest.fromBranchId.toString()) {
      return res.status(403).json({ message: 'You can only respond to requests from your branch' });
    }
    
    // Check if already processed
    if (transferRequest.status !== 'pending') {
      return res.status(400).json({ message: 'This request has already been processed' });
    }
    
    transferRequest.status = status;
    transferRequest.respondedBy = req.user.id;
    transferRequest.respondedAt = Date.now();
    
    // If approved, transfer the jewelry
    if (status === 'approved') {
      const jewelry = await Jewelry.findById(transferRequest.jewelryId);
      
      // Check if jewelry exists and has enough quantity
      if (!jewelry) {
        return res.status(404).json({ message: 'Jewelry not found' });
      }
      
      if (jewelry.quantity < transferRequest.quantity) {
        return res.status(400).json({ message: 'Not enough quantity available' });
      }
      
      // Check if jewelry already exists at destination branch
      const existingJewelryAtDestination = await Jewelry.findOne({
        name: jewelry.name,
        category: jewelry.category,
        material: jewelry.material,
        branchId: transferRequest.toBranchId
      });
      
      if (existingJewelryAtDestination) {
        // If exists, increment quantity
        existingJewelryAtDestination.quantity += transferRequest.quantity;
        await existingJewelryAtDestination.save();
      } else {
        // If not, create new jewelry at destination
        const newJewelryAtDestination = new Jewelry({
          name: jewelry.name,
          category: jewelry.category,
          material: jewelry.material,
          weight: jewelry.weight,
          price: jewelry.price,
          quantity: transferRequest.quantity,
          description: jewelry.description,
          branchId: transferRequest.toBranchId,
          imageUrl: jewelry.imageUrl
        });
        
        await newJewelryAtDestination.save();
      }
      
      // Decrement quantity from source
      jewelry.quantity -= transferRequest.quantity;
      
      // If quantity becomes 0, delete the jewelry
      if (jewelry.quantity <= 0) {
        await Jewelry.findByIdAndDelete(jewelry._id);
      } else {
        await jewelry.save();
      }
    }
    
    await transferRequest.save();
    
    res.json(transferRequest);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// Get transfer request by ID
app.get('/api/transfer-requests/:id', authenticateToken, async (req, res) => {
  try {
    const transferRequest = await TransferRequest.findById(req.params.id)
      .populate('jewelryId', 'name category price')
      .populate('fromBranchId', 'name location')
      .populate('toBranchId', 'name location')
      .populate('requestedBy', 'name username')
      .populate('respondedBy', 'name username');
    
    if (!transferRequest) {
      return res.status(404).json({ message: 'Transfer request not found' });
    }
    
    // Check permissions (admin can see all, staff only their branch)
    if (req.user.role !== 'admin' && 
        req.user.branchId.toString() !== transferRequest.fromBranchId.toString() && 
        req.user.branchId.toString() !== transferRequest.toBranchId.toString()) {
      return res.status(403).json({ message: 'You can only view requests involving your branch' });
    }
    
    res.json(transferRequest);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ========== SERVER STARTUP ==========
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

module.exports = app;
