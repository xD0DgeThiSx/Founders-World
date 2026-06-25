local Players = game:GetService("Players")

-- Prevent characters from auto-spawning at stale SpawnLocations before world is built.
-- Must be set before any yield so it takes effect before the first frame.
Players.CharacterAutoLoads = false

local Shared = game:GetService("ReplicatedStorage"):WaitForChild("Shared")

local RuntimeConfig = require(Shared.Config.RuntimeConfig)
local ServiceRegistry = require(script.Parent.Services.ServiceRegistry)

local function main()
	if RuntimeConfig.Debug.BootLogging then
		print("[FoundersWorld] Server bootstrap initialized")
	end

	ServiceRegistry.start()

	-- World is now built and CentralSpawn exists — load characters.
	for _, player in ipairs(Players:GetPlayers()) do
		player:LoadCharacter()
	end

	Players.PlayerAdded:Connect(function(player)
		player:LoadCharacter()
	end)
end

main()
