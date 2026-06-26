local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RuntimeConfig = require(ReplicatedStorage.Shared.Config.RuntimeConfig)

local PlayerSessionService = require(script.Parent.PlayerSessionService)
local RemoteRegistryService = require(script.Parent.RemoteRegistryService)

local TeleportService = {}

local venueTargets = {}
local hubTarget

local function getRegisteredVenueKeys()
	local keys = {}
	for venueId in pairs(venueTargets) do
		table.insert(keys, venueId)
	end
	table.sort(keys)
	return keys
end

local function canTeleport(session)
	return session and os.clock() >= session.TeleportCooldownUntil
end

local function setCooldown(session)
	session.TeleportCooldownUntil = os.clock() + RuntimeConfig.World.TeleportCooldown
end

local function teleportPlayerTo(player, targetCFrame)
	local character = player.Character
	if not character then
		warn("[TeleportService] Character missing for", player.Name)
		return false, "Character not ready."
	end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		warn("[TeleportService] HumanoidRootPart missing for", player.Name)
		return false, "Character not ready."
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local safeOffsetY = (RuntimeConfig.World and RuntimeConfig.World.SafeArrivalOffsetY) or 3
	local arrivalCFrame = targetCFrame + Vector3.new(0, safeOffsetY, 0)

	warn("[TeleportService] Teleport start:", player.Name, "->", arrivalCFrame.Position)
	rootPart.AssemblyLinearVelocity = Vector3.zero
	rootPart.AssemblyAngularVelocity = Vector3.zero
	character:PivotTo(arrivalCFrame)
	rootPart.AssemblyLinearVelocity = Vector3.zero
	rootPart.AssemblyAngularVelocity = Vector3.zero

	if humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end

	warn("[TeleportService] Teleport complete:", player.Name, "->", arrivalCFrame.Position)
	return true
end

function TeleportService.setHubTarget(targetCFrame)
	hubTarget = targetCFrame
end

function TeleportService.registerVenueTarget(venueId, targetCFrame, venueName)
	venueTargets[venueId] = {
		Target = targetCFrame,
		Name = venueName or venueId,
	}
	warn("[TeleportService] Registered venue target:", venueId, targetCFrame.Position, "name:", venueName or venueId)
	warn("[TeleportService] Available venue targets:", table.concat(getRegisteredVenueKeys(), ", "))
end

function TeleportService.teleportToCFrame(player, targetCFrame, successMessage)
	local session = PlayerSessionService.GetSession(player)

	if not session then
		warn("[TeleportService] Session unavailable for", player.Name)
		return false, "Session unavailable."
	end

	if not canTeleport(session) then
		warn("[TeleportService] Teleport cooling down for", player.Name)
		return false, "Teleport cooling down."
	end

	if not targetCFrame then
		warn("[TeleportService] Target CFrame unavailable for", player.Name)
		return false, "Teleport target unavailable."
	end

	setCooldown(session)
	local moved, moveMessage = teleportPlayerTo(player, targetCFrame)
	if not moved then
		return false, moveMessage
	end

	if successMessage then
		RemoteRegistryService.notifyPlayer(player, successMessage, "Success")
	end

	return true
end

function TeleportService.teleportToVenue(player, venueId)
	local venueTarget = venueTargets[venueId]

	if not venueTarget then
		warn("[TeleportService] Venue target unavailable for", venueId, "requested by", player.Name)
		warn("[TeleportService] Available venue target keys:", table.concat(getRegisteredVenueKeys(), ", "))
		return false, "Venue target unavailable."
	end

	warn("[TeleportService] Venue teleport requested:", player.Name, "->", venueId, venueTarget.Target.Position)
	return TeleportService.teleportToCFrame(player, venueTarget.Target, "Teleported to " .. venueTarget.Name)
end

function TeleportService.teleportToHub(player)
	if not hubTarget then
		warn("[TeleportService] Hub target unavailable for", player.Name)
		return false, "Hub target unavailable."
	end

	warn("[TeleportService] Hub teleport requested:", player.Name, "->", hubTarget.Position)
	return TeleportService.teleportToCFrame(player, hubTarget, "Returned to Founder's Plaza")
end

return TeleportService
