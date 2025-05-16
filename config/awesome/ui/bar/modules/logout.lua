local awful = require("awful")
local wibox = require("wibox")
local helpers = require("helpers")
local colors = require("theme.colorsheme")
local user = require("config.user")
local _ = require("ui.exitscreen")

local logout_icon_path = user.config.home .. "/.config/awesome/theme/icons/exit_1.svg" -- Path to your SVG icon

local buttons = {
	awful.button({
		description = "open launcher",
		modifiers = {},
		button = 1,
		on_press = function() awesome.emit_signal("exit_screen::show") end,
		on_release = nil,
	}),
}

local logout = wibox.widget({
	image = helpers.recolor_image(logout_icon_path, colors.red),
	resize = true,
	valign = "center",
	halign = "center",
	widget = wibox.widget.imagebox,
	buttons = buttons,
})
local mylogout = helpers.margin(logout, 0, 0, 0, 0)

return mylogout
