#!/bin/bash

CONFIG_DIR="$HOME/.config/hypr"
CURRENT=$(readlink -f "$CONFIG_DIR/monitors.lua")

if [[ "$CURRENT" == *"-home.lua" ]]; then
    ln -sf "$CONFIG_DIR/monitors-work.lua" "$CONFIG_DIR/monitors.lua"
    ln -sf "$CONFIG_DIR/monitors-work.conf" "$CONFIG_DIR/monitors.conf"
    notify-send "Hyprland" "Modo Trabalho ativado (Notebook à esquerda)"
else
    ln -sf "$CONFIG_DIR/monitors-home.lua" "$CONFIG_DIR/monitors.lua"
    ln -sf "$CONFIG_DIR/monitors-home.conf" "$CONFIG_DIR/monitors.conf"
    notify-send "Hyprland" "Modo Casa ativado (Monitor à esquerda)"
fi

hyprctl reload
