local lib = require("lib")

script.on_event(defines.events.on_surface_created, function()
	for _, surface in pairs(game.surfaces) do
		lib.update_space_platforms(surface)
	end
end)

script.on_nth_tick(30, function()
	for _, force in pairs(game.forces) do
		for _, platform in pairs(force.platforms) do
			if platform.hub and platform.hub.valid then
				local source_inv = platform.hub.get_inventory(defines.inventory.hub_main)

				local contents = source_inv.get_contents()
				if #contents > 0 then
					game.print("Platform " .. platform.name .. " has contents in its hub")
					local source_planet = platform.space_location

					local target_planet
					for _, planet in pairs(game.planets) do
						if lib.get_platform_name(planet) == platform.name then
							target_planet = planet
							break
						end
					end

					if source_planet and target_planet then
						local target_platform
						for _, platform2 in pairs(force.platforms) do
							if
								platform2.space_location
								and platform2.space_location.name == target_planet.name
								and lib.get_platform_name(source_planet) == platform2.name
							then
								target_platform = platform2
								break
							end
						end

						if target_platform and target_platform.hub and target_platform.hub.valid then
							local cargo_pod = target_platform.hub.create_cargo_pod()
							if cargo_pod and cargo_pod.valid then
								cargo_pod.cargo_pod_destination = {
									type = defines.cargo_destination.surface,
									surface = target_planet.surface,
								}

								local target_inv = cargo_pod.get_inventory(defines.inventory.cargo_unit)

								for _, item in pairs(source_inv.get_contents()) do
									target_inv.insert(item)
								end

								game.print(cargo_pod.position.x .. " " .. cargo_pod.position.y)

								cargo_pod.force_finish_ascending()

								game.print(cargo_pod.position.x .. " " .. cargo_pod.position.y)

								source_inv.clear()
							end
						end
					end
				end
			end
		end
	end
end)
