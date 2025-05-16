local wezterm = require("wezterm")

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.front_end = "OpenGL"
config.color_scheme = "Catppuccin Mocha"
config.font = wezterm.font("JetBrains Mono Nerd Font")
config.enable_scroll_bar = false
config.enable_tab_bar = false
config.enable_wayland = false
config.default_prog = { "tmux" }

config.window_padding = {
	left = 2,
	right = 2,
	top = 2,
	bottom = 0,
}

return config
