local lib = require("lib")
local logistic = require("scripts.logistic")

for _, player in pairs(game.connected_players) do
	player.leave_space_platform()
end

for _, force in pairs(game.forces) do
	for _, platform in pairs(force.platforms) do
		platform.destroy(0)
	end
end

for _, surface in pairs(game.surfaces) do
	lib.update_space_platforms(surface)

	local cargo_pads = surface.find_entities_filtered({ name = "cargo-landing-pad" })
	for _, pad in pairs(cargo_pads) do
		logistic.update_cargo_landing_pad(pad)
	end
end
