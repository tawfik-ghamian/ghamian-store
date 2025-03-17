// config/logger.js
const winston = require('winston');
const fs = require('fs');
const path = require('path');

// Create logs directory if it doesn't exist
const logsDir = path.join(process.cwd(), 'logs');
if (!fs.existsSync(logsDir)) {
  fs.mkdirSync(logsDir);
}

// Custom log format with timestamps and colors
const logFormat = winston.format.combine(
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
  winston.format.errors({ stack: true }),
  winston.format.splat(),
  winston.format.printf(({ level, message, timestamp, ...metadata }) => {
    let metaStr = '';
    if (Object.keys(metadata).length > 0 && metadata.stack === undefined) {
      metaStr = JSON.stringify(metadata);
    }
    return `${timestamp} [${level.toUpperCase()}]: ${message} ${metaStr}`;
  })
);

// Create logger based on environment
const createLogger = (config) => {
  const transports = [];
  
  // Always log errors to a file
  transports.push(
    new winston.transports.File({ 
      filename: path.join(logsDir, 'error.log'), 
      level: 'error',
      maxsize: 5242880, // 5MB
      maxFiles: 5,
    })
  );
  
  // Log all levels to a combined file
  transports.push(
    new winston.transports.File({ 
      filename: path.join(logsDir, `${config.env}.log`),
      maxsize: 10485760, // 10MB
      maxFiles: 5,
    })
  );
  
  // Add console logging for non-production environments
  if (config.env !== 'production' || config.logging.console) {
    transports.push(
      new winston.transports.Console({
        format: winston.format.combine(
          winston.format.colorize(),
          winston.format.simple()
        )
      })
    );
  }
  
  // Create the logger
  const logger = winston.createLogger({
    level: config.logging.level || 'info',
    format: logFormat,
    transports
  });
  
  // Add a stream for Morgan HTTP logger
  logger.stream = {
    write: (message) => {
      logger.info(message.trim());
    }
  };
  
  return logger;
};

module.exports = createLogger;
