local lib = require("lib")
local Logistic = require("scripts.Logistic")

local Public = {}

function Public.get_platform_name(target_planet)
	return "[space-location=" .. target_planet.name .. "] " .. target_planet.name:gsub("^%l", string.upper)
end

function Public.ensure_scripted_space_platforms(surface)
	for _, force in pairs(game.forces) do
		if force.name ~= "enemy" and force.name ~= "neutral" then
			for _, planet in pairs(game.planets) do
				if planet.surface and planet.surface == surface then
					for _, target_planet in pairs(game.planets) do
						if target_planet.name ~= surface.name then
							if force.is_space_location_unlocked(target_planet.name) or target_planet.surface then
								local existing_platform
								for _, platform in pairs(force.platforms) do
									if
										platform.name == Public.get_platform_name(target_planet)
										and platform.space_location.name == surface.name
									then
										if platform.scheduled_for_deletion then
											platform.cancel_deletion()
										end
										existing_platform = platform
									end
								end

								if not existing_platform then
									Public.create_platform(force, planet, target_planet)
								end
							end
						end
					end
				end
			end
		end
	end
end

function Public.create_platform(force, orbit_planet, target_planet)
	local platform = force.create_space_platform({
		name = Public.get_platform_name(target_planet),
		planet = orbit_planet.name,
		starter_pack = lib.INTERNAL_SPACE_PLATFORM_STARTER_PACK_NAME,
	})

	platform.apply_starter_pack()

	local hub = platform.hub
	hub.operable = false
	hub.destructible = false

	local logistics = hub.get_logistic_sections()

	for _, section in pairs(logistics.sections) do
		logistics.remove_section(section.index)
	end

	logistics.add_section(Logistic.get_logistic_group_name(orbit_planet, target_planet))
end

function Public.sync_platform_inventories()
	storage.forces = storage.forces or {}

	local filtered_forces = {}
	for _, force in pairs(game.forces) do
		if force.name ~= "enemy" and force.name ~= "neutral" then
			filtered_forces[force.name] = force
		end
	end

	for _, force in pairs(filtered_forces) do
		storage.forces[force.name] = storage.forces[force.name] or {}
		local force_data = storage.forces[force.name]

		for _, platform in pairs(force.platforms) do
			if
				platform.hub
				and platform.hub.valid
				and platform.space_location
				and platform.space_location.valid
				and platform.space_location.type == "planet"
			then
				local source_inv = platform.hub.get_inventory(defines.inventory.hub_main)

				force_data.platform_data = force_data.platform_data or {}
				force_data.platform_data[platform.index] = force_data.platform_data[platform.index]
					or {
						tracked_pods = {},
					}
				local platform_data = force_data.platform_data[platform.index]

				for pod_id, pod in pairs(platform_data.tracked_pods) do
					if not (pod and pod.valid) then
						platform_data.tracked_pods[pod_id] = nil
					end
				end

				local target_planet
				local landing_pad
				for _, planet in pairs(game.planets) do
					if
						planet.surface
						and planet.surface.valid
						and Public.get_platform_name(planet) == platform.name
					then
						target_planet = planet
						if force_data.landing_pads and force_data.landing_pads[planet.surface.name] then
							landing_pad = force_data.landing_pads[planet.surface.name]
						end
						break
					end
				end

				local logistics = platform.hub.get_logistic_sections()
				local section = logistics.sections[2] -- The first custom logistic section
				if section then
					local i = 1
					local slots_adjusted = 0
					while slots_adjusted < section.filters_count do
						local filter = section.get_slot(i)
						filter.import_from = platform.space_location.name
						if filter then
							slots_adjusted = slots_adjusted + 1
							section.set_slot(i, filter)
						end
						i = i + 1
					end
				end

				if target_planet and landing_pad and landing_pad.valid then
					source_inv.clear()

					local pad_inv = landing_pad.get_inventory(defines.inventory.cargo_landing_pad_main)

					for _, item in pairs(pad_inv.get_contents()) do
						source_inv.insert(item)
					end

					for _, pod in pairs(platform_data.tracked_pods) do
						if pod and pod.valid then
							local pod_inv = pod.get_inventory(defines.inventory.cargo_unit)
							for _, item in pairs(pod_inv.get_contents()) do
								source_inv.insert(item)
							end
						end
					end
				end
			end
		end
	end
end

return Public
