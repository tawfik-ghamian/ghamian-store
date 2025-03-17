class JewelryController {
  constructor(models, logger) {
    this.models = models;
    this.logger = logger;
  }

  // Get all jewelry (filtered by branch if staff)
  async getAllJewelry(req, res, next) {
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
      
      const jewelry = await this.models.Jewelry.find(query).populate('branchId', 'name location');
      res.json(jewelry);
    } catch (error) {
      next(error);
    }
  }

  // Create jewelry
  async createJewelry(req, res, next) {
    try {
      const { name, category, material, weight, price, quantity, description, imageUrl } = req.body;
      
      // Determine branch ID
      let branchId = req.body.branchId;
      
      // Staff can only add to their branch
      if (req.user.role === 'staff') {
        branchId = req.user.branchId;
      }
      
      // Verify branch exists
      const branch = await this.models.Branch.findById(branchId);
      if (!branch) {
        return res.status(404).json({ message: 'Branch not found' });
      }
      
      const newJewelry = new this.models.Jewelry({
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
      this.logger.info(`New jewelry created: ${name} in branch ${branch.name}`);
      res.status(201).json(newJewelry);
    } catch (error) {
      next(error);
    }
  }

  // Get jewelry by ID
  async getJewelryById(req, res, next) {
    try {
      const jewelry = await this.models.Jewelry.findById(req.params.id).populate('branchId', 'name location');
      
      if (!jewelry) {
        return res.status(404).json({ message: 'Jewelry not found' });
      }
      
      res.json