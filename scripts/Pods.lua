local util = require("util")
local Platforms = require("scripts.Platforms")

local Public = {}

function Public.update_cargo_pods()
	storage.forces = storage.forces or {}

	local filtered_forces = {}
	for _, force in pairs(game.forces) do
		if force.name ~= "enemy" and force.name ~= "neutral" then
			filtered_forces[force.name] = force
		end
	end

	for _, force in pairs(filtered_forces) do
		storage.forces[force.name] = storage.forces[force.name] or {}
		local force_data = storage.forces[force.name]

		for _, platform in pairs(force.platforms) do
			if platform.hub and platform.hub.valid then
				local source_inv = platform.hub.get_inventory(defines.inventory.hub_main)

				force_data.platform_data = force_data.platform_data or {}
				force_data.platform_data[platform.index] = force_data.platform_data[platform.index]
					or {
						previous_contents = {},
						tracked_pods = {},
					}
				local platform_data = force_data.platform_data[platform.index]

				for pod_id, pod in pairs(platform_data.tracked_pods) do
					if not (pod and pod.valid) then
						platform_data.tracked_pods[pod_id] = nil
					end
				end

				local target_planet
				local landing_pad
				for _, planet in pairs(game.planets) do
					if
						planet.surface
						and planet.surface.valid
						and Platforms.get_platform_name(planet) == platform.name
					then
						target_planet = planet
						if force_data.landing_pads and force_data.landing_pads[planet.surface.name] then
							landing_pad = force_data.landing_pads[planet.surface.name]
						end
						break
					end
				end

				if target_planet then
					local current_contents = source_inv.get_contents()
					local has_increased = false

					local increased_items = {}
					for _, current_item in pairs(current_contents) do
						local prev_amount = 0
						for _, prev_item in pairs(platform_data.previous_contents) do
							if prev_item.name == current_item.name and prev_item.quality == current_item.quality then
								prev_amount = prev_item.count
								break
							end
						end
						if current_item.count > prev_amount then
							has_increased = true
							table.insert(increased_items, {
								name = current_item.name,
								count = current_item.count - prev_amount,
								quality = current_item.quality,
							})
						end
					end

					if landing_pad and landing_pad.valid then
						if has_increased then
							local cargo_pod = platform.hub.create_cargo_pod()
							if cargo_pod and cargo_pod.valid then
								-- game.print(
								-- 	string.format(
								-- 		"[Pods] Created cargo pod %d for force '%s', from platform '%s' to surface '%s' with increased items",
								-- 		cargo_pod.unit_number,
								-- 		force.name,
								-- 		platform.name,
								-- 		target_planet.surface.name
								-- 	)
								-- )
								cargo_pod.cargo_pod_destination = {
									type = defines.cargo_destination.surface,
									surface = target_planet.surface,
								}
								local pod_inv = cargo_pod.get_inventory(defines.inventory.cargo_unit)
								for _, item in pairs(increased_items) do
									pod_inv.insert(item)
								end
								cargo_pod.force_finish_ascending()
								platform_data.tracked_pods[cargo_pod.unit_number] = cargo_pod
							end
						end

						local pad_inv = landing_pad.get_inventory(defines.inventory.cargo_landing_pad_main)
						local total_contents = {}

						for _, item in pairs(pad_inv.get_contents()) do
							table.insert(total_contents, item)
						end

						for _, pod in pairs(platform_data.tracked_pods) do
							if pod and pod.valid then
								local pod_inv = pod.get_inventory(defines.inventory.cargo_unit)
								for _, item in pairs(pod_inv.get_contents()) do
									table.insert(total_contents, item)
								end
							end
						end

						source_inv.clear()
						for _, item in pairs(total_contents) do
							source_inv.insert(item)
						end
					else
						if #current_contents > 0 then
							local cargo_pod = platform.hub.create_cargo_pod()
							if cargo_pod and cargo_pod.valid then
								-- game.print(
								-- 	string.format(
								-- 		"[Pods] Created cargo pod %d for force '%s', from platform '%s' to surface '%s' with all contents",
								-- 		cargo_pod.unit_number,
								-- 		force.name,
								-- 		platform.name,
								-- 		target_planet.surface.name
								-- 	)
								-- )
								cargo_pod.cargo_pod_destination = {
									type = defines.cargo_destination.surface,
									surface = target_planet.surface,
								}
								local target_inv = cargo_pod.get_inventory(defines.inventory.cargo_unit)
								for _, item in pairs(current_contents) do
									target_inv.insert(item)
								end
								cargo_pod.force_finish_ascending()
								source_inv.clear()
							end
						end
					end

					platform_data.previous_contents = util.table.deepcopy(source_inv.get_contents())
				end
			end
		end
	end
end

return Public
