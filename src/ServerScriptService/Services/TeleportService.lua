local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RuntimeConfig = require(ReplicatedStorage.Shared.Config.RuntimeConfig)

local PlayerProfileService = require(script.Parent.PlayerProfileService)
local PlayerSessionService = require(script.Parent.PlayerSessionService)
local RemoteRegistryService = require(script.Parent.RemoteRegistryService)

local TeleportService = {}

local venueTargets = {}
local hubTarget

local function canTeleport(session)
	return session and os.clock() >= session.TeleportCooldownUntil
end

local function setCooldown(session)
	session.TeleportCooldownUntil = os.clock() + RuntimeConfig.World.TeleportCooldown
end

function TeleportService.setHubTarget(targetCFrame)
	hubTarget = targetCFrame
end

function TeleportService.registerVenueTarget(venueId, targetCFrame, venueName)
	venueTargets[venueId] = {
		Target = targetCFrame,
		Name = venueName or venueId,
	}
end

function TeleportService.teleportToCFrame(player, targetCFrame, successMessage)
	local session = PlayerSessionService.GetSession(player)

	if not session then
		return false, "Session unavailable."
	end

	if not canTeleport(session) then
		return false, "Teleport cooling down."
	end

	local character = player.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not rootPart then
		return false, "Character not ready."
	end

	setCooldown(session)
	rootPart.CFrame = targetCFrame + Vector3.new(0, RuntimeConfig.World.SafeArrivalOffsetY, 0)
	PlayerProfileService.incrementStat(player, "Teleports", 1)
	RemoteRegistryService.syncPlayerProfile(player, PlayerProfileService.getProfilePayload(player))

	if successMessage then
		RemoteRegistryService.notifyPlayer(player, successMessage, "Success")
	end

	return true
end

function TeleportService.teleportToVenue(player, venueId)
	local venueTarget = venueTargets[venueId]

	if not venueTarget then
		return false, "Venue target unavailable."
	end

	return TeleportService.teleportToCFrame(player, venueTarget.Target, "Teleported to " .. venueTarget.Name)
end

function TeleportService.teleportToHub(player)
	if not hubTarget then
		return false, "Hub target unavailable."
	end

	return TeleportService.teleportToCFrame(player, hubTarget, "Returned to Founder's Plaza")
end

return TeleportService
