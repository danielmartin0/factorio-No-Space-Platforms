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

	local fired =
		Public.attempt_fire_cargo_pod(platform.hub, target_planet_surface, pod_inv.get_contents(), platform, force)

	if not fired then
		storage.pending_pods = storage.pending_pods or {}
		table.insert(storage.pending_pods, {
			platform = platform,
			target_surface = target_planet_surface,
			force = force,
			items = pod_inv.get_contents(),
		})
		return
	end
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

	cargo_pod.destroy()
end

function Public.attempt_fire_cargo_pod(hub, target_surface, items, platform, force)
	local cargo_pod = hub.create_cargo_pod()

	if not cargo_pod then
		return false
	end

	-- game.print(
	-- 	string.format(
	-- 		"[Pods] Created cargo pod %d for force '%s', from platform '%s' to surface '%s'",
	-- 		cargo_pod2.unit_number,
	-- 		force.name,
	-- 		platform.name,
	-- 		target_planet_surface.name
	-- 	)
	-- )

	cargo_pod.cargo_pod_destination = {
		type = defines.cargo_destination.surface,
		surface = target_surface,
	}

	local pod_inv = cargo_pod.get_inventory(defines.inventory.cargo_unit)
	for _, item in pairs(items) do
		pod_inv.insert(item)
	end

	storage.forces = storage.forces or {}
	storage.forces[force.name] = storage.forces[force.name] or {}
	local force_data = storage.forces[force.name]
	force_data.platform_data = force_data.platform_data or {}
	force_data.platform_data[platform.index] = force_data.platform_data[platform.index] or {
		tracked_pods = {},
	}
	force_data.platform_data[platform.index].tracked_pods[cargo_pod.unit_number] = cargo_pod

	cargo_pod.force_finish_ascending()
	return true
end

function Public.retry_pending_pods()
	storage.pending_pods = storage.pending_pods or {}

	for i = #storage.pending_pods, 1, -1 do
		local pending = storage.pending_pods[i]
		if pending.platform and pending.platform.valid then
			local fired = Pods.attempt_fire_cargo_pod(
				pending.platform.hub,
				pending.target_surface,
				pending.items,
				pending.platform,
				pending.force
			)

			if fired then
				table.remove(storage.pending_pods, i)
			end
		else
			table.remove(storage.pending_pods, i)
		end
	end
end

return Public
