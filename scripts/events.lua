local lib = require("lib")
local silo = require("scripts.silo")
local logistic = require("scripts.logistic")

script.on_event(defines.events.on_surface_created, function(event)
	local surface = game.surfaces[event.surface_index]

	lib.update_space_platforms(surface)
end)

script.on_event({
	defines.events.on_built_entity,
	defines.events.on_robot_built_entity,
	defines.events.script_raised_built,
	defines.events.script_raised_revive,
}, function(event)
	logistic.update_cargo_landing_pad(event.entity)
end)

script.on_event(defines.events.on_cargo_pod_finished_ascending, function(event)
	game.print("Cargo pod finished ascending: " .. event.cargo_pod.surface.name)
end)
