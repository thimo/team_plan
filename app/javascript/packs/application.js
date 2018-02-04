import { Application } from "stimulus"
import { definitionsFromContext } from "stimulus/webpack-helpers"

require('../startui/app.js')

// Which will recursively load all modules within the current folder that end in .js.
var requireApplication = require.context('./application', true, /\.js$/);
requireApplication.keys().forEach(requireApplication);

const application = Application.start()
const context = require.context("./controllers", true, /\.js$/)
application.load(definitionsFromContext(context))
