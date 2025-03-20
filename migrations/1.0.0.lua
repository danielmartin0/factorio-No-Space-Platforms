local Logistic = require("scripts.Logistic")
local Platforms = require("scripts.Platforms")

for _, player in pairs(game.connected_players) do
	player.leave_space_platform()
end

for _, force in pairs(game.forces) do
	for _, platform in pairs(force.platforms) do
		platform.destroy(0)
	end
end

for _, surface in pairs(game.surfaces) do
	Platforms.ensure_scripted_space_platforms(surface)

	local cargo_pads = surface.find_entities_filtered({ type = "cargo-landing-pad" })
	for _, pad in pairs(cargo_pads) do
		Logistic.update_cargo_landing_pad(pad)
	end
end
