#!/bin/bash

CONFIG_DIR="$HOME/.config/umbriel"
CURRENT=$(readlink -f "$CONFIG_DIR/monitors.toml")

if [[ "$CURRENT" == *"-home.toml" ]]; then
    ln -sfn monitors-work.toml "$CONFIG_DIR/monitors.toml"
    MSG="Modo Trabalho ativado (Notebook à esquerda)"
else
    ln -sfn monitors-home.toml "$CONFIG_DIR/monitors.toml"
    MSG="Modo Casa ativado (Monitor à esquerda)"
fi

umbriel msg config-reload
notify-send "Umbriel" "$MSG"
