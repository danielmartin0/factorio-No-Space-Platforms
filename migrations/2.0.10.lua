for _, force in pairs(game.forces) do
	for _, platform in pairs(force.platforms) do
		platform.hidden = true
	end
end
