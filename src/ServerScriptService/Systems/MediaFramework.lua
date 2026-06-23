local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WorldConfig = require(ReplicatedStorage.Shared.Config.WorldConfig)

local MediaFramework = {}

local PANEL_STYLES = {
	Photo = {
		BodyColor = Color3.fromRGB(44, 44, 44),
		HeaderColor = Color3.fromRGB(255, 213, 144),
		FrameColor = Color3.fromRGB(120, 95, 54),
		AccentText = Color3.fromRGB(255, 242, 224),
	},
	Spotify = {
		BodyColor = Color3.fromRGB(18, 34, 23),
		HeaderColor = Color3.fromRGB(29, 185, 84),
		FrameColor = Color3.fromRGB(12, 74, 33),
		AccentText = Color3.fromRGB(224, 255, 232),
	},
	Twitch = {
		BodyColor = Color3.fromRGB(30, 20, 55),
		HeaderColor = Color3.fromRGB(145, 70, 255),
		FrameColor = Color3.fromRGB(74, 42, 128),
		AccentText = Color3.fromRGB(241, 232, 255),
	},
	YouTube = {
		BodyColor = Color3.fromRGB(52, 12, 12),
		HeaderColor = Color3.fromRGB(255, 56, 56),
		FrameColor = Color3.fromRGB(120, 24, 24),
		AccentText = Color3.fromRGB(255, 230, 230),
	},
}

local DEFAULT_FEEDS = {
	Photo = WorldConfig.Media.PhotoSlides,
	Spotify = WorldConfig.Media.SpotifyTracks,
	Twitch = WorldConfig.Media.TwitchStreams,
	YouTube = WorldConfig.Media.YouTubeShowcase,
}

local function createPart(name, parent, properties)
	local className = properties.ClassName or "Part"
	properties.ClassName = nil

	local part = Instance.new(className)
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

local function createTextLabel(parent, properties)
	local label = Instance.new("TextLabel")

	for property, value in pairs(properties) do
		label[property] = value
	end

	label.Parent = parent
	return label
end

local function createPanelFrame(panelFolder, panelConfig, worldPosition, style)
	local frame = createPart(panelConfig.Name, panelFolder, {
		Size = panelConfig.Size + Vector3.new(1.5, 1.5, 0.5),
		Position = worldPosition,
		Color = style.FrameColor,
		Material = Enum.Material.Metal,
	})

	local screen = createPart(panelConfig.Name .. "Screen", panelFolder, {
		Size = panelConfig.Size,
		Position = worldPosition + Vector3.new(0, 0, 0.3),
		Color = style.BodyColor,
		Material = Enum.Material.SmoothPlastic,
	})

	local header = createPart(panelConfig.Name .. "Header", panelFolder, {
		Size = Vector3.new(panelConfig.Size.X, 1.6, 0.5),
		Position = worldPosition + Vector3.new(0, panelConfig.Size.Y / 2 - 0.8, 0.45),
		Color = style.HeaderColor,
		Material = Enum.Material.Neon,
	})

	return frame, screen, header
end

local function createPanelGui(screen, title, items, style)
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Face = Enum.NormalId.Front
	surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surfaceGui.PixelsPerStud = 40
	surfaceGui.Parent = screen

	createTextLabel(surfaceGui, {
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.04, 0.04),
		Size = UDim2.fromScale(0.92, 0.18),
		Font = Enum.Font.GothamBold,
		Text = title,
		TextColor3 = style.AccentText,
		TextScaled = true,
	})

	createTextLabel(surfaceGui, {
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.04, 0.24),
		Size = UDim2.fromScale(0.92, 0.1),
		Font = Enum.Font.GothamMedium,
		Text = "Placeholder feed cycling",
		TextColor3 = style.HeaderColor,
		TextScaled = true,
	})

	local bodyLabel = createTextLabel(surfaceGui, {
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.07, 0.37),
		Size = UDim2.fromScale(0.86, 0.5),
		Font = Enum.Font.Gotham,
		TextWrapped = true,
		TextColor3 = Color3.new(1, 1, 1),
		TextScaled = true,
		Text = items[1] or "Placeholder",
	})

	task.spawn(function()
		local itemIndex = 1
		while bodyLabel.Parent do
			bodyLabel.Text = items[itemIndex]
			itemIndex += 1

			if itemIndex > #items then
				itemIndex = 1
			end

			task.wait(4)
		end
	end)
end

function MediaFramework.build(mediaRoot, venueConfig)
	local venueMedia = Instance.new("Folder")
	venueMedia.Name = venueConfig.Name
	venueMedia.Parent = mediaRoot
	local builtPanels = {}

	for _, panelConfig in ipairs(venueConfig.MediaPanels or {}) do
		local mediaType = panelConfig.MediaType
		local style = PANEL_STYLES[mediaType]
		local items = panelConfig.Items or DEFAULT_FEEDS[mediaType] or { "Placeholder" }
		local worldPosition = venueConfig.Position + panelConfig.Offset

		if style then
			local panelFolder = Instance.new("Folder")
			panelFolder.Name = panelConfig.Name
			panelFolder.Parent = venueMedia

			local _, screen = createPanelFrame(panelFolder, panelConfig, worldPosition, style)
			createPanelGui(screen, panelConfig.Title, items, style)

			table.insert(builtPanels, {
				Config = panelConfig,
				Screen = screen,
			})
		end
	end

	return builtPanels
end

return MediaFramework
