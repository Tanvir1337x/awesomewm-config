local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local wibox = require("wibox")
local naughty = require("naughty")

local flex = require("flex")

local unpack = unpack or table.unpack

-- Initialize tables and vars for module
local env = {}

-- Build hotkeys depended on config parameters
function env:init(args)
	-- init vars
	args = args or {}

	-- environment vars
	self.theme = args.theme or "rosybrown"
	self.mod = args.mod or "Mod4" -- Windows/Command key
	self.alt = args.alt or "Mod1" -- Alt key
	self.terminal = args.terminal or "kitty"
	self.fm = args.fm or "thunar"
	self.user = args.user or os.getenv("USER")

	self.home = os.getenv("HOME")
	self.themedir = awful.util.get_configuration_dir() .. "themes/" .. self.theme

	-- boolean defaults is pain
	self.sloppy_focus = args.sloppy_focus or true
	self.color_border_focus = args.color_border_focus or false
	self.set_slave = args.set_slave == nil and true or false
	self.set_center = args.set_center or false
	self.desktop_autohide = args.desktop_autohide or false

	-- theme setup
	beautiful.init(env.themedir .. "/theme.lua")

	-- naughty config
	naughty.config.padding = beautiful.useless_gap and 2 * beautiful.useless_gap or 0

	if beautiful.naughty then
		naughty.config.presets.normal = flex.util.table.merge(beautiful.naughty.base, beautiful.naughty.normal)
		naughty.config.presets.critical = flex.util.table.merge(beautiful.naughty.base, beautiful.naughty.critical)
		naughty.config.presets.low = flex.util.table.merge(beautiful.naughty.base, beautiful.naughty.low)
	end
end

-- Common functions
-- Wallpaper setup
env.wallpaper = function(s)
	local selected_tag = s.selected_tag

	if selected_tag and beautiful.wallpapers[selected_tag.name] then
		gears.wallpaper.maximized(beautiful.wallpapers[selected_tag.name], s, true)
	elseif beautiful.wallpaper then
		if not env.desktop_autohide and awful.util.file_readable(beautiful.wallpaper) then
			gears.wallpaper.maximized(beautiful.wallpaper, s, true)
		else
			gears.wallpaper.set(beautiful.color and beautiful.color.bg)
		end
	end
end

screen.connect_signal("tag::history::update", function(s)
	env.wallpaper(s)
end)

-- Tag tooltip text generation
env.tagtip = function(t)
	local layname = awful.layout.getname(awful.tag.getproperty(t, "layout"))
	if flex.util.table.check(beautiful, "widget.layoutbox.name_alias") then
		layname = beautiful.widget.layoutbox.name_alias[layname] or layname
	end
	return string.format("%s (%d apps) [%s]", t.name, #(t:clients()), layname)
end

-- Panel widgets wrapper
env.wrapper = function(widget, name, buttons)
	local margin = flex.util.table.check(beautiful, "widget.wrapper") and beautiful.widget.wrapper[name]
		or { 0, 0, 0, 0 }
	if buttons then
		widget:buttons(buttons)
	end

	return wibox.container.margin(widget, unpack(margin))
end

return env
