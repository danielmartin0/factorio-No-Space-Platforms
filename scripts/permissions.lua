script.on_configuration_changed(function()
	for _, group in pairs(game.permissions.groups) do
		group.set_allows_action(defines.input_action.cancel_delete_space_platform, false)
		group.set_allows_action(defines.input_action.create_space_platform, false)
		group.set_allows_action(defines.input_action.delete_space_platform, false)
		group.set_allows_action(defines.input_action.instantly_create_space_platform, false)
		group.set_allows_action(defines.input_action.open_new_platform_button_from_rocket_silo, false)
		group.set_allows_action(defines.input_action.rename_space_platform, false)
	end
end)
