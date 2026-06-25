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

local function createPlateText(parent, face, text, textColor)
	local surfaceGui = createInstance("SurfaceGui", "PlateText", parent)
	surfaceGui.Face = face
	surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surfaceGui.PixelsPerStud = 60

	local padding = createInstance("UIPadding", "Padding", surfaceGui)
	padding.PaddingLeft = UDim.new(0, 6)
	padding.PaddingRight = UDim.new(0, 6)
	padding.PaddingTop = UDim.new(0, 3)
	padding.PaddingBottom = UDim.new(0, 3)

	local plateLabel = createInstance("TextLabel", "Text", surfaceGui)
	plateLabel.BackgroundTransparency = 1
	plateLabel.Size = UDim2.fromScale(1, 1)
	plateLabel.Font = Enum.Font.GothamBold
	plateLabel.TextXAlignment = Enum.TextXAlignment.Center
	plateLabel.TextYAlignment = Enum.TextYAlignment.Center
	plateLabel.TextScaled = false
	plateLabel.TextSize = #text > 9 and 13 or (#text > 6 and 16 or 19)
	plateLabel.TextColor3 = textColor
	plateLabel.TextStrokeTransparency = 0.85
	plateLabel.Text = text

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

local function createSafetyGround(environmentFolder)
	local safetyFolder = createFolder("SafetyGround", environmentFolder)

	local function createGroundPad(name, size, position, color, material, transparency)
		return createPart(name, safetyFolder, {
			Size = size,
			Position = position,
			Color = color,
			Material = material,
			Transparency = transparency,
			CanCollide = true,
		})
	end

	local hub = WorldConfig.Hub
	createGroundPad(
		"HubSafetyApron",
		Vector3.new(hub.Size.X + 90, 2, hub.Size.Z + 90),
		hub.Position + Vector3.new(0, -1, 0),
		Color3.fromRGB(78, 90, 76),
		Enum.Material.Grass,
		0
	)

	local vehicleMinX, vehicleMaxX = math.huge, -math.huge
	local vehicleMinZ, vehicleMaxZ = math.huge, -math.huge
	local vehicleCount = 0

	for _, vehicleConfig in ipairs(WorldConfig.Vehicles or {}) do
		vehicleMinX = math.min(vehicleMinX, vehicleConfig.Position.X)
		vehicleMaxX = math.max(vehicleMaxX, vehicleConfig.Position.X)
		vehicleMinZ = math.min(vehicleMinZ, vehicleConfig.Position.Z)
		vehicleMaxZ = math.max(vehicleMaxZ, vehicleConfig.Position.Z)
		vehicleCount += 1
	end

	if vehicleCount > 0 then
		local lotCenter = Vector3.new((vehicleMinX + vehicleMaxX) / 2, -0.95, (vehicleMinZ + vehicleMaxZ) / 2)
		local lotSize = Vector3.new((vehicleMaxX - vehicleMinX) + 42, 1.9, (vehicleMaxZ - vehicleMinZ) + 28)
		createGroundPad("VehicleLotSafety", lotSize, lotCenter, Color3.fromRGB(62, 62, 68), Enum.Material.Slate, 0)
	end

	for _, zoneConfig in ipairs(WorldConfig.Zones or {}) do
		if zoneConfig.ZoneType == "Active" then
			createGroundPad(
				zoneConfig.Id .. "SafetyApron",
				Vector3.new(zoneConfig.Size.X + 22, 1.6, zoneConfig.Size.Z + 22),
				zoneConfig.Position + Vector3.new(0, -0.8, 0),
				Color3.fromRGB(82, 96, 80),
				Enum.Material.Grass,
				0
			)
		end
	end

	for _, roadConfig in ipairs(WorldConfig.Roads or {}) do
		local direction = roadConfig.EndPosition - roadConfig.StartPosition
		local length = direction.Magnitude

		if length > 0 then
			local shoulderCenter = roadConfig.StartPosition:Lerp(roadConfig.EndPosition, 0.5)
			local shoulder = createGroundPad(
				roadConfig.Name .. "SafetyFill",
				Vector3.new(roadConfig.Width + 28, 1.2, length + 18),
				shoulderCenter + Vector3.new(0, -0.6, 0),
				Color3.fromRGB(72, 82, 74),
				Enum.Material.Grass,
				0
			)
			shoulder.CFrame = CFrame.lookAt(shoulderCenter + Vector3.new(0, -0.6, 0), roadConfig.EndPosition + Vector3.new(0, -0.6, 0))
		end
	end
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
	local color = propConfig.Color or venueConfig.Color
	local accent = propConfig.Accent or venueConfig.Accent

	-- Top platform
	createPart("SlidePlatform", slideFolder, {
		Size = Vector3.new(7, 1, 7),
		Position = center + Vector3.new(-slideSize.X / 4, slideSize.Y, 0),
		Color = accent,
		Material = Enum.Material.Metal,
		CanCollide = true,
	})

	-- Platform safety railing (back + one side)
	createPart("PlatformRailBack", slideFolder, {
		Size = Vector3.new(7, 3, 0.4),
		Position = center + Vector3.new(-slideSize.X / 4, slideSize.Y + 2, -3.5),
		Color = Color3.fromRGB(195, 210, 220),
		Material = Enum.Material.Metal,
		CanCollide = false,
	})
	createPart("PlatformRailSide", slideFolder, {
		Size = Vector3.new(0.4, 3, 7),
		Position = center + Vector3.new(-slideSize.X / 4 - 3.5, slideSize.Y + 2, 0),
		Color = Color3.fromRGB(195, 210, 220),
		Material = Enum.Material.Metal,
		CanCollide = false,
	})

	-- Slide ramp (WedgePart rotated so slope runs along X)
	createPart("SlideRamp", slideFolder, {
		ClassName = "WedgePart",
		Size = Vector3.new(slideSize.X, slideSize.Y, slideSize.Z),
		Position = center + Vector3.new(0, slideSize.Y / 2, 0),
		Color = color,
		Material = Enum.Material.SmoothPlastic,
		CFrame = CFrame.new(center + Vector3.new(0, slideSize.Y / 2, 0)) * CFrame.Angles(0, math.rad(90), 0),
		CanCollide = true,
	})

	-- Support column under the platform
	createPart("SlideColumn", slideFolder, {
		Size = Vector3.new(2, slideSize.Y, 2),
		Position = center + Vector3.new(-slideSize.X / 4, slideSize.Y / 2, 0),
		Color = Color3.fromRGB(170, 185, 198),
		Material = Enum.Material.Metal,
		CanCollide = true,
	})

	-- Ladder rungs (4 evenly spaced up the column)
	for r = 1, 4 do
		createPart("LadderRung" .. r, slideFolder, {
			Size = Vector3.new(3.5, 0.4, 0.4),
			Position = Vector3.new(
				center.X - slideSize.X / 4,
				center.Y + slideSize.Y * (r / 5),
				center.Z - 1.2
			),
			Color = Color3.fromRGB(155, 175, 190),
			Material = Enum.Material.Metal,
			CanCollide = true,
		})
	end

	-- Splash pool at the landing zone (opposite side from platform)
	createPart("SplashPool", slideFolder, {
		Size = Vector3.new(slideSize.Z + 4, 2, 8),
		Position = center + Vector3.new(slideSize.X * 0.44, 1, 0),
		Color = Color3.fromRGB(60, 170, 230),
		Material = Enum.Material.Glass,
		Transparency = 0.3,
		CanCollide = true,
	})
	createPart("SplashFoam", slideFolder, {
		Size = Vector3.new(slideSize.Z + 4, 0.3, 8.2),
		Position = center + Vector3.new(slideSize.X * 0.44, 2.2, 0),
		Color = Color3.fromRGB(200, 238, 255),
		Material = Enum.Material.Neon,
		Transparency = 0.18,
		CanCollide = false,
	})

	local labelAnchor = createPart("SlideLabel", slideFolder, {
		Size = Vector3.new(4, 1, 4),
		Position = center + Vector3.new(0, slideSize.Y + 4, 0),
		Color = accent,
		Material = Enum.Material.Neon,
		CanCollide = false,
	})
	createBillboardText(labelAnchor, propConfig.Label or propConfig.Name, "Water Slide", venueConfig.Accent)
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

local function createConfettiEmitter(propsFolder, venueConfig, propConfig)
	local emitter = createPart(propConfig.Name, propsFolder, {
		Size = propConfig.Size,
		Position = worldPosition(venueConfig, propConfig.Offset),
		Color = propConfig.Color or venueConfig.Accent,
		Material = Enum.Material.SmoothPlastic,
		Transparency = 1,
		CanCollide = false,
	})

	local colors = propConfig.Colors or {
		Color3.fromRGB(255, 100, 180),
		Color3.fromRGB(255, 235, 60),
		Color3.fromRGB(80, 185, 255),
		Color3.fromRGB(180, 80, 255),
		Color3.fromRGB(80, 230, 200),
	}

	local particle = createInstance("ParticleEmitter", "Confetti", emitter)
	particle.Rate = propConfig.Rate or 15
	particle.Lifetime = NumberRange.new(2, 5)
	particle.Speed = NumberRange.new(1, 5)
	particle.SpreadAngle = Vector2.new(180, 180)
	particle.RotSpeed = NumberRange.new(-45, 45)
	particle.Rotation = NumberRange.new(0, 360)
	particle.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.35),
		NumberSequenceKeypoint.new(1, 0.08),
	})
	particle.LightEmission = 0.8
	particle.LightInfluence = 0.2
	particle.Acceleration = Vector3.new(0, -20, 0)
	particle.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, colors[1]),
		ColorSequenceKeypoint.new(0.25, colors[2]),
		ColorSequenceKeypoint.new(0.5, colors[3]),
		ColorSequenceKeypoint.new(0.75, colors[4]),
		ColorSequenceKeypoint.new(1, colors[5] or colors[1]),
	})
end

local function createProp(propsFolder, venueConfig, propConfig)
	if propConfig.Kind == "Confetti" then
		createConfettiEmitter(propsFolder, venueConfig, propConfig)
	elseif propConfig.Kind == "Pool" then
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

		if propConfig.VenueId then
			definition.VenueId = propConfig.VenueId
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
	local c = vehicleConfig.Color
	local accent = vehicleConfig.Accent or c
	local trim = vehicleConfig.TrimColor or Color3.fromRGB(200, 200, 200)
	local vt = vehicleConfig.VehicleType
	local vehicleProfiles = {
		Bronco = {
			bodyW = 9.6,
			bodyL = 16.8,
			chassisH = 2.6,
			hoodH = 2.2,
			cabinH = 3.2,
			rearH = 2.4,
			hoodL = 5.2,
			cabinL = 6.2,
			rearL = 5.0,
			roofW = 8.4,
			roofH = 1.1,
			roofL = 7.2,
			wheelR = 2.0,
			wheelThickness = 1.75,
			hasRoof = true,
			cabinOffsetZ = -0.8,
		},
		Jeep = {
			bodyW = 8.4,
			bodyL = 14.8,
			chassisH = 2.3,
			hoodH = 1.9,
			cabinH = 2.7,
			rearH = 2.0,
			hoodL = 4.4,
			cabinL = 5.0,
			rearL = 4.2,
			roofW = 7.2,
			roofH = 0.7,
			roofL = 5.0,
			wheelR = 1.8,
			wheelThickness = 1.55,
			hasRoof = false,
			cabinOffsetZ = -0.4,
		},
		PinkJeep = "Jeep",
		LuxurySUV = {
			bodyW = 10.6,
			bodyL = 20.5,
			chassisH = 2.8,
			hoodH = 2.0,
			cabinH = 3.3,
			rearH = 2.5,
			hoodL = 6.2,
			cabinL = 8.2,
			rearL = 6.1,
			roofW = 9.4,
			roofH = 1.2,
			roofL = 10.4,
			wheelR = 2.1,
			wheelThickness = 1.8,
			hasRoof = true,
			cabinOffsetZ = -1.2,
		},
		Yukon = "LuxurySUV",
		GolfCart = {
			bodyW = 7.8,
			bodyL = 12.2,
			chassisH = 2.0,
			hoodH = 1.3,
			cabinH = 2.0,
			rearH = 1.7,
			hoodL = 3.0,
			cabinL = 4.5,
			rearL = 3.8,
			roofW = 7.2,
			roofH = 0.7,
			roofL = 6.0,
			wheelR = 1.45,
			wheelThickness = 1.2,
			hasRoof = true,
			cabinOffsetZ = -0.2,
		},
		GoKart = {
			bodyW = 6.6,
			bodyL = 10.8,
			chassisH = 1.3,
			hoodH = 0.9,
			cabinH = 1.1,
			rearH = 1.0,
			hoodL = 2.3,
			cabinL = 3.6,
			rearL = 2.9,
			roofW = 0,
			roofH = 0,
			roofL = 0,
			wheelR = 1.25,
			wheelThickness = 1.05,
			hasRoof = false,
			cabinOffsetZ = -0.1,
		},
		Buggy = {
			bodyW = 8.2,
			bodyL = 13.4,
			chassisH = 1.9,
			hoodH = 1.6,
			cabinH = 2.0,
			rearH = 1.8,
			hoodL = 3.8,
			cabinL = 4.8,
			rearL = 3.8,
			roofW = 6.8,
			roofH = 0.8,
			roofL = 4.4,
			wheelR = 1.7,
			wheelThickness = 1.45,
			hasRoof = false,
			cabinOffsetZ = -0.2,
		},
	}

	local profile = vehicleProfiles[vt] or vehicleProfiles.Bronco
	if type(profile) == "string" then
		profile = vehicleProfiles[profile]
	end

	local bodyLocalY = profile.wheelR + profile.chassisH / 2

	local model = Instance.new("Model")
	model.Name = vehicleConfig.Id

	local function makePart(name, lx, ly, lz, sx, sy, sz, color, material, transparency)
		local part = Instance.new("Part")
		part.Name = name
		part.Size = Vector3.new(sx, sy, sz)
		part.Color = color
		part.Material = material or Enum.Material.SmoothPlastic
		part.Anchored = true
		part.CanCollide = false
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		if transparency then part.Transparency = transparency end
		part.CFrame = CFrame.new(lx, ly, lz)
		part.Parent = model
		return part
	end

	local function makeCFramePart(name, cframe, size, color, material, transparency)
		local part = Instance.new("Part")
		part.Name = name
		part.Size = size
		part.Color = color
		part.Material = material or Enum.Material.SmoothPlastic
		part.Anchored = true
		part.CanCollide = false
		part.TopSurface = Enum.SurfaceType.Smooth
		part.BottomSurface = Enum.SurfaceType.Smooth
		if transparency then
			part.Transparency = transparency
		end
		part.CFrame = cframe
		part.Parent = model
		return part
	end

	local function makeWheel(name, lx, lz)
		local ly = profile.wheelR
		local tire = Instance.new("Part")
		tire.Name = name
		tire.Shape = Enum.PartType.Cylinder
		tire.Size = Vector3.new(profile.wheelThickness, profile.wheelR * 2, profile.wheelR * 2)
		tire.Color = Color3.fromRGB(22, 22, 22)
		tire.Material = Enum.Material.SmoothPlastic
		tire.Anchored = true
		tire.CanCollide = false
		tire.TopSurface = Enum.SurfaceType.Smooth
		tire.BottomSurface = Enum.SurfaceType.Smooth
		tire.CFrame = CFrame.new(lx, ly, lz)
		tire.Parent = model

		local sidewall = Instance.new("Part")
		sidewall.Name = name .. "Sidewall"
		sidewall.Shape = Enum.PartType.Cylinder
		sidewall.Size = Vector3.new(profile.wheelThickness * 0.7, profile.wheelR * 1.7, profile.wheelR * 1.7)
		sidewall.Color = Color3.fromRGB(42, 42, 42)
		sidewall.Material = Enum.Material.SmoothPlastic
		sidewall.Anchored = true
		sidewall.CanCollide = false
		sidewall.TopSurface = Enum.SurfaceType.Smooth
		sidewall.BottomSurface = Enum.SurfaceType.Smooth
		sidewall.CFrame = CFrame.new(lx, ly, lz)
		sidewall.Parent = model

		local hub = Instance.new("Part")
		hub.Name = name .. "Hub"
		hub.Shape = Enum.PartType.Cylinder
		hub.Size = Vector3.new(profile.wheelThickness * 0.45, profile.wheelR * 0.95, profile.wheelR * 0.95)
		hub.Color = trim
		hub.Material = Enum.Material.Metal
		hub.Anchored = true
		hub.CanCollide = false
		hub.TopSurface = Enum.SurfaceType.Smooth
		hub.BottomSurface = Enum.SurfaceType.Smooth
		hub.CFrame = CFrame.new(lx, ly, lz)
		hub.Parent = model
	end

	local hoodCenterZ = profile.bodyL / 2 - profile.hoodL / 2 - 0.6
	local cabinCenterZ = profile.cabinOffsetZ
	local rearCenterZ = -profile.bodyL / 2 + profile.rearL / 2 + 0.6

	local body = makePart("Body", 0, bodyLocalY, 0, profile.bodyW, profile.chassisH, profile.bodyL, c)
	local hood = makePart("Hood", 0, bodyLocalY + profile.chassisH / 2 + profile.hoodH / 2 - 0.2, hoodCenterZ, profile.bodyW - 0.5, profile.hoodH, profile.hoodL, c)
	local cabin = makePart("Cabin", 0, bodyLocalY + profile.chassisH / 2 + profile.cabinH / 2 - 0.1, cabinCenterZ, profile.bodyW - 1.0, profile.cabinH, profile.cabinL, c)
	local rearDeck = makePart("RearDeck", 0, bodyLocalY + profile.chassisH / 2 + profile.rearH / 2 - 0.2, rearCenterZ, profile.bodyW - 0.8, profile.rearH, profile.rearL, c)

	local fenderY = profile.wheelR + 0.55
	makePart("FrontFenderLeft", -(profile.bodyW / 2 - 0.5), fenderY, hoodCenterZ, 0.8, 1.8, profile.hoodL - 0.3, c)
	makePart("FrontFenderRight", profile.bodyW / 2 - 0.5, fenderY, hoodCenterZ, 0.8, 1.8, profile.hoodL - 0.3, c)
	makePart("RearFenderLeft", -(profile.bodyW / 2 - 0.5), fenderY, rearCenterZ, 0.8, 1.8, profile.rearL - 0.3, c)
	makePart("RearFenderRight", profile.bodyW / 2 - 0.5, fenderY, rearCenterZ, 0.8, 1.8, profile.rearL - 0.3, c)

	local roofTopY = bodyLocalY + profile.chassisH / 2 + profile.cabinH
	local roofCenterY = roofTopY + profile.roofH / 2
	if profile.hasRoof and profile.roofW > 0 then
		makePart("Roof", 0, roofCenterY, cabinCenterZ - 0.4, profile.roofW, profile.roofH, profile.roofL, c)
		makePart("WindowL", -(profile.bodyW / 2 - 0.12), bodyLocalY + profile.chassisH / 2 + profile.cabinH / 2, cabinCenterZ - 0.4, 0.18, profile.cabinH - 0.35, profile.cabinL - 0.8,
			Color3.fromRGB(155, 210, 240), Enum.Material.Glass, 0.3)
		makePart("WindowR", profile.bodyW / 2 - 0.12, bodyLocalY + profile.chassisH / 2 + profile.cabinH / 2, cabinCenterZ - 0.4, 0.18, profile.cabinH - 0.35, profile.cabinL - 0.8,
			Color3.fromRGB(155, 210, 240), Enum.Material.Glass, 0.3)
	elseif vt == "Jeep" or vt == "PinkJeep" or vt == "Buggy" then
		makePart("RollBarLeft", -(profile.bodyW / 2 - 0.5), roofTopY - 0.2, cabinCenterZ - 0.3, 0.35, profile.cabinH + 0.8, profile.cabinL - 0.7, trim, Enum.Material.Metal)
		makePart("RollBarRight", profile.bodyW / 2 - 0.5, roofTopY - 0.2, cabinCenterZ - 0.3, 0.35, profile.cabinH + 0.8, profile.cabinL - 0.7, trim, Enum.Material.Metal)
		makePart("RollBarTop", 0, roofTopY + profile.cabinH / 2 + 0.15, cabinCenterZ - 0.3, profile.bodyW - 1.0, 0.28, profile.cabinL - 0.9, trim, Enum.Material.Metal)
	end

	local windshieldTilt = math.rad(-28)
	local windshieldHeight = profile.cabinH + 0.2
	local windshieldZ = hoodCenterZ - profile.hoodL / 2 + 0.95
	local windshieldY = bodyLocalY + profile.chassisH / 2 + profile.cabinH * 0.74
	makeCFramePart(
		"Windshield",
		CFrame.new(0, windshieldY, windshieldZ) * CFrame.Angles(windshieldTilt, 0, 0),
		Vector3.new(profile.bodyW - 1.1, windshieldHeight, 0.18),
		Color3.fromRGB(155, 210, 240),
		Enum.Material.Glass,
		0.22
	)

	if profile.hasRoof then
		local rearWindowZ = rearCenterZ + profile.rearL / 2 - 0.8
		local rearWindowY = bodyLocalY + profile.chassisH / 2 + profile.cabinH * 0.72
		makeCFramePart(
			"RearWindow",
			CFrame.new(0, rearWindowY, rearWindowZ) * CFrame.Angles(math.rad(22), 0, 0),
			Vector3.new(profile.bodyW - 1.4, profile.cabinH, 0.16),
			Color3.fromRGB(155, 210, 240),
			Enum.Material.Glass,
			0.26
		)
	end

	local bumperY = profile.wheelR + 0.35
	makePart("FrontBumper", 0, bumperY, profile.bodyL / 2 + 0.45, profile.bodyW + 0.5, 0.85, 0.72, trim, Enum.Material.Metal)
	makePart("RearBumper", 0, bumperY, -profile.bodyL / 2 - 0.45, profile.bodyW + 0.5, 0.85, 0.72, trim, Enum.Material.Metal)
	makePart("FrontGrille", 0, bodyLocalY + profile.chassisH / 2 + 0.4, profile.bodyL / 2 - 0.22, profile.bodyW - 1.2, 1.6, 0.32, trim, Enum.Material.Metal)

	local lightY = bodyLocalY + profile.chassisH / 2 + 0.5
	makePart("HeadlightL", -profile.bodyW / 2 + 1.55, lightY, profile.bodyL / 2 + 0.05, 2.0, 1.0, 0.28, Color3.fromRGB(255, 252, 220), Enum.Material.Neon)
	makePart("HeadlightR", profile.bodyW / 2 - 1.55, lightY, profile.bodyL / 2 + 0.05, 2.0, 1.0, 0.28, Color3.fromRGB(255, 252, 220), Enum.Material.Neon)
	makePart("TaillightL", -profile.bodyW / 2 + 1.55, lightY, -profile.bodyL / 2 - 0.05, 2.0, 1.0, 0.28, Color3.fromRGB(220, 30, 30), Enum.Material.Neon)
	makePart("TaillightR", profile.bodyW / 2 - 1.55, lightY, -profile.bodyL / 2 - 0.05, 2.0, 1.0, 0.28, Color3.fromRGB(220, 30, 30), Enum.Material.Neon)

	local wfz = profile.bodyL / 2 - math.max(profile.hoodL * 0.58, 2.5)
	local wrz = -profile.bodyL / 2 + math.max(profile.rearL * 0.58, 2.4)
	local wx = profile.bodyW / 2 + profile.wheelThickness / 2 - 0.1
	makeWheel("WheelFL", -wx, wfz)
	makeWheel("WheelFR",  wx, wfz)
	makeWheel("WheelRL", -wx, wrz)
	makeWheel("WheelRR",  wx, wrz)

	local frontPlate = makePart("FrontPlate", 0, bumperY + 0.12, profile.bodyL / 2 + 0.82, 4.6, 1.35, 0.14, Color3.fromRGB(244, 242, 236))
	local rearPlate = makePart("RearPlate", 0, bumperY + 0.12, -profile.bodyL / 2 - 0.82, 4.6, 1.35, 0.14, Color3.fromRGB(244, 242, 236))
	createPlateText(frontPlate, Enum.NormalId.Front, vehicleConfig.PlateText, Color3.fromRGB(20, 20, 20))
	createPlateText(rearPlate, Enum.NormalId.Back, vehicleConfig.PlateText, Color3.fromRGB(20, 20, 20))

	local labelBaseY = profile.hasRoof and roofCenterY or (bodyLocalY + profile.chassisH / 2 + profile.cabinH)
	local topY = labelBaseY + 3
	local labelAnchor = makePart("OwnerAnchor", 0, topY, 0, 1, 0.2, 1, accent, Enum.Material.Neon, 1)
	createBillboardText(labelAnchor, vehicleConfig.PlateText, vehicleConfig.Owner or vehicleConfig.Name, Color3.fromRGB(255, 255, 255), {
		AlwaysOnTop = false,
		MaxDistance = 60,
		Size = UDim2.fromOffset(160, 44),
		StudsOffset = Vector3.new(0, 2, 0),
	})

	model.PrimaryPart = body
	model.Parent = vehiclesFolder
	-- Position.Y is floor surface; bodyLocalY offsets body centre above it
	model:PivotTo(CFrame.new(
		vehicleConfig.Position.X,
		vehicleConfig.Position.Y + bodyLocalY,
		vehicleConfig.Position.Z
	) * CFrame.Angles(0, math.rad(vehicleConfig.Heading or 0), 0))
	task.wait()

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

local function createPlazaFireworks(plazaFolder)
	local launchPositions = {
		Vector3.new(90, 3, -90),
		Vector3.new(-90, 3, -90),
		Vector3.new(90, 3, 90),
		Vector3.new(-90, 3, 90),
		Vector3.new(0, 3, -110),
		Vector3.new(0, 3, 110),
	}

	local colorSets = {
		{ Color3.fromRGB(255, 60, 60), Color3.fromRGB(255, 200, 30), Color3.fromRGB(255, 255, 120) },
		{ Color3.fromRGB(80, 160, 255), Color3.fromRGB(100, 220, 255), Color3.fromRGB(210, 245, 255) },
		{ Color3.fromRGB(255, 80, 200), Color3.fromRGB(255, 160, 240), Color3.fromRGB(255, 220, 255) },
		{ Color3.fromRGB(80, 255, 120), Color3.fromRGB(200, 255, 100), Color3.fromRGB(255, 255, 200) },
		{ Color3.fromRGB(200, 80, 255), Color3.fromRGB(255, 100, 200), Color3.fromRGB(255, 200, 255) },
		{ Color3.fromRGB(255, 200, 60), Color3.fromRGB(255, 130, 30), Color3.fromRGB(255, 60, 80) },
	}

	local rates = { 0.6, 0.85, 0.7, 0.95, 0.65, 0.8 }

	for i, launchPos in ipairs(launchPositions) do
		local colors = colorSets[i]

		local emitter = createPart("FireworkLauncher" .. i, plazaFolder, {
			Size = Vector3.new(1, 1, 1),
			Position = launchPos,
			Color = colors[1],
			Transparency = 1,
			CanCollide = false,
		})

		local particle = createInstance("ParticleEmitter", "FireworkBurst", emitter)
		particle.Rate = rates[i]
		particle.Lifetime = NumberRange.new(3, 4.5)
		particle.Speed = NumberRange.new(65, 105)
		particle.SpreadAngle = Vector2.new(14, 14)
		particle.RotSpeed = NumberRange.new(0, 60)
		particle.Rotation = NumberRange.new(0, 360)
		particle.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.18),
			NumberSequenceKeypoint.new(0.32, 2.8),
			NumberSequenceKeypoint.new(0.65, 3.6),
			NumberSequenceKeypoint.new(1, 0.08),
		})
		particle.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.28, 0),
			NumberSequenceKeypoint.new(0.75, 0.35),
			NumberSequenceKeypoint.new(1, 1),
		})
		particle.LightEmission = 1
		particle.LightInfluence = 0
		particle.Acceleration = Vector3.new(0, -40, 0)
		particle.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, colors[1]),
			ColorSequenceKeypoint.new(0.5, colors[2]),
			ColorSequenceKeypoint.new(1, colors[3]),
		})
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
	createPlazaFireworks(plazaFolder)
end

local function createVenueAmbientSound(venueFolder, venueConfig)
	if not venueConfig.AmbientSoundId or venueConfig.AmbientSoundId == 0 then
		return
	end

	local emitter = createPart(venueConfig.Name .. "SoundEmitter", venueFolder, {
		Size = Vector3.new(1, 1, 1),
		Position = venueConfig.Position + Vector3.new(0, 8, 0),
		Transparency = 1,
		CanCollide = false,
	})

	local sound = createInstance("Sound", "AmbientSound", emitter)
	sound.SoundId = "rbxassetid://" .. tostring(venueConfig.AmbientSoundId)
	sound.Looped = true
	sound.Volume = venueConfig.AmbientSoundVolume or 0.4
	sound.RollOffMaxDistance = math.max(venueConfig.Footprint.X, venueConfig.Footprint.Z) * 1.5
	sound.RollOffMinDistance = 10
	sound:Play()
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
	createPart(venueConfig.Name .. " ArrivalMarker", spawnFolder, {
		Size = Vector3.new(10, 0.5, 10),
		Position = spawnPosition + Vector3.new(0, -1.5, 0),
		Color = venueConfig.Accent,
		Material = Enum.Material.Neon,
		Transparency = 0.4,
		Anchored = true,
		CanCollide = false,
	})
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

	createVenueAmbientSound(venueFolder, venueConfig)

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

local function setupEnvironment()
	local Lighting = game:GetService("Lighting")
	Lighting.ClockTime = 18
	Lighting.Brightness = 1.4
	Lighting.ExposureCompensation = 0.15
	Lighting.Ambient = Color3.fromRGB(80, 60, 120)
	Lighting.OutdoorAmbient = Color3.fromRGB(100, 80, 140)

	local function ensureChild(className, name)
		local existing = Lighting:FindFirstChild(name)
		if existing then
			existing:Destroy()
		end
		local child = Instance.new(className)
		child.Name = name
		child.Parent = Lighting
		return child
	end

	local atm = ensureChild("Atmosphere", "WorldAtmosphere")
	atm.Density = 0.22
	atm.Offset = 0.2
	atm.Color = Color3.fromRGB(200, 175, 230)
	atm.Decay = Color3.fromRGB(80, 60, 120)
	atm.Glare = 0.2
	atm.Haze = 0.1

	local cc = ensureChild("ColorCorrectionEffect", "WorldColorCorrection")
	cc.Brightness = 0.04
	cc.Contrast = 0.08
	cc.Saturation = 0.25
	cc.TintColor = Color3.fromRGB(255, 245, 255)

	local bloom = ensureChild("BloomEffect", "WorldBloom")
	bloom.Intensity = 0.35
	bloom.Size = 20
	bloom.Threshold = 0.95
end

function WorldBuilderService.build()
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("SpawnLocation") then
			obj:Destroy()
		end
	end

	local folders = createWorldFolders()

	createAmbientSound()

	local envOk, envErr = pcall(setupEnvironment)
	if not envOk then
		warn("[FoundersWorld] setupEnvironment failed (non-fatal):", envErr)
	end

	createSafetyGround(folders.Environment)

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
		local venueOk, venueErr = pcall(buildVenue, venueFolder, venueConfig, folders.Spawns, folders.Teleports, folders.Media, folders.Navigation)
		if not venueOk then
			warn("[FoundersWorld] Venue build failed for", venueConfig.Id, ":", venueErr)
		end
	end

	for _, vehicleConfig in ipairs(WorldConfig.Vehicles or {}) do
		local ok, err = pcall(createVehicle, folders.Vehicles, vehicleConfig)
		if not ok then
			warn("[FoundersWorld] Vehicle build failed for", vehicleConfig.Id, ":", err)
		end
	end
end

return WorldBuilderService
