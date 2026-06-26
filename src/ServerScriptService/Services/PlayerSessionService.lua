local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RuntimeConfig = require(ReplicatedStorage.Shared.Config.RuntimeConfig)
local WorldConfig = require(ReplicatedStorage.Shared.Config.WorldConfig)

local RemoteRegistryService = require(script.Parent.RemoteRegistryService)

local vipWelcomes = {
	lue0615 = "Hey Lue! Your crew is already here. Girls Hangout is calling!",
	BUTTERTHEMBUNS = "Welcome back! The Secret Food Court is waiting for you below Girls Hangout.",
	Emilyplays902 = "EmilyPlays is in the building! Your streaming corner is ready.",
	Emigirl0615 = "EmiGirl has arrived! The VIP lounge is all yours.",
}

local abbieRevealMessages = {
	{ delay = 2,  text = "Happy 11th Birthday Abbie Jo! Your special day starts RIGHT NOW!", kind = "Birthday" },
	{ delay = 6,  text = "Your Birthday Room is decorated just for you inside Girls Hangout!", kind = "Birthday" },
	{ delay = 10, text = "Mom, Dad, and Charlie Lue built Founder's World just for YOU. Have the best 11th birthday ever!", kind = "Birthday" },
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

local function getHubSpawnCFrame()
	local safeOffsetY = math.max((RuntimeConfig.World and RuntimeConfig.World.SafeArrivalOffsetY) or 3, 5)
	return CFrame.new(WorldConfig.Hub.SpawnPosition + Vector3.new(0, safeOffsetY, 0))
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
	if player.Name == "Abbiejo615" then
		for _, entry in ipairs(abbieRevealMessages) do
			local msg, kind, delay = entry.text, entry.kind, entry.delay
			task.delay(delay, function()
				if player.Parent then
					RemoteRegistryService.notifyPlayer(player, msg, kind)
				end
			end)
		end
		return
	end

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
	local spawned = false

	local function onCharacterSpawned(character, isFirst)
		task.spawn(function()
			local rootPart = character:WaitForChild("HumanoidRootPart", 10)
			if not rootPart then
				warn("[PSS] sendToHub: HumanoidRootPart not found for", player.Name)
				return
			end
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			local hubCFrame = getHubSpawnCFrame()
			warn("[PSS] sendToHub: teleporting", player.Name, "→", hubCFrame.Position)
			for i = 1, 3 do
				if not rootPart.Parent then
					break
				end
				rootPart.AssemblyLinearVelocity = Vector3.zero
				rootPart.AssemblyAngularVelocity = Vector3.zero
				character:PivotTo(hubCFrame)
				if humanoid then
					humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
				end
				task.wait()
			end
			warn("[PSS] sendToHub: done for", player.Name)
		end)
		task.defer(function()
			RemoteRegistryService.syncPlayerRole(player, buildRolePayload(session))
		end)
		if isFirst then
			sendWelcomeMessage(player, session)
		end
	end

	player.CharacterAdded:Connect(function(character)
		local isFirst = not spawned
		spawned = true
		onCharacterSpawned(character, isFirst)
	end)

	if player.Character then
		warn("[PSS] bindPlayer:", player.Name, "already has character, teleporting now")
		spawned = true
		onCharacterSpawned(player.Character, true)
	else
		warn("[PSS] bindPlayer:", player.Name, "no character yet, loading now")
		player:LoadCharacter()
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
