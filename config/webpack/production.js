process.env.NODE_ENV = process.env.NODE_ENV || 'production'

const environment = require('./environment')

environment.devtool = 'sourcemap'

module.exports = environment
