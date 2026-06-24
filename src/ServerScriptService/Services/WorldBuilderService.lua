local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")

local WorldConfig = require(ReplicatedStorage.Shared.Config.WorldConfig)

local MediaFramework = require(ServerScriptService.Systems.MediaFramework)
local InteractionService = require(script.Parent.InteractionService)
local TeleportService = require(script.Parent.TeleportService)

local WorldBuilderService = {}

local zoneLookup = {}
local venueLookup = {}

for _, zoneConfig in ipairs(WorldConfig.Zones or {}) do
	zoneLookup[zoneConfig.Id] = zoneConfig
end

for _, venueConfig in ipairs(WorldConfig.Venues or {}) do
	venueLookup[venueConfig.Id] = venueConfig
end

local function createFolder(name, parent)
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent
	return folder
end

local function createInstance(className, name, parent)
	local instance = Instance.new(className)
	instance.Name = name
	instance.Parent = parent
	return instance
end

local function createPart(name, parent, properties)
	local className = properties.ClassName or "Part"
	local finalCFrame = properties.CFrame
	properties.ClassName = nil
	properties.CFrame = nil

	local part = createInstance(className, name, parent)

	if part:IsA("BasePart") then
		part.Anchored = true
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
	end

	for property, value in pairs(properties) do
		part[property] = value
	end

	if finalCFrame then
		part.CFrame = finalCFrame
	end

	return part
end

local function createSurfaceText(parent, face, title, subtitle, textColor)
	local surfaceGui = createInstance("SurfaceGui", "SurfaceText", parent)
	surfaceGui.Face = face
	surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surfaceGui.PixelsPerStud = 40

	local titleLabel = createInstance("TextLabel", "Title", surfaceGui)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.fromScale(1, 0.54)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextWrapped = true
	titleLabel.TextScaled = true
	titleLabel.TextColor3 = textColor
	titleLabel.Text = title

	local subtitleLabel = createInstance("TextLabel", "Subtitle", surfaceGui)
	subtitleLabel.BackgroundTransparency = 1
	subtitleLabel.Position = UDim2.fromScale(0.04, 0.5)
	subtitleLabel.Size = UDim2.fromScale(0.92, 0.42)
	subtitleLabel.Font = Enum.Font.Gotham
	subtitleLabel.TextWrapped = true
	subtitleLabel.TextScaled = true
	subtitleLabel.TextColor3 = textColor
	subtitleLabel.Text = subtitle

	return surfaceGui
end

local function createBillboardText(part, title, subtitle, textColor, options)
	options = options or {}

	local billboard = createInstance("BillboardGui", "BillboardText", part)
	billboard.Size = options.Size or UDim2.fromOffset(150, 44)
	billboard.StudsOffset = options.StudsOffset or Vector3.new(0, 3.25, 0)
	billboard.AlwaysOnTop = options.AlwaysOnTop or false
	billboard.MaxDistance = options.MaxDistance or 80

	local titleLabel = createInstance("TextLabel", "Title", billboard)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = subtitle and subtitle ~= "" and UDim2.fromScale(1, 0.58) or UDim2.fromScale(1, 1)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextWrapped = true
	titleLabel.TextScaled = false
	titleLabel.TextSize = options.TitleTextSize or 16
	titleLabel.TextColor3 = textColor
	titleLabel.TextStrokeTransparency = 0.65
	titleLabel.Text = title

	local subtitleLabel = createInstance("TextLabel", "Subtitle", billboard)
	subtitleLabel.BackgroundTransparency = 1
	subtitleLabel.Position = UDim2.fromScale(0, 0.56)
	subtitleLabel.Size = UDim2.fromScale(1, 0.34)
	subtitleLabel.Font = Enum.Font.Gotham
	subtitleLabel.TextWrapped = true
	subtitleLabel.TextScaled = false
	subtitleLabel.TextSize = options.SubtitleTextSize or 11
	subtitleLabel.TextColor3 = textColor
	subtitleLabel.TextStrokeTransparency = 0.75
	subtitleLabel.Visible = subtitle ~= nil and subtitle ~= ""
	subtitleLabel.Text = subtitle or ""

	return billboard
end

local function createSpawn(spawnFolder, name, position, color)
	local spawn = createInstance("SpawnLocation", name, spawnFolder)
	spawn.Anchored = true
	spawn.Size = Vector3.new(10, 1, 10)
	spawn.Position = position
	spawn.Color = color
	spawn.Material = Enum.Material.Neon
	spawn.Neutral = true
	spawn.Transparency = 0.1
	return spawn
end

local function createSign(signFolder, name, position, title, subtitle, color, accent, size)
	size = size or Vector3.new(14, 10, 1)

	local sign = createPart(name, signFolder, {
		Size = size,
		Position = position,
		Color = color,
		Material = Enum.Material.SmoothPlastic,
	})

	createPart(name .. "Frame", signFolder, {
		Size = size + Vector3.new(1, 1, -0.3),
		Position = position + Vector3.new(0, 0, 0.75),
		Color = accent,
		Material = Enum.Material.Metal,
	})

	createSurfaceText(sign, Enum.NormalId.Front, title, subtitle, accent)

	return sign
end

local function getZoneConfig(zoneId)
	return zoneLookup[zoneId]
end

local function hasOpenSide(roomConfig, side)
	for _, openSide in ipairs(roomConfig.OpenSides or {}) do
		if openSide == side then
			return true
		end
	end

	return false
end

local function worldPosition(venueConfig, offset)
	return venueConfig.Position + offset
end

local function createNavigationPad(parent, name, position, color, label, options)
	options = options or {}

	local pad = createPart(name, parent, {
		Size = options.PadSize or Vector3.new(14, 1, 14),
		Position = position,
		Color = color,
		Material = options.PadMaterial or Enum.Material.Neon,
		Transparency = options.PadTransparency or 0,
		CanCollide = true,
	})

	local markerOffset = options.MarkerOffset or Vector3.new(0, 5, -7)
	local marker = createPart(name .. "Marker", parent, {
		Size = options.MarkerSize or Vector3.new(10, 8, 1),
		Position = position + markerOffset,
		Color = options.MarkerColor or Color3.fromRGB(25, 25, 25),
		Material = options.MarkerMaterial or Enum.Material.SmoothPlastic,
		CanCollide = true,
	})

	createSurfaceText(marker, Enum.NormalId.Front, label, options.Subtitle or "Teleport", color)

	return pad
end

local function createPathMarker(parent, name, position, color, label)
	local marker = createPart(name, parent, {
		Size = Vector3.new(12, 0.6, 8),
		Position = position,
		Color = color,
		Material = Enum.Material.Neon,
		CanCollide = true,
	})

	createSurfaceText(marker, Enum.NormalId.Top, label, ">>", Color3.fromRGB(28, 28, 28))

	return marker
end

local function createRoad(roadsFolder, roadConfig)
	local direction = roadConfig.EndPosition - roadConfig.StartPosition
	local center = roadConfig.StartPosition:Lerp(roadConfig.EndPosition, 0.5)
	local length = direction.Magnitude

	if length <= 0 then
		return
	end

	local roadPart = createPart(roadConfig.Name, roadsFolder, {
		Size = Vector3.new(roadConfig.Width, roadConfig.Height, length),
		Color = roadConfig.Color,
		Material = roadConfig.Material,
		CFrame = CFrame.lookAt(center, roadConfig.EndPosition),
		CanCollide = true,
	})

	createPart(roadConfig.Name .. "Stripe", roadsFolder, {
		Size = Vector3.new(math.max(roadConfig.Width * 0.1, 1), 0.2, math.max(length - 8, 8)),
		Color = Color3.fromRGB(255, 221, 124),
		Material = Enum.Material.Neon,
		CFrame = roadPart.CFrame + Vector3.new(0, (roadConfig.Height / 2) + 0.1, 0),
		CanCollide = false,
	})
end

local function createZonePlatform(zoneFolder, zoneConfig)
	createPart("ZonePlatform", zoneFolder, {
		Size = zoneConfig.Size,
		Position = zoneConfig.Position + Vector3.new(0, 1, 0),
		Color = zoneConfig.Color,
		Material = Enum.Material.Concrete,
		CanCollide = true,
	})

	createPart("ZoneBorder", zoneFolder, {
		Size = Vector3.new(zoneConfig.Size.X + 6, 1, zoneConfig.Size.Z + 6),
		Position = zoneConfig.Position + Vector3.new(0, 0.55, 0),
		Color = zoneConfig.Accent,
		Material = Enum.Material.Metal,
		CanCollide = true,
	})
end

local function createZoneArrival(zoneFolder, zoneConfig)
	local arrivalPad = createNavigationPad(zoneFolder, zoneConfig.Name .. "ArrivalPad", zoneConfig.Position + zoneConfig.ArrivalOffset, zoneConfig.Accent, zoneConfig.Name)

	if zoneConfig.ZoneType == "Active" then
		InteractionService.registerPrompt(arrivalPad, {
			ActionType = "TeleportVenue",
			ActionText = "Enter",
			ObjectText = zoneConfig.Name,
			VenueId = zoneConfig.TeleportDestinationId or zoneConfig.Id,
			CooldownKey = "ZoneArrival:" .. zoneConfig.Id,
		})
	else
		InteractionService.registerPrompt(arrivalPad, {
			ActionType = "Notify",
			ActionText = "Preview",
			ObjectText = zoneConfig.Name,
			Message = zoneConfig.FutureExpansionText,
			CooldownKey = "ZoneArrival:" .. zoneConfig.Id,
		})
	end
end

local function createZoneMarker(zoneFolder, zoneConfig)
	local marker = createPart("ExpansionMarker", zoneFolder, {
		Size = Vector3.new(8, 18, 8),
		Position = zoneConfig.Position + Vector3.new(0, 9, zoneConfig.Size.Z / 2 - 24),
		Color = zoneConfig.Accent,
		Material = Enum.Material.Neon,
		CanCollide = true,
	})

	local markerTitle = zoneConfig.ZoneType == "Active" and (zoneConfig.ShortLabel or zoneConfig.Name) or "Future"
	local markerSubtitle = zoneConfig.ZoneType == "Active" and "" or (zoneConfig.ShortLabel or "Future")

	createBillboardText(marker, markerTitle, markerSubtitle, zoneConfig.Accent, {
		Size = UDim2.fromOffset(120, 34),
		StudsOffset = Vector3.new(0, 2.5, 0),
		MaxDistance = zoneConfig.ZoneType == "Active" and 55 or 45,
		TitleTextSize = 14,
		SubtitleTextSize = 10,
	})

	InteractionService.registerPrompt(marker, {
		ActionType = "Notify",
		ActionText = "Inspect",
		ObjectText = zoneConfig.Name,
		Message = zoneConfig.FutureExpansionText,
		CooldownKey = "ZoneMarker:" .. zoneConfig.Id,
	})
end

local function createZoneSigns(zoneFolder, zoneConfig)
	createSign(
		zoneFolder,
		"ZoneSign",
		zoneConfig.Position + Vector3.new(0, 18, -zoneConfig.Size.Z / 2 + 8),
		zoneConfig.LargeSignTitle,
		zoneConfig.LargeSignSubtitle,
		zoneConfig.Color,
		zoneConfig.Accent,
		Vector3.new(24, 12, 1)
	)

	createSign(
		zoneFolder,
		"ZoneDebugSign",
		zoneConfig.Position + Vector3.new(zoneConfig.Size.X / 2 - 18, 10, zoneConfig.Size.Z / 2 - 12),
		zoneConfig.Name,
		string.format("%s | %s | %s", zoneConfig.BuildPhase, zoneConfig.Status, zoneConfig.Category),
		Color3.fromRGB(28, 28, 28),
		zoneConfig.Accent,
		Vector3.new(18, 10, 1)
	)
end

local function buildZone(zoneFolder, zoneConfig)
	createZonePlatform(zoneFolder, zoneConfig)
	createZoneArrival(zoneFolder, zoneConfig)
	createZoneMarker(zoneFolder, zoneConfig)
	createZoneSigns(zoneFolder, zoneConfig)
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
		CanCollide = true,
	})

	createPart("Roof", shellFolder, {
		Size = Vector3.new(footprint.X, 2, footprint.Z),
		Position = Vector3.new(position.X, roofY, position.Z),
		Color = venueConfig.Accent,
		Material = Enum.Material.Metal,
		Transparency = venueConfig.RoofTransparency or 0.08,
		CanCollide = true,
	})

	createPart("BackWall", shellFolder, {
		Size = Vector3.new(footprint.X, footprint.Y, 2),
		Position = Vector3.new(position.X, wallY, position.Z + footprint.Z / 2),
		Color = venueConfig.Accent,
		Material = Enum.Material.Concrete,
		CanCollide = true,
	})

	createPart("LeftWall", shellFolder, {
		Size = Vector3.new(2, footprint.Y, footprint.Z),
		Position = Vector3.new(position.X - footprint.X / 2, wallY, position.Z),
		Color = venueConfig.Accent,
		Material = Enum.Material.Concrete,
		CanCollide = true,
	})

	createPart("RightWall", shellFolder, {
		Size = Vector3.new(2, footprint.Y, footprint.Z),
		Position = Vector3.new(position.X + footprint.X / 2, wallY, position.Z),
		Color = venueConfig.Accent,
		Material = Enum.Material.Concrete,
		CanCollide = true,
	})

	local doorWidth = 14
	local frontSegmentWidth = (footprint.X - doorWidth) / 2

	createPart("FrontWallLeft", shellFolder, {
		Size = Vector3.new(frontSegmentWidth, footprint.Y, 2),
		Position = Vector3.new(position.X - (doorWidth / 2 + frontSegmentWidth / 2), wallY, position.Z - footprint.Z / 2),
		Color = venueConfig.Accent,
		Material = Enum.Material.Concrete,
		CanCollide = true,
	})

	createPart("FrontWallRight", shellFolder, {
		Size = Vector3.new(frontSegmentWidth, footprint.Y, 2),
		Position = Vector3.new(position.X + (doorWidth / 2 + frontSegmentWidth / 2), wallY, position.Z - footprint.Z / 2),
		Color = venueConfig.Accent,
		Material = Enum.Material.Concrete,
		CanCollide = true,
	})

	local doorwayRoot = createFolder("Doors", venueFolder)

	createPart("LeftDoorFrame", doorwayRoot, {
		Size = Vector3.new(18, 18, 4),
		Position = position + Vector3.new(-16, 9, -footprint.Z / 2),
		Color = venueConfig.Accent,
		Material = Enum.Material.Metal,
		CanCollide = true,
	})

	createPart("RightDoorFrame", doorwayRoot, {
		Size = Vector3.new(18, 18, 4),
		Position = position + Vector3.new(16, 9, -footprint.Z / 2),
		Color = venueConfig.Accent,
		Material = Enum.Material.Metal,
		CanCollide = true,
	})

	createPart("DoorLintel", doorwayRoot, {
		Size = Vector3.new(doorWidth, 4, 4),
		Position = position + Vector3.new(0, 16, -footprint.Z / 2),
		Color = venueConfig.Accent,
		Material = Enum.Material.Metal,
		CanCollide = true,
	})

	local door = createPart("MainDoor", doorwayRoot, {
		Size = Vector3.new(doorWidth, 12, 2),
		Position = position + Vector3.new(0, 6, -footprint.Z / 2),
		Color = venueConfig.Color,
		Material = Enum.Material.Glass,
		Transparency = 0.2,
		CanCollide = true,
	})

	InteractionService.registerPrompt(door, {
		ActionType = "Door",
		ActionText = "Open",
		ObjectText = venueConfig.Name,
		Target = door,
		ClosedCFrame = door.CFrame,
		OpenOffset = Vector3.new(0, 12, 0),
		CooldownKey = "Door:" .. venueConfig.Id,
	})
end

local function createRoomPart(name, parent, size, position, color, material)
	return createPart(name, parent, {
		Size = size,
		Position = position,
		Color = color,
		Material = material,
		CanCollide = true,
	})
end

local function createRoom(roomsFolder, venueConfig, roomConfig)
	local roomFolder = createFolder(roomConfig.Name, roomsFolder)
	local center = worldPosition(venueConfig, roomConfig.Offset)
	local roomColor = roomConfig.FloorColor or venueConfig.Color:Lerp(Color3.new(1, 1, 1), 0.18)
	local wallColor = roomConfig.WallColor or venueConfig.Accent
	local wallHeight = roomConfig.WallHeight or 16
	local wallThickness = roomConfig.WallThickness or 1
	local floorY = venueConfig.Position.Y + 1.15

	createRoomPart("Floor", roomFolder, Vector3.new(roomConfig.Size.X, 0.3, roomConfig.Size.Z), Vector3.new(center.X, floorY, center.Z), roomColor, roomConfig.FloorMaterial)

	local walls = {
		North = {
			Size = Vector3.new(roomConfig.Size.X, wallHeight, wallThickness),
			Position = Vector3.new(center.X, venueConfig.Position.Y + wallHeight / 2, center.Z - roomConfig.Size.Z / 2),
		},
		South = {
			Size = Vector3.new(roomConfig.Size.X, wallHeight, wallThickness),
			Position = Vector3.new(center.X, venueConfig.Position.Y + wallHeight / 2, center.Z + roomConfig.Size.Z / 2),
		},
		West = {
			Size = Vector3.new(wallThickness, wallHeight, roomConfig.Size.Z),
			Position = Vector3.new(center.X - roomConfig.Size.X / 2, venueConfig.Position.Y + wallHeight / 2, center.Z),
		},
		East = {
			Size = Vector3.new(wallThickness, wallHeight, roomConfig.Size.Z),
			Position = Vector3.new(center.X + roomConfig.Size.X / 2, venueConfig.Position.Y + wallHeight / 2, center.Z),
		},
	}

	for side, wallData in pairs(walls) do
		if not hasOpenSide(roomConfig, side) then
			createRoomPart(side .. "Wall", roomFolder, wallData.Size, wallData.Position, wallColor, Enum.Material.SmoothPlastic)
		end
	end

	local labelPart = createPart("RoomLabel", roomFolder, {
		Size = roomConfig.LabelSize or Vector3.new(math.min(roomConfig.Size.X * 0.6, 16), 4, 1),
		Position = roomConfig.LabelOffset and (center + roomConfig.LabelOffset)
			or Vector3.new(center.X, venueConfig.Position.Y + wallHeight - 2, center.Z - roomConfig.Size.Z / 2 + 0.8),
		Color = wallColor,
		Material = Enum.Material.SmoothPlastic,
		CanCollide = false,
	})
	createSurfaceText(labelPart, roomConfig.LabelFace or Enum.NormalId.Front, roomConfig.Label, venueConfig.Name, venueConfig.Color)
end

local function createStandardProp(propsFolder, venueConfig, propConfig)
	local propPart = createPart(propConfig.Name, propsFolder, {
		ClassName = propConfig.ClassName,
		Size = propConfig.Size,
		Position = worldPosition(venueConfig, propConfig.Offset),
		Color = propConfig.Color or venueConfig.Accent,
		Material = propConfig.Material,
		Shape = propConfig.Shape,
		Transparency = propConfig.Transparency,
		CanCollide = true,
	})

	if not propConfig.HideBillboard then
		createBillboardText(propPart, propConfig.Label or propConfig.Name, propConfig.Kind, venueConfig.Accent)
	end
	return propPart
end

local function createPoolPlaceholder(propsFolder, venueConfig, propConfig)
	local poolFolder = createFolder(propConfig.Name, propsFolder)
	local center = worldPosition(venueConfig, propConfig.Offset)
	local poolSize = propConfig.Size

	createPart("PoolShell", poolFolder, {
		Size = poolSize,
		Position = center,
		Color = propConfig.Accent or venueConfig.Accent,
		Material = Enum.Material.Concrete,
		CanCollide = true,
	})

	createPart("PoolWater", poolFolder, {
		Size = Vector3.new(poolSize.X - 2, math.max(poolSize.Y - 2, 1), poolSize.Z - 2),
		Position = center + Vector3.new(0, math.max(poolSize.Y * 0.35, 1), 0),
		Color = propConfig.Color or Color3.fromRGB(74, 142, 196),
		Material = Enum.Material.Glass,
		Transparency = 0.25,
		CanCollide = true,
	})

	local labelAnchor = createPart("PoolLabel", poolFolder, {
		Size = Vector3.new(6, 1, 6),
		Position = center + Vector3.new(0, poolSize.Y + 2, 0),
		Color = propConfig.Accent or venueConfig.Accent,
		Material = Enum.Material.Neon,
		CanCollide = false,
	})
	createBillboardText(labelAnchor, propConfig.Label or propConfig.Name, propConfig.Subtitle or "Pool", venueConfig.Accent, {
		MaxDistance = 60,
		Size = UDim2.fromOffset(145, 40),
		StudsOffset = Vector3.new(0, 2.75, 0),
	})
end

local function createHotTubPlaceholder(propsFolder, venueConfig, propConfig)
	local hotTubFolder = createFolder(propConfig.Name, propsFolder)
	local center = worldPosition(venueConfig, propConfig.Offset)
	local hotTubSize = propConfig.Size

	createPart("TubShell", hotTubFolder, {
		Size = hotTubSize,
		Position = center,
		Color = propConfig.Accent or venueConfig.Accent,
		Material = Enum.Material.Metal,
		CanCollide = true,
	})

	createPart("TubWater", hotTubFolder, {
		Size = Vector3.new(hotTubSize.X - 2, math.max(hotTubSize.Y - 2, 1), hotTubSize.Z - 2),
		Position = center + Vector3.new(0, math.max(hotTubSize.Y * 0.35, 1), 0),
		Color = propConfig.Color or Color3.fromRGB(114, 170, 214),
		Material = Enum.Material.Glass,
		Transparency = 0.2,
		CanCollide = true,
	})

	local labelAnchor = createPart("TubLabel", hotTubFolder, {
		Size = Vector3.new(4, 1, 4),
		Position = center + Vector3.new(0, hotTubSize.Y + 2, 0),
		Color = propConfig.Accent or venueConfig.Accent,
		Material = Enum.Material.Neon,
		CanCollide = false,
	})
	createBillboardText(labelAnchor, propConfig.Label or propConfig.Name, propConfig.Subtitle or "Spa", venueConfig.Accent, {
		MaxDistance = 60,
		Size = UDim2.fromOffset(145, 40),
		StudsOffset = Vector3.new(0, 2.75, 0),
	})
end

local function createSlidePlaceholder(propsFolder, venueConfig, propConfig)
	local slideFolder = createFolder(propConfig.Name, propsFolder)
	local center = worldPosition(venueConfig, propConfig.Offset)
	local slideSize = propConfig.Size

	createPart("SlidePlatform", slideFolder, {
		Size = Vector3.new(6, 1, 6),
		Position = center + Vector3.new(-slideSize.X / 4, slideSize.Y, 0),
		Color = propConfig.Accent or venueConfig.Accent,
		Material = Enum.Material.Metal,
		CanCollide = true,
	})

	createPart("SlideRamp", slideFolder, {
		ClassName = "WedgePart",
		Size = Vector3.new(slideSize.X, slideSize.Y, slideSize.Z),
		Position = center + Vector3.new(0, slideSize.Y / 2, 0),
		Color = propConfig.Color or venueConfig.Color,
		Material = Enum.Material.SmoothPlastic,
		CFrame = CFrame.new(center + Vector3.new(0, slideSize.Y / 2, 0)) * CFrame.Angles(0, math.rad(90), 0),
		CanCollide = true,
	})

	local labelAnchor = createPart("SlideLabel", slideFolder, {
		Size = Vector3.new(4, 1, 4),
		Position = center + Vector3.new(0, slideSize.Y + 3, 0),
		Color = propConfig.Accent or venueConfig.Accent,
		Material = Enum.Material.Neon,
		CanCollide = false,
	})
	createBillboardText(labelAnchor, propConfig.Label or propConfig.Name, "Placeholder", venueConfig.Accent)
end

local function createArcadeCabinetProp(propsFolder, venueConfig, propConfig)
	local folder = createFolder(propConfig.Name, propsFolder)
	local center = worldPosition(venueConfig, propConfig.Offset)
	local s = propConfig.Size
	local color = propConfig.Color or venueConfig.Accent
	local accent = propConfig.Accent or Color3.fromRGB(255, 255, 255)

	createPart("CabinetBody", folder, {
		Size = Vector3.new(s.X, s.Y * 0.76, s.Z),
		Position = center + Vector3.new(0, -(s.Y * 0.12), 0),
		Color = color,
		Material = Enum.Material.SmoothPlastic,
		CanCollide = true,
	})
	createPart("Marquee", folder, {
		Size = Vector3.new(s.X + 0.4, s.Y * 0.24, s.Z * 0.5),
		Position = center + Vector3.new(0, s.Y * 0.38, -(s.Z * 0.25)),
		Color = accent,
		Material = Enum.Material.Neon,
		CanCollide = true,
	})
	createPart("Screen", folder, {
		Size = Vector3.new(s.X * 0.72, s.Y * 0.38, 0.2),
		Position = center + Vector3.new(0, -(s.Y * 0.06), -(s.Z / 2 + 0.1)),
		Color = Color3.fromRGB(80, 220, 255),
		Material = Enum.Material.Neon,
		Transparency = 0.08,
		CanCollide = false,
	})
	createPart("LeftTrim", folder, {
		Size = Vector3.new(0.25, s.Y, 0.25),
		Position = center + Vector3.new(-(s.X / 2), 0, -(s.Z / 2)),
		Color = accent,
		Material = Enum.Material.Neon,
		CanCollide = false,
	})
	createPart("RightTrim", folder, {
		Size = Vector3.new(0.25, s.Y, 0.25),
		Position = center + Vector3.new(s.X / 2, 0, -(s.Z / 2)),
		Color = accent,
		Material = Enum.Material.Neon,
		CanCollide = false,
	})
	local labelAnchor = createPart("Label", folder, {
		Size = Vector3.new(3, 0.5, 3),
		Position = center + Vector3.new(0, s.Y / 2 + 2.5, 0),
		Color = accent,
		Material = Enum.Material.Neon,
		CanCollide = false,
	})
	createBillboardText(labelAnchor, propConfig.Label or propConfig.Name, propConfig.Kind, venueConfig.Accent)
end

local function createCinemaScreenProp(propsFolder, venueConfig, propConfig)
	local folder = createFolder(propConfig.Name, propsFolder)
	local center = worldPosition(venueConfig, propConfig.Offset)
	local s = propConfig.Size
	local color = propConfig.Color or venueConfig.Color
	local accent = propConfig.Accent or venueConfig.Accent

	createPart("ScreenSurface", folder, {
		Size = Vector3.new(s.X, s.Y, 0.3),
		Position = center,
		Color = Color3.fromRGB(238, 238, 238),
		Material = Enum.Material.SmoothPlastic,
		CanCollide = true,
	})
	createPart("ScreenFrame", folder, {
		Size = Vector3.new(s.X + 1.2, s.Y + 1.2, 0.2),
		Position = center + Vector3.new(0, 0, 0.26),
		Color = Color3.fromRGB(18, 18, 18),
		Material = Enum.Material.Metal,
		CanCollide = true,
	})
	createPart("LeftCurtain", folder, {
		Size = Vector3.new(2.5, s.Y + 4, 2),
		Position = center + Vector3.new(-(s.X / 2 + 2), 0.5, 0.4),
		Color = color,
		Material = Enum.Material.Fabric,
		CanCollide = true,
	})
	createPart("RightCurtain", folder, {
		Size = Vector3.new(2.5, s.Y + 4, 2),
		Position = center + Vector3.new(s.X / 2 + 2, 0.5, 0.4),
		Color = color,
		Material = Enum.Material.Fabric,
		CanCollide = true,
	})
	createPart("Pelmet", folder, {
		Size = Vector3.new(s.X + 7, 1.5, 2),
		Position = center + Vector3.new(0, s.Y / 2 + 1.25, 0.4),
		Color = accent,
		Material = Enum.Material.Metal,
		CanCollide = true,
	})
	local labelAnchor = createPart("Label", folder, {
		Size = Vector3.new(3, 0.5, 3),
		Position = center + Vector3.new(0, s.Y / 2 + 4, 0),
		Color = accent,
		Material = Enum.Material.Neon,
		CanCollide = false,
	})
	createBillboardText(labelAnchor, propConfig.Label or propConfig.Name, propConfig.Kind, venueConfig.Accent)
end

local function createPoolChairProp(propsFolder, venueConfig, propConfig)
	local folder = createFolder(propConfig.Name, propsFolder)
	local center = worldPosition(venueConfig, propConfig.Offset)
	local s = propConfig.Size
	local color = propConfig.Color or venueConfig.Accent
	local accent = propConfig.Accent or venueConfig.Accent

	createPart("Seat", folder, {
		Size = Vector3.new(s.X * 0.62, s.Y * 0.28, s.Z),
		Position = center + Vector3.new(-(s.X * 0.19), 0, 0),
		Color = color,
		Material = Enum.Material.Fabric,
		CanCollide = true,
	})
	createPart("BackRest", folder, {
		Size = Vector3.new(s.X * 0.38, s.Y, s.Z),
		Color = color,
		Material = Enum.Material.Fabric,
		CFrame = CFrame.new(center + Vector3.new(s.X * 0.31, 0, 0)) * CFrame.Angles(0, 0, math.rad(28)),
		CanCollide = true,
	})
	createPart("Towel", folder, {
		Size = Vector3.new(s.X * 0.5, 0.18, s.Z * 0.82),
		Position = center + Vector3.new(-(s.X * 0.15), s.Y * 0.15, 0),
		Color = accent,
		Material = Enum.Material.SmoothPlastic,
		CanCollide = false,
	})
	local labelAnchor = createPart("Label", folder, {
		Size = Vector3.new(2, 0.5, 2),
		Position = center + Vector3.new(0, s.Y / 2 + 2.5, 0),
		Color = accent,
		Material = Enum.Material.Neon,
		CanCollide = false,
	})

	if not propConfig.HideBillboard then
		createBillboardText(labelAnchor, propConfig.Label or propConfig.Name, propConfig.Kind, venueConfig.Accent)
	end
end

local function createVIPDisplayProp(propsFolder, venueConfig, propConfig)
	local folder = createFolder(propConfig.Name, propsFolder)
	local center = worldPosition(venueConfig, propConfig.Offset)
	local s = propConfig.Size
	local color = propConfig.Color or venueConfig.Accent
	local accent = propConfig.Accent or venueConfig.Accent

	local mainPanel = createPart(propConfig.Name, folder, {
		Size = Vector3.new(s.X, s.Y, 0.4),
		Position = center,
		Color = color,
		Material = Enum.Material.Neon,
		Transparency = 0.08,
		CanCollide = true,
	})
	createPart("Frame", folder, {
		Size = Vector3.new(s.X + 1.5, s.Y + 1.5, 0.2),
		Position = center + Vector3.new(0, 0, 0.31),
		Color = accent,
		Material = Enum.Material.Metal,
		CanCollide = true,
	})
	createPart("LeftColumn", folder, {
		Size = Vector3.new(2, s.Y + 6, 2),
		Position = center + Vector3.new(-(s.X / 2 + 2), 1, 0),
		Color = accent,
		Material = Enum.Material.Neon,
		CanCollide = true,
	})
	createPart("RightColumn", folder, {
		Size = Vector3.new(2, s.Y + 6, 2),
		Position = center + Vector3.new(s.X / 2 + 2, 1, 0),
		Color = accent,
		Material = Enum.Material.Neon,
		CanCollide = true,
	})
	createPart("Crown", folder, {
		Size = Vector3.new(s.X + 7, 2, 2),
		Position = center + Vector3.new(0, s.Y / 2 + 2, 0),
		Color = accent,
		Material = Enum.Material.Metal,
		CanCollide = true,
	})
	createPart("LeftStar", folder, {
		Size = Vector3.new(3.5, 3.5, 3.5),
		Shape = Enum.PartType.Ball,
		Position = center + Vector3.new(-(s.X / 2 + 2), s.Y / 2 + 5, 0),
		Color = accent,
		Material = Enum.Material.Neon,
		CanCollide = false,
	})
	createPart("RightStar", folder, {
		Size = Vector3.new(3.5, 3.5, 3.5),
		Shape = Enum.PartType.Ball,
		Position = center + Vector3.new(s.X / 2 + 2, s.Y / 2 + 5, 0),
		Color = accent,
		Material = Enum.Material.Neon,
		CanCollide = false,
	})
	createSurfaceText(mainPanel, Enum.NormalId.Front, "VIP", "Girls Only", accent)
	local labelAnchor = createPart("Label", folder, {
		Size = Vector3.new(3, 0.5, 3),
		Position = center + Vector3.new(0, s.Y / 2 + 5.5, 0),
		Color = accent,
		Material = Enum.Material.Neon,
		CanCollide = false,
	})
	createBillboardText(labelAnchor, propConfig.Label or "VIP Star Lounge", "VIP Only", venueConfig.Accent)
end

local function createProp(propsFolder, venueConfig, propConfig)
	if propConfig.Kind == "Pool" then
		createPoolPlaceholder(propsFolder, venueConfig, propConfig)
	elseif propConfig.Kind == "HotTub" then
		createHotTubPlaceholder(propsFolder, venueConfig, propConfig)
	elseif propConfig.Kind == "Slide" then
		createSlidePlaceholder(propsFolder, venueConfig, propConfig)
	elseif propConfig.Kind == "ArcadeCabinet" then
		createArcadeCabinetProp(propsFolder, venueConfig, propConfig)
	elseif propConfig.Kind == "CinemaScreen" then
		createCinemaScreenProp(propsFolder, venueConfig, propConfig)
	elseif propConfig.Kind == "PoolChair" then
		createPoolChairProp(propsFolder, venueConfig, propConfig)
	elseif propConfig.Kind == "VIPDisplay" then
		createVIPDisplayProp(propsFolder, venueConfig, propConfig)
	else
		createStandardProp(propsFolder, venueConfig, propConfig)
	end
end

local function getPropInteractionDefinition(venueConfig, propConfig)
	local function applyInteractionOverrides(definition)
		if propConfig.ActionType then
			definition.ActionType = propConfig.ActionType
		end

		if propConfig.ActionText then
			definition.ActionText = propConfig.ActionText
		end

		if propConfig.ObjectText then
			definition.ObjectText = propConfig.ObjectText
		end

		if propConfig.Message then
			definition.Message = propConfig.Message
		end

		if propConfig.RoleRequired then
			definition.RoleRequired = propConfig.RoleRequired
		end

		return definition
	end

	if propConfig.Kind == "Display" then
		local actionType = "Notify"
		local message = "Viewing " .. (propConfig.Label or propConfig.Name)
		local roleRequired

		if string.find(propConfig.Name, "Founder") then
			actionType = "FounderAction"
			message = "Opened founder display placeholder."
			roleRequired = "Founder"
		end

		return applyInteractionOverrides({
			ActionType = actionType,
			ActionText = "Open",
			ObjectText = propConfig.Label or propConfig.Name,
			Message = message,
			RoleRequired = roleRequired,
			CooldownKey = "Prop:" .. venueConfig.Id .. ":" .. propConfig.Name,
		})
	end

	if propConfig.Kind == "CommandCenter" then
		return applyInteractionOverrides({
			ActionType = "FounderAction",
			ActionText = "Access",
			ObjectText = propConfig.Label or propConfig.Name,
			Message = "AI command center placeholder opened.",
			RoleRequired = "Founder",
			CooldownKey = "Prop:" .. venueConfig.Id .. ":" .. propConfig.Name,
		})
	end

	if propConfig.Kind == "Arcade" or propConfig.Kind == "GamingStation" then
		return applyInteractionOverrides({
			ActionType = "Notify",
			ActionText = "Inspect",
			ObjectText = propConfig.Label or propConfig.Name,
			Message = "Interaction placeholder: " .. (propConfig.Label or propConfig.Name),
			CooldownKey = "Prop:" .. venueConfig.Id .. ":" .. propConfig.Name,
		})
	end

	if propConfig.Kind == "VIPDisplay" then
		return applyInteractionOverrides({
			ActionType = "Notify",
			ActionText = "Enter",
			ObjectText = propConfig.Label or propConfig.Name,
			Message = propConfig.Message or "Welcome to the VIP area!",
			RoleRequired = "VIP",
			CooldownKey = "Prop:" .. venueConfig.Id .. ":" .. propConfig.Name,
		})
	end

	return nil
end

local function createVehicle(vehiclesFolder, vehicleConfig)
	local folder = createFolder(vehicleConfig.Id, vehiclesFolder)
	local pos = vehicleConfig.Position
	local c = vehicleConfig.Color
	local accent = vehicleConfig.Accent or c
	local vt = vehicleConfig.VehicleType

	local bodyW, bodyH, bodyL = 9, 5, 16
	local roofW, roofH, roofL = 8, 2.5, 9
	local hasRoof = true
	if vt == "Jeep" then
		bodyW, bodyH, bodyL = 8, 4.5, 14
		hasRoof = false
	elseif vt == "LuxurySUV" then
		bodyW, bodyH, bodyL = 10, 5, 20
		roofW, roofH, roofL = 9, 2, 11
	end

	-- All vehicles face +Z (Heading=0), so front = +Z face, rear = -Z face.
	-- pos.Y is the floor reference (Y=2); body bottom sits at pos.Y.
	local bY = pos.Y + bodyH / 2

	local body = createPart("Body", folder, {
		Size = Vector3.new(bodyW, bodyH, bodyL),
		Position = Vector3.new(pos.X, bY, pos.Z),
		Color = c,
		Material = Enum.Material.SmoothPlastic,
		Anchored = true,
		CanCollide = false,
	})

	if hasRoof then
		createPart("Roof", folder, {
			Size = Vector3.new(roofW, roofH, roofL),
			Position = Vector3.new(pos.X, pos.Y + bodyH + roofH / 2, pos.Z - bodyL / 2 + roofL / 2 + 1),
			Color = c,
			Material = Enum.Material.SmoothPlastic,
			Anchored = true,
			CanCollide = false,
		})
	end

	-- Neon headlights on front face (+Z)
	createPart("HeadlightL", folder, {
		Size = Vector3.new(2.5, 1.5, 0.4),
		Position = Vector3.new(pos.X - bodyW / 2 + 1.8, bY + bodyH / 2 - 1.5, pos.Z + bodyL / 2),
		Color = Color3.fromRGB(255, 252, 220),
		Material = Enum.Material.Neon,
		Anchored = true,
		CanCollide = false,
	})
	createPart("HeadlightR", folder, {
		Size = Vector3.new(2.5, 1.5, 0.4),
		Position = Vector3.new(pos.X + bodyW / 2 - 1.8, bY + bodyH / 2 - 1.5, pos.Z + bodyL / 2),
		Color = Color3.fromRGB(255, 252, 220),
		Material = Enum.Material.Neon,
		Anchored = true,
		CanCollide = false,
	})

	-- Neon taillights on rear face (-Z)
	createPart("TaillightL", folder, {
		Size = Vector3.new(2.5, 1.5, 0.4),
		Position = Vector3.new(pos.X - bodyW / 2 + 1.8, bY + bodyH / 2 - 1.5, pos.Z - bodyL / 2),
		Color = Color3.fromRGB(220, 30, 30),
		Material = Enum.Material.Neon,
		Anchored = true,
		CanCollide = false,
	})
	createPart("TaillightR", folder, {
		Size = Vector3.new(2.5, 1.5, 0.4),
		Position = Vector3.new(pos.X + bodyW / 2 - 1.8, bY + bodyH / 2 - 1.5, pos.Z - bodyL / 2),
		Color = Color3.fromRGB(220, 30, 30),
		Material = Enum.Material.Neon,
		Anchored = true,
		CanCollide = false,
	})

	-- License plate on front face
	local plate = createPart("LicensePlate", folder, {
		Size = Vector3.new(5, 1.5, 0.4),
		Position = Vector3.new(pos.X, pos.Y + 2, pos.Z + bodyL / 2),
		Color = Color3.fromRGB(245, 245, 245),
		Material = Enum.Material.SmoothPlastic,
		Anchored = true,
		CanCollide = false,
	})
	createBillboardText(plate, vehicleConfig.PlateText, "", Color3.fromRGB(20, 20, 20), {
		AlwaysOnTop = false,
		MaxDistance = 30,
		Size = UDim2.fromOffset(110, 24),
		StudsOffset = Vector3.new(0, 0, 0),
	})

	-- Floating owner label above vehicle
	local labelY = pos.Y + bodyH + (hasRoof and roofH or 0) + 3
	local labelAnchor = createPart("OwnerAnchor", folder, {
		Size = Vector3.new(1, 0.2, 1),
		Position = Vector3.new(pos.X, labelY, pos.Z),
		Color = accent,
		Material = Enum.Material.Neon,
		Transparency = 1,
		Anchored = true,
		CanCollide = false,
	})
	createBillboardText(labelAnchor, vehicleConfig.PlateText, vehicleConfig.Owner or vehicleConfig.Name, Color3.fromRGB(255, 255, 255), {
		AlwaysOnTop = false,
		MaxDistance = 60,
		Size = UDim2.fromOffset(160, 44),
		StudsOffset = Vector3.new(0, 2, 0),
	})

	InteractionService.registerPrompt(body, {
		ActionType = "Notify",
		ActionText = "Inspect",
		ObjectText = vehicleConfig.Name,
		Message = vehicleConfig.Owner
			and (vehicleConfig.Owner .. "'s " .. vehicleConfig.Name .. " — Plate: " .. vehicleConfig.PlateText)
			or vehicleConfig.Name,
		CooldownKey = "Vehicle:" .. vehicleConfig.Id,
	})
end

local function createVenueSigns(signFolder, venueConfig)
	local shellSignPosition = Vector3.new(venueConfig.Position.X, venueConfig.Position.Y + venueConfig.Footprint.Y + 8, venueConfig.Position.Z - venueConfig.Footprint.Z / 2 + 2)
	createSign(signFolder, "VenueSign", shellSignPosition, venueConfig.Name, venueConfig.Theme, venueConfig.Color, venueConfig.Accent, Vector3.new(18, 10, 1))

	for index, signConfig in ipairs(venueConfig.Signs or {}) do
		createSign(
			signFolder,
			"ConfiguredSign" .. tostring(index),
			worldPosition(venueConfig, signConfig.Offset),
			signConfig.Title,
			signConfig.Subtitle,
			signConfig.Color or venueConfig.Color,
			signConfig.Accent or venueConfig.Accent,
			signConfig.Size
		)
	end
end

local function createFounderHubMonument(plazaFolder)
	local founderAnchor = createPart("FounderMonument", plazaFolder, {
		Size = Vector3.new(18, 10, 2),
		Position = Vector3.new(0, 6, -18),
		Color = Color3.fromRGB(28, 28, 28),
		Material = Enum.Material.SmoothPlastic,
		CanCollide = true,
	})

	createSurfaceText(founderAnchor, Enum.NormalId.Front, "Founder", WorldConfig.VIP.FounderUsername, Color3.fromRGB(255, 201, 68))
	InteractionService.registerPrompt(founderAnchor, {
		ActionType = "FounderAction",
		ActionText = "Open",
		ObjectText = "Founder Display",
		Message = "Founder monument placeholder opened.",
		RoleRequired = "Founder",
		CooldownKey = "FounderMonument",
	})
end

local function createHubDirectionalSigns(plazaFolder)
	for _, zoneConfig in ipairs(WorldConfig.Zones or {}) do
		createSign(
			plazaFolder,
			zoneConfig.Id .. "DirectionSign",
			WorldConfig.Hub.Position + zoneConfig.HubSignOffset + Vector3.new(0, 10, 0),
			zoneConfig.ShortLabel or zoneConfig.Name,
			string.format("%s | %s", zoneConfig.ZoneType == "Active" and "Travel" or "Future", zoneConfig.Status),
			Color3.fromRGB(32, 32, 32),
			zoneConfig.Accent,
			Vector3.new(16, 9, 1)
		)
	end
end

local function createTeleportHubBoard(plazaFolder)
	local activeZones = {}
	local futureZones = {}

	for _, zoneConfig in ipairs(WorldConfig.Zones or {}) do
		if zoneConfig.ZoneType == "Active" then
			table.insert(activeZones, zoneConfig.HubBoardLabel or zoneConfig.Name)
		else
			table.insert(futureZones, zoneConfig.HubBoardLabel or zoneConfig.Name)
		end
	end

	createSign(
		plazaFolder,
		"ActiveTeleportHubBoard",
		WorldConfig.Hub.Position + WorldConfig.Hub.ActiveBoardOffset,
		"Active Teleports",
		table.concat(activeZones, "\n"),
		Color3.fromRGB(24, 28, 36),
		Color3.fromRGB(255, 201, 68),
		WorldConfig.Hub.ActiveBoardSize
	)

	createSign(
		plazaFolder,
		"FutureTeleportHubBoard",
		WorldConfig.Hub.Position + WorldConfig.Hub.FutureBoardOffset,
		"Future Zones",
		table.concat(futureZones, "\n"),
		Color3.fromRGB(34, 34, 34),
		Color3.fromRGB(196, 196, 196),
		WorldConfig.Hub.FutureBoardSize
	)
end

local function createHubTeleportPads(navigationFolder)
	for _, zoneConfig in ipairs(WorldConfig.Zones or {}) do
		local padOffset = zoneConfig.HubPadOffset
		if padOffset then
			local padPosition = WorldConfig.Hub.Position + Vector3.new(padOffset.X, 2.5, padOffset.Z)

			if zoneConfig.ZoneType == "Active" then
				local venueConfig = venueLookup[zoneConfig.Id]
				local padColor = (venueConfig and venueConfig.Accent) or zoneConfig.Accent
				local hubPad = createNavigationPad(
					navigationFolder,
					zoneConfig.Name .. "TeleportPad",
					padPosition,
					padColor,
					zoneConfig.ShortLabel or zoneConfig.Name,
					{
						Subtitle = "Teleport",
					}
				)

				InteractionService.registerPrompt(hubPad, {
					ActionType = "TeleportVenue",
					ActionText = "Teleport",
					ObjectText = zoneConfig.Name,
					VenueId = zoneConfig.TeleportDestinationId or zoneConfig.Id,
					CooldownKey = "TeleportVenue:" .. zoneConfig.Id,
				})
			else
				local futurePad = createNavigationPad(
					navigationFolder,
					zoneConfig.Name .. "FutureMarker",
					padPosition,
					Color3.fromRGB(132, 132, 132),
					zoneConfig.ShortLabel or zoneConfig.Name,
					{
						Subtitle = "Future",
						PadSize = Vector3.new(10, 0.8, 10),
						PadMaterial = Enum.Material.SmoothPlastic,
						PadTransparency = 0.15,
						MarkerSize = Vector3.new(9, 6, 1),
						MarkerOffset = Vector3.new(0, 4, -5),
						MarkerColor = Color3.fromRGB(48, 48, 48),
					}
				)

				InteractionService.registerPrompt(futurePad, {
					ActionType = "Notify",
					ActionText = "Preview",
					ObjectText = zoneConfig.Name,
					Message = zoneConfig.FutureExpansionText,
					CooldownKey = "FutureZone:" .. zoneConfig.Id,
				})
			end
		end
	end
end

local function createPlazaPathMarkers(navigationFolder)
	for _, zoneConfig in ipairs(WorldConfig.Zones or {}) do
		if zoneConfig.ZoneType == "Active" and zoneConfig.PathStartOffset and zoneConfig.PathEndOffset then
			local markerCount = math.max(zoneConfig.PathMarkerCount or 4, 2)

			for index = 1, markerCount do
				local alpha = index / markerCount
				local pathOffset = zoneConfig.PathStartOffset:Lerp(zoneConfig.PathEndOffset, alpha)
				createPathMarker(
					navigationFolder,
					string.format("%sPathMarker%d", zoneConfig.Id, index),
					WorldConfig.Hub.Position + Vector3.new(pathOffset.X, 0.45, pathOffset.Z),
					zoneConfig.PathColor or zoneConfig.Accent,
					zoneConfig.ShortLabel or zoneConfig.Name
				)
			end
		end
	end
end

local function buildFounderPlaza(plazaFolder, navigationFolder, spawnFolder)
	local hub = WorldConfig.Hub

	createPart("PlazaFloor", plazaFolder, {
		Size = hub.Size,
		Position = hub.Position + Vector3.new(0, 1, 0),
		Color = Color3.fromRGB(212, 212, 212),
		Material = Enum.Material.Concrete,
		CanCollide = true,
	})

	createPart("PlazaCenterRing", plazaFolder, {
		Size = Vector3.new(72, 1.2, 72),
		Position = hub.Position + Vector3.new(0, 1.1, 0),
		Color = Color3.fromRGB(255, 201, 68),
		Material = Enum.Material.Neon,
		CanCollide = true,
	})

	createPart("PlazaSpawnZone", plazaFolder, {
		Size = Vector3.new(42, 1.2, 42),
		Position = hub.SpawnPosition - Vector3.new(0, 2, 0),
		Color = Color3.fromRGB(255, 239, 179),
		Material = Enum.Material.Neon,
		Transparency = 0.18,
		CanCollide = true,
	})

	createSign(
		navigationFolder,
		"HubWelcomeSign",
		hub.Position + hub.WelcomeSignOffset,
		hub.SignText,
		"Central spawn, travel hub, and expansion gateway",
		Color3.fromRGB(35, 35, 35),
		Color3.fromRGB(255, 255, 255),
		Vector3.new(34, 14, 1)
	)

	createSpawn(spawnFolder, "CentralSpawn", hub.SpawnPosition, Color3.fromRGB(255, 201, 68))
	createFounderHubMonument(plazaFolder)
	createTeleportHubBoard(navigationFolder)
	createHubTeleportPads(navigationFolder)
	createPlazaPathMarkers(navigationFolder)
	createHubDirectionalSigns(navigationFolder)
end

local function buildVenue(venueFolder, venueConfig, spawnFolder, teleportFolder, mediaFolder, navigationFolder)
	createVenueShell(venueFolder, venueConfig)

	local roomsFolder = createFolder("Rooms", venueFolder)
	local propsFolder = createFolder("Props", venueFolder)
	local signsFolder = createFolder("Signs", venueFolder)

	for _, roomConfig in ipairs(venueConfig.Rooms or {}) do
		createRoom(roomsFolder, venueConfig, roomConfig)
	end

	for _, propConfig in ipairs(venueConfig.Props or {}) do
		createProp(propsFolder, venueConfig, propConfig)
	end

	for _, propInstance in ipairs(propsFolder:GetDescendants()) do
		if propInstance:IsA("BasePart") then
			local matchedConfig

			for _, propConfig in ipairs(venueConfig.Props or {}) do
				if propConfig.Name == propInstance.Name then
					matchedConfig = propConfig
					break
				end
			end

			if matchedConfig then
				local interactionDefinition = getPropInteractionDefinition(venueConfig, matchedConfig)
				if interactionDefinition then
					InteractionService.registerPrompt(propInstance, interactionDefinition)
				end
			end
		end
	end

	createVenueSigns(signsFolder, venueConfig)

	local spawnOffset = venueConfig.SpawnOffset or Vector3.new(0, 3, -22)
	local spawnPosition = venueConfig.Position + spawnOffset
	createSpawn(spawnFolder, venueConfig.Name .. " Spawn", spawnPosition, venueConfig.Accent)
	TeleportService.registerVenueTarget(venueConfig.Id, CFrame.new(spawnPosition), venueConfig.Name)

	local returnPadOffset = venueConfig.ReturnPadOffset or Vector3.new(0, 2.5, venueConfig.Footprint.Z / 2 - 14)
	local arrivalPad = createNavigationPad(
		teleportFolder,
		venueConfig.Name .. " ReturnPad",
		venueConfig.Position + returnPadOffset,
		venueConfig.Accent,
		"Return to Plaza",
		venueConfig.ReturnPadOptions
	)
	InteractionService.registerPrompt(arrivalPad, {
		ActionType = "TeleportHub",
		ActionText = "Teleport",
		ObjectText = "Founder's Plaza",
		CooldownKey = "TeleportHub:" .. venueConfig.Id,
	})

	local builtPanels = MediaFramework.build(mediaFolder, venueConfig)

	for _, builtPanel in ipairs(builtPanels) do
		local mediaType = builtPanel.Config.MediaType
		local actionText = "View"
		local objectText = builtPanel.Config.Title

		if mediaType == "Spotify" then
			actionText = "Open"
			objectText = "Spotify Station"
		elseif mediaType == "Twitch" then
			actionText = "Watch"
			objectText = "Twitch Wall"
		elseif mediaType == "YouTube" then
			actionText = "View"
			objectText = "YouTube Showcase"
		elseif mediaType == "Photo" then
			actionText = "View"
			objectText = "Slideshow"
		end

		InteractionService.registerPrompt(builtPanel.Screen, {
			ActionType = "Media",
			ActionText = actionText,
			ObjectText = objectText,
			Message = "Interaction placeholder: " .. builtPanel.Config.Title,
			CooldownKey = "Media:" .. venueConfig.Id .. ":" .. builtPanel.Config.Name,
		})
	end
end

local function createWorldFolders()
	local existing = Workspace:FindFirstChild("FoundersWorld")
	if existing then
		existing:Destroy()
	end

	local root = createFolder("FoundersWorld", Workspace)
	local mapFolder = createFolder("Map", root)
	local plazaFolder = createFolder("Plaza", mapFolder)
	local zonesFolder = createFolder("Zones", mapFolder)
	local venuesFolder = createFolder("Venues", mapFolder)
	local roadsFolder = createFolder("Roads", mapFolder)
	local navigationFolder = createFolder("Navigation", mapFolder)
	local spawnsFolder = createFolder("Spawns", mapFolder)
	local mediaFolder = createFolder("Media", mapFolder)
	local teleportFolder = createFolder("Teleports", mapFolder)
	local environmentFolder = createFolder("Environment", mapFolder)
	local vehiclesFolder = createFolder("Vehicles", mapFolder)

	return {
		Map = mapFolder,
		Plaza = plazaFolder,
		Zones = zonesFolder,
		Venues = venuesFolder,
		Roads = roadsFolder,
		Navigation = navigationFolder,
		Spawns = spawnsFolder,
		Media = mediaFolder,
		Teleports = teleportFolder,
		Environment = environmentFolder,
		Vehicles = vehiclesFolder,
	}
end

local function createAmbientSound()
	local sound = SoundService:FindFirstChild("PrototypeAmbient")
	if sound then
		sound:Destroy()
	end

	sound = createInstance("Sound", "PrototypeAmbient", SoundService)
	sound.Looped = true
	sound.Volume = 0
end

function WorldBuilderService.build()
	local folders = createWorldFolders()

	createAmbientSound()
	buildFounderPlaza(folders.Plaza, folders.Navigation, folders.Spawns)

	for _, roadConfig in ipairs(WorldConfig.Roads or {}) do
		createRoad(folders.Roads, roadConfig)
	end

	for _, zoneConfig in ipairs(WorldConfig.Zones or {}) do
		local zoneFolder = createFolder(zoneConfig.Name, folders.Zones)
		buildZone(zoneFolder, zoneConfig)
	end

	TeleportService.setHubTarget(CFrame.new(WorldConfig.Hub.SpawnPosition))

	for _, venueConfig in ipairs(WorldConfig.Venues or {}) do
		local venueFolder = createFolder(venueConfig.Name, folders.Venues)
		buildVenue(venueFolder, venueConfig, folders.Spawns, folders.Teleports, folders.Media, folders.Navigation)
	end

	for _, vehicleConfig in ipairs(WorldConfig.Vehicles or {}) do
		createVehicle(folders.Vehicles, vehicleConfig)
	end
end

return WorldBuilderService
