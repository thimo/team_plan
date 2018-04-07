process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const environment = require('./environment');

const configureHotModuleReplacement = require('webpacker-react/configure-hot-module-replacement');

module.exports = configureHotModuleReplacement(environment);
