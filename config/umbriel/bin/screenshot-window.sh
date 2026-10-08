#!/bin/bash
# Screenshot da janela focada -> Satty (substitui o `hyprctl activewindow -j`).

GEOMETRY=$(umbriel windows --json | jq -r '
    (if type == "array" then . else (.ok // .data // []) end)
    | map(select(.active)) | first // empty
    | "\(.x),\(.y) \(.w)x\(.h)"')

if [[ -z "$GEOMETRY" ]]; then
    notify-send "Umbriel" "Nenhuma janela focada"
    exit 1
fi

grim -g "$GEOMETRY" - | satty --filename - --early-exit --copy-command "wl-copy"
