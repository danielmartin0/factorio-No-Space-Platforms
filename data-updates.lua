if settings.startup["Space-Age-Without-Platforms-disable-mod"].value then
	return
end

if data.raw["space-platform-hub"]["space-platform-hub"] then
	data.raw["space-platform-hub"]["space-platform-hub"].inventory_size = 2000
end
