-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:

hl.on("hyprland.start", function()
	-- Activa graphical-session.target: sin esto xdg-desktop-portal no arranca
	-- (Requisite=) y falla el compartir pantalla. Arrastra cliphist y nm-applet.
	hl.exec_cmd(
		"dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE HYPRLAND_INSTANCE_SIGNATURE && systemctl --user start hyprland-session.target"
	)

	hl.exec_cmd("quickshell")
	hl.exec_cmd("awww-daemon")
	hl.exec_cmd("~/.local/bin/wallpaper-rotate.sh")
	-- hl.exec_cmd("udiskie --tray --no-notify")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("mako")
	hl.exec_cmd("cliphist wipe")
	-- hl.exec_cmd("blueman-applet")
	-- hl.exec_cmd("~/.config/hypr/scripts/start-keyring.sh")
end)
