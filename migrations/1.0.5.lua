local Platforms = require("scripts.Platforms")

for _, planet in pairs(game.planets) do
	if planet.surface and planet.surface.valid then
		Platforms.update_space_platforms(planet.surface)
	end
end
