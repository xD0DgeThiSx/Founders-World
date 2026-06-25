local ProfileConfig = {
	SchemaVersion = 1,
	DefaultProfile = {
		SchemaVersion = 1,
		Progression = {
			Level = 1,
			XP = 0,
			CompletedOnboarding = false,
		},
		Entitlements = {
			Founder = false,
			VIP = false,
			EarlyTester = false,
		},
		Stats = {
			Visits = 0,
			Teleports = 0,
			Interactions = 0,
		},
		Preferences = {
			PreferredSpawn = "hub",
			ShowDebugLabels = false,
		},
	},
	Permissions = {
		Founder = {
			CanUseFounderActions = true,
			CanEnterVIPAreas = true,
			CanAccessDebugTools = true,
		},
		VIP = {
			CanUseFounderActions = false,
			CanEnterVIPAreas = true,
			CanAccessDebugTools = false,
		},
		Guest = {
			CanUseFounderActions = false,
			CanEnterVIPAreas = false,
			CanAccessDebugTools = false,
		},
	},
}

return ProfileConfig
