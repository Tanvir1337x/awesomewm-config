-- Grab environment
local awful = require("awful")

-- Initialize tables and vars for module
local autostart = {}

-- Application list function
function autostart.run()
	-- essentials
	awful.spawn.with_shell("xrandr --output HDMI-0 --primary --mode 1920x1080 --rate 100 --pos 0x0 --rotate normal") -- display output
	awful.spawn.with_shell("xset -dpms") -- prevent X server from turning off the display
	awful.spawn.with_shell("xset s off") -- disable X screen saver feature
	awful.spawn.with_shell("xset r rate 250 50") -- speed up keyboard auto-repeat rate

	-- tray
	-- awful.spawn.with_shell("nm-tray") -- NetworkManager Tray
	awful.spawn.with_shell("nm-applet") -- NetworkManager Tray
	awful.spawn.with_shell("pasystray") -- PulseAudio Tray
	awful.spawn.with_shell("blueman-applet") -- Bluetooth (Blueman) Tray

	-- cloud
	--[[
	awful.spawn.with_shell("megasync") -- MEGA sync daemon
	awful.spawn.with_shell("cozydrive") -- Cozy Drive daemon
	awful.spawn.with_shell("maestral_qt") -- Maestral (Dropbox) daemon
	awful.spawn.with_shell("onedrivegui") -- OneDrive daemon
	--]]

	-- apps

	-- daemon
	awful.spawn.with_shell("picom --daemon") -- compositor
	awful.spawn.with_shell("copyq") -- clipboard manager daemon
	-- awful.spawn.with_shell("flashfocus") -- flashfocus daemon
end

-- Read and commands from file and spawn them
function autostart.run_from_file(file_)
	local f = io.open(file_)
	for line in f:lines() do
		if line:sub(1, 1) ~= "#" then
			awful.spawn.with_shell(line)
		end
	end
	f:close()
end

return autostart
