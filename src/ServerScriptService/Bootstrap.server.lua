local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")

local RuntimeConfig = require(Shared.Config.RuntimeConfig)
local ServiceRegistry = require(script.Parent.Services.ServiceRegistry)

local function main()
	if RuntimeConfig.Debug.BootLogging then
		print("[FoundersWorld] Server bootstrap initialized")
	end

	ServiceRegistry.start()
end

main()
