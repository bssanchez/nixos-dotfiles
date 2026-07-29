#!/usr/bin/env bash

if pidof wlogout >/dev/null; then
    killall wlogout
    exit 0
fi

CSS="$HOME/.local/state/theme/wlogout.css"
[ -f "$CSS" ] || CSS="$HOME/.config/wlogout/style-dark.css"

COLS=6 # buttons per row
ROWS=1
BW=150 # button width
BH=150 # button height
GAP=18 # separation between buttons

read -r MON_W MON_H < <(
    hyprctl -j monitors 2>/dev/null | python3 -c '
import json,sys
try:
    mons=json.load(sys.stdin)
    m=next((x for x in mons if x.get("focused")), mons[0])
    print(int(m["width"]/m["scale"]), int(m["height"]/m["scale"]))
except Exception:
    print(1920,1080)
' 2>/dev/null
)
: "${MON_W:=1920}" "${MON_H:=1080}"

GRID_W=$(( COLS*BW + (COLS-1)*GAP ))
GRID_H=$(( ROWS*BH + (ROWS-1)*GAP ))
MX=$(( (MON_W - GRID_W) / 2 )); [ "$MX" -lt 0 ] && MX=0
MY=$(( (MON_H - GRID_H) / 2 )); [ "$MY" -lt 0 ] && MY=0

wlogout -b "$COLS" -c "$GAP" -r "$GAP" \
    -L "$MX" -R "$MX" -T "$MY" -B "$MY" \
    -C "$CSS" -l "$HOME/.config/wlogout/layout"
