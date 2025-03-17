const jwt = require('jsonwebtoken');
const config = require('../config/config');

// Authentication middleware
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  
  if (!token) return res.status(401).json({ message: 'Authentication required' });
  
  jwt.verify(token, config.jwt.secret, (err, user) => {
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
  try {
    const { Jewelry } = req.models;
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
  } catch (error) {
    next(error);
  }
};

module.exports = {
  authenticateToken,
  isAdmin,
  isSameBranch
};
