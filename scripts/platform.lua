local lib = require("lib")

script.on_event(defines.events.on_surface_created, function()
	for _, surface in pairs(game.surfaces) do
		lib.update_space_platforms(surface)
	end
end)
