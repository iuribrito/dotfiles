local M = {}

M.config = {
	-- My profile config
	user = "Iuri Brito",
	home = os.getenv("HOME"),
	host = "aorus",
	theme = "catppuccin_mocha",
	font = "JetBrains Mono Bold 10",
	font_name = "JetBrains Mono",
}

M.apps = {
	-- My profile apps
	terminal = "wezterm",
	web_browser = "zen",
	text_editor = "nvim",
	launcher = "rofi -show drun -theme ~/.config/rofi/config.rasi",
	file_manager = "thunar",
	screnshoot = "flameshot",
	image_viewer = "sxiv",
	pdf_viewer = "zathura",
	notes = "obsidian",
}

return M
