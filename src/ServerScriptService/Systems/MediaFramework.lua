local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WorldConfig = require(ReplicatedStorage.Shared.Config.WorldConfig)

local MediaFramework = {}

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

local function createPanel(part, title, items, accent)
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Face = Enum.NormalId.Front
	surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surfaceGui.PixelsPerStud = 40
	surfaceGui.Parent = part

	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.fromScale(1, 0.2)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Text = title
	titleLabel.TextColor3 = accent
	titleLabel.TextScaled = true
	titleLabel.Parent = surfaceGui

	local bodyLabel = Instance.new("TextLabel")
	bodyLabel.BackgroundTransparency = 1
	bodyLabel.Position = UDim2.fromScale(0.05, 0.24)
	bodyLabel.Size = UDim2.fromScale(0.9, 0.7)
	bodyLabel.Font = Enum.Font.Gotham
	bodyLabel.TextWrapped = true
	bodyLabel.TextColor3 = Color3.new(1, 1, 1)
	bodyLabel.TextScaled = true
	bodyLabel.Text = items[1]
	bodyLabel.Parent = surfaceGui

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

local function buildPhotoSlideshow(parent, basePosition, accent)
	local frame = createPart("PhotoSlideshow", parent, {
		Size = Vector3.new(18, 10, 1),
		Position = basePosition,
		Color = Color3.fromRGB(25, 25, 25),
		Material = Enum.Material.SmoothPlastic,
	})

	createPanel(frame, "Photo Slideshow", WorldConfig.Media.PhotoSlides, accent)
end

local function buildSpotifyStation(parent, basePosition, accent)
	local station = createPart("SpotifyStation", parent, {
		Size = Vector3.new(10, 8, 4),
		Position = basePosition,
		Color = Color3.fromRGB(24, 24, 24),
		Material = Enum.Material.Metal,
	})

	createPanel(station, "Spotify Station", WorldConfig.Media.SpotifyTracks, accent)
end

local function buildTwitchWall(parent, basePosition, accent)
	local wall = createPart("TwitchWall", parent, {
		Size = Vector3.new(20, 10, 1),
		Position = basePosition,
		Color = Color3.fromRGB(33, 22, 56),
		Material = Enum.Material.SmoothPlastic,
	})

	createPanel(wall, "Twitch Streaming Wall", WorldConfig.Media.TwitchStreams, accent)
end

local function buildYouTubeShowcase(parent, basePosition, accent)
	local frame = createPart("YouTubeShowcase", parent, {
		Size = Vector3.new(20, 10, 1),
		Position = basePosition,
		Color = Color3.fromRGB(54, 14, 14),
		Material = Enum.Material.SmoothPlastic,
	})

	createPanel(frame, "YouTube Showcase", WorldConfig.Media.YouTubeShowcase, accent)
end

function MediaFramework.build(mediaRoot, venueConfig)
	local venueMedia = Instance.new("Folder")
	venueMedia.Name = venueConfig.Name
	venueMedia.Parent = mediaRoot

	local base = venueConfig.Position
	local footprint = venueConfig.Footprint
	local accent = venueConfig.Accent

	if venueConfig.Media.Photo then
		buildPhotoSlideshow(venueMedia, base + Vector3.new(-footprint.X / 2 + 12, 8, 12), accent)
	end

	if venueConfig.Media.Spotify then
		buildSpotifyStation(venueMedia, base + Vector3.new(0, 4, footprint.Z / 2 - 10), accent)
	end

	if venueConfig.Media.Twitch then
		buildTwitchWall(venueMedia, base + Vector3.new(footprint.X / 2 - 12, 8, 12), accent)
	end

	if venueConfig.Media.YouTube then
		buildYouTubeShowcase(venueMedia, base + Vector3.new(0, 8, 28), accent)
	end
end

return MediaFramework
