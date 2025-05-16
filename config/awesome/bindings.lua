local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")
local user = require("config.user")
local naughty = require("naughty")
local helpers = require("helpers")

-- supers
local alt = "Mod1"
local super = "Mod4"
local ctrl = "Control"
local shift = "Shift"

-- Mouse buttons
local leftclick = 1
local midclick = 2
local rightclick = 3
local scrolldown = 4
local scrollup = 5
local sidedownclick = 8
local ideupclick = 9

-- Create the main menu
local mymainmenu = awful.menu({
	items = {
		{
			"open terminal",
			function()
				awful.spawn(user.apps.terminal)
			end,
		},
		{
			"open web browser",
			function()
				awful.spawn(user.apps.web_browser)
			end,
		},
		{
			"open file manager",
			function()
				awful.spawn(user.apps.file_manager)
			end,
		},
		{
			"open text editor",
			function()
				awful.spawn(user.apps.text_editor)
			end,
		},
		{
			"open launcher",
			function()
				awful.spawn(user.apps.launcher)
			end,
		},
		{ "reload awesome", awesome.restart },
		{ "quit awesome", awesome.quit },
	},
	border_width = 2,
	border_color = "#000000",
	font = user.config.font,
	icon_size = 24,
})

-- {{{ Mouse bindings
awful.mouse.append_global_mousebindings({
	-- awful.button({ }, 3, function () mymainmenu:toggle() end),
	-- awful.button({}, 4, awful.tag.viewprev),
	-- awful.button({}, 5, awful.tag.viewnext),
})
-- }}}

-- {{{ Key bindings

-- General Awesome keys
awful.keyboard.append_global_keybindings({
	awful.key({ super }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),
	awful.key({ super }, "w", function()
		mymainmenu:show()
	end, { description = "show main menu", group = "awesome" }),
	awful.key({ super, ctrl }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
	awful.key({ super, shift }, "q", awesome.quit, { description = "quit awesome", group = "awesome" }),
	awful.key({ super }, "Return", function()
		awful.spawn(user.apps.terminal)
	end, { description = "open a terminal", group = "launcher" }),
	awful.key({ super }, "space", function()
		awful.spawn(user.apps.launcher)
	end, { description = "show the menubar", group = "launcher" }),
	awful.key({ super }, "v", function()
		awful.spawn("clipcat-menu")
	end, { description = "open clipboard history", group = "awesome" }),
	awful.key({ super }, "x", function()
		if not naughty.suspended then
			naughty.destroy_all_notifications()
		end
		naughty.suspended = not naughty.suspended
		naughty.emit_signal("property::suspended", naughty, naughty.suspended)
	end, { description = "Toggle don't disturb", group = "awesome" }),
	awful.key({ super }, "l", function()
		awesome.emit_signal("exit_screen::show")
	end),
})

-- Tags related keybindings
awful.keyboard.append_global_keybindings({
	awful.key({ super }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" }),
	awful.key({ super }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),
	awful.key({ super }, "Escape", awful.tag.history.restore, { description = "go back", group = "tag" }),
})

-- Focus related keybindings
awful.keyboard.append_global_keybindings({
	awful.key({ super }, "j", function()
		awful.client.focus.byidx(1)
	end, { description = "focus next by index", group = "client" }),
	awful.key({ super }, "k", function()
		awful.client.focus.byidx(-1)
	end, { description = "focus previous by index", group = "client" }),
	awful.key({ super }, "Tab", function()
		awful.client.focus.history.previous()
		if client.focus then
			client.focus:raise()
		end
	end, { description = "go back", group = "client" }),
	awful.key({ super, ctrl }, "j", function()
		awful.screen.focus_relative(1)
	end, { description = "focus the next screen", group = "screen" }),
	awful.key({ super, ctrl }, "k", function()
		awful.screen.focus_relative(-1)
	end, { description = "focus the previous screen", group = "screen" }),
	awful.key({ super, ctrl }, "n", function()
		local c = awful.client.restore()
		-- Focus restored client
		if c then
			c:activate({ raise = true, context = "key.unminimize" })
		end
	end, { description = "restore minimized", group = "client" }),
})

-- Layout related keybindings
awful.keyboard.append_global_keybindings({
	awful.key({ super, shift }, "j", function()
		awful.client.swap.byidx(1)
	end, { description = "swap with next client by index", group = "client" }),
	awful.key({ super, shift }, "k", function()
		awful.client.swap.byidx(-1)
	end, { description = "swap with previous client by index", group = "client" }),
	awful.key({ super }, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),
	awful.key({ super, shift, ctrl }, "l", function()
		awful.tag.incmwfact(0.05)
	end, { description = "increase master width factor", group = "layout" }),
	awful.key({ super }, "h", function()
		awful.tag.incmwfact(-0.05)
	end, { description = "decrease master width factor", group = "layout" }),
	awful.key({ super, shift }, "h", function()
		awful.tag.incnmaster(1, nil, true)
	end, { description = "increase the number of master clients", group = "layout" }),
	awful.key({ super, shift }, "l", function()
		awful.tag.incnmaster(-1, nil, true)
	end, { description = "decrease the number of master clients", group = "layout" }),
	awful.key({ super, ctrl }, "h", function()
		awful.tag.incncol(1, nil, true)
	end, { description = "increase the number of columns", group = "layout" }),
	awful.key({ super, ctrl }, "l", function()
		awful.tag.incncol(-1, nil, true)
	end, { description = "decrease the number of columns", group = "layout" }),
	awful.key({ super, ctrl }, "space", function()
		awful.layout.inc(1)
	end, { description = "select next", group = "layout" }),
	awful.key({ super, shift }, "space", function()
		awful.layout.inc(-1)
	end, { description = "select previous", group = "layout" }),
})

awful.keyboard.append_global_keybindings({
	awful.key({
		modifiers = { super },
		keygroup = "numrow",
		description = "only view tag",
		group = "tag",
		on_press = function(index)
			local screen = awful.screen.focused()
			local tag = screen.tags[index]
			if tag then
				tag:view_only()
			end
		end,
	}),
	awful.key({
		modifiers = { super, "Control" },
		keygroup = "numrow",
		description = "toggle tag",
		group = "tag",
		on_press = function(index)
			local screen = awful.screen.focused()
			local tag = screen.tags[index]
			if tag then
				awful.tag.viewtoggle(tag)
			end
		end,
	}),
	awful.key({
		modifiers = { super, "Shift" },
		keygroup = "numrow",
		description = "move focused client to tag",
		group = "tag",
		on_press = function(index)
			if client.focus then
				local tag = client.focus.screen.tags[index]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end,
	}),
	awful.key({
		modifiers = { super, "Control", "Shift" },
		keygroup = "numrow",
		description = "toggle focused client on tag",
		group = "tag",
		on_press = function(index)
			if client.focus then
				local tag = client.focus.screen.tags[index]
				if tag then
					client.focus:toggle_tag(tag)
				end
			end
		end,
	}),
	awful.key({
		modifiers = { super },
		keygroup = "numpad",
		description = "select layout directly",
		group = "layout",
		on_press = function(index)
			local t = awful.screen.focused().selected_tag
			if t then
				t.layout = t.layouts[index] or t.layout
			end
		end,
	}),
})

client.connect_signal("request::default_mousebindings", function()
	awful.mouse.append_client_mousebindings({
		awful.button({}, 1, function(c)
			c:activate({ context = "mouse_click" })
		end),
		awful.button({ super }, 1, function(c)
			c:activate({ context = "mouse_click", action = "mouse_move" })
		end),
		awful.button({ super }, 3, function(c)
			c:activate({ context = "mouse_click", action = "mouse_resize" })
		end),
	})
end)

client.connect_signal("request::default_keybindings", function()
	awful.keyboard.append_client_keybindings({
		awful.key({ super, shift }, "f", function(c)
			c.fullscreen = not c.fullscreen
			c:raise()
		end, { description = "toggle fullscreen", group = "client" }),
		awful.key({ super }, "q", function(c)
			c:kill()
		end, { description = "close", group = "client" }),
		awful.key({ super }, "f", awful.client.floating.toggle, { description = "toggle floating", group = "client" }),
		awful.key({ super, "Control" }, "Return", function(c)
			c:swap(awful.client.getmaster())
		end, { description = "move to master", group = "client" }),
		awful.key({ super }, "o", function(c)
			c:move_to_screen()
		end, { description = "move to screen", group = "client" }),
		awful.key({ super }, "t", function(c)
			c.ontop = not c.ontop
		end, { description = "toggle keep on top", group = "client" }),
		awful.key({ super }, "n", function(c)
			-- The client currently has the input focus, so it cannot be
			-- minimized, since minimized clients can't have the focus.
			c.minimized = true
		end, { description = "minimize", group = "client" }),
		awful.key({ super }, "m", function(c)
			c.maximized = not c.maximized
			c:raise()
		end, { description = "(un)maximize", group = "client" }),
		awful.key({ super, "Control" }, "m", function(c)
			c.maximized_vertical = not c.maximized_vertical
			c:raise()
		end, { description = "(un)maximize vertically", group = "client" }),
		awful.key({ super, "Shift" }, "m", function(c)
			c.maximized_horizontal = not c.maximized_horizontal
			c:raise()
		end, { description = "(un)maximize horizontally", group = "client" }),
	})
end)

-- MediaKeys
awful.keyboard.append_global_keybindings({
	-- Brightness Control
	awful.key({}, "XF86MonBrightnessUp", function()
		helpers.brightness_control("increase")
	end, { description = "increase brightness", group = "hotkeys" }),
	awful.key({}, "XF86MonBrightnessDown", function()
		helpers.brightness_control("decrease")
	end, { description = "decrease brightness", group = "hotkeys" }),
	-- Volume control
	awful.key({}, "XF86AudioRaiseVolume", function()
		-- system_controls.volume_control("increase", 5)
	end, {
		description = "increase volume",
		group = "hotkeys",
	}),
	awful.key({}, "XF86AudioLowerVolume", function()
		-- system_controls.volume_control("decrease", 5)
	end, {
		description = "decrease volume",
		group = "hotkeys",
	}),
	awful.key({}, "XF86AudioMute", function()
		-- system_controls.volume_control("mute")
	end, {
		description = "mute volume",
		group = "hotkeys",
	}),
	awful.key({}, "XF86AudioMicMute", function()
		-- system_controls.mic_toggle()
	end, {
		description = "mute microphone",
		group = "hotkeys",
	}), -- Music
	awful.key({}, "XF86AudioPlay", function()
		-- playerctl:play_pause()
	end, {
		description = "toggle music",
		group = "hotkeys",
	}),
	awful.key({}, "XF86AudioPrev", function()
		-- playerctl:previous()
	end, {
		description = "previous music",
		group = "hotkeys",
	}),
	awful.key({}, "XF86AudioNext", function()
		-- playerctl:next()
	end, {
		description = "next music",
		group = "hotkeys",
	}),
})

-- Screenshots
awful.keyboard.append_global_keybindings({
	awful.key({}, "Print", function()
		awful.spawn("flameshot gui")
	end, { description = "take an area screenshot", group = "screenshots" }),
	awful.key({ super }, "Print", function()
		awful.spawn("flameshot full")
	end, { description = "take a full screenshot", group = "screenshots" }),
})

-- }}}
