--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
	-- Ignore maximize requests from all apps. You'll probably like this.
	name = "suppress-maximize-events",
	match = { class = ".*" },

	suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
	-- Fix some dragging issues with XWayland
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},

	no_focus = true,
})

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

-- Hyprland-run windowrule
hl.window_rule({
	name = "move-hyprland-run",
	match = { class = "hyprland-run" },

	move = "20 monitor_h-120",
	float = true,
})

-- Custom rules
hl.window_rule({
	name = "locate-filechooser-dialogs",
	match = { title = ".*(desea guardar|desea abrir)$" },

	center = true,
	float = true,
	size = { 800, 500 },
})

hl.window_rule({
	name = "floating-apps",
	match = { class = "^(fileroller|galculator|zoom|org\\.gnome\\.FileRoller)$" },

	float = true,
	center = true,
})

hl.window_rule({
	name = "notifications-opacity",
	match = { class = "^(mako)$" },

	opacity = "0.9",
})

hl.window_rule({
	name = "terminal-rules",
	match = { class = "^(.*kitty.*)$" },

	size = { 700, 350 },
	center = true,
})

hl.window_rule({
	name = "devtools-rules",
	match = { class = "^(DevTools.*)$" },

	float = true,
	center = true,
	move = "20 monitor_h-220",
	size = { "monitor_w - 40", "200" },
})

hl.window_rule({
	name = "xdg-portal-rules",
	match = { class = "xdg-desktop-portal-gtk" },

	float = true,
	center = true,
	size = { 800, 500 },
})

hl.window_rule({
	name = "workspace-1-apps",
	match = { class = "^(pcmanfm)$" },

	workspace = 1,
})

hl.window_rule({
	name = "workspace-2-apps",
	match = { class = "^(Windsurf|windsurf|Kiro|Code|code|Antigravity|antigravity|Cursor|cursor)$" },

	workspace = 2,
})

hl.window_rule({
	name = "workspace-3-apps",
	match = { class = "^(brave-browser)$" },

	workspace = 3,
})

hl.window_rule({
	name = "modals-rules",
	match = { class = "^(DesktopEditors)$" },

	center = true,
})