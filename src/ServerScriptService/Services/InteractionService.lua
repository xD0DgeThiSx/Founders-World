local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local RuntimeConfig = require(ReplicatedStorage.Shared.Config.RuntimeConfig)

local PlayerProfileService = require(script.Parent.PlayerProfileService)
local PlayerSessionService = require(script.Parent.PlayerSessionService)
local RemoteRegistryService = require(script.Parent.RemoteRegistryService)
local TeleportService = require(script.Parent.TeleportService)

local InteractionService = {}

local function roleRank(role)
	if role == "Founder" then
		return 3
	end

	if role == "VIP" then
		return 2
	end

	return 1
end

local function meetsRoleRequirement(player, requiredRole)
	if not requiredRole then
		return true
	end

	return roleRank(PlayerSessionService.GetPlayerRole(player)) >= roleRank(requiredRole)
end

local function throttleInteraction(session, key)
	local now = os.clock()
	local expiresAt = session.InteractionCooldowns[key] or 0

	if now < expiresAt then
		return false
	end

	session.InteractionCooldowns[key] = now + RuntimeConfig.World.InteractionCooldown
	return true
end

local function recordInteraction(player)
	PlayerProfileService.incrementStat(player, "Interactions", 1)
	RemoteRegistryService.syncPlayerProfile(player, PlayerProfileService.getProfilePayload(player))
end

local function createPrompt(parent, definition)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = definition.ActionText
	prompt.ObjectText = definition.ObjectText
	prompt.HoldDuration = definition.HoldDuration or RuntimeConfig.World.PromptHoldDuration
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = definition.MaxActivationDistance or 14
	prompt.Parent = parent

	prompt.Triggered:Connect(function(player)
		InteractionService.handlePrompt(player, definition)
	end)

	return prompt
end

local function openDoor(definition)
	local door = definition.Target

	if not door or not door.Parent then
		return
	end

	if door:GetAttribute("DoorBusy") or door:GetAttribute("DoorIsOpen") then
		return
	end

	local closedCFrame = definition.ClosedCFrame or door.CFrame
	local openOffset = definition.OpenOffset or Vector3.new(0, 12, 0)
	local openCFrame = closedCFrame * CFrame.new(openOffset)

	door:SetAttribute("DoorBusy", true)
	door:SetAttribute("DoorIsOpen", true)

	local tween = TweenService:Create(door, TweenInfo.new(RuntimeConfig.World.DoorOpenTime, Enum.EasingStyle.Sine), {
		CFrame = openCFrame,
	})
	tween:Play()
	tween.Completed:Wait()

	task.delay(RuntimeConfig.World.DoorAutoCloseDelay, function()
		if not door.Parent then
			return
		end

		local closeTween = TweenService:Create(door, TweenInfo.new(RuntimeConfig.World.DoorOpenTime, Enum.EasingStyle.Sine), {
			CFrame = closedCFrame,
		})
		closeTween:Play()
		closeTween.Completed:Wait()

		door:SetAttribute("DoorIsOpen", false)
		door:SetAttribute("DoorBusy", false)
	end)
end

function InteractionService.start()
	RemoteRegistryService.getFunction("RequestVenueTeleport").OnServerInvoke = function(player, venueId)
		return InteractionService.requestVenueTeleport(player, venueId)
	end

	RemoteRegistryService.getFunction("RequestMediaInteract").OnServerInvoke = function(player, payload)
		return InteractionService.requestMediaInteract(player, payload)
	end

	RemoteRegistryService.getFunction("RequestFounderAction").OnServerInvoke = function(player, payload)
		return InteractionService.requestFounderAction(player, payload)
	end
end

function InteractionService.registerPrompt(parent, definition)
	return createPrompt(parent, definition)
end

function InteractionService.handlePrompt(player, definition)
	local session = PlayerSessionService.GetSession(player)

	if not session then
		return
	end

	local cooldownKey = definition.CooldownKey or (definition.ActionType .. ":" .. definition.ObjectText)
	if not throttleInteraction(session, cooldownKey) then
		return
	end

	if not meetsRoleRequirement(player, definition.RoleRequired) then
		RemoteRegistryService.notifyPlayer(player, "You do not have access to " .. definition.ObjectText, "Warning")
		return
	end

	recordInteraction(player)

	if definition.ActionType == "Door" then
		openDoor(definition)
		return
	end

	if definition.ActionType == "TeleportVenue" then
		local success, message = TeleportService.teleportToVenue(player, definition.VenueId)
		if not success then
			RemoteRegistryService.notifyPlayer(player, message, "Warning")
		end
		return
	end

	if definition.ActionType == "TeleportHub" then
		local success, message = TeleportService.teleportToHub(player)
		if not success then
			RemoteRegistryService.notifyPlayer(player, message, "Warning")
		end
		return
	end

	if definition.ActionType == "Media" then
		RemoteRegistryService.notifyPlayer(player, definition.Message or ("Opened " .. definition.ObjectText), "Info")
		return
	end

	if definition.ActionType == "FounderAction" then
		RemoteRegistryService.notifyPlayer(player, definition.Message or ("Accessed " .. definition.ObjectText), "Info")
		return
	end

	if definition.ActionType == "Notify" then
		RemoteRegistryService.notifyPlayer(player, definition.Message or definition.ObjectText, "Info")
	end
end

function InteractionService.requestVenueTeleport(player, venueId)
	local success, message = TeleportService.teleportToVenue(player, venueId)

	if not success then
		RemoteRegistryService.notifyPlayer(player, message, "Warning")
	end

	return {
		Success = success,
		Message = message,
	}
end

function InteractionService.requestMediaInteract(player, payload)
	local panelName = payload and payload.PanelName or "Media Panel"
	recordInteraction(player)
	RemoteRegistryService.notifyPlayer(player, "Interaction placeholder: " .. panelName, "Info")

	-- Future hook: media stations can route to richer playback systems here.
	return {
		Success = true,
		Message = "Media placeholder opened.",
	}
end

function InteractionService.requestFounderAction(player, payload)
	local actionName = payload and payload.ActionName or "Founder Action"

	if not PlayerSessionService.HasPermission(player, "CanUseFounderActions") then
		RemoteRegistryService.notifyPlayer(player, "Founder access required.", "Warning")
		return {
			Success = false,
			Message = "Founder access required.",
		}
	end

	recordInteraction(player)
	RemoteRegistryService.notifyPlayer(player, "Founder placeholder: " .. actionName, "Info")

	-- Future hooks:
	-- Founder Tablet
	-- VIP doors
	-- Media stations
	-- Surprise drops
	return {
		Success = true,
		Message = "Founder action acknowledged.",
	}
end

return InteractionService
