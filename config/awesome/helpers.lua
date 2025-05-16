local wibox = require("wibox")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi
local colors = require("theme.colorsheme")
local spawn = require("awful.spawn")

local helpers = {}


helpers.run_command = function(cmd)
  local handle = io.popen(cmd)
  if handle then
    local result = handle:read("*a")
    handle:close()
    return result:gsub("\n", "") -- Remove trailing newline
  else
    return nil -- Return nil if the command fails
  end
end

helpers.mtext = function(color, font, text)
	return '<span color="' .. color .. '" font="' .. font .. '">' .. text .. "</span>"
end

helpers.textbox = function(color, font, text)
	return wibox.widget({
		markup = '<span color="' .. color .. '" font="' .. font .. '">' .. text .. "</span>",
		widget = wibox.widget.textbox,
	})
end

helpers.margin = function(wgt, ml, mr, mt, mb, visible)
	return wibox.widget({
		wgt,
		widget = wibox.container.margin,
		left = dpi(ml),
		right = dpi(mr),
		top = dpi(mt),
		bottom = dpi(mb),
		visible = visible,
	})
end

helpers.rrect = function(radius)
	radius = radius or dpi(4)
	return function(cr, width, height)
		gears.shape.rounded_rect(cr, width, height, radius)
	end
end

helpers.cbackground = function(widget, shape, bg)
	return wibox.widget({
		widget,
		shape = shape,
		bg = bg,
		widget = wibox.container.background,
	})
end

helpers.tagcolor = function(self, c3)
	if c3.selected then
		self.bg = colors.pink
		self.forced_width = 36
	elseif #c3:clients() == 0 then
		self.bg = colors.surface1
		self.forced_width = 12
	else
		self.bg = colors.blue
		self.forced_width = 12
	end
end

helpers.recolor_image = function(image, color)
	return gears.color.recolor_image(image, color)
end

-- Brightness Control
helpers.get_brightness = function()
	spawn.easy_async_with_shell("brightnessctl i | grep -o '[0-9]*%'", function(stdout)
		local value = tonumber(stdout:match("(%d+)"))
		awesome.emit_signal("brightness::value", value)
	end)
end

helpers.brightness_control = function(type, value)
	local cmd
	if type == "increase" then
		cmd = "brightnessctl set 5%+ -q"
	elseif type == "decrease" then
		cmd = "brightnessctl set 5%- -q"
	else
		cmd = "brightnessctl set -q " .. tostring(value) .. "%"
	end

	spawn.easy_async(cmd, helpers.get_brightness)
end

-- Volume Control
helpers.get_volume = function()
	spawn.easy_async("pamixer --get-mute --get-volume", function(stdout)
		local muted, volume = table.unpack(gears.string.split(stdout, " "))
		awesome.emit_signal("signal::volume", tonumber(volume), muted == "true")
	end)
end

helpers.volume_control = function(type, value)
	local cmd
	if type == "increase" then
		cmd = "pamixer -i " .. tostring(value)
	elseif type == "decrease" then
		cmd = "pamixer -d " .. tostring(value)
	elseif type == "mute" then
		cmd = "pamixer -t"
	else
		cmd = "pamixer --set-volume " .. tostring(value)
	end

	spawn.easy_async(cmd, helpers.get_volume)
end

return helpers
