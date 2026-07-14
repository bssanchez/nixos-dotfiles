#!/usr/bin/env bash
# Rota el fondo de pantalla usando awww, eligiendo una imagen aleatoria del
# directorio de fondos cada N segundos, con una transición animada.
#
# Variables de entorno (opcionales):
#   WALLPAPER_DIR         directorio de fondos   (def: $HOME/Imágenes/fondos)
#   WALLPAPER_INTERVAL    segundos entre cambios (def: 300 = 5 min)
#   WALLPAPER_TRANSITION  tipo de transición awww (def: grow)
set -euo pipefail

DIR="${WALLPAPER_DIR:-$HOME/Imágenes/fondos}"
INTERVAL="${WALLPAPER_INTERVAL:-300}"
TRANSITION="${WALLPAPER_TRANSITION:-grow}"

# Espera a que el daemon de awww esté listo.
until awww query >/dev/null 2>&1; do
    sleep 0.5
done

last=""
while true; do
    mapfile -t imgs < <(find "$DIR" -type f \
        \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
        -o -iname '*.webp' -o -iname '*.gif' -o -iname '*.bmp' \) | sort)

    if (( ${#imgs[@]} == 0 )); then
        sleep "$INTERVAL"
        continue
    fi

    # Elige una imagen aleatoria, distinta a la anterior si hay más de una.
    img="${imgs[RANDOM % ${#imgs[@]}]}"
    if (( ${#imgs[@]} > 1 )); then
        while [[ "$img" == "$last" ]]; do
            img="${imgs[RANDOM % ${#imgs[@]}]}"
        done
    fi
    last="$img"

    awww img "$img" \
        --resize crop \
        --crop-gravity center \
        --transition-type "$TRANSITION" \
        --transition-duration 2 \
        --transition-fps 60

    sleep "$INTERVAL"
done
