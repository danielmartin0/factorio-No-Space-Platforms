if settings.startup["Space-Age-Without-Platforms-disable-mod"].value then
	return
end

require("scripts.Pods")
require("scripts.Events")
require("scripts.Logistic")
require("scripts.Permissions")
require("scripts.Platforms")
