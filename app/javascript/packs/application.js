import { Application } from "stimulus";
import { definitionsFromContext } from "stimulus/webpack-helpers";

import "jquery";
import "jquery-ujs";
import "bootstrap";
import "popper.js";
// import '@coreui/coreui'
import "select2";
import "bootstrap-datepicker";
import "bootstrap-datepicker/dist/locales/bootstrap-datepicker.nl.min";
import "chart.js";
import "trix";
import "sticky-table-headers";

import "trix/dist/trix.css";
import "bootstrap-datepicker/dist/css/bootstrap-datepicker3";

import Turbolinks from "turbolinks";
Turbolinks.start();

// Which will recursively load all modules within the current folder that end in .js.
var requireApplication = require.context("../application", true, /\.js$/);
requireApplication.keys().forEach(requireApplication);

const application = Application.start();
const context = require.context("../controllers", true, /\.js$/);
application.load(definitionsFromContext(context));

$.fn.select2.defaults.set("theme", "bootstrap");
