-- Grab environment
local beautiful = require("beautiful")
local flex = require("flex")
local awful = require("awful")

-- Initialize tables and vars for module
local menu = {}

-- Build function
function menu:init(args)
	-- vars
	args = args or {}
	local env = args.env or {}
	local separator = args.separator or { widget = flex.gauge.separator.horizontal() }
	local theme = args.theme or { auto_hotkey = true }
	local icon_style = args.icon_style or { custom_only = false, scalable_only = true }

	-- theme vars
	local default_icon = flex.util.base.placeholder()
	local icon = flex.util.table.check(beautiful, "icon.awesome") and beautiful.icon.awesome or default_icon
	local color = flex.util.table.check(beautiful, "color.icon") and beautiful.color.icon or nil

	-- icon finder
	local function micon(name)
		return flex.service.dfparser.lookup_icon(name, icon_style)
	end

	-- Application submenu
	local appmenu = flex.service.dfparser.menu({ icons = icon_style, wm_name = "awesome" })

	-- Awesome submenu
	local awesomemenu = {
		{ "Restart", awesome.restart, micon("gnome-session-reboot") },
		separator,
		{ "Awesome config", "code /home/user/.config/awesome/", micon("terminal") },
	}

	-- Nix submenu
	local nixmenu = {
		{ "NixOS config", "code /home/user/repositories/tanvir1337x/github/nixos-config", micon("terminal") },
	}

	-- Places submenu
	local placesmenu = {
		{ "Downloads", env.fm .. " downloads", micon("folder-download") },
		{ "Music", env.fm .. " media/musics", micon("folder-music") },
		{ "Pictures", env.fm .. " media/pictures", micon("folder-pictures") },
		{ "Videos", env.fm .. " media/videos", micon("folder-videos") },
		separator,
		{ "media1", env.fm .. " /mnt/media1", micon("folder-bookmarks") },
		{ "media2", env.fm .. " /mnt/media2", micon("folder-bookmarks") },
		{ "media3", env.fm .. " /mnt/media3", micon("folder-bookmarks") },
		{ "media4", env.fm .. " /mnt/media4", micon("folder-bookmarks") },
	}

	-- Exit submenu
	local exitmenu = {
		{ "Lockscreen", "i3lock-fancy-rapid 5 5", micon("lock") },
		separator,
		{ "Reboot", "systemctl reboot", micon("gnome-session-reboot") },
		{ "Shutdown", "systemctl poweroff", micon("system-shutdown") },
		{ "Suspend", "systemctl suspend", micon("system-suspend") },
		{ "Hibernate", "systemctl hibernate", micon("system-hibernate") },
		{ "Hybrid Sleep", "systemctl hybrid-sleep", micon("system-hybrid-sleep") },
		separator,
		{ "Log out", awesome.quit, micon("exit") },
	}

	-- Main menu
	self.mainmenu = flex.menu({
		theme = theme,
		items = {
			{ "Awesome", awesomemenu, micon("awesome") },
			{ "NixOS", nixmenu, micon("nix-snowflake") },
			{ "Applications", appmenu, micon("folder") },
			{ "Places", placesmenu, micon("folder_home"), key = "c" },
			separator,
			{ "Terminal", env.terminal, micon("terminal") },
			{ "Thunar", env.fm, micon("folder") },
			{ "Firefox ESR", "firefox-esr", micon("firefox") },
			{ "VSCode", "code", micon("code-editor") },
			{ "Bluetooth Manager", "blueman-manager", micon("bluetooth") },
			{ "Wifi Hotspot", "wihotspot-gui", micon("wifi") },
			{ "Volume Control", "pavucontrol", micon("volume") },
			separator,
			{ "Exit", exitmenu, micon("exit") },
		},
	})

	-- Menu panel widget
	self.widget = flex.gauge.svgbox(icon, nil, color)
	self.buttons = awful.util.table.join(awful.button({}, 1, function()
		self.mainmenu:toggle()
	end))
end

return menu
