// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

require('../startui/app.js')

var requireApplication = require.context('../application', true, /\.js$/);
requireApplication.keys().forEach(requireApplication);
// Which will recursively load all modules within the current folder that end in .js.
