local util = require("util")
local Platforms = require("scripts.Platforms")

local Public = {}

Public.handle_cargo_pod_arrival_on_platforms = function(event)
	local cargo_pod = event.cargo_pod
	if not (cargo_pod and cargo_pod.valid) then
		return
	end

	local surface = cargo_pod.surface
	if not (surface and surface.valid) then
		return
	end

	local platform = surface.platform
	if not (platform and platform.valid) then
		return
	end

	local force = cargo_pod.force
	if not (force and force.valid) then
		return
	end

	local pod_inv = cargo_pod.get_inventory(defines.inventory.cargo_unit)

	if not (pod_inv and pod_inv.valid) then
		return
	end

	if pod_inv.is_empty() then
		return
	end

	local target_planet_surface
	for _, planet in pairs(game.planets) do
		if Platforms.get_platform_name(planet) == platform.name then
			if planet.surface and planet.surface.valid then
				target_planet_surface = planet.surface
			else
				target_planet_surface = planet.create_surface()
			end

			break
		end
	end

	local cargo_pod2 = platform.hub.create_cargo_pod()

	cargo_pod2.cargo_pod_destination = {
		type = defines.cargo_destination.surface,
		surface = target_planet_surface,
	}

	local pod2_inv = cargo_pod2.get_inventory(defines.inventory.cargo_unit)
	for _, item in pairs(pod_inv.get_contents()) do
		pod2_inv.insert(item)
	end

	storage.forces = storage.forces or {}
	storage.forces[force.name] = storage.forces[force.name] or {}
	local force_data = storage.forces[force.name]
	force_data.platform_data = force_data.platform_data or {}
	force_data.platform_data[platform.index] = force_data.platform_data[platform.index] or {
		tracked_pods = {},
	}
	force_data.platform_data[platform.index].tracked_pods[cargo_pod2.unit_number] = cargo_pod2

	-- game.print(
	-- 	string.format(
	-- 		"[Pods] Created cargo pod %d for force '%s', from platform '%s' to surface '%s'",
	-- 		cargo_pod2.unit_number,
	-- 		force.name,
	-- 		platform.name,
	-- 		target_planet_surface.name
	-- 	)
	-- )

	cargo_pod2.force_finish_ascending()
end

Public.prevent_manual_cargo_pod_departures = function(event)
	local cargo_pod = event.cargo_pod
	if not (cargo_pod and cargo_pod.valid) then
		return
	end

	local force = cargo_pod.force
	if not (force and force.valid) then
		return
	end

	local surface = cargo_pod.surface
	if not (surface and surface.valid) then
		return
	end

	local platform = surface.platform
	if not (platform and platform.valid) then
		return
	end

	local hub = platform.hub
	if not (hub and hub.valid) then
		return
	end

	-- Ignore pods tracked by the platform
	if
		storage.forces
		and storage.forces[force.name]
		and storage.forces[force.name].platform_data
		and storage.forces[force.name].platform_data[platform.index]
		and storage.forces[force.name].platform_data[platform.index].tracked_pods
		and storage.forces[force.name].platform_data[platform.index].tracked_pods[cargo_pod.unit_number]
	then
		return
	end

	local hub_inv = hub.get_inventory(defines.inventory.hub_main)
	if not (hub_inv and hub_inv.valid) then
		return
	end

	local pod_inv = cargo_pod.get_inventory(defines.inventory.cargo_unit)
	if not (pod_inv and pod_inv.valid) then
		cargo_pod.destroy()
		return
	end

	for item_name, count in pairs(pod_inv.get_contents()) do
		hub_inv.insert({ name = item_name, count = count })
	end

	cargo_pod.destroy()
end

return Public
