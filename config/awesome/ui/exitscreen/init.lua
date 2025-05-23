local awful = require("awful")
local beautiful = require("beautiful")
local gtable = require("gears.table")
local wibox = require("wibox")
local colors = require("theme.colorsheme")
local user = require("config.user")

local helpers = require("helpers")
local lock_screen = require("ui.lockscreen")
local button = require("ui.exitscreen.button")

local dpi = beautiful.xresources.apply_dpi
lock_screen.init()

local function hide_exit_screen()
	awesome.emit_signal("exit_screen::hide")
end

-- Commands
local poweroff_command = function()
	awful.spawn.with_shell("systemctl poweroff")
	awesome.emit_signal("exit_screen::hide")
end

local reboot_command = function()
	awful.spawn.with_shell("systemctl reboot")
	awesome.emit_signal("exit_screen::hide")
end

local suspend_command = function()
	awesome.emit_signal("exit_screen::hide")
	-- lock_screen_show()
	awful.spawn.with_shell("systemctl suspend")
end

local exit_command = function()
	awesome.quit()
end

local lock_command = function()
	awesome.emit_signal("exit_screen::hide")
	lock_screen_show()
end

-- Create the buttons
local poweroff = button("\u{e8ac}", colors.red, "P", "oweroff", poweroff_command)
local reboot = button("\u{f053}", colors.yellow, "R", "eboot", reboot_command)
local suspend = button("\u{ef44}", colors.lavender, "S", "uspend", suspend_command)
local lock = button("\u{e897}", colors.green, "L", "ock", lock_command)
local exit = button("\u{e9ba}", colors.blue, "E", "xit", exit_command)

local create_exit_screen = function(s)
	s.exit_screen = wibox({
		screen = s,
		type = "splash",
		visible = false,
		ontop = true,
		bg = colors.base .. "D7",
		y = s.geometry.y,
		height = s.geometry.height,
		width = s.geometry.width,
	})

	s.exit_screen:setup({
		{
			{
				{
					markup = "Press any of the listed keys to perform an action",
					font = user.config.font_name .. " 13",
					halign = "center",
					widget = wibox.widget.textbox,
				},
				fg = colors.foreground .. "A0",
				widget = wibox.container.background,
			},
			{
				poweroff,
				reboot,
				suspend,
				lock,
				exit,
				spacing = dpi(44),
				layout = wibox.layout.fixed.horizontal,
			},
			spacing = dpi(32),
			layout = wibox.layout.fixed.vertical,
		},
		widget = wibox.container.place,
	})

	s.exit_screen:buttons(gtable.join(awful.button({}, 2, hide_exit_screen), awful.button({}, 3, hide_exit_screen)))
end

screen.connect_signal("request::desktop_decoration", create_exit_screen)
screen.connect_signal("removed", create_exit_screen)

local exit_screen_grabber = awful.keygrabber({
	auto_start = true,
	stop_event = "release",
	keypressed_callback = function(self, mod, key, command)
		if key == "s" then
			suspend_command()
		elseif key == "e" then
			exit_command()
		elseif key == "l" then
			lock_command()
		elseif key == "p" then
			poweroff_command()
		elseif key == "r" then
			reboot_command()
		elseif key == "Escape" or key == "q" or key == "x" then
			awesome.emit_signal("exit_screen::hide")
		end
	end,
})

awesome.connect_signal("exit_screen::show", function()
	for s in screen do
		s.exit_screen.visible = true
	end
	exit_screen_grabber:start()
end)

awesome.connect_signal("exit_screen::hide", function()
	exit_screen_grabber:stop()
	for s in screen do
		s.exit_screen.visible = false
	end
end)
