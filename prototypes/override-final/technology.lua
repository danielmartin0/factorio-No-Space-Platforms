local lib = require("lib")

if data.raw.technology["rocket-silo"] then
	-- Remove space-platform and space-platform-thruster technologies
	for _, tech_name in pairs({ "space-platform", "space-platform-thruster" }) do
		if data.raw.technology[tech_name] then
			local tech = data.raw.technology[tech_name]
			local rocket_silo = data.raw.technology["rocket-silo"]

			if tech.effects then
				rocket_silo.effects = rocket_silo.effects or {}

				for _, effect in ipairs(tech.effects) do
					table.insert(rocket_silo.effects, effect)
				end
			end

			lib.excise_technology(tech_name)
		end
	end

	-- Remove recipe unlocks that are now obsolete
	if data.raw.technology["rocket-silo"].effects then
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

		-- Remove rocket-silo prerequisite from technologies that don't unlock space locations
		for _, tech in pairs(data.raw.technology) do
			log(
				tech.name
					.. " has prerequisites "
					.. (tech.prerequisites and serpent.block(tech.prerequisites) or "nil")
			)

			if tech.prerequisites and lib.find(tech.prerequisites, "rocket-silo") then
				local has_space_location = false
				if tech.effects then
					for _, effect in ipairs(tech.effects) do
						if effect.type == "unlock-space-location" then
							has_space_location = true
							break
						end
					end
				end

				log(tech.name .. " full prerequisites: " .. serpent.block(tech.prerequisites))

				if #tech.prerequisites > 1 and not has_space_location then
					local new_prerequisites = {}
					for _, prereq in ipairs(tech.prerequisites) do
						if prereq ~= "rocket-silo" then
							table.insert(new_prerequisites, prereq)
						end
					end
					tech.prerequisites = new_prerequisites
				end
			end
		end
	end
end
