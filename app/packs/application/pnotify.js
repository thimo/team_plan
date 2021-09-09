import * as PNotify from "@pnotify/core";
import * as PNotifyMobile from "@pnotify/mobile";
import * as PNotifyBootstrap4 from "@pnotify/bootstrap4";
import * as PNotifyFontAwesome5 from "@pnotify/font-awesome5";

PNotify.defaultModules.set(PNotifyMobile, {});
PNotify.defaultModules.set(PNotifyBootstrap4, {});
PNotify.defaultModules.set(PNotifyFontAwesome5, {});
PNotify.defaults.sticker = false

window.pnotify = window.PNotify = PNotify
