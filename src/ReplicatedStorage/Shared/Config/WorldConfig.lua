local function withOptions(base, options)
	options = options or {}

	for key, value in pairs(options) do
		base[key] = value
	end

	return base
end

local function room(name, offset, size, options)
	return withOptions({
		Name = name,
		Offset = offset,
		Size = size,
		WallHeight = 16,
		WallThickness = 1,
		OpenSides = {},
		Label = name,
		FloorMaterial = Enum.Material.SmoothPlastic,
		FloorColor = nil,
		WallColor = nil,
	}, options)
end

local function prop(name, kind, offset, size, options)
	return withOptions({
		Name = name,
		Kind = kind,
		Offset = offset,
		Size = size,
		Color = nil,
		Accent = nil,
		Material = Enum.Material.SmoothPlastic,
		Label = name,
		ClassName = "Part",
		Shape = Enum.PartType.Block,
		Transparency = 0,
	}, options)
end

local function mediaPanel(name, mediaType, offset, size, options)
	return withOptions({
		Name = name,
		MediaType = mediaType,
		Offset = offset,
		Size = size,
		Title = name,
		Items = nil,
	}, options)
end

local function sign(title, subtitle, offset, options)
	return withOptions({
		Title = title,
		Subtitle = subtitle,
		Offset = offset,
		Size = Vector3.new(14, 10, 1),
		Color = nil,
		Accent = nil,
	}, options)
end

local function zone(id, name, position, size, options)
	return withOptions({
		Id = id,
		Name = name,
		Position = position,
		Size = size,
		Color = Color3.fromRGB(82, 82, 82),
		Accent = Color3.fromRGB(255, 201, 68),
		Status = "Active",
		BuildPhase = "Phase 4",
		Category = "Venue",
		ZoneType = "Existing",
		ArrivalOffset = Vector3.new(0, 3, -18),
		HubSignOffset = Vector3.new(),
		HubPadOffset = nil,
		HubBoardLabel = name,
		ShortLabel = name,
		LargeSignTitle = name,
		LargeSignSubtitle = "Core Area",
		FutureExpansionText = "Ready for expansion",
		TeleportDestinationId = nil,
		PathColor = nil,
		PathStartOffset = nil,
		PathEndOffset = nil,
		PathMarkerCount = 4,
	}, options)
end

local function road(name, startPosition, endPosition, width, options)
	return withOptions({
		Name = name,
		StartPosition = startPosition,
		EndPosition = endPosition,
		Width = width,
		Height = 1,
		Color = Color3.fromRGB(74, 74, 74),
		Material = Enum.Material.Concrete,
	}, options)
end

local WorldConfig = {
	Hub = {
		Name = "Founder's Plaza",
		Position = Vector3.new(0, 0, 0),
		Size = Vector3.new(260, 2, 260),
		SignText = "Welcome to Founder's World",
		SpawnPosition = Vector3.new(0, 3, 42),
		WelcomeSignOffset = Vector3.new(0, 20, -102),
		ActiveBoardOffset = Vector3.new(-36, 14, 102),
		ActiveBoardSize = Vector3.new(22, 16, 1),
		FutureBoardOffset = Vector3.new(36, 14, 102),
		FutureBoardSize = Vector3.new(22, 16, 1),
	},
	VIP = {
		FounderUsername = "xD0DgeThiSx",
		Names = {
			"Abbiejo615",
			"lue0615",
			"BUTTERTHEMBUNS",
			"Emilyplays902",
			"Emigirl0615",
		},
		-- Phase 2 only seeds display data. A future entitlement or permission service
		-- can consume this table for VIP doors, title tags, special teleports, or UI.
		Notes = "Reserved for future VIP and founder permission hooks.",
	},
	Media = {
		PhotoSlides = {
			"Vision Board",
			"Community Moment",
			"Prototype Venue",
			"Future Expansion",
		},
		SpotifyTracks = {
			"Placeholder Track A",
			"Placeholder Track B",
			"Placeholder Track C",
		},
		TwitchStreams = {
			"Live Build Session",
			"Community Stream",
			"Feature Preview",
		},
		YouTubeShowcase = {
			"World Tour Teaser",
			"Studio Breakdown",
			"Founder's Update",
		},
	},
	Zones = {
		zone("stromblad-estate", "Stromblad Estate", Vector3.new(-260, 0, -300), Vector3.new(190, 2, 180), {
			Color = Color3.fromRGB(137, 114, 90),
			Accent = Color3.fromRGB(241, 219, 187),
			Category = "Venue",
			ZoneType = "Active",
			HubSignOffset = Vector3.new(-140, 0, -130),
			HubPadOffset = Vector3.new(-74, 0, -72),
			HubBoardLabel = "Stromblad",
			ShortLabel = "Stromblad",
			LargeSignSubtitle = "Modern home district",
			FutureExpansionText = "Active venue ready for interior growth",
			TeleportDestinationId = "stromblad-estate",
			PathColor = Color3.fromRGB(241, 219, 187),
			PathStartOffset = Vector3.new(-34, 0, -28),
			PathEndOffset = Vector3.new(-108, 0, -110),
		}),
		zone("girls-hangout", "Girls Hangout", Vector3.new(260, 0, -300), Vector3.new(182, 2, 180), {
			Color = Color3.fromRGB(255, 196, 226),
			Accent = Color3.fromRGB(255, 240, 248),
			Category = "Venue",
			ZoneType = "Active",
			HubSignOffset = Vector3.new(132, 0, -118),
			HubPadOffset = Vector3.new(78, 0, -72),
			HubBoardLabel = "Girls",
			ShortLabel = "Girls",
			LargeSignSubtitle = "Social fun district",
			FutureExpansionText = "Active venue ready for party features",
			TeleportDestinationId = "girls-hangout",
			PathColor = Color3.fromRGB(255, 196, 226),
			PathStartOffset = Vector3.new(34, 0, -28),
			PathEndOffset = Vector3.new(108, 0, -110),
		}),
		zone("founder-lounge", "Founder Lounge", Vector3.new(320, 0, 180), Vector3.new(188, 2, 168), {
			Color = Color3.fromRGB(58, 65, 82),
			Accent = Color3.fromRGB(215, 191, 126),
			Category = "Venue",
			ZoneType = "Active",
			HubSignOffset = Vector3.new(138, 0, 134),
			HubPadOffset = Vector3.new(92, 0, 58),
			HubBoardLabel = "Lounge",
			ShortLabel = "Lounge",
			LargeSignSubtitle = "Founder networking district",
			FutureExpansionText = "Active venue ready for VIP systems",
			TeleportDestinationId = "founder-lounge",
			PathColor = Color3.fromRGB(215, 191, 126),
			PathStartOffset = Vector3.new(38, 0, 24),
			PathEndOffset = Vector3.new(118, 0, 96),
		}),
		zone("contentforge-studio", "ContentForge Studio", Vector3.new(-360, 0, 210), Vector3.new(204, 2, 176), {
			Color = Color3.fromRGB(73, 101, 132),
			Accent = Color3.fromRGB(181, 224, 255),
			Category = "Venue",
			ZoneType = "Active",
			HubSignOffset = Vector3.new(-116, 0, 138),
			HubPadOffset = Vector3.new(-86, 0, 62),
			HubBoardLabel = "Studio",
			ShortLabel = "Studio",
			LargeSignSubtitle = "Creator production district",
			FutureExpansionText = "Active venue ready for creator systems",
			TeleportDestinationId = "contentforge-studio",
			PathColor = Color3.fromRGB(181, 224, 255),
			PathStartOffset = Vector3.new(-38, 0, 24),
			PathEndOffset = Vector3.new(-118, 0, 96),
		}),
		zone("bo6-gaming-lounge", "BO6 Gaming Lounge", Vector3.new(-360, 0, -40), Vector3.new(196, 2, 168), {
			Color = Color3.fromRGB(60, 60, 60),
			Accent = Color3.fromRGB(255, 111, 0),
			Category = "Venue",
			ZoneType = "Active",
			HubSignOffset = Vector3.new(-154, 0, -18),
			HubPadOffset = Vector3.new(-106, 0, -10),
			HubBoardLabel = "BO6",
			ShortLabel = "BO6",
			LargeSignSubtitle = "Competitive play district",
			FutureExpansionText = "Active venue ready for tournament systems",
			TeleportDestinationId = "bo6-gaming-lounge",
			PathColor = Color3.fromRGB(255, 111, 0),
			PathStartOffset = Vector3.new(-38, 0, 0),
			PathEndOffset = Vector3.new(-126, 0, -6),
		}),
		zone("water-park", "Water Park", Vector3.new(0, 0, 500), Vector3.new(210, 2, 180), {
			Color = Color3.fromRGB(95, 185, 230),
			Accent = Color3.fromRGB(225, 247, 255),
			Status = "Placeholder",
			Category = "Future Expansion",
			ZoneType = "Placeholder",
			HubSignOffset = Vector3.new(0, 0, 126),
			HubPadOffset = Vector3.new(0, 0, 78),
			HubBoardLabel = "Water Park",
			ShortLabel = "Water",
			LargeSignSubtitle = "Placeholder zone",
			FutureExpansionText = "Future water attractions and slides",
		}),
		zone("outdoor-mall", "Outdoor Mall", Vector3.new(520, 0, 40), Vector3.new(210, 2, 180), {
			Color = Color3.fromRGB(201, 196, 174),
			Accent = Color3.fromRGB(255, 247, 216),
			Status = "Placeholder",
			Category = "Future Expansion",
			ZoneType = "Placeholder",
			HubSignOffset = Vector3.new(126, 0, 24),
			HubPadOffset = Vector3.new(40, 0, 78),
			HubBoardLabel = "Outdoor Mall",
			ShortLabel = "Mall",
			LargeSignSubtitle = "Placeholder zone",
			FutureExpansionText = "Future storefronts and social spaces",
		}),
		zone("drive-in-theater", "Drive-In Theater", Vector3.new(0, 0, -560), Vector3.new(240, 2, 210), {
			Color = Color3.fromRGB(66, 55, 78),
			Accent = Color3.fromRGB(222, 205, 255),
			Status = "Placeholder",
			Category = "Future Expansion",
			ZoneType = "Placeholder",
			HubSignOffset = Vector3.new(0, 0, -130),
			HubPadOffset = Vector3.new(80, 0, 78),
			HubBoardLabel = "Drive-In",
			ShortLabel = "Drive-In",
			LargeSignSubtitle = "Placeholder zone",
			FutureExpansionText = "Future movie nights and theater features",
		}),
		zone("offroad-track", "Offroad Track", Vector3.new(-580, 0, -320), Vector3.new(240, 2, 210), {
			Color = Color3.fromRGB(108, 85, 62),
			Accent = Color3.fromRGB(230, 202, 160),
			Status = "Placeholder",
			Category = "Future Expansion",
			ZoneType = "Placeholder",
			HubSignOffset = Vector3.new(-128, 0, -36),
			HubPadOffset = Vector3.new(-40, 0, 78),
			HubBoardLabel = "Offroad",
			ShortLabel = "Offroad",
			LargeSignSubtitle = "Placeholder zone",
			FutureExpansionText = "Future offroad loops and obstacle staging",
		}),
		zone("future-amusement-park", "Future Amusement Park", Vector3.new(580, 0, 320), Vector3.new(250, 2, 220), {
			Color = Color3.fromRGB(178, 116, 164),
			Accent = Color3.fromRGB(255, 214, 247),
			Status = "Placeholder",
			Category = "Future Expansion",
			ZoneType = "Placeholder",
			HubSignOffset = Vector3.new(128, 0, 118),
			HubPadOffset = Vector3.new(-80, 0, 78),
			HubBoardLabel = "Amusement",
			ShortLabel = "Amusement",
			LargeSignSubtitle = "Placeholder zone",
			FutureExpansionText = "Future rides, midway, and event areas",
		}),
	},
	Roads = {
		road("PlazaToStromblad", Vector3.new(-70, 1.1, -70), Vector3.new(-220, 1.1, -240), 14),
		road("PlazaToGirlsHangout", Vector3.new(70, 1.1, -70), Vector3.new(220, 1.1, -240), 14),
		road("PlazaToFounderLounge", Vector3.new(80, 1.1, 70), Vector3.new(260, 1.1, 150), 14),
		road("PlazaToContentForge", Vector3.new(-80, 1.1, 70), Vector3.new(-300, 1.1, 170), 14),
		road("PlazaToBO6", Vector3.new(-90, 1.1, 10), Vector3.new(-300, 1.1, -20), 14),
		road("PlazaToWaterPark", Vector3.new(0, 1.1, 120), Vector3.new(0, 1.1, 410), 14),
		road("PlazaToOutdoorMall", Vector3.new(120, 1.1, 10), Vector3.new(430, 1.1, 35), 14),
		road("PlazaToDriveIn", Vector3.new(0, 1.1, -120), Vector3.new(0, 1.1, -470), 14),
		road("PlazaToOffroadTrack", Vector3.new(-120, 1.1, -40), Vector3.new(-500, 1.1, -260), 14),
		road("PlazaToAmusementPark", Vector3.new(120, 1.1, 90), Vector3.new(490, 1.1, 270), 14),
		road("StrombladToGirlsHangout", Vector3.new(-170, 1.1, -300), Vector3.new(170, 1.1, -300), 10, {
			Color = Color3.fromRGB(92, 92, 92),
		}),
		road("ContentForgeToBO6", Vector3.new(-360, 1.1, 120), Vector3.new(-360, 1.1, 50), 10, {
			Color = Color3.fromRGB(92, 92, 92),
		}),
	},
	Venues = {
		{
			Id = "stromblad-estate",
			Name = "Stromblad Estate",
			Theme = "Modern family estate with poolside social spaces",
			Position = Vector3.new(-260, 0, -300),
			Footprint = Vector3.new(112, 32, 106),
			Color = Color3.fromRGB(162, 131, 94),
			Accent = Color3.fromRGB(241, 219, 187),
			SpawnOffset = Vector3.new(0, 3, -26),
			Rooms = {
				room("Grand Foyer", Vector3.new(0, 0, -8), Vector3.new(38, 2, 20), {
					OpenSides = { "South" },
					FloorColor = Color3.fromRGB(214, 196, 170),
				}),
				room("Family Lounge", Vector3.new(-24, 0, 12), Vector3.new(30, 2, 26), {
					OpenSides = { "East", "South" },
					FloorColor = Color3.fromRGB(189, 171, 140),
				}),
				room("Kitchen Suite", Vector3.new(24, 0, 10), Vector3.new(30, 2, 24), {
					OpenSides = { "West", "South" },
					FloorColor = Color3.fromRGB(222, 205, 175),
				}),
				room("Pool Deck", Vector3.new(-18, 0, 40), Vector3.new(34, 2, 22), {
					OpenSides = { "North", "East" },
					FloorColor = Color3.fromRGB(170, 156, 132),
				}),
				room("Hot Tub Terrace", Vector3.new(16, 0, 40), Vector3.new(24, 2, 22), {
					OpenSides = { "North", "West" },
					FloorColor = Color3.fromRGB(160, 145, 123),
				}),
				room("Media Loft", Vector3.new(24, 0, 38), Vector3.new(30, 2, 22), {
					OpenSides = { "North", "West" },
					FloorColor = Color3.fromRGB(176, 160, 136),
				}),
			},
			Props = {
				prop("Entry Fountain", "Display", Vector3.new(0, 4, -18), Vector3.new(12, 8, 12), {
					Color = Color3.fromRGB(120, 101, 79),
					Accent = Color3.fromRGB(241, 219, 187),
					Label = "Estate Entry Fountain",
					Shape = Enum.PartType.Cylinder,
				}),
				prop("Estate Sectional", "Seat", Vector3.new(-30, 2, 12), Vector3.new(18, 4, 7), {
					Color = Color3.fromRGB(115, 89, 62),
					Material = Enum.Material.Fabric,
				}),
				prop("Coffee Table", "Table", Vector3.new(-14, 1.5, 12), Vector3.new(8, 3, 6), {
					Color = Color3.fromRGB(103, 70, 46),
					Material = Enum.Material.WoodPlanks,
				}),
				prop("Stone Fireplace", "Display", Vector3.new(-10, 6, 12), Vector3.new(14, 10, 2), {
					Color = Color3.fromRGB(96, 84, 70),
					Label = "Stone Fireplace",
				}),
				prop("Gallery Wall", "Display", Vector3.new(34, 7, -2), Vector3.new(16, 10, 1), {
					Color = Color3.fromRGB(58, 44, 30),
					Label = "Family Gallery",
				}),
				prop("Kitchen Island", "Table", Vector3.new(24, 2, 6), Vector3.new(16, 4, 8), {
					Color = Color3.fromRGB(118, 84, 57),
					Material = Enum.Material.WoodPlanks,
				}),
				prop("Dining Table", "Table", Vector3.new(24, 2, 18), Vector3.new(18, 4, 8), {
					Color = Color3.fromRGB(136, 101, 72),
					Material = Enum.Material.WoodPlanks,
				}),
				prop("Glass Walkway", "FloorPad", Vector3.new(0, 2.1, 28), Vector3.new(14, 0.2, 18), {
					Color = Color3.fromRGB(227, 240, 245),
					Material = Enum.Material.Glass,
					Transparency = 0.25,
				}),
				prop("Pool Placeholder", "Pool", Vector3.new(-18, 0, 40), Vector3.new(24, 4, 14), {
					Color = Color3.fromRGB(74, 142, 196),
					Accent = Color3.fromRGB(213, 232, 247),
				}),
				prop("Pool Chair A", "PoolChair", Vector3.new(-30, 2, 35), Vector3.new(8, 3, 4), {
					Color = Color3.fromRGB(247, 239, 230),
					Accent = Color3.fromRGB(162, 131, 94),
				}),
				prop("Pool Chair B", "PoolChair", Vector3.new(-30, 2, 45), Vector3.new(8, 3, 4), {
					Color = Color3.fromRGB(247, 239, 230),
					Accent = Color3.fromRGB(162, 131, 94),
				}),
				prop("Cabana Daybed", "Seat", Vector3.new(0, 2, 44), Vector3.new(16, 4, 6), {
					Color = Color3.fromRGB(188, 166, 136),
					Material = Enum.Material.Fabric,
				}),
				prop("Hot Tub Placeholder", "HotTub", Vector3.new(18, 0, 40), Vector3.new(12, 4, 12), {
					Color = Color3.fromRGB(72, 120, 158),
					Accent = Color3.fromRGB(230, 238, 244),
				}),
				prop("Fire Bowl", "Display", Vector3.new(30, 5, 42), Vector3.new(5, 5, 5), {
					Color = Color3.fromRGB(224, 131, 68),
					Material = Enum.Material.Neon,
					Label = "Fire Bowl",
					Shape = Enum.PartType.Ball,
				}),
				prop("Loft Console", "Table", Vector3.new(16, 2, 38), Vector3.new(10, 3, 5), {
					Color = Color3.fromRGB(92, 71, 52),
					Material = Enum.Material.WoodPlanks,
				}),
			},
			MediaPanels = {
				mediaPanel("Estate Memories", "Photo", Vector3.new(34, 8, 8), Vector3.new(18, 10, 1), {
					Title = "Estate Memories",
					Items = {
						"Welcome Home Portrait",
						"Family Lounge Snapshot",
						"Kitchen Night Hosting",
						"Poolside Golden Hour",
					},
				}),
				mediaPanel("Home Tour Showcase", "YouTube", Vector3.new(34, 8, 38), Vector3.new(18, 10, 1), {
					Title = "Home Tour Showcase",
				}),
				mediaPanel("Estate Soundtrack", "Spotify", Vector3.new(-2, 5, 30), Vector3.new(12, 8, 3), {
					Title = "Sunset Playlist",
				}),
			},
			Signs = {
				sign("The Stromblads", "Welcome Home", Vector3.new(0, 22, -51), {
					Size = Vector3.new(20, 10, 1),
				}),
				sign("Gather Here", "Family lounge + fireplace", Vector3.new(-24, 14, 2), {
					Size = Vector3.new(14, 8, 1),
				}),
				sign("Kitchen Suite", "Snacks, stories, and late-night chats", Vector3.new(24, 14, 0), {
					Size = Vector3.new(16, 8, 1),
				}),
				sign("Pool Deck", "Golden hour hangout", Vector3.new(-18, 14, 28), {
					Size = Vector3.new(12, 8, 1),
				}),
				sign("Spa Terrace", "Hot tub + fire bowl", Vector3.new(18, 14, 28), {
					Size = Vector3.new(12, 8, 1),
				}),
				sign("Media Loft", "Home tours and highlight reels", Vector3.new(24, 14, 28), {
					Size = Vector3.new(14, 8, 1),
				}),
			},
		},
		{
			Id = "girls-hangout",
			Name = "Girls Hangout",
			Theme = "Bright social hangout graybox",
			Position = Vector3.new(260, 0, -300),
			Footprint = Vector3.new(100, 28, 96),
			Color = Color3.fromRGB(255, 170, 214),
			Accent = Color3.fromRGB(255, 240, 248),
			SpawnOffset = Vector3.new(0, 3, -24),
			Rooms = {
				room("Arcade Room", Vector3.new(-24, 0, 6), Vector3.new(28, 2, 24), {
					OpenSides = { "East", "South" },
					FloorColor = Color3.fromRGB(255, 221, 239),
				}),
				room("Theater Room", Vector3.new(20, 0, 4), Vector3.new(30, 2, 26), {
					OpenSides = { "West", "South" },
					FloorColor = Color3.fromRGB(248, 206, 232),
				}),
				room("Streaming Corner", Vector3.new(-24, 0, 34), Vector3.new(24, 2, 22), {
					OpenSides = { "North", "East" },
					FloorColor = Color3.fromRGB(242, 190, 224),
				}),
				room("Lounge Seating", Vector3.new(20, 0, 34), Vector3.new(30, 2, 22), {
					OpenSides = { "North", "West" },
					FloorColor = Color3.fromRGB(255, 230, 242),
				}),
			},
			Props = {
				prop("Arcade Cabinet A", "ArcadeCabinet", Vector3.new(-36, 5, -1), Vector3.new(5, 10, 4), {
					Color = Color3.fromRGB(255, 94, 170),
					Accent = Color3.fromRGB(255, 220, 240),
				}),
				prop("Arcade Cabinet B", "ArcadeCabinet", Vector3.new(-36, 5, 7), Vector3.new(5, 10, 4), {
					Color = Color3.fromRGB(200, 60, 160),
					Accent = Color3.fromRGB(255, 220, 240),
				}),
				prop("Arcade Cabinet C", "ArcadeCabinet", Vector3.new(-36, 5, 15), Vector3.new(5, 10, 4), {
					Color = Color3.fromRGB(255, 130, 200),
					Accent = Color3.fromRGB(255, 220, 240),
				}),
				prop("Dance Floor", "FloorPad", Vector3.new(-22, 2.1, 8), Vector3.new(18, 0.2, 16), {
					Color = Color3.fromRGB(255, 80, 180),
					Material = Enum.Material.Neon,
					Transparency = 0.35,
				}),
				prop("Prize Counter", "Table", Vector3.new(-18, 2, -3), Vector3.new(14, 4, 4), {
					Color = Color3.fromRGB(230, 160, 210),
					Material = Enum.Material.WoodPlanks,
				}),
				prop("Cinema Screen", "CinemaScreen", Vector3.new(20, 10, -7), Vector3.new(22, 12, 1), {
					Color = Color3.fromRGB(255, 170, 214),
					Accent = Color3.fromRGB(255, 240, 248),
				}),
				prop("Front Row Seats", "Seat", Vector3.new(20, 2, 4), Vector3.new(22, 4, 6), {
					Color = Color3.fromRGB(221, 145, 195),
					Material = Enum.Material.Fabric,
				}),
				prop("Back Row Seats", "Seat", Vector3.new(20, 2, 11), Vector3.new(22, 4, 6), {
					Color = Color3.fromRGB(200, 120, 175),
					Material = Enum.Material.Fabric,
				}),
				prop("Popcorn Stand", "Table", Vector3.new(10, 2, 15), Vector3.new(4, 6, 4), {
					Color = Color3.fromRGB(240, 180, 60),
					Material = Enum.Material.SmoothPlastic,
				}),
				prop("Streaming Desk", "Table", Vector3.new(-26, 1.5, 34), Vector3.new(10, 3, 5), {
					Color = Color3.fromRGB(198, 137, 181),
					Material = Enum.Material.WoodPlanks,
				}),
				prop("Ring Light", "Display", Vector3.new(-36, 9, 34), Vector3.new(6, 6, 1), {
					Color = Color3.fromRGB(255, 250, 220),
					Material = Enum.Material.Neon,
					Shape = Enum.PartType.Cylinder,
				}),
				prop("Gaming Chair", "Seat", Vector3.new(-22, 2, 38), Vector3.new(5, 8, 5), {
					Color = Color3.fromRGB(180, 80, 150),
					Material = Enum.Material.Fabric,
				}),
				prop("Pool", "Pool", Vector3.new(0, 0, 40), Vector3.new(22, 4, 12), {
					Color = Color3.fromRGB(104, 193, 255),
					Accent = Color3.fromRGB(235, 247, 255),
				}),
				prop("Water Slide", "Slide", Vector3.new(18, 0, 42), Vector3.new(18, 8, 6), {
					Color = Color3.fromRGB(255, 124, 198),
					Accent = Color3.fromRGB(255, 255, 255),
				}),
				prop("Pool Chair A", "PoolChair", Vector3.new(-18, 2, 36), Vector3.new(8, 3, 4), {
					Color = Color3.fromRGB(255, 240, 240),
					Accent = Color3.fromRGB(255, 170, 214),
				}),
				prop("Pool Chair B", "PoolChair", Vector3.new(-18, 2, 44), Vector3.new(8, 3, 4), {
					Color = Color3.fromRGB(255, 240, 240),
					Accent = Color3.fromRGB(255, 170, 214),
				}),
				prop("Umbrella Post", "Display", Vector3.new(-28, 7, 40), Vector3.new(1.5, 14, 1.5), {
					Color = Color3.fromRGB(255, 240, 248),
					Material = Enum.Material.Metal,
				}),
				prop("VIP Floor Pad", "FloorPad", Vector3.new(28, 2.1, 40), Vector3.new(14, 0.2, 14), {
					Color = Color3.fromRGB(255, 200, 230),
					Material = Enum.Material.Neon,
					Transparency = 0.25,
				}),
				prop("VIP Star Wall", "VIPDisplay", Vector3.new(34, 10, 40), Vector3.new(18, 12, 1), {
					Color = Color3.fromRGB(255, 170, 214),
					Accent = Color3.fromRGB(255, 240, 248),
					Label = "VIP Star Lounge",
					Message = "Welcome, superstar! Abbie, Lue, Emi & Sophia — this spot is yours.",
				}),
			},
			MediaPanels = {
				mediaPanel("Theater Slideshow", "Photo", Vector3.new(28, 8, 2), Vector3.new(20, 10, 1), {
					Title = "Theater Slideshow",
				}),
				mediaPanel("Hangout Stream", "Twitch", Vector3.new(-10, 8, 34), Vector3.new(18, 10, 1), {
					Title = "Streaming Corner",
				}),
				mediaPanel("Girls Playlist", "Spotify", Vector3.new(16, 5, 34), Vector3.new(12, 8, 3), {
					Title = "Girls Playlist",
				}),
			},
			Signs = {
				sign("Girls Hangout", "Abbie · Lue · Emi · Emi · Sophia", Vector3.new(0, 20, -44), {
					Size = Vector3.new(28, 10, 1),
				}),
				sign("Abbie", "Arcade Captain", Vector3.new(-24, 14, -5), {
					Size = Vector3.new(10, 8, 1),
				}),
				sign("Lue", "Theater Host", Vector3.new(20, 14, -5), {
					Size = Vector3.new(10, 8, 1),
				}),
				sign("Emi", "Streaming Queen", Vector3.new(-24, 14, 23), {
					Size = Vector3.new(10, 8, 1),
				}),
				sign("Emi", "Lounge Lead", Vector3.new(20, 14, 23), {
					Size = Vector3.new(10, 8, 1),
				}),
				sign("Sophia", "Pool Queen", Vector3.new(0, 14, 44), {
					Size = Vector3.new(10, 8, 1),
				}),
			},
		},
		{
			Id = "founder-lounge",
			Name = "Founder Lounge",
			Theme = "Premium founder networking graybox",
			Position = Vector3.new(320, 0, 180),
			Footprint = Vector3.new(102, 30, 88),
			Color = Color3.fromRGB(48, 58, 74),
			Accent = Color3.fromRGB(215, 191, 126),
			SpawnOffset = Vector3.new(0, 3, -22),
			Rooms = {
				room("Founder Wall", Vector3.new(-24, 0, 6), Vector3.new(28, 2, 22), {
					OpenSides = { "East", "South" },
					FloorColor = Color3.fromRGB(62, 73, 89),
				}),
				room("VIP Lounge", Vector3.new(20, 0, 6), Vector3.new(30, 2, 22), {
					OpenSides = { "West", "South" },
					FloorColor = Color3.fromRGB(53, 63, 79),
				}),
				room("Media Viewing Wall", Vector3.new(20, 0, 34), Vector3.new(30, 2, 22), {
					OpenSides = { "West", "North" },
					FloorColor = Color3.fromRGB(58, 68, 84),
				}),
				room("Spotify Station Area", Vector3.new(-24, 0, 34), Vector3.new(28, 2, 22), {
					OpenSides = { "East", "North" },
					FloorColor = Color3.fromRGB(46, 56, 72),
				}),
			},
			Props = {
				prop("Founder Title Display", "Display", Vector3.new(-26, 7, 4), Vector3.new(18, 10, 1), {
					Color = Color3.fromRGB(35, 40, 52),
					Label = "Founder: xD0DgeThiSx",
				}),
				prop("VIP Couch", "Seat", Vector3.new(22, 2, 10), Vector3.new(18, 4, 8), {
					Color = Color3.fromRGB(79, 66, 44),
					Material = Enum.Material.Leather,
				}),
				prop("VIP Table", "Table", Vector3.new(22, 1.5, 20), Vector3.new(10, 3, 6), {
					Color = Color3.fromRGB(96, 81, 54),
					Material = Enum.Material.WoodPlanks,
				}),
				prop("Founder Names Wall", "Display", Vector3.new(-28, 7, 18), Vector3.new(20, 10, 1), {
					Color = Color3.fromRGB(29, 35, 45),
					Label = "VIP Roll Call",
				}),
			},
			MediaPanels = {
				mediaPanel("Founder Playlist", "Spotify", Vector3.new(-20, 5, 34), Vector3.new(12, 8, 3), {
					Title = "Founder Playlist",
				}),
				mediaPanel("Founder Twitch Wall", "Twitch", Vector3.new(28, 8, 30), Vector3.new(18, 10, 1), {
					Title = "Founder Twitch Wall",
				}),
				mediaPanel("Founder YouTube Wall", "YouTube", Vector3.new(28, 8, 40), Vector3.new(18, 10, 1), {
					Title = "Founder YouTube Wall",
				}),
			},
			Signs = {
				sign("Founder Lounge", "Founder: xD0DgeThiSx", Vector3.new(0, 21, -47), {
					Size = Vector3.new(18, 10, 1),
				}),
			},
		},
		{
			Id = "contentforge-studio",
			Name = "ContentForge Studio",
			Theme = "Creator production studio graybox",
			Position = Vector3.new(-360, 0, 210),
			Footprint = Vector3.new(118, 30, 96),
			Color = Color3.fromRGB(68, 94, 123),
			Accent = Color3.fromRGB(181, 224, 255),
			SpawnOffset = Vector3.new(0, 3, -24),
			Rooms = {
				room("Creator Studio", Vector3.new(-28, 0, 6), Vector3.new(30, 2, 24), {
					OpenSides = { "East", "South" },
					FloorColor = Color3.fromRGB(89, 116, 146),
				}),
				room("Podcast Area", Vector3.new(22, 0, 6), Vector3.new(32, 2, 24), {
					OpenSides = { "West", "South" },
					FloorColor = Color3.fromRGB(80, 104, 132),
				}),
				room("YouTube Recording Set", Vector3.new(-28, 0, 36), Vector3.new(30, 2, 24), {
					OpenSides = { "East", "North" },
					FloorColor = Color3.fromRGB(75, 102, 132),
				}),
				room("AI Command Center", Vector3.new(22, 0, 36), Vector3.new(32, 2, 24), {
					OpenSides = { "West", "North" },
					FloorColor = Color3.fromRGB(67, 94, 124),
				}),
			},
			Props = {
				prop("Studio Desk", "Table", Vector3.new(-30, 1.5, 6), Vector3.new(16, 3, 6), {
					Color = Color3.fromRGB(48, 68, 92),
					Material = Enum.Material.Metal,
				}),
				prop("Podcast Table", "Table", Vector3.new(22, 1.5, 8), Vector3.new(12, 3, 12), {
					Color = Color3.fromRGB(55, 75, 100),
					Material = Enum.Material.WoodPlanks,
				}),
				prop("Recording Backdrop", "Display", Vector3.new(-30, 7, 34), Vector3.new(18, 10, 1), {
					Color = Color3.fromRGB(33, 48, 66),
				}),
				prop("AI Command Center", "CommandCenter", Vector3.new(20, 4, 34), Vector3.new(18, 8, 6), {
					Color = Color3.fromRGB(28, 49, 72),
				}),
				prop("Digital Product Showcase", "Display", Vector3.new(38, 6, 14), Vector3.new(12, 10, 1), {
					Color = Color3.fromRGB(37, 59, 82),
				}),
			},
			MediaPanels = {
				mediaPanel("Studio Slideshow", "Photo", Vector3.new(-12, 8, 36), Vector3.new(18, 10, 1), {
					Title = "Studio Slideshow",
				}),
				mediaPanel("Creator Stream Wall", "Twitch", Vector3.new(34, 8, 36), Vector3.new(18, 10, 1), {
					Title = "Creator Stream Wall",
				}),
				mediaPanel("YouTube Recording Feed", "YouTube", Vector3.new(-12, 8, 46), Vector3.new(18, 10, 1), {
					Title = "YouTube Recording Feed",
				}),
			},
			Signs = {
				sign("ContentForge Studio", "Create. Record. Launch.", Vector3.new(0, 21, -47), {
					Size = Vector3.new(20, 10, 1),
				}),
			},
		},
		{
			Id = "bo6-gaming-lounge",
			Name = "BO6 Gaming Lounge",
			Theme = "Competitive gaming graybox lounge",
			Position = Vector3.new(-360, 0, -40),
			Footprint = Vector3.new(108, 28, 90),
			Color = Color3.fromRGB(40, 40, 40),
			Accent = Color3.fromRGB(255, 111, 0),
			SpawnOffset = Vector3.new(0, 3, -22),
			Rooms = {
				room("Gaming Stations", Vector3.new(-28, 0, 8), Vector3.new(32, 2, 24), {
					OpenSides = { "East", "South" },
					FloorColor = Color3.fromRGB(56, 56, 56),
				}),
				room("Tournament Seating", Vector3.new(22, 0, 8), Vector3.new(34, 2, 24), {
					OpenSides = { "West", "South" },
					FloorColor = Color3.fromRGB(62, 62, 62),
				}),
				room("Squad Wall", Vector3.new(-28, 0, 36), Vector3.new(32, 2, 20), {
					OpenSides = { "East", "North" },
					FloorColor = Color3.fromRGB(52, 52, 52),
				}),
				room("Streaming Wall", Vector3.new(22, 0, 36), Vector3.new(34, 2, 20), {
					OpenSides = { "West", "North" },
					FloorColor = Color3.fromRGB(49, 49, 49),
				}),
			},
			Props = {
				prop("Gaming Pods", "GamingStation", Vector3.new(-32, 4, 8), Vector3.new(18, 8, 6), {
					Color = Color3.fromRGB(26, 26, 26),
					Accent = Color3.fromRGB(255, 111, 0),
				}),
				prop("Tournament Benches", "Seat", Vector3.new(24, 2, 10), Vector3.new(20, 4, 8), {
					Color = Color3.fromRGB(79, 79, 79),
					Material = Enum.Material.Metal,
				}),
				prop("Squad Wall Display", "Display", Vector3.new(-34, 7, 34), Vector3.new(18, 10, 1), {
					Color = Color3.fromRGB(26, 26, 26),
					Label = "Squad Wall",
				}),
				prop("xD0DgeThiSx Feature Display", "Display", Vector3.new(34, 7, 12), Vector3.new(18, 10, 1), {
					Color = Color3.fromRGB(26, 26, 26),
					Label = "Featured Founder: xD0DgeThiSx",
				}),
			},
			MediaPanels = {
				mediaPanel("BO6 Streaming Wall", "Twitch", Vector3.new(30, 8, 34), Vector3.new(18, 10, 1), {
					Title = "BO6 Streaming Wall",
				}),
				mediaPanel("BO6 Showcase", "YouTube", Vector3.new(30, 8, 44), Vector3.new(18, 10, 1), {
					Title = "BO6 Showcase",
				}),
				mediaPanel("Pre-Match Playlist", "Spotify", Vector3.new(-14, 5, 34), Vector3.new(12, 8, 3), {
					Title = "Pre-Match Playlist",
				}),
			},
			Signs = {
				sign("BO6 Gaming Lounge", "xD0DgeThiSx Feature Zone", Vector3.new(0, 20, -44), {
					Size = Vector3.new(20, 10, 1),
				}),
			},
		},
	},
}

return WorldConfig
