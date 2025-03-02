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

for name, achievement in pairs(data.raw["research-with-science-pack-achievement"]) do
	if achievement.science_pack == "space-science-pack" then
		data.raw["research-with-science-pack-achievement"][name] = nil
	end
end
