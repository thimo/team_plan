require('../startui/app.js')

// Which will recursively load all modules within the current folder that end in .js.
var requireApplication = require.context('../application', true, /\.js$/);
requireApplication.keys().forEach(requireApplication);
