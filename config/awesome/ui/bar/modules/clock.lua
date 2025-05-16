local awful     = require("awful")
local wibox     = require("wibox")
local watch     = require("awful.widget.watch")
local colors    = require("theme.colorsheme")
local helpers   = require("helpers")
local user      = require("config.user")
local naughty   = require("naughty")

-- Clock widget
--------------------------------------------------------------------------------
local date_cmd = [[
  bash -c "date '+%d %b %Y'"
]]

local time_cmd = [[
  bash -c "date '+%H:%M'"
]]

local date_icon = wibox.widget {
  markup = helpers.mtext(colors.foreground, user.config.font, " "),
  widget = wibox.widget.textbox,
  valign = "center",
  halign = "center",
}

local time_icon = wibox.widget {
  markup = helpers.mtext(colors.foreground, user.config.font, "󰥔 "),
  widget = wibox.widget.textbox,
  valign = "center",
  halign = "center",
}

local time_text = wibox.widget {
  id = "time_text",
  widget = wibox.widget.textbox,
  valign = "center",
  halign = "center",
}

local date_text = wibox.widget {
  id = "date_text",
  widget = wibox.widget.textbox,
  valign = "center",
  halign = "center",
}

local date_container = wibox.widget {
  {
    date_icon,
    date_text,
    layout = wibox.layout.fixed.horizontal,
  },
  widget = wibox.container.background,
}

local time_container = wibox.widget {
  {
    time_icon,
    time_text,
    layout = wibox.layout.fixed.horizontal,
  },
  widget = wibox.container.background,
}

local clock_container = wibox.widget {
  {
    date_container,
    wibox.widget.separator {
      forced_width = 20,
      color = colors.background,
    },
    time_container,
    layout = wibox.layout.fixed.horizontal,
  },
  widget = wibox.container.background,
}

watch(date_cmd, 60,
  function(widget, stdout)
    widget.markup = helpers.mtext(colors.foreground, user.config.font, stdout)
  end,
  date_text)

watch(time_cmd, 30,
  function(widget, stdout)
    widget.markup = helpers.mtext(colors.foreground, user.config.font, stdout)
  end,
  time_text)

local mytextclock = helpers.margin(clock_container, 2, 0, 2, 2)

-- Calendar widget
--------------------------------------------------------------------------------
local calendar = awful.widget.calendar_popup.month {
  margin = 10,
  spacing = 10,
  week_numbers = false,
  long_weekdays = false,
  shape = helpers.rrect(10),
  start_sunday = true,

  style_month = {
    fg_color     = colors.foreground,
    bg_color     = colors.mantle,
    padding      = 10,
    border_width = 2,
    border_color = colors.background,
    shape = helpers.rrect(0)
  },
  style_header = {
    fg_color = colors.background,
    bg_color = colors.pink,
    shape = helpers.rrect(4)
  },
  style_weekday = {
    fg_color = colors.blue,
    bg_color = colors.mantle,
    border_color = colors.mantle,
  },
  style_normal = {
    fg_color = colors.subtext0,
    bg_color = colors.mantle,
    border_color = colors.mantle,
  },
  style_focus = {
    fg_color = colors.background,
    bg_color = colors.pink,
    shape = helpers.rrect(4),
  },
}

mytextclock:buttons(
  awful.util.table.join(
    awful.button({}, 1, function()
      calendar:attach(mytextclock, "tm", { on_hover = false })
    end)
  )
)

return mytextclock
