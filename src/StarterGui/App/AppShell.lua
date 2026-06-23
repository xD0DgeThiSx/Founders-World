local NotificationController = require(script.Parent.NotificationController)

local AppShell = {}
AppShell.__index = AppShell

local function createLabel(parent, properties)
	local label = Instance.new("TextLabel")

	for property, value in pairs(properties) do
		label[property] = value
	end

	label.Parent = parent
	return label
end

local function createButton(parent, text, position)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -20, 0, 34)
	button.Position = position
	button.BackgroundColor3 = Color3.fromRGB(35, 41, 52)
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamBold
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextScaled = true
	button.Text = text
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button

	return button
end

function AppShell.new(playerGui, venues)
	local self = setmetatable({
		VenueCallbacks = {},
	}, AppShell)

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "FoundersWorldApp"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui
	self.ScreenGui = screenGui

	local hud = Instance.new("Frame")
	hud.Name = "MainHud"
	hud.BackgroundTransparency = 1
	hud.Size = UDim2.fromScale(1, 1)
	hud.Parent = screenGui
	self.Hud = hud

	local roleCard = Instance.new("Frame")
	roleCard.Name = "RoleCard"
	roleCard.Size = UDim2.fromOffset(260, 108)
	roleCard.Position = UDim2.fromOffset(20, 20)
	roleCard.BackgroundColor3 = Color3.fromRGB(22, 28, 36)
	roleCard.BorderSizePixel = 0
	roleCard.Parent = hud

	local roleCorner = Instance.new("UICorner")
	roleCorner.CornerRadius = UDim.new(0, 12)
	roleCorner.Parent = roleCard

	createLabel(roleCard, {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 10),
		Size = UDim2.fromOffset(232, 22),
		Font = Enum.Font.GothamBold,
		Text = "Founder's World",
		TextColor3 = Color3.fromRGB(255, 201, 68),
		TextScaled = true,
	})

	self.RoleLabel = createLabel(roleCard, {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 40),
		Size = UDim2.fromOffset(232, 22),
		Font = Enum.Font.GothamBold,
		Text = "Role: Guest",
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextScaled = true,
	})

	self.StatusLabel = createLabel(roleCard, {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 68),
		Size = UDim2.fromOffset(232, 16),
		Font = Enum.Font.Gotham,
		Text = "Status: exploring public spaces",
		TextColor3 = Color3.fromRGB(207, 214, 223),
		TextScaled = true,
	})

	self.FounderLabel = createLabel(roleCard, {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 86),
		Size = UDim2.fromOffset(232, 14),
		Font = Enum.Font.Gotham,
		Text = "Founder/VIP sync pending",
		TextColor3 = Color3.fromRGB(167, 176, 188),
		TextScaled = true,
	})

	local venueMenu = Instance.new("Frame")
	venueMenu.Name = "VenueNavigation"
	venueMenu.Size = UDim2.fromOffset(280, 280)
	venueMenu.Position = UDim2.new(1, -300, 0, 20)
	venueMenu.BackgroundColor3 = Color3.fromRGB(22, 28, 36)
	venueMenu.BorderSizePixel = 0
	venueMenu.Parent = hud

	local menuCorner = Instance.new("UICorner")
	menuCorner.CornerRadius = UDim.new(0, 12)
	menuCorner.Parent = venueMenu

	createLabel(venueMenu, {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 10),
		Size = UDim2.fromOffset(250, 24),
		Font = Enum.Font.GothamBold,
		Text = "Venue Navigation",
		TextColor3 = Color3.fromRGB(255, 201, 68),
		TextScaled = true,
	})

	createLabel(venueMenu, {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 36),
		Size = UDim2.fromOffset(250, 18),
		Font = Enum.Font.Gotham,
		Text = "Placeholder client menu powered by remotes",
		TextColor3 = Color3.fromRGB(207, 214, 223),
		TextScaled = true,
	})

	for index, venue in ipairs(venues) do
		local button = createButton(venueMenu, venue.Name, UDim2.new(0, 10, 0, 56 + ((index - 1) * 40)))
		button.MouseButton1Click:Connect(function()
			for _, callback in ipairs(self.VenueCallbacks) do
				callback(venue)
			end
		end)
	end

	local notificationLayer = Instance.new("Frame")
	notificationLayer.Name = "NotificationLayer"
	notificationLayer.Size = UDim2.fromScale(1, 1)
	notificationLayer.BackgroundTransparency = 1
	notificationLayer.Parent = hud

	self.NotificationController = NotificationController.new(notificationLayer)

	return self
end

function AppShell:onVenueSelected(callback)
	table.insert(self.VenueCallbacks, callback)
end

function AppShell:setRole(payload)
	local role = payload.Role or "Guest"
	self.RoleLabel.Text = "Role: " .. role

	if payload.IsFounder then
		self.StatusLabel.Text = "Status: founder tools unlocked"
		self.FounderLabel.Text = "Founder: " .. (payload.FounderUsername or payload.Username or "")
	elseif payload.IsVIP then
		self.StatusLabel.Text = "Status: VIP lounge access seeded"
		self.FounderLabel.Text = "VIP member active"
	else
		self.StatusLabel.Text = "Status: exploring public spaces"
		self.FounderLabel.Text = "Founder: " .. (payload.FounderUsername or "")
	end
end

function AppShell:showNotification(payload)
	self.NotificationController:show(payload)
end

return AppShell
