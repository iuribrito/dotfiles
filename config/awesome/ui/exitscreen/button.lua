local awful_button = require("awful.button")
local gtable = require("gears.table")
local gshape = require("gears.shape")
local beautiful = require("beautiful")
local wibox = require("wibox")
local colors = require("theme.colorsheme")
local user = require("config.user")
local gears = require("gears")

local helpers = require("helpers")
local text_icon = require("ui.widgets.text-icon")

local button_size = 120
local button_bg = colors.background

local text_fg = colors.foreground .. "C0"
local key_icon_bg = button_bg .. "D0"
local label_font = user.config.font_name .. " 20"

return function(symbol, hover_color, key, text, command)
    local icon = text_icon {
        markup = helpers.mtext(hover_color, label_font, symbol),
        size = 32,
        widget = wibox.widget.textbox
    }

    local key_icon = wibox.widget {
        {
            markup = key,
            font = label_font,
            align = "center",
            widget = wibox.widget.textbox
        },
        border_color = colors.foreground .. 70,
        border_width = 1,
        forced_width = 32,
        fg = text_fg,
        bg = key_icon_bg,
        shape = helpers.rrect(4),
        widget = wibox.container.background
    }

    local label = wibox.widget {
        markup = helpers.mtext(text_fg, label_font, text),
        font = label_font,
        widget = wibox.widget.textbox
    }

    local button_label = wibox.widget {
        {
            key_icon,
            label,
            spacing = 2,
            layout = wibox.layout.fixed.horizontal,
            widget = wibox.container.background
        },
        widget = wibox.container.place
    }

    local button = wibox.widget {
        {
            icon,
            layout = wibox.container.place
        },
        forced_height = button_size,
        forced_width = button_size,
        shape = gshape.circle,
        bg = button_bg,
        border_width = 1,
        border_color = hover_color,
        widget = wibox.container.background
    }

    local labeled_button = wibox.widget {
        button,
        button_label,
        spacing = 12,
        layout = wibox.layout.fixed.vertical,
        widget = wibox.container.background
    }

    labeled_button:connect_signal(
        "mouse::enter", function()
            icon.markup = helpers.mtext(colors.background, label_font, icon.text)
            button.bg = hover_color

            key_icon.fg = hover_color
            key_icon.border_color = hover_color

            label.markup = helpers.mtext(hover_color, label_font, label.text)
        end
    )

    labeled_button:connect_signal(
        "mouse::leave", function()
            icon.markup = helpers.mtext(hover_color, label_font, icon.text)
            button.bg = button_bg

            key_icon.fg = text_fg
            key_icon.border_color = text_fg

            label.markup = helpers.mtext(text_fg, label_font, label.text)
        end
    )

    -- helpers.add_hover_cursor(labeled_button, "hand1")
    labeled_button:buttons(gears.table.join(awful_button({}, 1, command)))

    return labeled_button
end
