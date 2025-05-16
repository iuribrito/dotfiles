#!/usr/bin/env bash

function run {
  if ! [[ "$(pgrep -f "$1")" ]]; then
    "$@" &
  fi
}

# run autorandr -c
run picom --config=$HOME/.config/awesome/theme/picom.conf
run xrdb -load "$HOME/.Xresources"
run feh --bg-fill ~/Pictures/wallpaper.jpg
run setxkbmap -layout "us" -variant intl -option caps:escape
run /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
run clipcatd

