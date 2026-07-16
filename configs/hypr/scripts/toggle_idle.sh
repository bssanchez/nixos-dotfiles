#!/usr/bin/env bash

STATE_FILE="$HOME/.cache/idle_enabled"

if [ ! -f "$STATE_FILE" ]; then
    echo "enabled" > "$STATE_FILE"
fi

if grep -q "enabled" "$STATE_FILE"; then
    echo "disabled" > "$STATE_FILE"
    notify-send "🔒 Bloqueo automático DESACTIVADO"
else
    echo "enabled" > "$STATE_FILE"
    notify-send "🔒 Bloqueo automático ACTIVADO"
fi
