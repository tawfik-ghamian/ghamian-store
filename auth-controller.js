const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

class AuthController {
  constructor(models, config, logger) {
    this.models = models;
    this.config = config;
    this.logger = logger;
  }

  // Register a new user (admin only)
  async register(req, res, next) {
    try {
      const { username, password, name, role, branchId } = req.body;
      
      const salt = await bcrypt.genSalt(this.config.security.bcryptSaltRounds);
      const hashedPassword = await bcrypt.hash(password, salt);
      
      const newUser = new this.models.User({
        username,
        password: hashedPassword,
        name,
        role,
        branchId
      });
      
      await newUser.save();
      this.logger.info(`New user registered: ${username} (${role})`);
      res.status(201).json({ message: 'User created successfully' });
    } catch (error) {
      next(error);
    }
  }

  // Login
  async login(req, res, next) {
    try {
      const { username, password } = req.body;
      
      const user = await this.models.User.findOne({ username });
      if (!user) {
        return res.status(401).json({ message: 'Invalid credentials' });
      }
      
      const validPassword = await bcrypt.compare(password, user.password);
      if (!validPassword) {
        return res.status(401).json({ message: 'Invalid credentials' });
      }
      
      const token = jwt.sign(
        { id: user._id, username: user.username, role: user.role, branchId: user.branchId },
        this.config.jwt.secret,
        { expiresIn: this.config.jwt.expiresIn }
      );
      
      this.logger.info(`User logged in: ${username}`);
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
      next(error);
    }
  }
}

module.exports = AuthController;
