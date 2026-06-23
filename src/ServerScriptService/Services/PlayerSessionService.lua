local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WorldConfig = require(ReplicatedStorage.Shared.Config.WorldConfig)

local PlayerProfileService = require(script.Parent.PlayerProfileService)
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

local function syncPlayerState(player, session)
	RemoteRegistryService.syncPlayerRole(player, buildRolePayload(session))
	RemoteRegistryService.syncPlayerProfile(player, PlayerProfileService.getProfilePayload(player))
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

	local profile = PlayerProfileService.createProfile(player, role)

	local session = {
		Player = player,
		UserId = player.UserId,
		Username = player.Name,
		DisplayName = player.DisplayName,
		IsFounder = isFounder,
		IsVIP = isVip,
		Role = role,
		Profile = profile,
		JoinClock = os.clock(),
		InteractionCooldowns = {},
		TeleportCooldownUntil = 0,
	}

	sessionsByUserId[player.UserId] = session
	syncPlayerState(player, session)
	return session
end

local function bindPlayer(player)
	local session = createSession(player)

	player.CharacterAdded:Connect(function()
		task.defer(function()
			syncPlayerState(player, session)
		end)
	end)
end

local function onPlayerAdded(player)
	bindPlayer(player)
end

local function onPlayerRemoving(player)
	sessionsByUserId[player.UserId] = nil
	PlayerProfileService.removeProfile(player)
end

function PlayerSessionService.start()
	RemoteRegistryService.getFunction("RequestPlayerProfile").OnServerInvoke = function(player)
		return PlayerSessionService.GetProfilePayload(player)
	end

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

function PlayerSessionService.GetProfile(player)
	return PlayerProfileService.getProfile(player)
end

function PlayerSessionService.GetProfilePayload(player)
	return PlayerProfileService.getProfilePayload(player)
end

function PlayerSessionService.HasPermission(player, permissionName)
	return PlayerProfileService.hasPermission(player, permissionName)
end

return PlayerSessionService
