local Platforms = require("scripts.Platforms")
local Logistic = require("scripts.Logistic")
local Pods = require("scripts.Pods")

script.on_nth_tick(60, function()
	Pods.update_cargo_pods()
end)

script.on_event({
	defines.events.on_surface_created,
	defines.events.on_surface_imported,
}, function(event)
	local surface = game.surfaces[event.surface_index]

	Platforms.update_space_platforms(surface)

	for _, force in pairs(game.forces) do
		storage.forces = storage.forces or {}
		storage.forces[force.name] = storage.forces[force.name] or {}
		storage.forces[force.name].landing_pads = storage.forces[force.name].landing_pads or {}

		for _, landing_pad in pairs(storage.forces[force.name].landing_pads) do
			Logistic.update_cargo_landing_pad(landing_pad)
		end
	end
end)

script.on_event({
	defines.events.on_built_entity,
	defines.events.on_robot_built_entity,
	defines.events.script_raised_built,
	defines.events.script_raised_revive,
}, function(event)
	local entity = event.entity
	if not (entity and entity.valid) then
		return
	end

	if entity.type == "cargo-landing-pad" then
		Logistic.update_cargo_landing_pad(entity)
	end
end)

script.on_event(defines.events.on_rocket_launch_ordered, function(event)
	local rocket = event.rocket
	local silo = event.rocket_silo

	if silo and silo.valid then
		storage.silos = storage.silos or {}

		if rocket and rocket.valid and rocket.attached_cargo_pod and rocket.attached_cargo_pod.valid then
			local cargo_pod = rocket.attached_cargo_pod
			local destination = cargo_pod.cargo_pod_destination
			local passenger = cargo_pod.get_passenger()

			if
				passenger
				and destination
				and destination.type == defines.cargo_destination.station
				and destination.station
				and destination.station.valid
				and destination.station.surface
				and destination.station.surface.valid
				and destination.station.surface.platform
				and destination.station.surface.platform.valid
			then
				local name = destination.station.surface.platform.name
				for _, planet in pairs(game.planets) do
					if Platforms.get_platform_name(planet) == name then
						local surface = planet.surface
						if not surface then
							surface = planet.create_surface()
						end

						cargo_pod.cargo_pod_destination = {
							type = defines.cargo_destination.surface,
							surface = surface,
						}
					end
				end
			end
		end
	end
end)

script.on_event(defines.events.on_gui_opened, function(event)
	if event.gui_type ~= defines.gui_type.entity then
		return
	end

	local player = game.players[event.player_index]

	if not (player and player.valid) then
		return
	end

	local entity = event.entity

	if not (entity and entity.valid and entity.type == "cargo-landing-pad") then
		return
	end

	Logistic.update_cargo_landing_pad(entity)
end)

-- TODO: Surface renamed?

script.on_event(defines.events.on_pre_surface_deleted, function(event)
	local surface = game.surfaces[event.surface_index]

	if not (surface and surface.valid) then
		return
	end

	for _, force in pairs(game.forces) do
		for i = #force.platforms, 1, -1 do
			local platform = force.platforms[i]
			if platform.space_location and platform.space_location.name == surface.name then
				platform.destroy(0)
			end
		end
	end
end)
