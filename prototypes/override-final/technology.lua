local lib = require("lib")

if not settings.startup["Space-Age-Without-Platforms-reduce-space-technology"].value then
	return
end

if data.raw.technology["rocket-silo"] then
	for _, tech_name in pairs({ "space-platform", "space-platform-thruster" }) do
		if data.raw.technology[tech_name] then
			local tech = data.raw.technology[tech_name]
			local rocket_silo = data.raw.technology["rocket-silo"]

			if tech.effects then
				rocket_silo.effects = rocket_silo.effects or {}
				log("Space Age Without Platforms: Merging effects from " .. tech_name .. " into rocket-silo")

				for _, effect in ipairs(tech.effects) do
					table.insert(rocket_silo.effects, effect)
				end
			end

			lib.excise_technology(tech_name)
		end
	end

	if data.raw.technology["rocket-silo"].effects then
		log("Space Age Without Platforms: Starting effect filtering for rocket-silo technology")
		local new_effects = {}
		for _, effect in ipairs(data.raw.technology["rocket-silo"].effects) do
			local keep_effect = true

			if effect.type == "unlock-recipe" then
				local recipe = data.raw.recipe[effect.recipe]

				if recipe and recipe.results and #recipe.results == 1 and recipe.results[1].name then
					local result = recipe.results[1].name
					local item = data.raw.item[result]

					if item and item.place_result then
						for _, entity_type in pairs({ "thruster", "asteroid-collector" }) do
							for _, entity in pairs(data.raw[entity_type] or {}) do
								if entity.name == item.place_result then
									keep_effect = false
								end
							end
						end
					elseif item and item.place_as_tile and item.place_as_tile.result == "space-platform-foundation" then
						keep_effect = false
					end
				end

				if recipe.name == "thruster-oxidizer" or recipe.name == "thruster-fuel" then
					keep_effect = false
				end
			end

			if keep_effect then
				table.insert(new_effects, effect)
			end
		end

		data.raw.technology["rocket-silo"].effects = new_effects
	end
end
