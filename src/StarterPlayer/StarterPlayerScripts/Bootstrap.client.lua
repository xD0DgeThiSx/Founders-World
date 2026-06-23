local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local RuntimeConfig = require(ReplicatedStorage.Shared.Config.RuntimeConfig)
local WorldConfig = require(ReplicatedStorage.Shared.Config.WorldConfig)
local AppShell = require(StarterGui:WaitForChild("App"):WaitForChild("AppShell"))

if RuntimeConfig.Debug.BootLogging then
	print("[FoundersWorld] Client bootstrap initialized")
end

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local events = remotes:WaitForChild("Events")
local functions = remotes:WaitForChild("Functions")

local appShell = AppShell.new(playerGui, WorldConfig.Venues)
local requestVenueTeleport = functions:WaitForChild("RequestVenueTeleport")
local notifyPlayer = events:WaitForChild("NotifyPlayer")
local syncPlayerRole = events:WaitForChild("SyncPlayerRole")

local function buildInitialRolePayload()
	local lowerName = string.lower(player.Name)
	local isFounder = lowerName == string.lower(WorldConfig.VIP.FounderUsername)
	local isVip = false

	for _, vipName in ipairs(WorldConfig.VIP.Names) do
		if lowerName == string.lower(vipName) then
			isVip = true
			break
		end
	end

	local role = "Guest"

	if isFounder then
		role = "Founder"
	elseif isVip then
		role = "VIP"
	end

	return {
		Role = role,
		IsFounder = isFounder,
		IsVIP = isVip,
		FounderUsername = WorldConfig.VIP.FounderUsername,
		Username = player.Name,
	}
end

local function connectSpawnWelcome()
	player.CharacterAdded:Connect(function()
		if RuntimeConfig.Debug.BootLogging then
			print(string.format("[FoundersWorld] %s entered the prototype world", player.Name))
		end
	end)
end

local function connectVenueNavigation()
	appShell:onVenueSelected(function(venue)
		local result = requestVenueTeleport:InvokeServer(venue.Id)

		if result and not result.Success then
			appShell:showNotification({
				Kind = "Warning",
				Message = result.Message or "Teleport failed.",
				Duration = RuntimeConfig.World.NotificationDuration,
			})
		end
	end)
end

local function connectRemoteEvents()
	notifyPlayer.OnClientEvent:Connect(function(payload)
		appShell:showNotification({
			Kind = payload.Kind or "Info",
			Message = payload.Message or "",
			Duration = RuntimeConfig.World.NotificationDuration,
		})
	end)

	syncPlayerRole.OnClientEvent:Connect(function(payload)
		appShell:setRole(payload)
	end)
end

connectSpawnWelcome()
connectVenueNavigation()
connectRemoteEvents()
appShell:setRole(buildInitialRolePayload())
