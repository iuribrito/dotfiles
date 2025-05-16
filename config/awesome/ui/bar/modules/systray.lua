local wibox = require("wibox")
local helpers = require("helpers")
local colors = require("theme.colorsheme")
local beautiful = require("beautiful")

beautiful.bg_systray = colors.base
beautiful.systray_icon_spacing = 10

local systray = { base_size = 20, widget = wibox.widget.systray }
local systrayContainer =
	helpers.cbackground({ systray, layout = wibox.layout.fixed.horizontal }, helpers.rrect(4), colors.base)

return systrayContainer
