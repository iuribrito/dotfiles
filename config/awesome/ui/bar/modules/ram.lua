local awful = require("awful")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local colors = require("theme.colorsheme")
local helpers = require("helpers")

local HOME = os.getenv("HOME")
local WIDGET_DIR = HOME .. "/.config/awesome/ui/bar/modules"
local ICON_PATH = WIDGET_DIR .. "/icons/chip.svg"

local ramgraph_widget = {}
local swapgraph_widget = {}
local ram_widget = {}

local function worker()
	local timeout = 2
	local widget_height = 25
	local widget_width = 25

	--- Main ram widget shown on wibar
	ramgraph_widget = wibox.widget({
		{
			{
				image = helpers.recolor_image(ICON_PATH, colors.blue),
				resize = true,
				widget = wibox.widget.imagebox,
			},
			valign = "center",
			layout = wibox.container.place,
		},
		max_value = 100,
		thickness = 3,
		forced_height = widget_height,
		forced_width = widget_width,
		colors = { colors.blue },
		bg = colors.background .. "88",
		start_angle = 4.71238898, -- 2pi*3/4
		paddings = 2,
		widget = wibox.container.arcchart,
		set_value = function(self, level)
			self:set_value(level)
		end,
	})

	swapgraph_widget = wibox.widget({
		{
			image = helpers.recolor_image(ICON_PATH, colors.pink),
			resize = true,
			widget = wibox.widget.imagebox,
		},
		max_value = 100,
		thickness = 3,
		forced_height = widget_height,
		forced_width = widget_width,
		colors = { colors.pink },
		bg = colors.background .. "88",
		start_angle = 4.71238898, -- 2pi*3/4
		paddings = 2,
		widget = wibox.container.arcchart,
		set_value = function(self, level)
			self:set_value(level)
		end,
	})

	ram_widget = wibox.widget({
		{
			ramgraph_widget,
			swapgraph_widget,
			spacing = 5,
			layout = wibox.layout.fixed.horizontal,
		},
		widget = wibox.container.background,
	})

	local total, used, total_swap, used_swap

	watch('bash -c "LANGUAGE=en_US.UTF-8 free | grep -z Mem.*Swap.*"', timeout, function(widget, stdout)
		total, used, _, _, _, _, _, _, _ =
			stdout:match("(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*Swap:%s*(%d+)%s*(%d+)%s*(%d+)")

		widget:set_value(math.floor(used / total * 100 + 0.5))
	end, ramgraph_widget)

	watch('bash -c "LANGUAGE=en_US.UTF-8 free | grep -z Mem.*Swap.*"', timeout, function(widget, stdout)
		_, _, _, _, _, _, total_swap, used_swap, _ =
			stdout:match("(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*(%d+)%s*Swap:%s*(%d+)%s*(%d+)%s*(%d+)")

		widget:set_value(math.floor(used_swap / total_swap * 100 + 0.5))
	end, swapgraph_widget)

	ramgraph_widget:buttons(awful.util.table.join(awful.button({}, 1, function()
		awful.spawn("wezterm -e btop")
	end)))

	swapgraph_widget:buttons(awful.util.table.join(awful.button({}, 1, function()
		awful.spawn("wezterm -e btop")
	end)))

	return ram_widget
end

return worker()
