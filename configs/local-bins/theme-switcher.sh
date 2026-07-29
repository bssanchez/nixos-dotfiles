#!/usr/bin/env bash

# Declarations
THEME_DARK="catppuccin-mocha-lavender-standard"
THEME_LIGHT="catppuccin-latte-lavender-standard"

QT_THEME_DARK="catppuccin-mocha-lavender"
QT_THEME_LIGHT="catppuccin-latte-lavender"

ICONS_DARK="Papirus-Dark"
ICONS_LIGHT="Papirus-Light"

CURRENT=$(gsettings get org.gnome.desktop.interface gtk-theme)


# Definitions
if [[ "$CURRENT" == "'$THEME_DARK'" ]]; then
  NEW_THEME=$THEME_LIGHT
  NEW_QT_THEME=$QT_THEME_LIGHT
  
  NEW_ICONS=$ICONS_LIGHT
  NEW_SCHEME="prefer-light"
  HYPR_COLOR="rgba(7c4dd8ff)"

  cat ~/.config/kitty/kitty-light.conf > ~/.local/state/theme/kitty.conf
  cat ~/.config/quickshell/themes/light.json > ~/.local/state/theme/quickshell.json
  cat ~/.config/hypr/hyprlock-colors-light.conf > ~/.local/state/theme/hyprlock-colors.conf
  cat ~/.config/wlogout/style-light.css > ~/.local/state/theme/wlogout.css
else
  NEW_THEME=$THEME_DARK
  NEW_QT_THEME=$QT_THEME_DARK
  
  NEW_ICONS=$ICONS_DARK
  NEW_SCHEME="prefer-dark"
  HYPR_COLOR="rgba(bb9af7ff)"

  cat ~/.config/kitty/kitty-dark.conf > ~/.local/state/theme/kitty.conf
  cat ~/.config/quickshell/themes/dark.json > ~/.local/state/theme/quickshell.json
  cat ~/.config/hypr/hyprlock-colors-dark.conf > ~/.local/state/theme/hyprlock-colors.conf
  cat ~/.config/wlogout/style-dark.css > ~/.local/state/theme/wlogout.css
fi

# Implementations
gsettings set org.gnome.desktop.interface gtk-theme "$NEW_THEME"
gsettings set org.gnome.desktop.interface icon-theme "'$NEW_ICONS'"
gsettings set org.gnome.desktop.interface color-scheme "$NEW_SCHEME"

if grep -q "theme=" ~/.config/Kvantum/kvantum.kvconfig; then
    sed -i "s/^theme=.*/theme=$NEW_QT_THEME/" ~/.config/Kvantum/kvantum.kvconfig
else
    echo -e "[General]\ntheme=$NEW_QT_THEME" >> ~/.config/Kvantum/kvantum.kvconfig
fi

sed -i "s/^icon_theme=.*/icon_theme=$NEW_ICONS/" ~/.config/qt5ct/qt5ct.conf 2>/dev/null
sed -i "s/^icon_theme=.*/icon_theme=$NEW_ICONS/" ~/.config/qt6ct/qt6ct.conf 2>/dev/null

sed -i "s/^@import \"\.\/themes.*/@import \"\.\/themes\/$NEW_QT_THEME\"/" ~/.config/rofi/theme.rasi 2>/dev/null

## Events
kitty @ set-colors --all --configured ~/.local/state/theme/kitty.conf

# hyprctl reload
