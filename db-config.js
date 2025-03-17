// config/database.js
const mongoose = require('mongoose');
const logger = require('./logger');

// Database schemas and models (moved from main file)
const createModels = () => {
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

  return { User, Branch, Jewelry, TransferRequest };
};

// Database connection function
const connectToDatabase = async (config) => {
  try {
    const connection = await mongoose.connect(config.database.url, config.database.options);
    logger.info(`Connected to database: ${config.database.url} (${config.env})`);
    
    // Initialize models after successful connection
    const models = createModels();
    
    // Add some seed data in development mode
    if (config.env === 'development' && config.database.seed) {
      await seedDevelopmentData(models);
    }
    
    return { connection, models };
  } catch (error) {
    logger.error(`Database connection error (${config.env}): ${error.message}`);
    throw error;
  }
};

// Seed function for development database
const seedDevelopmentData = async (models) => {
  const { User, Branch, Jewelry } = models;
  
  // Check if we already have data
  const adminCount = await User.countDocuments({ role: 'admin' });
  if (adminCount > 0) {
    logger.info('Development database already seeded, skipping');
    return;
  }
  
  logger.info('Seeding development database with initial data');
  
  try {
    // Create admin user
    const adminUser = new User({
      username: 'admin',
      password: '$2b$10$iNT.d38.rdsRvRMU95WTSu0ZNUfaUjHBDiZAWRmOJVYIl1sJr3A/m', // 'password123'
      name: 'Admin User',
      role: 'admin'
    });
    await adminUser.save();
    
    // Create test branch
    const testBranch = new Branch({
      name: 'Test Branch',
      location: 'Test Location',
      contactNumber: '123-456-7890'
    });
    await testBranch.save();
    
    // Create test staff user
    const staffUser = new User({
      username: 'staff',
      password: '$2b$10$iNT.d38.rdsRvRMU95WTSu0ZNUfaUjHBDiZAWRmOJVYIl1sJr3A/m', // 'password123'
      name: 'Staff User',
      role: 'staff',
      branchId: testBranch._id
    });
    await staffUser.save();
    
    // Create sample jewelry
    const sampleJewelry = new Jewelry({
      name: 'Gold Ring',
      category: 'Ring',
      material: 'Gold',
      weight: 10,
      price: 1200,
      quantity: 5,
      description: 'Sample gold ring for testing',
      branchId: testBranch._id
    });
    await sampleJewelry.save();
    
    logger.info('Development database seeded successfully');
  } catch (error) {
    logger.error(`Error seeding development database: ${error.message}`);
  }
};

module.exports = { connectToDatabase };
