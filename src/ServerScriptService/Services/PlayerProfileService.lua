local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileConfig = require(ReplicatedStorage.Shared.Config.ProfileConfig)

local PlayerProfileService = {}

local profilesByUserId = {}

local function deepCopy(value)
	if type(value) ~= "table" then
		return value
	end

	local copy = {}

	for key, childValue in pairs(value) do
		copy[key] = deepCopy(childValue)
	end

	return copy
end

local function getPermissionsForRole(role)
	return ProfileConfig.Permissions[role] or ProfileConfig.Permissions.Guest
end

local function applyRoleEntitlements(profile, role)
	profile.Entitlements.Founder = role == "Founder"
	profile.Entitlements.VIP = role == "VIP" or role == "Founder"
end

local function buildProfilePayload(profile)
	return {
		SchemaVersion = profile.SchemaVersion,
		Progression = deepCopy(profile.Progression),
		Entitlements = deepCopy(profile.Entitlements),
		Stats = deepCopy(profile.Stats),
		Preferences = deepCopy(profile.Preferences),
		Permissions = deepCopy(profile.Permissions),
	}
end

function PlayerProfileService.start()
	-- Phase 5 intentionally keeps profiles in memory only.
	-- A future persistence service can replace createProfile/loadProfile without changing callers.
end

function PlayerProfileService.createProfile(player, role)
	local profile = deepCopy(ProfileConfig.DefaultProfile)
	profile.UserId = player.UserId
	profile.Username = player.Name
	profile.DisplayName = player.DisplayName
	profile.Role = role or "Guest"
	profile.Permissions = deepCopy(getPermissionsForRole(profile.Role))

	applyRoleEntitlements(profile, profile.Role)
	profile.Stats.Visits += 1

	profilesByUserId[player.UserId] = profile
	return profile
end

function PlayerProfileService.removeProfile(player)
	profilesByUserId[player.UserId] = nil
end

function PlayerProfileService.getProfile(player)
	return profilesByUserId[player.UserId]
end

function PlayerProfileService.getProfilePayload(player)
	local profile = PlayerProfileService.getProfile(player)

	if not profile then
		return nil
	end

	return buildProfilePayload(profile)
end

function PlayerProfileService.hasPermission(player, permissionName)
	local profile = PlayerProfileService.getProfile(player)

	if not profile then
		return false
	end

	return profile.Permissions[permissionName] == true
end

function PlayerProfileService.incrementStat(player, statName, amount)
	local profile = PlayerProfileService.getProfile(player)

	if not profile then
		return nil
	end

	amount = amount or 1
	profile.Stats[statName] = (profile.Stats[statName] or 0) + amount
	return profile.Stats[statName]
end

return PlayerProfileService
