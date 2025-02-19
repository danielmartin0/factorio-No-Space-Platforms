local lib = require("lib")

local Public = {}

function Public.update_cargo_landing_pad(entity)
	if
		not (entity and entity.valid and entity.name == "cargo-landing-pad" and entity.surface and entity.surface.valid)
	then
		return
	end

	local logistics = entity.get_logistic_sections()

	for _, section in pairs(logistics.sections) do
		logistics.remove_section(section.index)
	end

	for _, planet in pairs(game.planets) do
		if planet.name ~= entity.surface.planet.name then
			logistics.add_section(lib.get_logistic_group_name(planet, entity.surface.planet))
		end
	end
end

-- -- TODO: Also fire this when the GUI for a cargo landing pad is closed so that we pick up section renamings
-- script.on_event(defines.events.on_entity_logistic_slot_changed, function(event)
-- 	local entity = event.entity
-- 	if not entity or not entity.valid then
-- 		return
-- 	end

-- 	if not entity.name == "cargo-landing-pad" then
-- 		return
-- 	end

-- 	for _, force in pairs(game.forces) do
-- 		if force.platforms then
-- 			for _, platform in pairs(force.platforms) do
-- 				if platform.name == lib.get_platform_name(entity.surface) then
-- 					local hub = platform.hub
-- 					if hub and hub.valid then
-- 						local pad_logistics = entity.get_logistic_sections()
-- 						local hub_logistics = hub.get_logistic_sections()

-- 						for _, section in pairs(hub_logistics.sections) do
-- 							hub_logistics.remove_section(section.index)
-- 						end

-- 						for _, section in pairs(pad_logistics.sections) do
-- 							if section.group then
-- 								hub_logistics.add_section(section.group)
-- 							end
-- 						end
-- 					end
-- 				end
-- 			end
-- 		end
-- 	end
-- end)

-- script.on_event(defines.events.on_entity_died, function(event)
-- 	storage.landing_pad = storage.landing_pad or {}

-- 	local entity = event.entity
-- 	if entity.name == "cargo-landing-pad" then
-- 		storage.landing_pad[entity.surface.name] = nil
-- 	end
-- end)

return Public
