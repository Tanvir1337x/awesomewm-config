-- Grab environment
local beautiful = require("beautiful")
--local awful = require("awful")
local flex = require("flex")

-- Initialize tables and vars for module
local desktop = {}

-- desktop aliases
local wgeometry = flex.util.desktop.wgeometry
local system = flex.system

-- Desktop widgets
function desktop:init(args)
	if not beautiful.desktop then
		return
	end

	args = args or {}
	local env = args.env or {}
	local autohide = env.desktop_autohide or false

	-- Caching calculated values
	local workareas = {}
	for s in screen do
		workareas[s] = s.workarea
		workareas[s].wgeometry = {}
		for name, place in pairs(beautiful.desktop.places) do
			workareas[s].wgeometry[name] = wgeometry(beautiful.desktop.grid, place, workareas[s])
		end
	end

	-- placement
	local places = beautiful.desktop.places

	-- Network speed
	local netspeed = { geometry = workareas[mouse.screen].wgeometry.netspeed }

	netspeed.args = {
		meter_function = system.net_speed,
		interface = "enp42s0",
		maxspeed = { up = 6 * 1024 ^ 2, down = 6 * 1024 ^ 2 },
		crit = { up = 6 * 1024 ^ 2, down = 6 * 1024 ^ 2 },
		timeout = 1,
		autoscale = true,
		label = "NET",
	}

	netspeed.style = {}

	-- SSD speed
	local ssdspeed = { geometry = workareas[mouse.screen].wgeometry.ssdspeed }

	ssdspeed.args = {
		interface = "nvme0n1",
		meter_function = system.disk_speed,
		timeout = 2,
		label = "SOLID DRIVE",
	}

	ssdspeed.style = beautiful.individual.desktop.speedmeter.drive

	-- CPU and memory usage
	local cpu_storage = { cpu_total = {}, cpu_active = {} }
	local cpumem = { geometry = workareas[mouse.screen].wgeometry.cpumem }

	cpumem.args = {
		topbars = { num = 8, maxm = 100, crit = 90 },
		lines = { { maxm = 100, crit = 80 }, { maxm = 100, crit = 80 } },
		meter = { args = cpu_storage, func = system.dformatted.cpumem },
		timeout = 5,
	}

	cpumem.style = beautiful.individual.desktop.multimeter.cpumem

	-- Disks
	local disks = { geometry = workareas[mouse.screen].wgeometry.disks }
	local disks_original_height = disks.geometry.height
	disks.geometry.height = beautiful.desktop.multimeter.height.upright

	disks.args = {
		sensors = {
			{ meter_function = system.fs_info, maxm = 100, crit = 80, name = "root", args = "/" },
			{ meter_function = system.fs_info, maxm = 100, crit = 80, name = "media1", args = "/mnt/media1" },
			{ meter_function = system.fs_info, maxm = 100, crit = 80, name = "media2", args = "/mnt/media2" },
			{ meter_function = system.fs_info, maxm = 100, crit = 80, name = "media3", args = "/mnt/media3" },
			{ meter_function = system.fs_info, maxm = 100, crit = 80, name = "windows", args = "/mnt/windows" },
		},
		timeout = 300,
	}

	disks.style = beautiful.individual.desktop.multiline.storage

	-- QEMU image (placed along with disks)
	local qm1 = "/var/lib/libvirt/images/Whonix-Workstation.qcow2"
	local qm2 = "/var/lib/libvirt/images/Whonix-Gateway.qcow2"

	local bms = beautiful.desktop.multimeter -- base multimeter style
	local dy = disks_original_height - (bms.height.upright + bms.height.lines)

	local qemu = { geometry = {} }

	-- triky placement
	qemu.geometry.x = disks.geometry.x
	qemu.geometry.y = disks.geometry.y + disks.geometry.height + dy
	qemu.geometry.width = disks.geometry.width
	qemu.geometry.height = beautiful.desktop.multimeter.height.lines

	--setup
	qemu.args = {
		sensors = {
			{
				meter_function = system.qemu_image_size,
				maxm = 100,
				crit = 90,
				name = "qemu-whonix-workstation",
				args = qm1,
			},
			{
				meter_function = system.qemu_image_size,
				maxm = 100,
				crit = 80,
				name = "qemu-whonix-gateway",
				args = qm2,
			},
		},
		timeout = 600,
	}

	qemu.style = beautiful.individual.desktop.multiline.images

	-- Calendar
	local cwidth = 100 -- calendar widget width
	local cy = 20 -- calendar widget upper margin
	local cheight = workareas[mouse.screen].height - 2 * cy

	local calendar = {
		args = { timeout = 60 },
		geometry = { x = workareas[mouse.screen].width - cwidth, y = cy, width = cwidth, height = cheight },
	}

	-- Initialize all desktop widgets
	cpumem.body = flex.desktop.multimeter(cpumem.args, cpumem.style)
	netspeed.body = flex.desktop.speedmeter.compact(netspeed.args, netspeed.style)
	ssdspeed.body = flex.desktop.speedmeter.compact(ssdspeed.args, ssdspeed.style)
	disks.body = flex.desktop.multiline(disks.args, disks.style)
	qemu.body = flex.desktop.multiline(qemu.args, qemu.style)

	calendar.body = flex.desktop.calendar(calendar.args, calendar.style)

	-- Desktop setup
	local desktop_objects = {
		cpumem,
		netspeed,
		ssdspeed,
		disks,
		qemu,
		calendar,
	}

	if not autohide then
		flex.util.desktop.build.static(desktop_objects)
	else
		flex.util.desktop.build.dynamic(desktop_objects, nil, beautiful.desktopbg, args.buttons)
	end

	calendar.body:activate_wibox(calendar.wibox)
end

return desktop
