local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RuntimeConfig = require(ReplicatedStorage.Shared.Config.RuntimeConfig)

if RuntimeConfig.Debug.BootLogging then
	print("[FoundersWorld] Client bootstrap initialized")
end

local function connectSpawnWelcome()
	local player = game.Players.LocalPlayer

	player.CharacterAdded:Connect(function()
		if RuntimeConfig.Debug.BootLogging then
			print(string.format("[FoundersWorld] %s entered the prototype world", player.Name))
		end
	end)
end

connectSpawnWelcome()
