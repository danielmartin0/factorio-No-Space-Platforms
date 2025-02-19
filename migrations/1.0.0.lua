local lib = require("lib")

for _, force in pairs(game.forces) do
	if force.platforms then
		for _, platform in pairs(force.platforms) do
			platform.destroy(0)
		end
	end
end

for _, surface in pairs(game.surfaces) do
	lib.update_space_platforms(surface)
end
