// config/config.js
require('dotenv').config();

const config = {
  development: {
    env: 'development',
    port: process.env.DEV_PORT || 3001,
    database: {
      url: process.env.DEV_DB_URL || 'mongodb://localhost:27017/ghamian_jewelry_store_dev',
      options: {
        useNewUrlParser: true,
        useUnifiedTopology: true
      },
      seed: true // Enable seeding in development
    },
    jwt: {
      secret: process.env.DEV_JWT_SECRET || 'GHAMIAN_DEV_SECRET_KEY',
      expiresIn: '1d'
    },
    logging: {
      level: 'debug',
      console: true,
      requests: true,
      colorize: true
    },
    security: {
      bcryptSaltRounds: 10
    }
  },
  
  test: {
    env: 'test',
    port: process.env.TEST_PORT || 3002,
    database: {
      url: process.env.TEST_DB_URL || 'mongodb://localhost:27017/ghamian_jewelry_store_test',
      options: {
        useNewUrlParser: true,
        useUnifiedTopology: true
      },
      seed: false
    },
    jwt: {
      secret: process.env.TEST_JWT_SECRET || 'GHAMIAN_TEST_SECRET_KEY',
      expiresIn: '1h'
    },
    logging: {
      level: 'error',
      console: false,
      requests: false
    },
    security: {
      bcryptSaltRounds: 10
    }
  },
  
  production: {
    env: 'production',
    port: process.env.PROD_PORT || 3000,
    database: {
      url: process.env.PROD_DB_URL || 'mongodb://localhost:27017/ghamian_jewelry_store_prod',
      options: {
        useNewUrlParser: true,
        useUnifiedTopology: true,
        poolSize: 10,
        socketTimeoutMS: 45000
      },
      seed: false
    },
    jwt: {
      secret: process.env.PROD_JWT_SECRET || 'GHAMIAN_PROD_SECRET_KEY',
      expiresIn: '8h'
    },
    logging: {
      level: 'info',
      console: false,
      requests: true
    },
    security: {
      bcryptSaltRounds: 12
    }
  }
};

// Get current environment from NODE_ENV
const env = process.env.NODE_ENV || 'development';

// Validate that we have a valid configuration for this environment
if (!config[env]) {
  console.error(`No configuration found for environment: ${env}`);
  process.exit(1);
}

module.exports = config[env];
