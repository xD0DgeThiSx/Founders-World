local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WorldConfig = require(ReplicatedStorage.Shared.Config.WorldConfig)

local RemoteRegistryService = require(script.Parent.RemoteRegistryService)

local PlayerSessionService = {}

local sessionsByUserId = {}
local founderName = string.lower(WorldConfig.VIP.FounderUsername)
local vipLookup = {}

for _, vipName in ipairs(WorldConfig.VIP.Names) do
	vipLookup[string.lower(vipName)] = true
end

local function isFounderName(name)
	return string.lower(name) == founderName
end

local function isVipName(name)
	return vipLookup[string.lower(name)] == true
end

local function buildRolePayload(session)
	return {
		Role = session.Role,
		IsFounder = session.IsFounder,
		IsVIP = session.IsVIP,
		Username = session.Username,
		FounderUsername = WorldConfig.VIP.FounderUsername,
		VIPNames = WorldConfig.VIP.Names,
	}
end

local function createSession(player)
	local isFounder = isFounderName(player.Name)
	local isVip = isVipName(player.Name)
	local role = "Guest"

	if isFounder then
		role = "Founder"
	elseif isVip then
		role = "VIP"
	end

	local session = {
		Player = player,
		UserId = player.UserId,
		Username = player.Name,
		DisplayName = player.DisplayName,
		IsFounder = isFounder,
		IsVIP = isVip,
		Role = role,
		JoinClock = os.clock(),
		InteractionCooldowns = {},
		TeleportCooldownUntil = 0,
	}

	sessionsByUserId[player.UserId] = session
	RemoteRegistryService.syncPlayerRole(player, buildRolePayload(session))
	return session
end

local function bindPlayer(player)
	local session = createSession(player)
	local firstSpawn = true

	player.CharacterAdded:Connect(function(character)
		if firstSpawn then
			firstSpawn = false
			task.spawn(function()
				local rootPart = character:WaitForChild("HumanoidRootPart", 10)
				if rootPart then
					rootPart.CFrame = CFrame.new(WorldConfig.Hub.SpawnPosition)
				end
			end)
		end
		task.defer(function()
			RemoteRegistryService.syncPlayerRole(player, buildRolePayload(session))
		end)
	end)
end

local function onPlayerAdded(player)
	bindPlayer(player)
end

local function onPlayerRemoving(player)
	sessionsByUserId[player.UserId] = nil
end

function PlayerSessionService.start()
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)

	for _, player in ipairs(Players:GetPlayers()) do
		bindPlayer(player)
	end
end

function PlayerSessionService.IsFounder(player)
	local session = sessionsByUserId[player.UserId]
	return session ~= nil and session.IsFounder or false
end

function PlayerSessionService.IsVIP(player)
	local session = sessionsByUserId[player.UserId]
	return session ~= nil and (session.IsVIP or session.IsFounder) or false
end

function PlayerSessionService.GetPlayerRole(player)
	local session = sessionsByUserId[player.UserId]

	if not session then
		return "Guest"
	end

	return session.Role
end

function PlayerSessionService.GetSession(player)
	return sessionsByUserId[player.UserId]
end

function PlayerSessionService.GetRolePayload(player)
	local session = sessionsByUserId[player.UserId]

	if not session then
		return nil
	end

	return buildRolePayload(session)
end

return PlayerSessionService
