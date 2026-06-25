local InteractionService = require(script.Parent.InteractionService)
local PlayerSessionService = require(script.Parent.PlayerSessionService)
local RemoteRegistryService = require(script.Parent.RemoteRegistryService)
local TeleportService = require(script.Parent.TeleportService)
local WorldBuilderService = require(script.Parent.WorldBuilderService)

local ServiceRegistry = {}

function ServiceRegistry.start()
	RemoteRegistryService.start()
	local buildOk, buildErr = pcall(WorldBuilderService.build)
	if not buildOk then
		warn("[FoundersWorld] WorldBuilderService.build failed:", buildErr)
		return
	end
	PlayerSessionService.start()
	InteractionService.start()
end

return ServiceRegistry
