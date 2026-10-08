#!/bin/bash
# Equivalente ao `hyprctl kill`: clique numa janela para matar o processo dela,
# Esc cancela. Usa o slurp restrito aos retângulos das janelas visíveis.

ACTIVE_WS=$(umbriel workspaces --json | jq -c '
    [(if type == "array" then . else (.ok // .data // []) end)[] | select(.active) | .id]')

TARGET=$(umbriel windows --json | jq -r --argjson ws "$ACTIVE_WS" '
    (if type == "array" then . else (.ok // .data // []) end)[]
    | select((.workspace as $w | $ws | index($w)) and .scratchpad == "" and (.tab_hidden | not))
    | select(.pid > 0)
    | "\(.x),\(.y) \(.w)x\(.h) \(.pid)"' | slurp -r -f '%l')

[[ -z "$TARGET" ]] && exit 0

kill -9 "$TARGET"
