local lib = require("lib")

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
