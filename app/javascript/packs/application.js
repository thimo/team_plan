// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import { Application } from "stimulus";
import { definitionsFromContext } from "stimulus/webpack-helpers";

require("@rails/ujs").start();
require("turbolinks").start();
require("@rails/activestorage").start();
require("channels");

import "jquery";
import "bootstrap";
import "popper.js";
// import '@coreui/coreui'
import "select2";
import "select2/dist/js/i18n/nl"
import "bootstrap-datepicker";
import "bootstrap-datepicker/dist/locales/bootstrap-datepicker.nl.min";
import "chart.js";
import "trix";
import "sticky-table-headers";

import "css/application";

// Which will recursively load all modules within the current folder that end in .js.
var requireApplication = require.context("../application", true, /\.js$/);
requireApplication.keys().forEach(requireApplication);

$.fn.select2.defaults.set("theme", "bootstrap");

const application = Application.start();
const context = require.context("../controllers", true, /\.js$/);
application.load(definitionsFromContext(context));
