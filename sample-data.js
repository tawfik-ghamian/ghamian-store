// Sample Data Generation Script
const mongoose = require('mongoose');
const bcrypt = require('bcrypt');

// Models (Import these from your main application file)
const User = mongoose.model('User', require('./models/user'));
const Branch = mongoose.model('Branch', require('./models/branch'));
const Jewelry = mongoose.model('Jewelry', require('./models/jewelry'));
const TransferRequest = mongoose.model('TransferRequest', require('./models/transferRequest'));

// Connect to database
mongoose.connect('mongodb://localhost:27017/ghamian_jewelry_store', {
  useNewUrlParser: true,
  useUnifiedTopology: true
});

// Clear existing data
async function clearAllData() {
  await User.deleteMany({});
  await Branch.deleteMany({});
  await Jewelry.deleteMany({});
  await TransferRequest.deleteMany({});
  console.log('All existing data cleared');
}

// Create sample data
async function createSampleData() {
  try {
    await clearAllData();
    
    // Create admin user first
    const adminPassword = await bcrypt.hash('admin123', 10);
    const admin = new User({
      username: 'admin',
      password: adminPassword,
      name: 'System Administrator',
      role: 'admin'
    });
    await admin.save();
    console.log('Admin user created');
    
    // Create branches
    const branches = [
      {
        name: 'Ghamian Downtown',
        location: '123 Main Street, Downtown',
        contactNumber: '+1-555-1234'
      },
      {
        name: 'Ghamian Uptown',
        location: '456 Park Avenue, Uptown',
        contactNumber: '+1-555-5678'
      },
      {
        name: 'Ghamian Westside',
        location: '789 West Boulevard, Westside',
        contactNumber: '+1-555-9012'
      },
      {
        name: 'Ghamian Eastside',
        location: '321 East Road, Eastside',
        contactNumber: '+1-555-3456'
      }
    ];
    
    const createdBranches = [];
    for (const branchData of branches) {
      const branch = new Branch(branchData);
      await branch.save();
      createdBranches.push(branch);
      console.log(`Branch created: ${branch.name}`);
    }
    
    // Create branch managers and staff
    const staffPassword = await bcrypt.hash('staff123', 10);
    
    for (let i = 0; i < createdBranches.length; i++) {
      // Create manager
      const manager = new User({
        username: `manager${i+1}`,
        password: staffPassword,
        name: `Manager ${i+1}`,
        role: 'staff',
        branchId: createdBranches[i]._id
      });
      await manager.save();
      
      // Update branch with manager
      createdBranches[i].manager = manager._id;
      await createdBranches[i].save();
      
      // Create additional staff for each branch
      for (let j = 1; j <= 2; j++) {
        const staff = new User({
          username: `staff${i+1}${j}`,
          password: staffPassword,
          name: `Staff ${i+1}-${j}`,
          role: 'staff',
          branchId: createdBranches[i]._id
        });
        await staff.save();
      }
      
      console.log(`Created staff for branch: ${createdBranches[i].name}`);
    }
    
    // Create jewelry items
    const jewelryCategories = ['Ring', 'Necklace', 'Bracelet', 'Earring', 'Watch', 'Pendant'];
    const materials = ['Gold', 'Silver', 'Platinum', 'Diamond', 'Pearl', 'Ruby', 'Sapphire', 'Emerald'];
    
    // Sample jewelry data for each branch
    const jewelryData = [
      // Branch 1 - Downtown (Luxury focus)
      [
        { name: 'Royal Diamond Ring', category: 'Ring', material: 'Diamond', weight: 12.5, price: 5999, quantity: 3 },
        { name: 'Platinum Elegance Watch', category: 'Watch', material: 'Platinum', weight: 85.0, price: 8999, quantity: 2 },
        { name: 'Sapphire Teardrop Necklace', category: 'Necklace', material: 'Sapphire', weight: 25.3, price: 4250, quantity: 4 },
        { name: 'Gold Sovereign Band', category: 'Ring', material: 'Gold', weight: 18.2, price: 1899, quantity: 5 },
        { name: 'Diamond Chandelier Earrings', category: 'Earring', material: 'Diamond', weight: 8.7, price: 3750, quantity: 3 }
      ],
      
      // Branch 2 - Uptown (Modern design focus)
      [
        { name: 'Contemporary Silver Bangle', category: 'Bracelet', material: 'Silver', weight: 45.8, price: 950, quantity: 8 },
        { name: 'Minimalist Gold Pendant', category: 'Pendant', material: 'Gold', weight: 12.1, price: 1450, quantity: 6 },
        { name: 'Geometric Ruby Ring', category: 'Ring', material: 'Ruby', weight: 10.5, price: 2250, quantity: 4 },
        { name: 'Modern Pearl Earrings', category: 'Earring', material: 'Pearl', weight: 5.3, price: 875, quantity: 10 },
        { name: 'Platinum Chain Necklace', category: 'Necklace', material: 'Platinum', weight: 32.4, price: 3150, quantity: 3 }
      ],
      
      // Branch 3 - Westside (Traditional focus)
      [
        { name: 'Classic Gold Wedding Band', category: 'Ring', material: 'Gold', weight: 9.8, price: 1250, quantity: 12 },
        { name: 'Traditional Pearl Necklace', category: 'Necklace', material: 'Pearl', weight: 28.5, price: 1850, quantity: 7 },
        { name: 'Vintage Ruby Earrings', category: 'Earring', material: 'Ruby', weight: 6.2, price: 2150, quantity: 5 },
        { name: 'Heirloom Emerald Bracelet', category: 'Bracelet', material: 'Emerald', weight: 22.7, price: 3650, quantity: 2 },
        { name: 'Antique Silver Pocket Watch', category: 'Watch', material: 'Silver', weight: 75.3, price: 1950, quantity: 3 }
      ],
      
      // Branch 4 - Eastside (Fashion forward focus)
      [
        { name: 'Trendy Diamond Choker', category: 'Necklace', material: 'Diamond', weight: 15.6, price: 2750, quantity: 4 },
        { name: 'Fashion Forward Ear Cuff', category: 'Earring', material: 'Silver', weight: 3.8, price: 650, quantity: 15 },
        { name: 'Statement Sapphire Ring', category: 'Ring', material: 'Sapphire', weight: 11.2, price: 1950, quantity: 6 },
        { name: 'Stackable Gold Bracelets', category: 'Bracelet', material: 'Gold', weight: 35.7, price: 1650, quantity: 8 },
        { name: 'Smart Hybrid Watch', category: 'Watch', material: 'Silver', weight: 62.5, price: 2450, quantity: 5 }
      ]
    ];
    
    // Create jewelry items for each branch
    for (let i = 0; i < createdBranches.length; i++) {
      const branchJewelry = jewelryData[i];
      
      for (const item of branchJewelry) {
        const jewelry = new Jewelry({
          ...item,
          description: `Beautiful ${item.material} ${item.category.toLowerCase()} from Ghamian Jewelry.`,
          branchId: createdBranches[i]._id,
          imageUrl: `/images/${item.category.toLowerCase()}_${i+1}.jpg` // Placeholder image path
        });
        
        await jewelry.save();
      }
      
      console.log(`Created jewelry for branch: ${createdBranches[i].name}`);
    }
    
    // Create sample transfer requests
    // Get some staff users to create requests
    const staff1 = await User.findOne({ username: 'staff11' });
    const staff2 = await User.findOne({ username: 'staff21' });
    
    // Get jewelry items for transfer
    const jewelry1 = await Jewelry.findOne({ name: 'Gold Sovereign Band' });
    const jewelry2 = await Jewelry.findOne({ name: 'Modern Pearl Earrings' });
    
    // Create transfer requests
    const transferRequest1 = new TransferRequest({
      jewelryId: jewelry1._id,
      fromBranchId: jewelry1.branchId,
      toBranchId: createdBranches[1]._id, // Downtown to Uptown
      quantity: 2,
      requestedBy: staff2._id,
      status: 'pending'
    });
    await transferRequest1.save();
    
    const transferRequest2 = new TransferRequest({
      jewelryId: jewelry2._id,
      fromBranchId: jewelry2.branchId,
      toBranchId: createdBranches[0]._id, // Uptown to Downtown
      quantity: 3,
      requestedBy: staff1._id,
      status: 'pending'
    });
    await transferRequest2.save();
    
    console.log('Created sample transfer requests');
    
    console.log('Sample data creation completed successfully!');
    console.log('\nCredentials:');
    console.log('Admin: username = admin, password = admin123');
    console.log('Branch Staff: username = staff11, password = staff123');
    
  } catch (error) {
    console.error('Error creating sample data:', error);
  } finally {
    // Close connection
    mongoose.connection.close();
  }
}

// Run the data creation
createSampleData();
