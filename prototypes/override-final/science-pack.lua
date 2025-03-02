local lib = require("lib")

if not settings.startup["Space-Age-Without-Platforms-disable-space-science"].value then
	return
end

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
