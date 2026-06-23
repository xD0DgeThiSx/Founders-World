local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local RuntimeConfig = require(ReplicatedStorage.Shared.Config.RuntimeConfig)
local WorldConfig = require(ReplicatedStorage.Shared.Config.WorldConfig)

local MediaFramework = require(ServerScriptService.Systems.MediaFramework)

local WorldBuilderService = {}

local DOOR_OPEN_ATTRIBUTE = "DoorIsOpen"

local function createFolder(name, parent)
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent
	return folder
end

local function createPart(name, parent, properties)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent

	for property, value in pairs(properties) do
		part[property] = value
	end

	return part
end

local function createLabel(parent, face, title, subtitle, textColor)
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Face = face
	surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surfaceGui.PixelsPerStud = 40
	surfaceGui.Parent = parent

	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.fromScale(1, 0.6)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextScaled = true
	titleLabel.TextColor3 = textColor
	titleLabel.Text = title
	titleLabel.Parent = surfaceGui

	local subtitleLabel = Instance.new("TextLabel")
	subtitleLabel.BackgroundTransparency = 1
	subtitleLabel.Position = UDim2.fromScale(0, 0.58)
	subtitleLabel.Size = UDim2.fromScale(1, 0.38)
	subtitleLabel.Font = Enum.Font.Gotham
	subtitleLabel.TextScaled = true
	subtitleLabel.TextColor3 = textColor
	subtitleLabel.Text = subtitle
	subtitleLabel.Parent = surfaceGui

	return surfaceGui, titleLabel, subtitleLabel
end

local function createSpawn(spawnFolder, name, position, color)
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = name
	spawn.Anchored = true
	spawn.Size = Vector3.new(10, 1, 10)
	spawn.Position = position
	spawn.Color = color
	spawn.Material = Enum.Material.Neon
	spawn.Neutral = true
	spawn.Transparency = 0.1
	spawn.Parent = spawnFolder
	return spawn
end

local function createSign(signFolder, name, position, title, subtitle, color, accent)
	local sign = createPart(name, signFolder, {
		Size = Vector3.new(14, 10, 1),
		Position = position,
		Color = color,
		Material = Enum.Material.SmoothPlastic,
	})

	local frame = createPart(name .. "Frame", signFolder, {
		Size = Vector3.new(15, 11, 0.5),
		Position = position + Vector3.new(0, 0, 0.75),
		Color = accent,
		Material = Enum.Material.Metal,
	})

	createLabel(sign, Enum.NormalId.Front, title, subtitle, accent)

	return sign, frame
end

local function createTeleportPrompt(parent, actionText, objectText, callback)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = actionText
	prompt.ObjectText = objectText
	prompt.HoldDuration = RuntimeConfig.World.PromptHoldDuration
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = 14
	prompt.Parent = parent
	prompt.Triggered:Connect(callback)
	return prompt
end

local function teleportCharacter(player, destinationCFrame)
	local character = player.Character
	if not character then
		return
	end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		return
	end

	rootPart.CFrame = destinationCFrame
end

local function connectDoor(door, label, closedCFrame, openOffset)
	local isAnimating = false
	local openCFrame = closedCFrame * CFrame.new(openOffset)

	door:SetAttribute(DOOR_OPEN_ATTRIBUTE, false)

	createTeleportPrompt(door, "Open", label, function()
		if isAnimating or door:GetAttribute(DOOR_OPEN_ATTRIBUTE) then
			return
		end

		isAnimating = true
		door:SetAttribute(DOOR_OPEN_ATTRIBUTE, true)

		local tween = TweenService:Create(door, TweenInfo.new(RuntimeConfig.World.DoorOpenTime, Enum.EasingStyle.Sine), {
			CFrame = openCFrame,
		})
		tween:Play()
		tween.Completed:Wait()

		task.delay(RuntimeConfig.World.DoorAutoCloseDelay, function()
			local closeTween = TweenService:Create(door, TweenInfo.new(RuntimeConfig.World.DoorOpenTime, Enum.EasingStyle.Sine), {
				CFrame = closedCFrame,
			})
			closeTween:Play()
			closeTween.Completed:Wait()
			door:SetAttribute(DOOR_OPEN_ATTRIBUTE, false)
			isAnimating = false
		end)
	end)
end

local function createDoor(venueFolder, venueConfig, centerPosition)
	local doorwayRoot = createFolder("Doors", venueFolder)

	local leftWall = createPart("LeftDoorFrame", doorwayRoot, {
		Size = Vector3.new(18, 18, 4),
		Position = centerPosition + Vector3.new(-15, 9, -venueConfig.Footprint.Z / 2),
		Color = venueConfig.Accent,
		Material = Enum.Material.Metal,
	})
	leftWall.CanCollide = true

	local rightWall = createPart("RightDoorFrame", doorwayRoot, {
		Size = Vector3.new(18, 18, 4),
		Position = centerPosition + Vector3.new(15, 9, -venueConfig.Footprint.Z / 2),
		Color = venueConfig.Accent,
		Material = Enum.Material.Metal,
	})
	rightWall.CanCollide = true

	local lintel = createPart("DoorLintel", doorwayRoot, {
		Size = Vector3.new(12, 4, 4),
		Position = centerPosition + Vector3.new(0, 16, -venueConfig.Footprint.Z / 2),
		Color = venueConfig.Accent,
		Material = Enum.Material.Metal,
	})
	lintel.CanCollide = true

	local door = createPart("MainDoor", doorwayRoot, {
		Size = Vector3.new(12, 12, 2),
		Position = centerPosition + Vector3.new(0, 6, -venueConfig.Footprint.Z / 2),
		Color = venueConfig.Color,
		Material = Enum.Material.Glass,
		Transparency = 0.2,
	})
	door.CanCollide = true

	connectDoor(door, venueConfig.Name, door.CFrame, Vector3.new(0, 12, 0))
end

local function createNavigationPad(parent, name, position, color, label)
	local pad = createPart(name, parent, {
		Size = Vector3.new(14, 1, 14),
		Position = position,
		Color = color,
		Material = Enum.Material.Neon,
	})

	local marker = createPart(name .. "Marker", parent, {
		Size = Vector3.new(10, 8, 1),
		Position = position + Vector3.new(0, 5, -7),
		Color = Color3.fromRGB(25, 25, 25),
		Material = Enum.Material.SmoothPlastic,
	})

	createLabel(marker, Enum.NormalId.Front, label, "Teleport", color)

	return pad
end

local function createVenueShell(venueFolder, venueConfig)
	local footprint = venueConfig.Footprint
	local position = venueConfig.Position
	local shellFolder = createFolder("Shell", venueFolder)
	local floorY = position.Y + 1
	local wallY = position.Y + footprint.Y / 2
	local roofY = position.Y + footprint.Y + 1

	createPart("Floor", shellFolder, {
		Size = Vector3.new(footprint.X, 2, footprint.Z),
		Position = Vector3.new(position.X, floorY, position.Z),
		Color = venueConfig.Color,
		Material = Enum.Material.Concrete,
	})

	createPart("Roof", shellFolder, {
		Size = Vector3.new(footprint.X, 2, footprint.Z),
		Position = Vector3.new(position.X, roofY, position.Z),
		Color = venueConfig.Accent,
		Material = Enum.Material.Metal,
	})

	createPart("BackWall", shellFolder, {
		Size = Vector3.new(footprint.X, footprint.Y, 2),
		Position = Vector3.new(position.X, wallY, position.Z + footprint.Z / 2),
		Color = venueConfig.Accent,
		Material = Enum.Material.Concrete,
	})

	createPart("LeftWall", shellFolder, {
		Size = Vector3.new(2, footprint.Y, footprint.Z),
		Position = Vector3.new(position.X - footprint.X / 2, wallY, position.Z),
		Color = venueConfig.Accent,
		Material = Enum.Material.Concrete,
	})

	createPart("RightWall", shellFolder, {
		Size = Vector3.new(2, footprint.Y, footprint.Z),
		Position = Vector3.new(position.X + footprint.X / 2, wallY, position.Z),
		Color = venueConfig.Accent,
		Material = Enum.Material.Concrete,
	})

	local frontSegmentWidth = (footprint.X - 12) / 2

	createPart("FrontWallLeft", shellFolder, {
		Size = Vector3.new(frontSegmentWidth, footprint.Y, 2),
		Position = Vector3.new(position.X - (12 / 2 + frontSegmentWidth / 2), wallY, position.Z - footprint.Z / 2),
		Color = venueConfig.Accent,
		Material = Enum.Material.Concrete,
	})

	createPart("FrontWallRight", shellFolder, {
		Size = Vector3.new(frontSegmentWidth, footprint.Y, 2),
		Position = Vector3.new(position.X + (12 / 2 + frontSegmentWidth / 2), wallY, position.Z - footprint.Z / 2),
		Color = venueConfig.Accent,
		Material = Enum.Material.Concrete,
	})

	createDoor(venueFolder, venueConfig, position)

	local signBasePosition = Vector3.new(position.X, position.Y + footprint.Y + 8, position.Z - footprint.Z / 2 + 2)
	createSign(createFolder("Signage", venueFolder), "VenueSign", signBasePosition, venueConfig.Name, venueConfig.Theme, venueConfig.Color, venueConfig.Accent)
end

local function createInteriorLayout(venueFolder, venueConfig)
	local contentFolder = createFolder("Content", venueFolder)
	local center = venueConfig.Position
	local footprint = venueConfig.Footprint
	local furnishColor = venueConfig.Accent

	createPart("ReceptionDesk", contentFolder, {
		Size = Vector3.new(18, 6, 6),
		Position = center + Vector3.new(0, 3, -footprint.Z / 2 + 16),
		Color = furnishColor,
		Material = Enum.Material.WoodPlanks,
	})

	createPart("CenterStage", contentFolder, {
		Size = Vector3.new(20, 2, 20),
		Position = center + Vector3.new(0, 1, 8),
		Color = venueConfig.Color:Lerp(Color3.new(1, 1, 1), 0.25),
		Material = Enum.Material.SmoothPlastic,
	})

	for index = -1, 1 do
		createPart("SeatRow" .. tostring(index + 2), contentFolder, {
			Size = Vector3.new(24, 3, 6),
			Position = center + Vector3.new(index * 24, 1.5, 28),
			Color = furnishColor,
			Material = Enum.Material.Fabric,
		})
	end
end

local function buildVenue(venueFolder, venueConfig, spawnFolder, teleportFolder, mediaFolder, navigationFolder, hubDestination)
	createVenueShell(venueFolder, venueConfig)
	createInteriorLayout(venueFolder, venueConfig)

	local spawnPosition = venueConfig.Position + Vector3.new(0, 3, -venueConfig.Footprint.Z / 2 + 22)
	createSpawn(spawnFolder, venueConfig.Name .. " Spawn", spawnPosition, venueConfig.Accent)

	local arrivalPad = createNavigationPad(teleportFolder, venueConfig.Name .. " ReturnPad", venueConfig.Position + Vector3.new(0, 0.5, venueConfig.Footprint.Z / 2 - 14), venueConfig.Accent, "Return to Plaza")
	createTeleportPrompt(arrivalPad, "Teleport", "Founder's Plaza", function(player)
		teleportCharacter(player, hubDestination + Vector3.new(0, 4, 0))
	end)

	local hubPad = createNavigationPad(navigationFolder, venueConfig.Name .. " TeleportPad", Vector3.new(venueConfig.Position.X * 0.28, 0.5, venueConfig.Position.Z * 0.28), venueConfig.Accent, venueConfig.Name)
	createTeleportPrompt(hubPad, "Teleport", venueConfig.Name, function(player)
		teleportCharacter(player, CFrame.new(spawnPosition + Vector3.new(0, 2, 0)))
	end)

	MediaFramework.build(mediaFolder, venueConfig)
end

local function createWorldFolders()
	local existing = Workspace:FindFirstChild("FoundersWorld")
	if existing then
		existing:Destroy()
	end

	local root = createFolder("FoundersWorld", Workspace)
	local mapFolder = createFolder("Map", root)
	local venuesFolder = createFolder("Venues", mapFolder)
	local navigationFolder = createFolder("Navigation", mapFolder)
	local spawnsFolder = createFolder("Spawns", mapFolder)
	local mediaFolder = createFolder("Media", mapFolder)
	local teleportFolder = createFolder("Teleports", mapFolder)
	local environmentFolder = createFolder("Environment", mapFolder)

	return root, {
		Map = mapFolder,
		Venues = venuesFolder,
		Navigation = navigationFolder,
		Spawns = spawnsFolder,
		Media = mediaFolder,
		Teleports = teleportFolder,
		Environment = environmentFolder,
	}
end

local function createAmbientSound()
	local sound = SoundService:FindFirstChild("PrototypeAmbient")
	if sound then
		sound:Destroy()
	end

	sound = Instance.new("Sound")
	sound.Name = "PrototypeAmbient"
	sound.Looped = true
	sound.Volume = 0
	sound.Parent = SoundService
end

function WorldBuilderService.build()
	local _, folders = createWorldFolders()

	createAmbientSound()

	local hub = WorldConfig.Hub
	local hubFloor = createPart("HubFloor", folders.Environment, {
		Size = hub.Size,
		Position = hub.Position + Vector3.new(0, 1, 0),
		Color = Color3.fromRGB(212, 212, 212),
		Material = Enum.Material.Concrete,
	})
	hubFloor.Parent = folders.Environment

	createPart("HubCenterMarker", folders.Environment, {
		Size = Vector3.new(30, 1.2, 30),
		Position = hub.Position + Vector3.new(0, 1.1, 0),
		Color = Color3.fromRGB(255, 201, 68),
		Material = Enum.Material.Neon,
	})

	createSign(folders.Navigation, "HubSign", hub.Position + Vector3.new(0, 8, -32), hub.SignText, "Choose a venue to explore", Color3.fromRGB(35, 35, 35), Color3.fromRGB(255, 255, 255))
	createSpawn(folders.Spawns, "CentralSpawn", hub.Position + Vector3.new(0, 3, 24), Color3.fromRGB(255, 201, 68))

	local hubDestination = CFrame.new(hub.Position + Vector3.new(0, 4, 24))

	for _, venueConfig in ipairs(WorldConfig.Venues) do
		local venueFolder = createFolder(venueConfig.Name, folders.Venues)
		buildVenue(venueFolder, venueConfig, folders.Spawns, folders.Teleports, folders.Media, folders.Navigation, hubDestination)
	end
end

return WorldBuilderService
