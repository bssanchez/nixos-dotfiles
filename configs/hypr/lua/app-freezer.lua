local paused = {}

hl.bind("SUPER + SHIFT + P", function()
	local win = hl.get_active_window()

	if not win then
		return
	end

	local pid = win.pid

	if paused[pid] then
		hl.exec_cmd(string.format("pstree -p %d | grep -o '[0-9]\\+' | sort -u | xargs kill -CONT", pid))
		hl.dispatch(hl.dsp.window.tag({ tag = "-paused" }))

		paused[pid] = nil

		hl.notification.create({
			text = string.format("Resumed: (%d) %s", pid, win.title),
			duration = 3000,
			icon = "ok",
		})
	else
		hl.exec_cmd(string.format("pstree -p %d | grep -o '[0-9]\\+' | sort -u | xargs kill -STOP", pid))
		hl.dispatch(hl.dsp.window.tag({ tag = "+paused" }))

		paused[pid] = true

		hl.notification.create({
			text = string.format("Paused: (%d) %s", pid, win.title),
			duration = 3000,
			icon = "warn",
		})
	end
end)

hl.window_rule({
	name = "paused-rules",
	match = { tag = "paused" },

	opacity = "0.80 override",
	border_color = "rgb(FF0000) rgb(880808)",
})
