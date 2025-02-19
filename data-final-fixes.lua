local lib = require("lib")

--== Space Science Pack ==--

if data.raw.tool["space-science-pack"] then
	data.raw.tool["space-science-pack"] = nil
end

if data.raw.recipe["space-science-pack"] then
	lib.excise_recipe("space-science-pack")
end

for _, lab in pairs(data.raw.lab) do
	if lab.inputs then
		local new_inputs = {}
		for _, input in ipairs(lab.inputs) do
			if input ~= "space-science-pack" then
				table.insert(new_inputs, input)
			end
		end
		lab.inputs = new_inputs
	end
end

for _, tech in pairs(data.raw.technology) do
	if tech.unit and tech.unit.ingredients then
		local new_ingredients = {}
		for _, ingredient in ipairs(tech.unit.ingredients) do
			if ingredient[1] ~= "space-science-pack" then
				table.insert(new_ingredients, ingredient)
			end
		end
		tech.unit.ingredients = new_ingredients
	end
end

for name, achievement in pairs(data.raw["research-with-science-pack-achievement"]) do
	if achievement.science_pack == "space-science-pack" then
		data.raw["research-with-science-pack-achievement"][name] = nil
	end
end

--== Rocket silos ==--

for _, silo in pairs(data.raw["rocket-silo"]) do
	silo.logistic_trash_inventory_size = 0
end

--== Space platform starter packs ==--

local make_tile_area = function(area, name) -- From vanilla
	local result = {}
	local left_top = area[1]
	local right_bottom = area[2]
	for x = left_top[1], right_bottom[1] do
		for y = left_top[2], right_bottom[2] do
			table.insert(result, {
				position = { x, y },
				tile = name,
			})
		end
	end
	return result
end

data:extend({
	lib.merge(data.raw["space-platform-starter-pack"]["space-platform-starter-pack"], {
		name = lib.INTERNAL_SPACE_PLATFORM_STARTER_PACK_NAME,
		tiles = make_tile_area({ { -4, -4 }, { 3, 3 } }, "space-platform-foundation"),
		initial_items = "nil",
	}),
})

for name, item in pairs(data.raw["space-platform-starter-pack"]) do
	if name ~= lib.INTERNAL_SPACE_PLATFORM_STARTER_PACK_NAME then
		lib.excise_item("space-platform-starter-pack", item.name)

		if data.raw.recipe[item.name] then
			lib.excise_recipe(item.name)
		end
	end
end

--== Technology Fixes ==--

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
