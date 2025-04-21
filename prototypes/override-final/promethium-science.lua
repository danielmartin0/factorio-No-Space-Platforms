local lib = require("lib")

if not settings.startup["Space-Age-Without-Platforms-remove-promethium-science"].value then
	return
end

if data.raw.tool["promethium-science-pack"] then
	data.raw.tool["promethium-science-pack"].hidden = true
end

if data.raw.recipe["promethium-science-pack"] then
	PlanetsLib.excise_recipe_from_tech_tree("promethium-science-pack")
end

if data.raw.technology["promethium-science-pack"] then
	PlanetsLib.excise_tech_from_tech_tree("promethium-science-pack")
end

-- for _, lab in pairs(data.raw.lab) do
-- 	if lab.inputs then
-- 		local new_inputs = {}
-- 		for _, input in ipairs(lab.inputs) do
-- 			if input ~= "promethium-science-pack" then
-- 				table.insert(new_inputs, input)
-- 			end
-- 		end
-- 		lab.inputs = new_inputs
-- 	end
-- end

for _, tech in pairs(data.raw.technology) do
	if tech.unit and tech.unit.ingredients then
		local new_ingredients = {}
		for _, ingredient in ipairs(tech.unit.ingredients) do
			if ingredient[1] ~= "promethium-science-pack" then
				table.insert(new_ingredients, ingredient)
			end
		end
		tech.unit.ingredients = new_ingredients
	end
end

-- for name, achievement in pairs(data.raw["research-with-science-pack-achievement"]) do
-- 	if achievement.science_pack == "promethium-science-pack" then
-- 		data.raw["research-with-science-pack-achievement"][name] = nil
-- 	end
-- end
