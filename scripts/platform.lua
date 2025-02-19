local lib = require("lib")

script.on_event(defines.events.on_surface_created, function(event)
	local surface = game.surfaces[event.surface_index]
	lib.create_space_platform_if_necessary(surface)
end)

-- script.on_nth_tick(5, function()
-- 	for _, force in pairs(game.forces) do
-- 		if force.platforms then
-- 			for _, platform in pairs(force.platforms) do
-- 				local hub = platform.hub
-- 				if hub and hub.valid then
-- 					hub.health = hub.max_health
-- 				end
-- 			end
-- 		end
-- 	end
-- end)
