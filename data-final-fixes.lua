require("prototypes.override-final.promethium-science")
require("prototypes.override-final.space-science")
require("prototypes.override-final.starter-pack")
require("prototypes.override-final.technology")

-- for _, silo in pairs(data.raw["rocket-silo"]) do
-- 	silo.logistic_trash_inventory_size = 0
-- end

for name, _ in pairs(data.raw["space-connection"]) do
	data.raw["space-connection"][name] = nil
end

for name, _ in pairs(data.raw["space-connection-distance-traveled-achievement"]) do
	data.raw["space-connection-distance-traveled-achievement"][name] = nil
end
