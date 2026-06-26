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

local function attachPointLight(part, lightConfig)
	if not lightConfig then
		return
	end

	local light = Instance.new("PointLight")
	light.Name = "PointLight"
	light.Color = lightConfig.Color or Color3.fromRGB(255, 244, 232)
	light.Range = lightConfig.Range or 12
	light.Brightness = lightConfig.Brightness or 1
	light.Shadows = lightConfig.Shadows or false
	light.Enabled = lightConfig.Enabled ~= false
	light.Parent = part
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
	spawn.CanCollide = false
	spawn.CanTouch = false
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
		CanCollide = options.PadCanCollide ~= false,
	})

	local markerOffset = options.MarkerOffset or Vector3.new(0, 5, -7)
	local marker = createPart(name .. "Marker", parent, {
		Size = options.MarkerSize or Vector3.new(10, 8, 1),
		Position = position + markerOffset,
		Color = options.MarkerColor or Color3.fromRGB(25, 25, 25),
		Material = options.MarkerMaterial or Enum.Material.SmoothPlastic,
		CanCollide = options.MarkerCanCollide ~= false,
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
	local landscapingFolder = createFolder("Landscaping", environmentFolder)

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

	local function createOrientedGroundPad(name, size, position, targetPosition, color, material, transparency)
		local pad = createGroundPad(name, size, position, color, material, transparency)
		pad.CFrame = CFrame.lookAt(position, targetPosition)
		return pad
	end

	local function createLandscapePart(name, size, position, color, material, transparency, shape)
		return createPart(name, landscapingFolder, {
			Size = size,
			Position = position,
			Color = color,
			Material = material,
			Transparency = transparency or 0,
			CanCollide = true,
			Shape = shape or Enum.PartType.Block,
		})
	end

	local function createTree(name, position, options)
		options = options or {}
		local trunkHeight = options.TrunkHeight or 14
		local canopySize = options.CanopySize or Vector3.new(14, 14, 14)
		createLandscapePart(
			name .. "Trunk",
			Vector3.new(2.2, trunkHeight, 2.2),
			position + Vector3.new(0, trunkHeight / 2, 0),
			options.TrunkColor or Color3.fromRGB(104, 78, 56),
			Enum.Material.WoodPlanks,
			0,
			Enum.PartType.Cylinder
		)
		createLandscapePart(
			name .. "Canopy",
			canopySize,
			position + Vector3.new(0, trunkHeight + canopySize.Y * 0.34, 0),
			options.CanopyColor or Color3.fromRGB(78, 120, 76),
			Enum.Material.Grass,
			0,
			Enum.PartType.Ball
		)
	end

	local function createShrub(name, position, size, color)
		createLandscapePart(name, size, position + Vector3.new(0, size.Y / 2, 0), color, Enum.Material.Grass, 0, Enum.PartType.Ball)
	end

	local function createRock(name, position, size, color)
		createLandscapePart(name, size, position + Vector3.new(0, size.Y / 2, 0), color, Enum.Material.Slate, 0, Enum.PartType.Ball)
	end

	local function createLightPost(name, position)
		createLandscapePart(name .. "Pole", Vector3.new(1.2, 14, 1.2), position + Vector3.new(0, 7, 0), Color3.fromRGB(76, 76, 82), Enum.Material.Metal)
		createLandscapePart(name .. "Lamp", Vector3.new(3, 2.4, 3), position + Vector3.new(0, 14.5, 0), Color3.fromRGB(255, 228, 172), Enum.Material.Neon, 0.08, Enum.PartType.Ball)
	end

	local function createVenueApproach(zoneConfig, color, material)
		createGroundPad(
			zoneConfig.Id .. "EntryApron",
			Vector3.new(math.min(zoneConfig.Size.X * 0.62, 54), 0.36, 24),
			zoneConfig.Position + Vector3.new(0, 0.18, -zoneConfig.Size.Z / 2 - 9),
			color,
			material,
			0
		)
	end

	local function createConnector(name, startPos, endPos, width, color, material, thickness)
		local direction = endPos - startPos
		local length = direction.Magnitude
		if length <= 0 then
			return
		end

		local center = startPos:Lerp(endPos, 0.5)
		createOrientedGroundPad(
			name,
			Vector3.new(width, thickness or 0.3, length + 8),
			Vector3.new(center.X, (thickness or 0.3) / 2, center.Z),
			Vector3.new(endPos.X, (thickness or 0.3) / 2, endPos.Z),
			color,
			material,
			0
		)
	end

	local function createRoutePocket(name, center, size, color, material, height)
		createGroundPad(name, Vector3.new(size.X, height or 0.34, size.Z), Vector3.new(center.X, (height or 0.34) / 2, center.Z), color, material, 0)
	end

	local hub = WorldConfig.Hub
	createGroundPad(
		"HubSafetyApron",
		Vector3.new(hub.Size.X + 180, 0.42, hub.Size.Z + 180),
		hub.Position + Vector3.new(0, 0.21, 0),
		Color3.fromRGB(72, 92, 74),
		Enum.Material.Grass,
		0
	)
	createGroundPad("HubNorthPromenade", Vector3.new(92, 0.34, 28), hub.Position + Vector3.new(0, 0.17, -108), Color3.fromRGB(168, 166, 158), Enum.Material.Concrete, 0)
	createGroundPad("HubSouthPromenade", Vector3.new(88, 0.34, 30), hub.Position + Vector3.new(0, 0.17, 110), Color3.fromRGB(170, 168, 160), Enum.Material.Concrete, 0)
	createGroundPad("HubWestPromenade", Vector3.new(28, 0.34, 88), hub.Position + Vector3.new(-108, 0.17, 0), Color3.fromRGB(164, 162, 154), Enum.Material.Concrete, 0)
	createGroundPad("HubEastPromenade", Vector3.new(28, 0.34, 88), hub.Position + Vector3.new(108, 0.17, 0), Color3.fromRGB(164, 162, 154), Enum.Material.Concrete, 0)
	createGroundPad("VehicleLotAsphalt", Vector3.new(108, 0.36, 42), Vector3.new(-24, 0.18, 6), Color3.fromRGB(92, 94, 96), Enum.Material.Asphalt, 0)
	createGroundPad("VehicleLotWalkway", Vector3.new(108, 0.28, 12), Vector3.new(-24, 0.14, 30), Color3.fromRGB(176, 174, 168), Enum.Material.Concrete, 0)
	createRoutePocket("HubNorthWestField", Vector3.new(-166, -4, -162), Vector3.new(164, 164), Color3.fromRGB(82, 106, 82), Enum.Material.Grass, 0.34)
	createRoutePocket("HubNorthEastField", Vector3.new(166, -4, -162), Vector3.new(164, 164), Color3.fromRGB(84, 108, 84), Enum.Material.Grass, 0.34)
	createRoutePocket("HubSouthWestField", Vector3.new(-170, 4, 176), Vector3.new(170, 176), Color3.fromRGB(82, 104, 82), Enum.Material.Grass, 0.34)
	createRoutePocket("HubSouthEastField", Vector3.new(170, 4, 176), Vector3.new(170, 176), Color3.fromRGB(84, 106, 84), Enum.Material.Grass, 0.34)
	createConnector("HubToVehicleLotBlend", Vector3.new(-36, 0, 18), Vector3.new(-36, 0, 44), 112, Color3.fromRGB(108, 112, 108), Enum.Material.Asphalt, 0.3)
	createConnector("HubToStrombladForecourt", Vector3.new(-68, 0, -64), Vector3.new(-124, 0, -126), 42, Color3.fromRGB(92, 112, 84), Enum.Material.Grass, 0.32)
	createConnector("HubToGirlsForecourt", Vector3.new(68, 0, -64), Vector3.new(124, 0, -126), 42, Color3.fromRGB(98, 122, 96), Enum.Material.Grass, 0.32)
	createConnector("HubToFounderForecourt", Vector3.new(78, 0, 68), Vector3.new(146, 0, 100), 42, Color3.fromRGB(178, 176, 168), Enum.Material.Concrete, 0.28)
	createConnector("HubToContentForgeForecourt", Vector3.new(-78, 0, 68), Vector3.new(-152, 0, 102), 42, Color3.fromRGB(170, 178, 184), Enum.Material.Concrete, 0.28)
	createConnector("HubToBlackOpsForecourt", Vector3.new(-88, 0, 10), Vector3.new(-160, 0, 4), 38, Color3.fromRGB(112, 114, 108), Enum.Material.Asphalt, 0.3)
	createConnector("HubToWaterParkForecourt", Vector3.new(0, 0, 112), Vector3.new(0, 0, 178), 40, Color3.fromRGB(188, 194, 190), Enum.Material.Concrete, 0.28)
	createConnector("HubToOutdoorMallForecourt", Vector3.new(110, 0, 18), Vector3.new(196, 0, 22), 42, Color3.fromRGB(174, 172, 164), Enum.Material.Concrete, 0.28)
	createConnector("HubToDriveInForecourt", Vector3.new(0, 0, -112), Vector3.new(0, 0, -186), 42, Color3.fromRGB(108, 110, 114), Enum.Material.Asphalt, 0.3)

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
		local lotCenter = Vector3.new((vehicleMinX + vehicleMaxX) / 2, 0.22, (vehicleMinZ + vehicleMaxZ) / 2)
		local lotSize = Vector3.new((vehicleMaxX - vehicleMinX) + 64, 0.38, (vehicleMaxZ - vehicleMinZ) + 46)
		createGroundPad("VehicleLotSafety", lotSize, Vector3.new(lotCenter.X, 0.19, lotCenter.Z), Color3.fromRGB(98, 102, 96), Enum.Material.Asphalt, 0)
		createRoutePocket("VehicleLotGrassBuffer", Vector3.new(lotCenter.X, 0, lotCenter.Z + 26), Vector3.new(lotSize.X + 40, 54), Color3.fromRGB(84, 104, 82), Enum.Material.Grass, 0.32)
	end

	for _, zoneConfig in ipairs(WorldConfig.Zones or {}) do
		if zoneConfig.ZoneType == "Active" then
			local apronColor = Color3.fromRGB(82, 108, 84)
			local apronMaterial = Enum.Material.Grass

			if zoneConfig.Id == "outdoor-mall" then
				apronColor = Color3.fromRGB(170, 168, 160)
				apronMaterial = Enum.Material.Concrete
			elseif zoneConfig.Id == "drive-in-theater" then
				apronColor = Color3.fromRGB(88, 90, 96)
				apronMaterial = Enum.Material.Asphalt
			elseif zoneConfig.Id == "water-park" then
				apronColor = Color3.fromRGB(194, 198, 196)
				apronMaterial = Enum.Material.Concrete
			elseif zoneConfig.Id == "stromblad-estate" or zoneConfig.Id == "girls-hangout" then
				apronColor = Color3.fromRGB(126, 142, 108)
				apronMaterial = Enum.Material.Grass
			end

			createGroundPad(
				zoneConfig.Id .. "SafetyApron",
				Vector3.new(zoneConfig.Size.X + 70, 0.4, zoneConfig.Size.Z + 64),
				zoneConfig.Position + Vector3.new(0, 0.2, 0),
				apronColor,
				apronMaterial,
				0
			)
			createVenueApproach(zoneConfig, apronColor, apronMaterial)

			if zoneConfig.Id == "stromblad-estate" then
				createRoutePocket("StrombladNorthLawn", zoneConfig.Position + Vector3.new(0, 0, -132), Vector3.new(214, 78), Color3.fromRGB(112, 132, 94), Enum.Material.Grass, 0.34)
				createConnector("StrombladRoadBlend", Vector3.new(-206, 0, -224), Vector3.new(-208, 0, -300), 84, Color3.fromRGB(114, 132, 96), Enum.Material.Grass, 0.34)
				createConnector("StrombladCrossroadBlend", Vector3.new(-172, 0, -300), Vector3.new(-90, 0, -300), 68, Color3.fromRGB(118, 134, 100), Enum.Material.Grass, 0.32)
			elseif zoneConfig.Id == "girls-hangout" then
				createRoutePocket("GirlsNorthLawn", zoneConfig.Position + Vector3.new(0, 0, -132), Vector3.new(206, 78), Color3.fromRGB(126, 170, 126), Enum.Material.Grass, 0.34)
				createConnector("GirlsRoadBlend", Vector3.new(206, 0, -224), Vector3.new(208, 0, -300), 84, Color3.fromRGB(132, 176, 132), Enum.Material.Grass, 0.34)
				createConnector("GirlsCrossroadBlend", Vector3.new(172, 0, -300), Vector3.new(90, 0, -300), 68, Color3.fromRGB(132, 176, 132), Enum.Material.Grass, 0.32)
				createRoutePocket("GirlsEntryCourt", zoneConfig.Position + Vector3.new(0, 0, -88), Vector3.new(122, 54), Color3.fromRGB(214, 212, 206), Enum.Material.Concrete, 0.32)
				createRoutePocket("GirlsSideLawnWest", zoneConfig.Position + Vector3.new(-96, 0, -18), Vector3.new(52, 164), Color3.fromRGB(116, 146, 110), Enum.Material.Grass, 0.32)
				createRoutePocket("GirlsSideLawnEast", zoneConfig.Position + Vector3.new(96, 0, -18), Vector3.new(52, 164), Color3.fromRGB(116, 146, 110), Enum.Material.Grass, 0.32)
				createRoutePocket("GirlsBackyardLawn", zoneConfig.Position + Vector3.new(4, 0, 82), Vector3.new(146, 62), Color3.fromRGB(112, 144, 108), Enum.Material.Grass, 0.32)
				createConnector("GirlsFrontPath", Vector3.new(208, 0, -226), Vector3.new(260, 0, -366), 34, Color3.fromRGB(214, 212, 206), Enum.Material.Concrete, 0.28)
				createConnector("GirlsPoolCourtPath", Vector3.new(260, 0, -236), Vector3.new(272, 0, -212), 54, Color3.fromRGB(214, 212, 206), Enum.Material.Concrete, 0.28)
			elseif zoneConfig.Id == "outdoor-mall" then
				createRoutePocket("OutdoorMallForecourt", zoneConfig.Position + Vector3.new(-56, 0, -74), Vector3.new(164, 72), Color3.fromRGB(164, 162, 156), Enum.Material.Concrete, 0.32)
				createRoutePocket("OutdoorMallParkingApron", zoneConfig.Position + Vector3.new(-44, 0, 72), Vector3.new(180, 92), Color3.fromRGB(104, 106, 108), Enum.Material.Asphalt, 0.32)
				createConnector("OutdoorMallRoadTie", Vector3.new(430, 0, 36), Vector3.new(470, 0, 36), 88, Color3.fromRGB(112, 114, 114), Enum.Material.Asphalt, 0.32)
			elseif zoneConfig.Id == "drive-in-theater" then
				createRoutePocket("DriveInEntryLot", zoneConfig.Position + Vector3.new(0, 0, -102), Vector3.new(196, 82), Color3.fromRGB(98, 100, 104), Enum.Material.Asphalt, 0.34)
				createRoutePocket("DriveInOuterBuffer", zoneConfig.Position + Vector3.new(0, 0, -178), Vector3.new(232, 84), Color3.fromRGB(108, 110, 100), Enum.Material.Ground, 0.32)
				createConnector("DriveInRoadTie", Vector3.new(0, 0, -470), Vector3.new(0, 0, -520), 82, Color3.fromRGB(102, 104, 106), Enum.Material.Asphalt, 0.34)
			elseif zoneConfig.Id == "water-park" then
				createRoutePocket("WaterParkForecourt", zoneConfig.Position + Vector3.new(0, 0, -92), Vector3.new(166, 86), Color3.fromRGB(194, 200, 198), Enum.Material.Concrete, 0.32)
				createRoutePocket("WaterParkOuterLawn", zoneConfig.Position + Vector3.new(0, 0, -154), Vector3.new(216, 84), Color3.fromRGB(94, 124, 92), Enum.Material.Grass, 0.32)
				createConnector("WaterParkRoadTie", Vector3.new(0, 0, 410), Vector3.new(0, 0, 450), 76, Color3.fromRGB(192, 198, 196), Enum.Material.Concrete, 0.32)
			elseif zoneConfig.Id == "founder-lounge" then
				createRoutePocket("FounderLoungeForecourt", zoneConfig.Position + Vector3.new(-18, 0, -76), Vector3.new(150, 78), Color3.fromRGB(168, 166, 156), Enum.Material.Concrete, 0.3)
			elseif zoneConfig.Id == "contentforge-studio" then
				createRoutePocket("ContentForgeForecourt", zoneConfig.Position + Vector3.new(0, 0, -78), Vector3.new(162, 76), Color3.fromRGB(168, 176, 182), Enum.Material.Concrete, 0.3)
			elseif zoneConfig.Id == "bo6-gaming-lounge" then
				createRoutePocket("BlackOpsForecourt", zoneConfig.Position + Vector3.new(0, 0, -72), Vector3.new(156, 72), Color3.fromRGB(104, 106, 100), Enum.Material.Asphalt, 0.3)
			end
		end
	end

	for _, roadConfig in ipairs(WorldConfig.Roads or {}) do
		local direction = roadConfig.EndPosition - roadConfig.StartPosition
		local length = direction.Magnitude

		if length > 0 then
			local center = roadConfig.StartPosition:Lerp(roadConfig.EndPosition, 0.5)
			local roadFrame = CFrame.lookAt(Vector3.new(center.X, 0.16, center.Z), Vector3.new(roadConfig.EndPosition.X, 0.16, roadConfig.EndPosition.Z))
			local sideOffset = roadConfig.Width / 2 + 4.25
			local roadsideMaterial = Enum.Material.Grass
			local roadsideColor = Color3.fromRGB(84, 106, 82)
			local shoulderMaterial = Enum.Material.Concrete
			local shoulderColor = Color3.fromRGB(154, 156, 150)

			if roadConfig.Name:find("Offroad") then
				roadsideMaterial = Enum.Material.Ground
				roadsideColor = Color3.fromRGB(124, 108, 82)
				shoulderMaterial = Enum.Material.Ground
				shoulderColor = Color3.fromRGB(138, 120, 92)
			elseif roadConfig.Name:find("DriveIn") or roadConfig.Name:find("OutdoorMall") then
				roadsideMaterial = Enum.Material.Ground
				roadsideColor = Color3.fromRGB(112, 114, 110)
				shoulderMaterial = Enum.Material.Asphalt
				shoulderColor = Color3.fromRGB(102, 104, 106)
			elseif roadConfig.Name:find("WaterPark") then
				roadsideMaterial = Enum.Material.Grass
				roadsideColor = Color3.fromRGB(88, 118, 88)
				shoulderMaterial = Enum.Material.Concrete
				shoulderColor = Color3.fromRGB(188, 192, 190)
			end

			createOrientedGroundPad(
				roadConfig.Name .. "GroundBase",
				Vector3.new(roadConfig.Width + 34, 0.34, length + 24),
				Vector3.new(center.X, 0.17, center.Z),
				Vector3.new(roadConfig.EndPosition.X, 0.17, roadConfig.EndPosition.Z),
				roadsideColor,
				roadsideMaterial,
				0
			)

			createOrientedGroundPad(
				roadConfig.Name .. "ShoulderLeft",
				Vector3.new(4.8, 0.2, length + 18),
				Vector3.new(center.X, 0.1, center.Z) - roadFrame.RightVector * sideOffset,
				Vector3.new(roadConfig.EndPosition.X, 0.1, roadConfig.EndPosition.Z),
				shoulderColor,
				shoulderMaterial,
				0
			)
			createOrientedGroundPad(
				roadConfig.Name .. "ShoulderRight",
				Vector3.new(4.8, 0.2, length + 18),
				Vector3.new(center.X, 0.1, center.Z) + roadFrame.RightVector * sideOffset,
				Vector3.new(roadConfig.EndPosition.X, 0.1, roadConfig.EndPosition.Z),
				shoulderColor,
				shoulderMaterial,
				0
			)

			if roadConfig.Width >= 14 and not roadConfig.Name:find("Offroad") then
				local sidewalkOffset = roadConfig.Width / 2 + 8.5
				createOrientedGroundPad(
					roadConfig.Name .. "SidewalkLeft",
					Vector3.new(3.8, 0.16, length + 8),
					Vector3.new(center.X, 0.08, center.Z) - roadFrame.RightVector * sidewalkOffset,
					Vector3.new(roadConfig.EndPosition.X, 0.08, roadConfig.EndPosition.Z),
					Color3.fromRGB(196, 196, 190),
					Enum.Material.Concrete,
					0
				)
				createOrientedGroundPad(
					roadConfig.Name .. "SidewalkRight",
					Vector3.new(3.8, 0.16, length + 8),
					Vector3.new(center.X, 0.08, center.Z) + roadFrame.RightVector * sidewalkOffset,
					Vector3.new(roadConfig.EndPosition.X, 0.08, roadConfig.EndPosition.Z),
					Color3.fromRGB(196, 196, 190),
					Enum.Material.Concrete,
					0
				)
			end
		end
	end

	createRoutePocket("CentralNorthGreen", Vector3.new(0, 0, -236), Vector3.new(230, 92), Color3.fromRGB(88, 112, 88), Enum.Material.Grass, 0.34)
	createRoutePocket("CentralSouthGreen", Vector3.new(0, 0, 300), Vector3.new(212, 122), Color3.fromRGB(88, 116, 90), Enum.Material.Grass, 0.34)
	createRoutePocket("WestActiveField", Vector3.new(-306, 0, -48), Vector3.new(176, 168), Color3.fromRGB(92, 110, 86), Enum.Material.Grass, 0.34)
	createRoutePocket("EastActiveField", Vector3.new(378, 0, 34), Vector3.new(220, 172), Color3.fromRGB(102, 118, 94), Enum.Material.Grass, 0.34)
	createRoutePocket("DriveInWestBuffer", Vector3.new(-122, 0, -542), Vector3.new(96, 112), Color3.fromRGB(106, 108, 98), Enum.Material.Ground, 0.34)
	createRoutePocket("DriveInEastBuffer", Vector3.new(122, 0, -542), Vector3.new(96, 112), Color3.fromRGB(106, 108, 98), Enum.Material.Ground, 0.34)
	createRoutePocket("WaterParkWestLawn", Vector3.new(-132, 0, 476), Vector3.new(112, 132), Color3.fromRGB(90, 124, 92), Enum.Material.Grass, 0.34)
	createRoutePocket("WaterParkEastLawn", Vector3.new(132, 0, 476), Vector3.new(112, 132), Color3.fromRGB(90, 124, 92), Enum.Material.Grass, 0.34)
	createRoutePocket("StrombladGirlsMedianField", Vector3.new(0, 0, -300), Vector3.new(212, 78), Color3.fromRGB(108, 134, 100), Enum.Material.Grass, 0.32)
	createRoutePocket("OutdoorMallSouthField", Vector3.new(520, 0, 146), Vector3.new(224, 124), Color3.fromRGB(116, 122, 108), Enum.Material.Ground, 0.32)
	createRoutePocket("OutdoorMallNorthField", Vector3.new(520, 0, -86), Vector3.new(224, 104), Color3.fromRGB(172, 170, 160), Enum.Material.Concrete, 0.28)
	createRoutePocket("OffroadTransitionShoulder", Vector3.new(-438, 0, -214), Vector3.new(174, 122), Color3.fromRGB(132, 116, 88), Enum.Material.Ground, 0.32)

	createTree("HubTreeNorthWest", Vector3.new(-138, 0, -138))
	createTree("HubTreeNorthEast", Vector3.new(138, 0, -138))
	createTree("HubTreeSouthWest", Vector3.new(-138, 0, 138))
	createTree("HubTreeSouthEast", Vector3.new(138, 0, 138))
	createTree("MallTreeLeft", Vector3.new(430, 0, 88), {
		CanopyColor = Color3.fromRGB(86, 126, 84),
	})
	createTree("MallTreeRight", Vector3.new(608, 0, 86), {
		CanopyColor = Color3.fromRGB(86, 126, 84),
	})
	createTree("GirlsFrontTree", Vector3.new(202, 0, -376), {
		CanopyColor = Color3.fromRGB(112, 152, 114),
	})
	createTree("EstateFrontTree", Vector3.new(-318, 0, -376), {
		CanopyColor = Color3.fromRGB(98, 128, 88),
	})
	createTree("WaterParkPalmLeft", Vector3.new(-92, 0, 422), {
		TrunkHeight = 18,
		CanopySize = Vector3.new(16, 10, 16),
		CanopyColor = Color3.fromRGB(88, 142, 92),
	})
	createTree("WaterParkPalmRight", Vector3.new(92, 0, 422), {
		TrunkHeight = 18,
		CanopySize = Vector3.new(16, 10, 16),
		CanopyColor = Color3.fromRGB(88, 142, 92),
	})
	createShrub("PlazaShrubWest", Vector3.new(-92, 0, 100), Vector3.new(8, 5, 8), Color3.fromRGB(90, 132, 84))
	createShrub("PlazaShrubEast", Vector3.new(92, 0, 100), Vector3.new(8, 5, 8), Color3.fromRGB(90, 132, 84))
	createShrub("FounderLoungeShrub", Vector3.new(278, 0, 118), Vector3.new(10, 5, 10), Color3.fromRGB(88, 122, 82))
	createShrub("ContentForgeShrub", Vector3.new(-316, 0, 138), Vector3.new(10, 5, 10), Color3.fromRGB(78, 110, 92))
	createRock("DriveInRockLeft", Vector3.new(-126, 0, -462), Vector3.new(8, 5, 7), Color3.fromRGB(92, 88, 96))
	createRock("DriveInRockRight", Vector3.new(126, 0, -462), Vector3.new(8, 5, 7), Color3.fromRGB(92, 88, 96))
	createRock("MallApproachRock", Vector3.new(392, 0, 74), Vector3.new(8, 5, 7), Color3.fromRGB(126, 122, 110))
	createRock("WaterParkRock", Vector3.new(-118, 0, 434), Vector3.new(7, 4, 6), Color3.fromRGB(132, 138, 136))
	createRock("GirlsFrontRock", Vector3.new(176, 0, -358), Vector3.new(7, 4, 6), Color3.fromRGB(148, 138, 148))
	createLightPost("HubLightWest", Vector3.new(-86, 0, 84))
	createLightPost("HubLightEast", Vector3.new(86, 0, 84))
	createLightPost("MallLight", Vector3.new(446, 0, 62))
	createLightPost("DriveInLight", Vector3.new(0, 0, -432))
	createLightPost("GirlsPathLight", Vector3.new(166, 0, -214))
	createLightPost("EstatePathLight", Vector3.new(-166, 0, -214))
	createLightPost("WaterParkPathLight", Vector3.new(0, 0, 438))
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
	local levelOffsetY = roomConfig.LevelOffsetY or 0
	local floorY = venueConfig.Position.Y + 1.15 + levelOffsetY
	local wallCenterY = venueConfig.Position.Y + levelOffsetY + wallHeight / 2

	createRoomPart("Floor", roomFolder, Vector3.new(roomConfig.Size.X, 0.3, roomConfig.Size.Z), Vector3.new(center.X, floorY, center.Z), roomColor, roomConfig.FloorMaterial)

	local walls = {
		North = {
			Size = Vector3.new(roomConfig.Size.X, wallHeight, wallThickness),
			Position = Vector3.new(center.X, wallCenterY, center.Z - roomConfig.Size.Z / 2),
		},
		South = {
			Size = Vector3.new(roomConfig.Size.X, wallHeight, wallThickness),
			Position = Vector3.new(center.X, wallCenterY, center.Z + roomConfig.Size.Z / 2),
		},
		West = {
			Size = Vector3.new(wallThickness, wallHeight, roomConfig.Size.Z),
			Position = Vector3.new(center.X - roomConfig.Size.X / 2, wallCenterY, center.Z),
		},
		East = {
			Size = Vector3.new(wallThickness, wallHeight, roomConfig.Size.Z),
			Position = Vector3.new(center.X + roomConfig.Size.X / 2, wallCenterY, center.Z),
		},
	}

	for side, wallData in pairs(walls) do
		if not hasOpenSide(roomConfig, side) then
			createRoomPart(side .. "Wall", roomFolder, wallData.Size, wallData.Position, wallColor, Enum.Material.SmoothPlastic)
		end
	end

	if not roomConfig.HideLabel then
		local labelPart = createPart("RoomLabel", roomFolder, {
			Size = roomConfig.LabelSize or Vector3.new(math.min(roomConfig.Size.X * 0.6, 16), 4, 1),
			Position = roomConfig.LabelOffset and (center + roomConfig.LabelOffset)
				or Vector3.new(center.X, venueConfig.Position.Y + levelOffsetY + wallHeight - 2, center.Z - roomConfig.Size.Z / 2 + 0.8),
			Color = wallColor,
			Material = Enum.Material.SmoothPlastic,
			CanCollide = false,
		})
		createSurfaceText(labelPart, roomConfig.LabelFace or Enum.NormalId.Front, roomConfig.Label, venueConfig.Name, venueConfig.Color)
	end
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

	attachPointLight(propPart, propConfig.PointLight)

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
	if not propConfig.HideBillboard then
		createBillboardText(labelAnchor, propConfig.Label or propConfig.Name, propConfig.Subtitle or "Pool", venueConfig.Accent, {
			MaxDistance = 60,
			Size = UDim2.fromOffset(145, 40),
			StudsOffset = Vector3.new(0, 2.75, 0),
		})
	end
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
	if not propConfig.HideBillboard then
		createBillboardText(labelAnchor, propConfig.Label or propConfig.Name, propConfig.Subtitle or "Spa", venueConfig.Accent, {
			MaxDistance = 60,
			Size = UDim2.fromOffset(145, 40),
			StudsOffset = Vector3.new(0, 2.75, 0),
		})
	end
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
	if not propConfig.HideBillboard then
		createBillboardText(labelAnchor, propConfig.Label or propConfig.Name, "Water Slide", venueConfig.Accent)
	end
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
	if not propConfig.HideBillboard then
		createBillboardText(labelAnchor, propConfig.Label or propConfig.Name, propConfig.Kind, venueConfig.Accent)
	end
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
	if not propConfig.HideBillboard then
		createBillboardText(labelAnchor, propConfig.Label or propConfig.Name, propConfig.Kind, venueConfig.Accent)
	end
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
		Size = Vector3.new(38, 0.35, 38),
		Position = Vector3.new(hub.SpawnPosition.X, 1.82, hub.SpawnPosition.Z),
		Color = Color3.fromRGB(255, 239, 179),
		Material = Enum.Material.Neon,
		Transparency = 0.28,
		CanCollide = false,
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

local function buildGirlsHangoutMansion(venueFolder, venueConfig, spawnFolder, teleportFolder, mediaFolder)
	local mansion = {
		Footprint = Vector3.new(176, 42, 132),
		SpawnOffset = Vector3.new(0, 3, -56),
		ReturnPadOffset = Vector3.new(-22, 2.55, -42),
		Primary = Color3.fromRGB(238, 236, 232),
		Trim = Color3.fromRGB(52, 56, 64),
		Concrete = Color3.fromRGB(214, 212, 206),
		Wood = Color3.fromRGB(114, 86, 62),
		Stone = Color3.fromRGB(168, 164, 158),
		Glass = Color3.fromRGB(194, 229, 255),
		Pink = Color3.fromRGB(255, 190, 222),
		PinkBright = Color3.fromRGB(255, 110, 186),
	}

	local position = venueConfig.Position
	local shellFolder = createFolder("Shell", venueFolder)
	local roomsFolder = createFolder("Rooms", venueFolder)
	local propsFolder = createFolder("Props", venueFolder)
	local signsFolder = createFolder("Signs", venueFolder)
	local doorsFolder = createFolder("Doors", venueFolder)

	createPart("MainFloor", shellFolder, {
		Size = Vector3.new(mansion.Footprint.X, 2, mansion.Footprint.Z),
		Position = position + Vector3.new(0, 1, 0),
		Color = mansion.Primary,
		Material = Enum.Material.Concrete,
		CanCollide = true,
	})
	createPart("UpperFloor", shellFolder, {
		Size = Vector3.new(108, 1.2, 84),
		Position = position + Vector3.new(0, 21, 2),
		Color = Color3.fromRGB(228, 226, 222),
		Material = Enum.Material.Concrete,
		CanCollide = true,
	})
	createPart("Roof", shellFolder, {
		Size = Vector3.new(112, 2, 88),
		Position = position + Vector3.new(0, 43, 4),
		Color = mansion.Trim,
		Material = Enum.Material.Metal,
		Transparency = 0.52,
		CanCollide = true,
	})

	local exteriorParts = {
		{ "BackWall", Vector3.new(176, 42, 2), Vector3.new(0, 21, 66), mansion.Primary, Enum.Material.SmoothPlastic },
		{ "LeftWall", Vector3.new(2, 42, 132), Vector3.new(-88, 21, 0), mansion.Trim, Enum.Material.Concrete },
		{ "RightWall", Vector3.new(2, 42, 132), Vector3.new(88, 21, 0), mansion.Trim, Enum.Material.Concrete },
		{ "FrontWallLeft", Vector3.new(66, 42, 2), Vector3.new(-55, 21, -66), mansion.Primary, Enum.Material.SmoothPlastic },
		{ "FrontWallRight", Vector3.new(66, 42, 2), Vector3.new(55, 21, -66), mansion.Primary, Enum.Material.SmoothPlastic },
		{ "EntryVolume", Vector3.new(34, 30, 12), Vector3.new(0, 15, -60), mansion.Trim, Enum.Material.SmoothPlastic },
		{ "WestWingVolume", Vector3.new(44, 26, 34), Vector3.new(-52, 13, -8), mansion.Primary, Enum.Material.SmoothPlastic },
		{ "EastWingVolume", Vector3.new(42, 26, 36), Vector3.new(54, 13, -6), mansion.Primary, Enum.Material.SmoothPlastic },
		{ "SouthGardenVolume", Vector3.new(74, 20, 30), Vector3.new(18, 10, 38), mansion.Primary, Enum.Material.SmoothPlastic },
		{ "EntryCourt", Vector3.new(68, 0.5, 30), Vector3.new(0, 1.1, -82), mansion.Concrete, Enum.Material.Concrete },
		{ "EntrySteps", Vector3.new(30, 0.4, 10), Vector3.new(0, 1.2, -68), Color3.fromRGB(226, 223, 218), Enum.Material.Concrete },
		{ "FrontPorch", Vector3.new(26, 0.45, 10), Vector3.new(0, 2.22, -70), Color3.fromRGB(232, 230, 225), Enum.Material.Concrete },
		{ "EntryThreshold", Vector3.new(20, 0.25, 5), Vector3.new(0, 2.13, -64), Color3.fromRGB(78, 80, 86), Enum.Material.Slate },
		{ "FrontCanopy", Vector3.new(34, 2, 16), Vector3.new(0, 16, -62), mansion.Trim, Enum.Material.Metal },
		{ "EntryPortalLeft", Vector3.new(3, 20, 2), Vector3.new(-15, 10, -61.4), mansion.Wood, Enum.Material.WoodPlanks },
		{ "EntryPortalRight", Vector3.new(3, 20, 2), Vector3.new(15, 10, -61.4), mansion.Wood, Enum.Material.WoodPlanks },
		{ "StoneFeatureWall", Vector3.new(16, 18, 0.5), Vector3.new(-60, 9, -59.8), mansion.Stone, Enum.Material.Slate },
		{ "FoyerAccentWest", Vector3.new(0.4, 12, 18), Vector3.new(-16.3, 7, -48), Color3.fromRGB(228, 220, 224), Enum.Material.SmoothPlastic },
		{ "FoyerAccentEast", Vector3.new(0.4, 12, 18), Vector3.new(16.3, 7, -48), Color3.fromRGB(230, 224, 228), Enum.Material.SmoothPlastic },
		{ "LoungeAccentPanel", Vector3.new(22, 12, 1), Vector3.new(-20, 7, 4), Color3.fromRGB(236, 224, 230), Enum.Material.SmoothPlastic },
		{ "BackyardTransition", Vector3.new(34, 0.24, 10), Vector3.new(16, 2.12, 60), Color3.fromRGB(226, 223, 218), Enum.Material.Concrete },
		{ "RoofTrimLower", Vector3.new(182, 1, 138), Vector3.new(0, 23, -2), mansion.Trim, Enum.Material.Metal },
		{ "RoofTrimUpper", Vector3.new(112, 1, 92), Vector3.new(0, 41, 4), Color3.fromRGB(58, 60, 66), Enum.Material.Metal },
		{ "BalconyDeck", Vector3.new(36, 0.4, 12), Vector3.new(28, 21.2, -62), Color3.fromRGB(226, 224, 220), Enum.Material.Concrete },
		{ "BalconyRail", Vector3.new(34, 8, 0.4), Vector3.new(28, 25, -67.8), Color3.fromRGB(80, 82, 88), Enum.Material.Metal },
		{ "BackyardPoolDeck", Vector3.new(82, 0.5, 44), Vector3.new(16, 1.1, 86), Color3.fromRGB(216, 214, 208), Enum.Material.Concrete },
	}
	for _, partData in ipairs(exteriorParts) do
		createPart(partData[1], shellFolder, {
			Size = partData[2],
			Position = position + partData[3],
			Color = partData[4],
			Material = partData[5],
			CanCollide = true,
		})
	end

	local glassParts = {
		{ "FrontWindowLeft", Vector3.new(24, 16, 0.4), Vector3.new(44, 12, -59.6) },
		{ "FrontWindowRight", Vector3.new(14, 16, 0.4), Vector3.new(-28, 12, -59.6) },
		{ "UpperWindowBand", Vector3.new(64, 10, 0.4), Vector3.new(14, 28, -59.5) },
		{ "WestGlassWall", Vector3.new(0.4, 18, 28), Vector3.new(-86.1, 18, -2) },
		{ "EastGlassWall", Vector3.new(0.4, 18, 30), Vector3.new(86.1, 18, 6) },
		{ "BackPatioDoors", Vector3.new(26, 18, 0.4), Vector3.new(12, 12, 65.6) },
		{ "FrontDoorSidelightLeft", Vector3.new(4, 12, 0.5), Vector3.new(-11, 7, -64.9) },
		{ "FrontDoorSidelightRight", Vector3.new(4, 12, 0.5), Vector3.new(11, 7, -64.9) },
		{ "FrontDoorTransomGlass", Vector3.new(20, 3, 0.5), Vector3.new(0, 14.5, -64.9) },
	}
	for _, glass in ipairs(glassParts) do
		createPart(glass[1], shellFolder, {
			Size = glass[2],
			Position = position + glass[3],
			Color = mansion.Glass,
			Material = Enum.Material.Glass,
			Transparency = 0.24,
			CanCollide = true,
		})
	end

	local roomConfigs = {
		{ Name = "Foyer", Offset = Vector3.new(0, 0, -48), Size = Vector3.new(34, 2, 20), OpenSides = { "North", "South" }, FloorColor = Color3.fromRGB(238, 236, 232), WallColor = Color3.fromRGB(246, 245, 242), WallHeight = 22, HideLabel = true, FloorMaterial = Enum.Material.SmoothPlastic },
		{ Name = "Grand Lounge", Offset = Vector3.new(0, 0, -12), Size = Vector3.new(52, 2, 34), OpenSides = { "North", "South", "East" }, FloorColor = Color3.fromRGB(232, 230, 226), WallColor = Color3.fromRGB(244, 243, 240), WallHeight = 22, HideLabel = true, FloorMaterial = Enum.Material.SmoothPlastic },
		{ Name = "Glam Kitchen", Offset = Vector3.new(-50, 0, -8), Size = Vector3.new(34, 2, 26), OpenSides = { "East", "South" }, FloorColor = Color3.fromRGB(242, 240, 236), WallColor = Color3.fromRGB(232, 226, 221), WallHeight = 20, HideLabel = true, FloorMaterial = Enum.Material.SmoothPlastic },
		{ Name = "Media Arcade", Offset = Vector3.new(50, 0, -8), Size = Vector3.new(34, 2, 28), OpenSides = { "West" }, FloorColor = Color3.fromRGB(230, 228, 226), WallColor = Color3.fromRGB(224, 219, 215), WallHeight = 20, HideLabel = true, FloorMaterial = Enum.Material.SmoothPlastic },
		{ Name = "Birthday Suite", Offset = Vector3.new(-34, 0, 28), Size = Vector3.new(40, 2, 28), OpenSides = { "North", "East", "South" }, FloorColor = Color3.fromRGB(246, 232, 238), WallColor = Color3.fromRGB(255, 194, 220), WallHeight = 20, HideLabel = true, FloorMaterial = Enum.Material.SmoothPlastic },
		{ Name = "Pool Gallery", Offset = Vector3.new(30, 0, 28), Size = Vector3.new(40, 2, 26), OpenSides = { "North", "West", "South" }, FloorColor = Color3.fromRGB(236, 233, 230), WallColor = Color3.fromRGB(226, 220, 214), WallHeight = 20, HideLabel = true, FloorMaterial = Enum.Material.SmoothPlastic },
		{ Name = "Upper Landing", Offset = Vector3.new(0, 0, 0), Size = Vector3.new(28, 2, 20), OpenSides = { "North", "South", "East", "West" }, FloorColor = Color3.fromRGB(240, 238, 234), WallColor = Color3.fromRGB(244, 243, 240), WallHeight = 16, LevelOffsetY = 20, HideLabel = true, FloorMaterial = Enum.Material.SmoothPlastic },
		{ Name = "Creator Suite", Offset = Vector3.new(-42, 0, -8), Size = Vector3.new(30, 2, 24), OpenSides = { "East", "South" }, FloorColor = Color3.fromRGB(236, 232, 237), WallColor = Color3.fromRGB(232, 202, 226), WallHeight = 16, LevelOffsetY = 20, HideLabel = true, FloorMaterial = Enum.Material.SmoothPlastic },
		{ Name = "VIP Lounge", Offset = Vector3.new(38, 0, -8), Size = Vector3.new(34, 2, 24), OpenSides = { "West" }, FloorColor = Color3.fromRGB(242, 233, 237), WallColor = Color3.fromRGB(244, 205, 224), WallHeight = 16, LevelOffsetY = 20, HideLabel = true, FloorMaterial = Enum.Material.SmoothPlastic },
		{ Name = "Sleepover Suite", Offset = Vector3.new(-26, 0, 30), Size = Vector3.new(42, 2, 26), OpenSides = { "North", "East" }, FloorColor = Color3.fromRGB(244, 236, 240), WallColor = Color3.fromRGB(232, 214, 224), WallHeight = 16, LevelOffsetY = 20, HideLabel = true, FloorMaterial = Enum.Material.SmoothPlastic },
		{ Name = "Vanity Bath", Offset = Vector3.new(34, 0, 30), Size = Vector3.new(26, 2, 22), OpenSides = { "West" }, FloorColor = Color3.fromRGB(242, 239, 236), WallColor = Color3.fromRGB(228, 222, 216), WallHeight = 16, LevelOffsetY = 20, HideLabel = true, FloorMaterial = Enum.Material.SmoothPlastic },
	}
	for _, roomConfig in ipairs(roomConfigs) do
		createRoom(roomsFolder, venueConfig, roomConfig)
	end

	local propList = {
		{ Name = "FoyerConsole", Kind = "Table", Offset = Vector3.new(11, 2, -49), Size = Vector3.new(10, 4, 3), Color = Color3.fromRGB(182, 154, 132), Material = Enum.Material.WoodPlanks, HideBillboard = true },
		{ Name = "FoyerMirror", Kind = "Display", Offset = Vector3.new(11, 9, -56), Size = Vector3.new(10, 10, 1), Color = Color3.fromRGB(238, 244, 248), Material = Enum.Material.Glass, Transparency = 0.2, HideBillboard = true },
		{ Name = "FoyerRunner", Kind = "FloorPad", Offset = Vector3.new(0, 2.08, -46), Size = Vector3.new(12, 0.16, 16), Color = Color3.fromRGB(245, 230, 236), Material = Enum.Material.SmoothPlastic, Transparency = 0.12, HideBillboard = true },
		{ Name = "ReturnAlcoveBench", Kind = "Seat", Offset = Vector3.new(-21, 2, -34), Size = Vector3.new(10, 3.5, 4), Color = Color3.fromRGB(232, 214, 222), Material = Enum.Material.Fabric, HideBillboard = true },
		{ Name = "ReturnAlcovePanel", Kind = "Display", Offset = Vector3.new(-22, 8, -36), Size = Vector3.new(12, 10, 1), Color = Color3.fromRGB(255, 236, 244), Material = Enum.Material.SmoothPlastic, HideBillboard = true },
		{ Name = "ReturnAlcoveGlow", Kind = "Display", Offset = Vector3.new(-22, 14, -36), Size = Vector3.new(8, 1.2, 1), Color = mansion.Pink, Material = Enum.Material.Neon, Transparency = 0.18, HideBillboard = true, PointLight = { Color = Color3.fromRGB(255, 214, 234), Range = 12, Brightness = 0.65 } },
		{ Name = "LivingSectional", Kind = "Seat", Offset = Vector3.new(-10, 2, -16), Size = Vector3.new(24, 4, 8), Color = Color3.fromRGB(228, 206, 214), Material = Enum.Material.Fabric, HideBillboard = true },
		{ Name = "LivingCoffeeTable", Kind = "Table", Offset = Vector3.new(8, 1.5, -10), Size = Vector3.new(12, 3, 6), Color = Color3.fromRGB(182, 154, 132), Material = Enum.Material.WoodPlanks, HideBillboard = true },
		{ Name = "LivingAreaRug", Kind = "FloorPad", Offset = Vector3.new(0, 2.08, -12), Size = Vector3.new(30, 0.16, 18), Color = Color3.fromRGB(242, 232, 236), Material = Enum.Material.SmoothPlastic, Transparency = 0.14, HideBillboard = true },
		{ Name = "LivingFireplaceWall", Kind = "Display", Offset = Vector3.new(6, 8, 4), Size = Vector3.new(20, 12, 2), Color = Color3.fromRGB(164, 160, 154), Material = Enum.Material.Slate, HideBillboard = true },
		{ Name = "LivingFireplaceGlow", Kind = "Display", Offset = Vector3.new(6, 4, 5.2), Size = Vector3.new(10, 4, 0.4), Color = Color3.fromRGB(255, 180, 120), Material = Enum.Material.Neon, Transparency = 0.1, HideBillboard = true, PointLight = { Color = Color3.fromRGB(255, 214, 170), Range = 18, Brightness = 0.8 } },
		{ Name = "PendantLamp", Kind = "Display", Offset = Vector3.new(6, 16, -10), Size = Vector3.new(3, 3, 3), Color = Color3.fromRGB(255, 239, 215), Material = Enum.Material.Neon, Shape = Enum.PartType.Ball, HideBillboard = true, PointLight = { Color = Color3.fromRGB(255, 238, 220), Range = 18, Brightness = 1.2 } },
		{ Name = "KitchenIsland", Kind = "Table", Offset = Vector3.new(-50, 2, -10), Size = Vector3.new(18, 4, 8), Color = Color3.fromRGB(228, 226, 222), Material = Enum.Material.SmoothPlastic, HideBillboard = true },
		{ Name = "KitchenBarStools", Kind = "Seat", Offset = Vector3.new(-50, 2, -18), Size = Vector3.new(18, 4, 4), Color = Color3.fromRGB(188, 162, 142), Material = Enum.Material.Fabric, HideBillboard = true },
		{ Name = "DessertBar", Kind = "Table", Offset = Vector3.new(-60, 2, 2), Size = Vector3.new(12, 4, 4), Color = Color3.fromRGB(255, 205, 224), Material = Enum.Material.SmoothPlastic, HideBillboard = true },
		{ Name = "PantryWall", Kind = "Display", Offset = Vector3.new(-60, 8, -10), Size = Vector3.new(12, 12, 1), Color = Color3.fromRGB(214, 210, 206), Material = Enum.Material.SmoothPlastic, HideBillboard = true },
		{ Name = "ArcadeCabinetA", Kind = "ArcadeCabinet", Offset = Vector3.new(60, 5, -20), Size = Vector3.new(5, 10, 4), Color = Color3.fromRGB(255, 105, 176), Accent = Color3.fromRGB(255, 220, 240), HideBillboard = true },
		{ Name = "ArcadeCabinetB", Kind = "ArcadeCabinet", Offset = Vector3.new(60, 5, -10), Size = Vector3.new(5, 10, 4), Color = Color3.fromRGB(200, 60, 160), Accent = Color3.fromRGB(255, 220, 240), HideBillboard = true },
		{ Name = "ArcadeCabinetC", Kind = "ArcadeCabinet", Offset = Vector3.new(60, 5, 0), Size = Vector3.new(5, 10, 4), Color = Color3.fromRGB(255, 130, 200), Accent = Color3.fromRGB(255, 220, 240), HideBillboard = true },
		{ Name = "ClipReviewScreen", Kind = "CinemaScreen", Offset = Vector3.new(42, 10, -20), Size = Vector3.new(24, 12, 1), Color = Color3.fromRGB(60, 60, 66), Accent = mansion.Pink, HideBillboard = true },
		{ Name = "ArcadeSofa", Kind = "Seat", Offset = Vector3.new(46, 2, -2), Size = Vector3.new(16, 4, 6), Color = Color3.fromRGB(214, 200, 212), Material = Enum.Material.Fabric, HideBillboard = true },
		{ Name = "BirthdayCakeBase", Kind = "Display", Offset = Vector3.new(-36, 3, 24), Size = Vector3.new(10, 2, 10), Color = Color3.fromRGB(255, 220, 150), HideBillboard = true },
		{ Name = "BirthdayCakeMid", Kind = "Display", Offset = Vector3.new(-36, 5.5, 24), Size = Vector3.new(8, 3, 8), Color = Color3.fromRGB(255, 170, 200), HideBillboard = true },
		{ Name = "BirthdayCakeTop", Kind = "Display", Offset = Vector3.new(-36, 8.5, 24), Size = Vector3.new(5, 3, 5), Color = Color3.fromRGB(255, 238, 242), HideBillboard = true },
		{ Name = "BirthdayCandleGlow", Kind = "Display", Offset = Vector3.new(-36, 11.8, 24), Size = Vector3.new(2.5, 2, 2.5), Color = Color3.fromRGB(255, 240, 80), Material = Enum.Material.Neon, HideBillboard = true, PointLight = { Color = Color3.fromRGB(255, 234, 172), Range = 14, Brightness = 0.9 } },
		{ Name = "BirthdayBanner", Kind = "Display", Offset = Vector3.new(-34, 11, 40.4), Size = Vector3.new(30, 5, 0.4), Color = mansion.PinkBright, Material = Enum.Material.Neon, HideBillboard = true },
		{ Name = "BirthdayLoungeSofa", Kind = "Seat", Offset = Vector3.new(-16, 2, 28), Size = Vector3.new(14, 4, 6), Color = Color3.fromRGB(244, 208, 222), Material = Enum.Material.Fabric, HideBillboard = true },
		{ Name = "PoolGallerySofa", Kind = "Seat", Offset = Vector3.new(16, 2, 28), Size = Vector3.new(16, 4, 6), Color = Color3.fromRGB(224, 218, 214), Material = Enum.Material.Fabric, HideBillboard = true },
		{ Name = "PoolGalleryScreen", Kind = "CinemaScreen", Offset = Vector3.new(44, 10, 38), Size = Vector3.new(18, 10, 1), Color = Color3.fromRGB(66, 68, 74), Accent = mansion.Pink, HideBillboard = true },
		{ Name = "SecretHatch", Kind = "Display", Offset = Vector3.new(6, 2.2, 8), Size = Vector3.new(10, 0.3, 10), Color = mansion.PinkBright, Material = Enum.Material.Neon, Transparency = 0.16, Label = "Secret Food Court" },
		{ Name = "TunnelShaftEast", Kind = "Display", Offset = Vector3.new(11, -14, 8), Size = Vector3.new(1, 34, 10), Color = Color3.fromRGB(72, 58, 94), HideBillboard = true },
		{ Name = "TunnelShaftWest", Kind = "Display", Offset = Vector3.new(1, -14, 8), Size = Vector3.new(1, 34, 10), Color = Color3.fromRGB(72, 58, 94), HideBillboard = true },
		{ Name = "TunnelShaftNorth", Kind = "Display", Offset = Vector3.new(6, -14, 3), Size = Vector3.new(9, 34, 1), Color = Color3.fromRGB(72, 58, 94), HideBillboard = true },
		{ Name = "TunnelShaftSouth", Kind = "Display", Offset = Vector3.new(6, -14, 13), Size = Vector3.new(9, 34, 1), Color = Color3.fromRGB(72, 58, 94), HideBillboard = true },
		{ Name = "UpperHallRail", Kind = "Display", Offset = Vector3.new(10, 24, 10), Size = Vector3.new(34, 4, 1), Color = Color3.fromRGB(74, 76, 84), Material = Enum.Material.Metal, HideBillboard = true },
		{ Name = "VIPLoungePad", Kind = "FloorPad", Offset = Vector3.new(40, 22.1, -10), Size = Vector3.new(18, 0.2, 18), Color = Color3.fromRGB(255, 176, 222), Material = Enum.Material.Neon, Transparency = 0.5, HideBillboard = true },
		{ Name = "VIPSofa", Kind = "Seat", Offset = Vector3.new(38, 22, -8), Size = Vector3.new(16, 4, 6), Color = Color3.fromRGB(242, 216, 228), Material = Enum.Material.Fabric, HideBillboard = true },
		{ Name = "VIPCoffeeTable", Kind = "Table", Offset = Vector3.new(38, 21.5, -2), Size = Vector3.new(8, 3, 5), Color = Color3.fromRGB(182, 154, 132), Material = Enum.Material.WoodPlanks, HideBillboard = true },
		{ Name = "VIPStarWall", Kind = "VIPDisplay", Offset = Vector3.new(54, 29, -8), Size = Vector3.new(18, 12, 1), Color = mansion.Pink, Accent = Color3.fromRGB(255, 247, 252), Label = "VIP Star Loft" },
		{ Name = "CreatorDesk", Kind = "Table", Offset = Vector3.new(-42, 21.5, -6), Size = Vector3.new(14, 3, 6), Color = Color3.fromRGB(188, 162, 142), Material = Enum.Material.WoodPlanks, HideBillboard = true },
		{ Name = "CreatorScreen", Kind = "CinemaScreen", Offset = Vector3.new(-42, 28, -15), Size = Vector3.new(18, 10, 1), Color = Color3.fromRGB(64, 66, 74), Accent = mansion.Pink, HideBillboard = true },
		{ Name = "RingLight", Kind = "Display", Offset = Vector3.new(-54, 28, -6), Size = Vector3.new(6, 6, 1), Color = Color3.fromRGB(255, 250, 220), Material = Enum.Material.Neon, Shape = Enum.PartType.Cylinder, HideBillboard = true, PointLight = { Color = Color3.fromRGB(255, 246, 230), Range = 14, Brightness = 1 } },
		{ Name = "SleepoverBedA", Kind = "Seat", Offset = Vector3.new(-36, 22, 30), Size = Vector3.new(12, 3, 7), Color = Color3.fromRGB(246, 228, 236), Material = Enum.Material.Fabric, HideBillboard = true },
		{ Name = "SleepoverBedB", Kind = "Seat", Offset = Vector3.new(-36, 22, 40), Size = Vector3.new(12, 3, 7), Color = Color3.fromRGB(230, 214, 228), Material = Enum.Material.Fabric, HideBillboard = true },
		{ Name = "SleepoverRug", Kind = "FloorPad", Offset = Vector3.new(-14, 22.08, 34), Size = Vector3.new(18, 0.16, 10), Color = Color3.fromRGB(248, 202, 230), Material = Enum.Material.SmoothPlastic, Transparency = 0.16, HideBillboard = true },
		{ Name = "VanityMirror", Kind = "Display", Offset = Vector3.new(36, 28, 30), Size = Vector3.new(10, 10, 1), Color = Color3.fromRGB(235, 242, 246), Material = Enum.Material.Glass, Transparency = 0.18, HideBillboard = true },
		{ Name = "VanityCounter", Kind = "Table", Offset = Vector3.new(36, 22, 36), Size = Vector3.new(12, 4, 4), Color = Color3.fromRGB(236, 213, 224), Material = Enum.Material.WoodPlanks, HideBillboard = true },
		{ Name = "GlamTub", Kind = "Display", Offset = Vector3.new(42, 23, 24), Size = Vector3.new(8, 4, 12), Color = Color3.fromRGB(246, 240, 244), Material = Enum.Material.SmoothPlastic, HideBillboard = true },
		{ Name = "Pool", Kind = "Pool", Offset = Vector3.new(4, 0, 88), Size = Vector3.new(30, 4, 16), Color = Color3.fromRGB(104, 193, 255), Accent = Color3.fromRGB(235, 247, 255), HideBillboard = true },
		{ Name = "PoolGlowEdge", Kind = "FloorPad", Offset = Vector3.new(4, 2.12, 96), Size = Vector3.new(32, 0.16, 0.5), Color = mansion.PinkBright, Material = Enum.Material.Neon, Transparency = 0.4, HideBillboard = true },
		{ Name = "PoolChaiseA", Kind = "PoolChair", Offset = Vector3.new(-26, 2, 82), Size = Vector3.new(8, 3, 4), Color = Color3.fromRGB(244, 236, 236), Accent = mansion.Pink, HideBillboard = true },
		{ Name = "PoolChaiseB", Kind = "PoolChair", Offset = Vector3.new(-26, 2, 92), Size = Vector3.new(8, 3, 4), Color = Color3.fromRGB(244, 236, 236), Accent = mansion.Pink, HideBillboard = true },
		{ Name = "PatioSofa", Kind = "Seat", Offset = Vector3.new(42, 2, 84), Size = Vector3.new(18, 4, 6), Color = Color3.fromRGB(234, 214, 220), Material = Enum.Material.Fabric, HideBillboard = true },
		{ Name = "PatioFireTable", Kind = "Table", Offset = Vector3.new(42, 1.5, 92), Size = Vector3.new(6, 3, 6), Color = Color3.fromRGB(182, 154, 132), Material = Enum.Material.WoodPlanks, HideBillboard = true },
		{ Name = "PoolAccentOrb", Kind = "Display", Offset = Vector3.new(42, 6, 98), Size = Vector3.new(3, 3, 3), Color = mansion.PinkBright, Material = Enum.Material.Neon, Shape = Enum.PartType.Ball, HideBillboard = true, PointLight = { Color = Color3.fromRGB(255, 166, 214), Range = 14, Brightness = 0.75 } },
		{ Name = "TreeTrunk", Kind = "Display", Offset = Vector3.new(86, 26, -6), Size = Vector3.new(4, 50, 4), Color = Color3.fromRGB(80, 55, 25), Material = Enum.Material.Wood, HideBillboard = true },
		{ Name = "TreehousePlatform", Kind = "Display", Offset = Vector3.new(86, 50, -6), Size = Vector3.new(20, 2, 20), Color = Color3.fromRGB(120, 80, 40), Material = Enum.Material.WoodPlanks, HideBillboard = true },
		{ Name = "TreehouseWallN", Kind = "Display", Offset = Vector3.new(86, 60, -15), Size = Vector3.new(20, 14, 1), Color = Color3.fromRGB(140, 100, 50), Material = Enum.Material.WoodPlanks, HideBillboard = true },
		{ Name = "TreehouseWallE", Kind = "Display", Offset = Vector3.new(95, 60, -6), Size = Vector3.new(1, 14, 18), Color = Color3.fromRGB(140, 100, 50), Material = Enum.Material.WoodPlanks, HideBillboard = true },
		{ Name = "TreehouseRoof", Kind = "Display", Offset = Vector3.new(86, 67, -6), Size = Vector3.new(22, 2, 22), Color = Color3.fromRGB(160, 120, 60), Material = Enum.Material.WoodPlanks, HideBillboard = true },
		{ Name = "TreehouseSign", Kind = "Display", Offset = Vector3.new(86, 58, -14.4), Size = Vector3.new(16, 6, 0.5), Color = Color3.fromRGB(200, 160, 90), Material = Enum.Material.Neon, HideBillboard = true },
		{ Name = "ZiplineCable", Kind = "Display", Offset = Vector3.new(-200, 51, -20), Size = Vector3.new(480, 0.4, 0.4), Color = Color3.fromRGB(55, 55, 55), Material = Enum.Material.Metal, HideBillboard = true },
	}
	for _, propConfig in ipairs(propList) do
		createProp(propsFolder, venueConfig, propConfig)
	end

	for step = 1, 12 do
		createProp(propsFolder, venueConfig, {
			Name = "StairStep" .. tostring(step),
			Kind = "Display",
			Offset = Vector3.new(-8, 1 + step, -2 + step * 4),
			Size = Vector3.new(10, 1, 4),
			Color = Color3.fromRGB(188, 162, 142),
			Material = Enum.Material.WoodPlanks,
			HideBillboard = true,
		})
	end

	local birthdayBanner = propsFolder:FindFirstChild("BirthdayBanner")
	if birthdayBanner then
		InteractionService.registerPrompt(birthdayBanner, {
			ActionType = "Notify",
			ActionText = "Read",
			ObjectText = "Birthday Banner",
			Message = "Happy 11th Birthday Abbie Jo! Love, Mom, Dad, and Charlie Lue",
			CooldownKey = "GirlsHangout:BirthdayBanner",
		})
	end

	local hatch = propsFolder:FindFirstChild("SecretHatch")
	if hatch then
		InteractionService.registerPrompt(hatch, {
			ActionType = "TeleportVenue",
			ActionText = "Enter",
			ObjectText = "Secret Food Court",
			VenueId = "underground-food-court",
			CooldownKey = "TeleportVenue:underground-food-court",
		})
	end

	local vipWall = propsFolder:FindFirstChild("VIPStarWall")
	if vipWall then
		InteractionService.registerPrompt(vipWall, {
			ActionType = "FounderAction",
			ActionText = "Open",
			ObjectText = "VIP Star Loft",
			RoleRequired = "VIP",
			Message = "VIP Star Loft opened a glam founder highlight moment.",
			CooldownKey = "GirlsHangout:VIPLoft",
		})
	end

	createSign(signsFolder, "VenueSign", position + Vector3.new(-44, 20, -70), "Girls Hangout", "Modern VIP glam mansion", Color3.fromRGB(34, 36, 42), mansion.Pink, Vector3.new(22, 8, 1))
	createSign(signsFolder, "BirthdaySign", position + Vector3.new(-34, 14, 44), "Birthday Suite", "Party room + memory wall", Color3.fromRGB(248, 196, 220), mansion.Trim, Vector3.new(16, 8, 1))
	createSign(signsFolder, "VIPSign", position + Vector3.new(38, 30, -26), "VIP Star Loft", "Balcony views and glam seating", Color3.fromRGB(242, 206, 226), mansion.Trim, Vector3.new(16, 8, 1))
	createSign(signsFolder, "PoolSign", position + Vector3.new(22, 14, 66), "Backyard Pool", "Late-night lounge and glow deck", Color3.fromRGB(214, 216, 222), mansion.Trim, Vector3.new(16, 8, 1))
	createSign(signsFolder, "EntrySign", position + Vector3.new(25, 8, -72), "Front Entry", "VIP house foyer", Color3.fromRGB(244, 240, 244), mansion.Trim, Vector3.new(12, 6, 1))

	local mediaVenueConfig = {
		Id = venueConfig.Id,
		Position = venueConfig.Position,
		MediaPanels = {
			{
				Name = "BirthdayMemoryWall",
				MediaType = "Photo",
				Offset = Vector3.new(-16, 8, 40),
				Size = Vector3.new(16, 9, 1),
				Title = "Birthday Memory Wall",
				Items = {
					"Abbie's Glam Party",
					"VIP Sleepover Night",
					"Poolside Golden Hour",
					"Creator Loft Highlights",
				},
			},
			{
				Name = "CreatorStream",
				MediaType = "Twitch",
				Offset = Vector3.new(-30, 28, -14),
				Size = Vector3.new(14, 9, 1),
				Title = "Creator Loft Stream",
			},
			{
				Name = "GirlsPlaylist",
				MediaType = "Spotify",
				Offset = Vector3.new(18, 8, 2),
				Size = Vector3.new(12, 8, 1),
				Title = "VIP House Playlist",
			},
		},
	}

	local builtPanels = MediaFramework.build(mediaFolder, mediaVenueConfig)
	for _, builtPanel in ipairs(builtPanels) do
		local mediaType = builtPanel.Config.MediaType
		local actionText = mediaType == "Spotify" and "Open" or (mediaType == "Twitch" and "Watch" or "View")
		local objectText = mediaType == "Spotify" and "Spotify Station" or (mediaType == "Twitch" and "Twitch Wall" or builtPanel.Config.Title)
		InteractionService.registerPrompt(builtPanel.Screen, {
			ActionType = "Media",
			ActionText = actionText,
			ObjectText = objectText,
			Message = "Interaction placeholder: " .. builtPanel.Config.Title,
			CooldownKey = "Media:" .. venueConfig.Id .. ":" .. builtPanel.Config.Name,
		})
	end

	local spawnPosition = position + mansion.SpawnOffset
	createPart(venueConfig.Name .. " ArrivalMarker", spawnFolder, {
		Size = Vector3.new(10, 0.5, 10),
		Position = spawnPosition + Vector3.new(0, -1.5, 0),
		Color = mansion.Pink,
		Material = Enum.Material.Neon,
		Transparency = 0.4,
		Anchored = true,
		CanCollide = false,
	})
	TeleportService.registerVenueTarget(venueConfig.Id, CFrame.new(spawnPosition), venueConfig.Name)

	local returnPad = createNavigationPad(
		teleportFolder,
		venueConfig.Name .. " ReturnPad",
		position + mansion.ReturnPadOffset,
		mansion.Pink,
		"Return to Plaza",
		{
			MarkerOffset = Vector3.new(0, 4.5, 6),
			MarkerColor = Color3.fromRGB(42, 42, 48),
			MarkerSize = Vector3.new(9, 6, 1),
			MarkerCanCollide = false,
			Subtitle = "Hub",
			PadSize = Vector3.new(12, 1, 12),
			PadMaterial = Enum.Material.SmoothPlastic,
			PadTransparency = 0.08,
		}
	)
	InteractionService.registerPrompt(returnPad, {
		ActionType = "TeleportHub",
		ActionText = "Teleport",
		ObjectText = "Founder's Plaza",
		CooldownKey = "TeleportHub:" .. venueConfig.Id,
	})

	local entrySconceLeft = createPart("EntrySconceLeft", doorsFolder, {
		Size = Vector3.new(1.4, 4, 1.2),
		Position = position + Vector3.new(-16, 8, -64.5),
		Color = Color3.fromRGB(255, 236, 214),
		Material = Enum.Material.Neon,
		Transparency = 0.12,
		CanCollide = false,
	})
	attachPointLight(entrySconceLeft, {
		Color = Color3.fromRGB(255, 228, 206),
		Range = 14,
		Brightness = 0.75,
	})

	local entrySconceRight = createPart("EntrySconceRight", doorsFolder, {
		Size = Vector3.new(1.4, 4, 1.2),
		Position = position + Vector3.new(16, 8, -64.5),
		Color = Color3.fromRGB(255, 236, 214),
		Material = Enum.Material.Neon,
		Transparency = 0.12,
		CanCollide = false,
	})
	attachPointLight(entrySconceRight, {
		Color = Color3.fromRGB(255, 228, 206),
		Range = 14,
		Brightness = 0.75,
	})

	createPart("DoorFrameLeft", doorsFolder, {
		Size = Vector3.new(1.2, 14, 2.2),
		Position = position + Vector3.new(-9.6, 7, -65.2),
		Color = mansion.Trim,
		Material = Enum.Material.Metal,
		CanCollide = true,
	})
	createPart("DoorFrameRight", doorsFolder, {
		Size = Vector3.new(1.2, 14, 2.2),
		Position = position + Vector3.new(9.6, 7, -65.2),
		Color = mansion.Trim,
		Material = Enum.Material.Metal,
		CanCollide = true,
	})
	createPart("DoorFrameTop", doorsFolder, {
		Size = Vector3.new(20.4, 1.2, 2.2),
		Position = position + Vector3.new(0, 13.6, -65.2),
		Color = mansion.Trim,
		Material = Enum.Material.Metal,
		CanCollide = true,
	})
	createPart("DoorHandleBar", doorsFolder, {
		Size = Vector3.new(0.4, 5, 0.4),
		Position = position + Vector3.new(0, 7, -64.1),
		Color = Color3.fromRGB(232, 214, 176),
		Material = Enum.Material.Metal,
		CanCollide = false,
	})

	local door = createPart("MainDoor", doorsFolder, {
		Size = Vector3.new(16, 12, 1.4),
		Position = position + Vector3.new(0, 7, -64.8),
		Color = mansion.Glass,
		Material = Enum.Material.Glass,
		Transparency = 0.14,
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

local function buildVenue(venueFolder, venueConfig, spawnFolder, teleportFolder, mediaFolder, navigationFolder)
	if venueConfig.Id == "girls-hangout" then
		buildGirlsHangoutMansion(venueFolder, venueConfig, spawnFolder, teleportFolder, mediaFolder)
		return
	end

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
	Lighting.Brightness = 1.65
	Lighting.ExposureCompensation = 0.08
	Lighting.Ambient = Color3.fromRGB(106, 108, 116)
	Lighting.OutdoorAmbient = Color3.fromRGB(118, 122, 128)

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
	atm.Density = 0.18
	atm.Offset = 0.1
	atm.Color = Color3.fromRGB(206, 210, 220)
	atm.Decay = Color3.fromRGB(102, 110, 126)
	atm.Glare = 0.12
	atm.Haze = 0.08

	local cc = ensureChild("ColorCorrectionEffect", "WorldColorCorrection")
	cc.Brightness = 0.03
	cc.Contrast = 0.06
	cc.Saturation = 0.1
	cc.TintColor = Color3.fromRGB(252, 250, 248)

	local bloom = ensureChild("BloomEffect", "WorldBloom")
	bloom.Intensity = 0.24
	bloom.Size = 18
	bloom.Threshold = 0.98
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
