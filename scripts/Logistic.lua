local Public = {}

function Public.get_logistic_group_name(orbit_planet, target_planet)
	return "[space-location="
		.. orbit_planet.name
		.. "] "
		.. orbit_planet.name
		.. "-to-"
		.. target_planet.name
		.. "[space-location="
		.. target_planet.name
		.. "]"
end

function Public.update_cargo_landing_pad(entity)
	if not (entity and entity.valid and entity.type == "cargo-landing-pad") then
		return
	end

	if not (entity.surface and entity.surface.valid and entity.force and entity.force.valid) then
		return
	end

	local logistics = entity.get_logistic_sections()

	for _, section in pairs(logistics.sections) do
		logistics.remove_section(section.index)
	end

	for _, planet in pairs(game.planets) do
		if planet.surface and planet.surface.valid and planet.name ~= entity.surface.planet.name then
			logistics.add_section(Public.get_logistic_group_name(planet, entity.surface.planet))
		end
	end

	storage.forces = storage.forces or {}
	storage.forces[entity.force.name] = storage.forces[entity.force.name] or {}

	storage.forces[entity.force.name].landing_pads = storage.forces[entity.force.name].landing_pads or {}
	storage.forces[entity.force.name].landing_pads[entity.surface.name] = entity

	return true
end

-- script.on_event(defines.events.on_entity_died, function(event)
-- 	storage.landing_pad = storage.landing_pad or {}

-- 	local entity = event.entity
-- 	if entity.name == "cargo-landing-pad" then
-- 		storage.landing_pad[entity.surface.name] = nil
-- 	end
-- end)

return Public
