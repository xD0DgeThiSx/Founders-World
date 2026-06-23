local InteractionService = require(script.Parent.InteractionService)
local PlayerProfileService = require(script.Parent.PlayerProfileService)
local PlayerSessionService = require(script.Parent.PlayerSessionService)
local RemoteRegistryService = require(script.Parent.RemoteRegistryService)
local TeleportService = require(script.Parent.TeleportService)
local WorldBuilderService = require(script.Parent.WorldBuilderService)

local ServiceRegistry = {}

function ServiceRegistry.start()
	RemoteRegistryService.start()
	PlayerProfileService.start()
	PlayerSessionService.start()
	InteractionService.start()
	WorldBuilderService.build()
end

return ServiceRegistry
