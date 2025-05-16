local awful = require("awful")
local wibox = require("wibox")
local helpers = require("helpers")
local colors = require("theme.colorsheme")

-----------------------------------------------------------------------------
-- Widgets
-----------------------------------------------------------------------------
local clock = require("ui.bar.modules.clock")
local layoutbox = require("ui.bar.modules.layoutbox")
local logout = require("ui.bar.modules.logout")
local systray = require("ui.bar.modules.systray")
local taglist = require("ui.bar.modules.taglist")
local tasklist = require("ui.bar.modules.tasklist")
local cpu = require("ui.bar.modules.cpu")
local battery = require("ui.bar.modules.battery")
local ram = require("ui.bar.modules.ram")

awful.screen.connect_for_each_screen(function(s)
	awful.tag({ "1", "2", "3", "4", "5" }, s, awful.layout.layouts[1])

	-----------------------------------------------------------------------------
	-- Bar
	-----------------------------------------------------------------------------

	s.bar = awful.wibar({
		position = "top",
		screen = s,
		visible = true,
		ontop = false,
		height = 40,
		margins = { top = 10, left = 10, right = 10 },
		shape = helpers.rrect(10),
		type = "dock",
	})

	s.bar:setup({
		{
			{
				-- Left widgets
				{
					helpers.margin(taglist(s), 10, 4, 14, 14),
					layout = wibox.layout.fixed.horizontal,
				},

				-- Center widgets
				{
					helpers.margin(clock, 0, 0, 8, 8),
					layout = wibox.layout.flex.horizontal,
				},

				-- Right widgets
				{
					helpers.margin(systray, 4, 4, 8, 8),
					helpers.margin(cpu, 4, 4, 8, 8),
					helpers.margin(ram, 4, 4, 8, 8),
					helpers.margin(battery, 4, 4, 8, 8),
					helpers.margin(logout, 4, 10, 8, 8),
					layout = wibox.layout.fixed.horizontal,
				},
				expand = "none",
				layout = wibox.layout.align.horizontal,
			},
			layout = wibox.layout.stack,
		},
		widget = wibox.container.background,
		bg = colors.mantle,
	})
end)
