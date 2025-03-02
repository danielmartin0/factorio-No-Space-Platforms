local lib = require("lib")
local Logistic = require("scripts.Logistic")

local Public = {}

function Public.get_platform_name(target_planet)
	return "[space-location=" .. target_planet.name .. "] " .. target_planet.name:gsub("^%l", string.upper)
end

function Public.update_space_platforms(surface)
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
	-- hub.operable = false
	hub.destructible = false

	local logistics = hub.get_logistic_sections()

	for _, section in pairs(logistics.sections) do
		logistics.remove_section(section.index)
	end

	logistics.add_section(Logistic.get_logistic_group_name(orbit_planet, target_planet))
end

return Public
