-- Refer to the wiki for more information.
-- https://wiki.hypr.land/Configuring/Start/

browser = "brave-nightly"
terminal = "kitty"
fileManager = "pcmanfm"
menu = "killall rofi || rofi -show drun"

require("lua.app-freezer")

hs = require("lua.hyprsplit")
hs.config({ num_workspaces = 10 })

require("lua.monitors")

require("lua.autostart")

require("lua.environment")

require("lua.permissions")

require("lua.look-and-feel")

require("lua.keybinds")

require("lua.rules")
