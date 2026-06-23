local WorldBuilderService = require(script.Parent.WorldBuilderService)

local ServiceRegistry = {}

function ServiceRegistry.start()
	WorldBuilderService.build()
end

return ServiceRegistry
