#!/bin/bash

# No ejecutar si el idle está deshabilitado
if grep -q "disabled" "$HOME/.cache/idle_enabled"; then
    echo "Screensaver deshabilitado, no se bloqueará"
    exit
fi

# No lanzar si ya está corriendo
pidof hyprlock && exit

hyprlock
