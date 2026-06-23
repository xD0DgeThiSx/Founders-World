local NotificationController = {}
NotificationController.__index = NotificationController

function NotificationController.new(container)
	return setmetatable({
		Container = container,
		Toasts = {},
	}, NotificationController)
end

function NotificationController:show(payload)
	local toast = Instance.new("Frame")
	toast.Name = "Toast"
	toast.Size = UDim2.fromOffset(320, 64)
	toast.BackgroundColor3 = Color3.fromRGB(29, 34, 43)
	toast.BorderSizePixel = 0
	toast.Parent = self.Container

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = toast

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 201, 68)
	stroke.Thickness = 1.5
	stroke.Parent = toast

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(14, 8)
	title.Size = UDim2.fromOffset(292, 20)
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = Color3.fromRGB(255, 201, 68)
	title.TextScaled = true
	title.Text = payload.Kind or "Info"
	title.Parent = toast

	local body = Instance.new("TextLabel")
	body.BackgroundTransparency = 1
	body.Position = UDim2.fromOffset(14, 28)
	body.Size = UDim2.fromOffset(292, 26)
	body.Font = Enum.Font.Gotham
	body.TextXAlignment = Enum.TextXAlignment.Left
	body.TextColor3 = Color3.fromRGB(255, 255, 255)
	body.TextScaled = true
	body.Text = payload.Message or ""
	body.Parent = toast

	table.insert(self.Toasts, toast)
	self:layout()

	task.delay(payload.Duration or 3.5, function()
		for index, existingToast in ipairs(self.Toasts) do
			if existingToast == toast then
				table.remove(self.Toasts, index)
				break
			end
		end

		if toast.Parent then
			toast:Destroy()
		end

		self:layout()
	end)
end

function NotificationController:layout()
	for index, toast in ipairs(self.Toasts) do
		toast.Position = UDim2.new(1, -340, 1, -(index * 74))
	end
end

return NotificationController
