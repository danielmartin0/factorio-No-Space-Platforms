local lib = require("lib")

local Public = {}

script.on_event(defines.events.on_rocket_launch_ordered, function(event)
	local rocket = event.rocket
	local silo = event.rocket_silo

	if silo and silo.valid then
		storage.silos = storage.silos or {}

		if rocket and rocket.valid and rocket.attached_cargo_pod and rocket.attached_cargo_pod.valid then
			local cargo_pod = rocket.attached_cargo_pod
			local destination = cargo_pod.cargo_pod_destination
			local passenger = cargo_pod.get_passenger()

			if
				passenger
				and destination
				and destination.type == defines.cargo_destination.station
				and destination.station
				and destination.station.valid
				and destination.station.surface
				and destination.station.surface.valid
				and destination.station.surface.platform
				and destination.station.surface.platform.valid
			then
				local name = destination.station.surface.platform.name
				for _, planet in pairs(game.planets) do
					if lib.get_platform_name(planet) == name and planet.surface and planet.surface.valid then
						cargo_pod.cargo_pod_destination = {
							type = defines.cargo_destination.surface,
							surface = planet.surface,
						}
					end
				end
			end
		end
	end
end)

return Public
