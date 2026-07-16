#!/usr/bin/env bash

# If idle is disabled, do not lock the screen
if grep -q "disabled" "$HOME/.cache/idle_enabled"; then
    echo "Screensaver deshabilitado, no se bloqueará"
    exit
fi

pidof hyprlock && exit

hyprlock
