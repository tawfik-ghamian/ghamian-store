// server.js
const express = require('express');
const bodyParser = require('body-parser');
const morgan = require('morgan');
const config = require('./config/config');
const createLogger = require('./config/logger');
const { connectToDatabase } = require('./config/database');
const routes = require('./routes');

// Initialize the logger with our config
const logger = createLogger(config);

// Initialize Express app
const app = express();

// Basic middleware
app.use(bodyParser.json());

// Request logging middleware
if (config.logging.requests) {
  app.use(morgan(config.env === 'development' ? 'dev' : 'combined', { stream: logger.stream }));
}

// Add environment-specific middleware
if (config.env !== 'production') {
  // Add request timing middleware for development
  app.use((req, res, next) => {
    req.startTime = Date.now();
    
    // Log response time when finished
    res.on('finish', () => {
      const duration = Date.now() - req.startTime;
      logger.debug(`${req.method} ${req.url} - ${res.statusCode} - ${duration}ms`);
    });
    
    next();
  });
  
  // Add route to check current environment
  app.get('/api/system/info', (req, res) => {
    res.json({
      environment: config.env,
      version: require('./package.json').version,
      uptime: process.uptime()
    });
  });
}

// Initialize API
const initializeAPI = async () => {
  try {
    // Connect to database and get models
    const { models } = await connectToDatabase(config);
    
    // Initialize routes with models
    routes(app, { config, logger, models });
    
    // Global error handler
    app.use((err, req, res, next) => {
      logger.error(`Error processing ${req.method} ${req.url}: ${err.message}`, { 
        error: err.stack,
        user: req.user ? req.user.id : 'unauthenticated',
        body: config.env !== 'production' ? req.body : '[redacted]'
      });
      
      res.status(err.status || 500).json({ 
        message: config.env === 'production' ? 'An unexpected error occurred' : err.message 
      });
    });
    
    // Handle 404 errors for unmatched routes
    app.use((req, res) => {
      logger.warn(`Route not found: ${req.method} ${req.url}`);
      res.status(404).json({ message: 'Endpoint not found' });
    });
    
    // Start server
    const server = app.listen(config.port, () => {
      logger.info(`Server running in ${config.env} mode on port ${config.port}`);
    });
    
    // Handle graceful shutdown
    process.on('SIGTERM', () => {
      logger.info('SIGTERM received, shutting down gracefully');
      server.close(() => {
        logger.info('HTTP server closed');
        process.exit(0);
      });
    });
    
    return server;
  } catch (error) {
    logger.error(`Failed to initialize API: ${error.message}`);
    process.exit(1);
  }
};

// Start the API if this file was run directly (not imported)
if (require.main === module) {
  initializeAPI();
}

module.exports = { app, initializeAPI };
