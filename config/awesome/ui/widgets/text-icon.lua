local beautiful = require "beautiful"
local wibox_widget = require "wibox.widget"
local user = require "config.user"

return function(args)
    return wibox_widget {
        markup = args.markup or args.text or "\u{e145}",
        font = user.config.font,
        align = "center",
        valign = "center",
        ellipsize = "none",
        widget = wibox_widget.textbox
    }
end
