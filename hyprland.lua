-- Punto de entrada de Hyprland 0.56+. Cada módulo configura una responsabilidad.
local settings = require("./lua/settings.lua")
local theme = require("./themes/" .. settings.theme .. ".lua")

require("./lua/monitors.lua")
require("./lua/environment.lua")
require("./lua/appearance.lua")(theme)
require("./lua/input.lua")
require("./lua/layouts.lua")
require("./lua/workspaces.lua")
require("./lua/windowrules.lua")
require("./lua/autostart.lua")
require("./lua/keybinds.lua")(settings)
