class BranchController {
  constructor(models, logger) {
    this.models = models;
    this.logger = logger;
  }

  // Get all branches
  async getAllBranches(req, res, next) {
    try {
      const branches = await this.models.Branch.find().populate('manager', 'name');
      res.json(branches);
    } catch (error) {
      next(error);
    }
  }

  // Create branch (admin only)
  async createBranch(req, res, next) {
    try {
      const { name, location, contactNumber, managerId } = req.body;
      
      const newBranch = new this.models.Branch({
        name,
        location,
        contactNumber,
        manager: managerId
      });
      
      await newBranch.save();
      this.logger.info(`New branch created: ${name}`);
      res.status(201).json(newBranch);
    } catch (error) {
      next(error);
    }
  }

  // Get branch by ID
  async getBranchById(req, res, next) {
    try {
      const branch = await this.models.Branch.findById(req.params.id).populate('manager', 'name');
      if (!branch) {
        return res.status(404).json({ message: 'Branch not found' });
      }
      res.json(branch);
    } catch (error) {
      next(error);
    }
  }

  // Update branch (admin only)
  async updateBranch(req, res, next) {
    try {
      const { name, location, contactNumber, managerId } = req.body;
      
      const updatedBranch = await this.models.Branch.findByIdAndUpdate(
        req.params.id,
        { name, location, contactNumber, manager: managerId },
        { new: true }
      );
      
      if (!updatedBranch) {
        return res.status(404).json({ message: 'Branch not found' });
      }
      
      this.logger.info(`Branch updated: ${name} (${req.params.id})`);
      res.json(updatedBranch);
    } catch (error) {
      next(error);
    }
  }

  // Delete branch (admin only)
  async deleteBranch(req, res, next) {
    try {
      const branch = await this.models.Branch.findById(req.params.id);
      
      if (!branch) {
        return res.status(404).json({ message: 'Branch not found' });
      }
      
      // Delete branch
      await this.models.Branch.findByIdAndDelete(req.params.id);
      
      // Delete all jewelry in this branch
      await this.models.Jewelry.deleteMany({ branchId: req.params.id });
      
      // Update users from this branch
      await this.models.User.updateMany({ branchId: req.params.id }, { branchId: null });
      
      this.logger.info(`Branch deleted: ${branch.name} (${req.params.id})`);
      res.json({ message: 'Branch deleted successfully' });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = BranchController;
