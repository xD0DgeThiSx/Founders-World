local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteConfig = require(ReplicatedStorage.Shared.Config.RemoteConfig)

local RemoteRegistryService = {}

local remoteRoot
local eventFolder
local functionFolder

local function ensureFolder(parent, name)
	local folder = parent:FindFirstChild(name)

	if not folder then
		folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = parent
	end

	return folder
end

local function ensureRemote(parent, className, name)
	local remote = parent:FindFirstChild(name)

	if not remote then
		remote = Instance.new(className)
		remote.Name = name
		remote.Parent = parent
	end

	return remote
end

function RemoteRegistryService.start()
	remoteRoot = ensureFolder(ReplicatedStorage, "Remotes")
	eventFolder = ensureFolder(remoteRoot, "Events")
	functionFolder = ensureFolder(remoteRoot, "Functions")

	for _, eventName in ipairs(RemoteConfig.Folders.Events) do
		ensureRemote(eventFolder, "RemoteEvent", eventName)
	end

	for _, functionName in ipairs(RemoteConfig.Folders.Functions) do
		ensureRemote(functionFolder, "RemoteFunction", functionName)
	end
end

function RemoteRegistryService.getEvent(name)
	return eventFolder:WaitForChild(name)
end

function RemoteRegistryService.getFunction(name)
	return functionFolder:WaitForChild(name)
end

function RemoteRegistryService.notifyPlayer(player, message, kind)
	local remote = RemoteRegistryService.getEvent("NotifyPlayer")
	remote:FireClient(player, {
		Message = message,
		Kind = kind or "Info",
	})
end

function RemoteRegistryService.syncPlayerRole(player, payload)
	local remote = RemoteRegistryService.getEvent("SyncPlayerRole")
	remote:FireClient(player, payload)
end

function RemoteRegistryService.syncPlayerProfile(player, payload)
	local remote = RemoteRegistryService.getEvent("SyncPlayerProfile")
	remote:FireClient(player, payload)
end

return RemoteRegistryService
