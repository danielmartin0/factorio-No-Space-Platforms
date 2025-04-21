local util = require("util")

local Public = {}

Public.INTERNAL_SPACE_PLATFORM_STARTER_PACK_NAME =
	"Space-Age-Without-Space-Platforms-internal-space-platform-starter-pack"

function Public.merge(old, new)
	old = util.table.deepcopy(old)

	for k, v in pairs(new) do
		if v == "nil" then
			old[k] = nil
		else
			old[k] = v
		end
	end

	return old
end

Public.find = function(tbl, f, ...)
	if type(f) == "function" then
		for k, v in pairs(tbl) do
			if f(v, k, ...) then
				return v, k
			end
		end
	else
		for k, v in pairs(tbl) do
			if v == f then
				return v, k
			end
		end
	end
	return nil
end

return Public
