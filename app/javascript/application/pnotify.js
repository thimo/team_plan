import PNotify from "pnotify/dist/es/PNotify.js";
import PNotifyButtons from "pnotify/dist/es/PNotifyButtons.js";

const stack_topright = {
  "dir1": "down",
  "dir2": "left",
  "firstpos1": 10,
  "firstpos2": 10,
  "spacing1": 10,
  "spacing2": 10
};

PNotify.defaults.styling = "bootstrap4";
PNotify.defaults.icons = "fontawesome5";
PNotify.defaults.shadow = false;
PNotify.defaults.cornerClass = "alert-fill";
PNotify.defaults.stack = stack_topright;

PNotify.defaults.modules = {
  Buttons: {
    closer: true,
    sticker: false
  }
};

window.pnotify = window.PNotify = PNotify
