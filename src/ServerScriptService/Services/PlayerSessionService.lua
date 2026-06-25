local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WorldConfig = require(ReplicatedStorage.Shared.Config.WorldConfig)

local RemoteRegistryService = require(script.Parent.RemoteRegistryService)

local vipWelcomes = {
	Abbiejo615 = "Happy Birthday Abbie Jo! The Birthday Room is ready for you — go find it!",
	lue0615 = "Hey Lue! Your crew is already here. Girls Hangout is calling!",
	BUTTERTHEMBUNS = "Welcome back! The Secret Food Court is waiting for you below Girls Hangout.",
	Emilyplays902 = "EmilyPlays is in the building! Your streaming corner is ready.",
	Emigirl0615 = "EmiGirl has arrived! The VIP lounge is all yours.",
}

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

local function sendWelcomeMessage(player, session)
	local msg
	if session.IsFounder then
		msg = "Welcome back, " .. WorldConfig.VIP.FounderUsername .. "! Founder's World is yours to command."
	elseif session.IsVIP then
		msg = vipWelcomes[player.Name] or ("Welcome back, " .. player.Name .. "! The Girls Hangout crew is here.")
	end
	if msg then
		task.delay(1.5, function()
			if player.Parent then
				RemoteRegistryService.notifyPlayer(player, msg, "VIP")
			end
		end)
	end
end

local function bindPlayer(player)
	local session = createSession(player)
	local firstSpawn = true

	local function sendToHub(character)
		if not firstSpawn then return end
		firstSpawn = false
		local hubCFrame = CFrame.new(WorldConfig.Hub.SpawnPosition)
		warn("[PSS] sendToHub: teleporting", player.Name, "→", WorldConfig.Hub.SpawnPosition)
		task.spawn(function()
			local rootPart = character:WaitForChild("HumanoidRootPart", 10)
			if not rootPart then
				warn("[PSS] sendToHub: HumanoidRootPart not found for", player.Name)
				return
			end
			-- Retry across 3 frames so spawn physics can't override the final set
			for i = 1, 3 do
				if not rootPart.Parent then break end
				rootPart.CFrame = hubCFrame
				task.wait()
			end
			warn("[PSS] sendToHub: done for", player.Name)
		end)
	end

	player.CharacterAdded:Connect(function(character)
		sendToHub(character)
		task.defer(function()
			RemoteRegistryService.syncPlayerRole(player, buildRolePayload(session))
		end)
		if firstSpawn then
			sendWelcomeMessage(player, session)
		end
	end)

	-- In Studio, character loads before this handler connects — handle it directly.
	if player.Character then
		warn("[PSS] bindPlayer:", player.Name, "already has a character, teleporting now")
		sendToHub(player.Character)
	else
		warn("[PSS] bindPlayer:", player.Name, "no character yet, waiting for CharacterAdded")
	end
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
