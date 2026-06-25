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

local function vehicle(id, name, position, options)
	return withOptions({
		Id = id,
		Name = name,
		Position = position,
		VehicleType = "Bronco",
		Color = Color3.fromRGB(20, 20, 20),
		Accent = Color3.fromRGB(60, 60, 60),
		TrimColor = Color3.fromRGB(100, 100, 100),
		PlateText = id,
		Owner = nil,
		Heading = 0,
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
		zone("bo6-gaming-lounge", "Black Ops 7 Gaming Lounge", Vector3.new(-360, 0, -40), Vector3.new(196, 2, 168), {
			Color = Color3.fromRGB(60, 60, 60),
			Accent = Color3.fromRGB(255, 111, 0),
			Category = "Venue",
			ZoneType = "Active",
			HubSignOffset = Vector3.new(-154, 0, -18),
			HubPadOffset = Vector3.new(-106, 0, -10),
			HubBoardLabel = "Black Ops 7",
			ShortLabel = "Black Ops 7",
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
			Status = "Active",
			Category = "Venue",
			ZoneType = "Active",
			HubSignOffset = Vector3.new(0, 0, 126),
			HubPadOffset = Vector3.new(0, 0, 78),
			HubBoardLabel = "Water Park",
			ShortLabel = "Water Park",
			LargeSignSubtitle = "Slides, splash pads & lazy river",
			FutureExpansionText = "Water attractions, slides, and splash zones",
			TeleportDestinationId = "water-park",
			PathColor = Color3.fromRGB(95, 185, 230),
			PathStartOffset = Vector3.new(0, 0, 42),
			PathEndOffset = Vector3.new(0, 0, 132),
		}),
		zone("outdoor-mall", "Outdoor Mall", Vector3.new(520, 0, 40), Vector3.new(210, 2, 180), {
			Color = Color3.fromRGB(201, 196, 174),
			Accent = Color3.fromRGB(255, 247, 216),
			Status = "Active",
			Category = "Venue",
			ZoneType = "Active",
			HubSignOffset = Vector3.new(126, 0, 24),
			HubPadOffset = Vector3.new(40, 0, 78),
			HubBoardLabel = "Outdoor Mall",
			ShortLabel = "Mall",
			LargeSignSubtitle = "Storefronts and social spaces",
			FutureExpansionText = "Active shopping district with boutique row and creator pop-ups",
			TeleportDestinationId = "outdoor-mall",
			PathColor = Color3.fromRGB(255, 247, 216),
			PathStartOffset = Vector3.new(42, 0, 0),
			PathEndOffset = Vector3.new(122, 0, 22),
		}),
		zone("drive-in-theater", "Drive-In Theater", Vector3.new(0, 0, -560), Vector3.new(240, 2, 210), {
			Color = Color3.fromRGB(66, 55, 78),
			Accent = Color3.fromRGB(222, 205, 255),
			Status = "Active",
			Category = "Venue",
			ZoneType = "Active",
			HubSignOffset = Vector3.new(0, 0, -130),
			HubPadOffset = Vector3.new(80, 0, 78),
			HubBoardLabel = "Drive-In",
			ShortLabel = "Drive-In",
			LargeSignSubtitle = "Movie nights and watch parties",
			FutureExpansionText = "Active theater district with snack bar and projection booth",
			TeleportDestinationId = "drive-in-theater",
			PathColor = Color3.fromRGB(222, 205, 255),
			PathStartOffset = Vector3.new(0, 0, -36),
			PathEndOffset = Vector3.new(0, 0, -128),
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
		road("PlazaToBlack Ops 7", Vector3.new(-90, 1.1, 10), Vector3.new(-300, 1.1, -20), 14),
		road("PlazaToWaterPark", Vector3.new(0, 1.1, 120), Vector3.new(0, 1.1, 410), 14),
		road("PlazaToOutdoorMall", Vector3.new(120, 1.1, 10), Vector3.new(430, 1.1, 35), 14),
		road("PlazaToDriveIn", Vector3.new(0, 1.1, -120), Vector3.new(0, 1.1, -470), 14),
		road("PlazaToOffroadTrack", Vector3.new(-120, 1.1, -40), Vector3.new(-500, 1.1, -260), 14),
		road("PlazaToAmusementPark", Vector3.new(120, 1.1, 90), Vector3.new(490, 1.1, 270), 14),
		road("StrombladToGirlsHangout", Vector3.new(-170, 1.1, -300), Vector3.new(170, 1.1, -300), 10, {
			Color = Color3.fromRGB(92, 92, 92),
		}),
		road("ContentForgeToBlack Ops 7", Vector3.new(-360, 1.1, 120), Vector3.new(-360, 1.1, 50), 10, {
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
				room("Master Suite", Vector3.new(-20, 0, -36), Vector3.new(28, 2, 20), {
					OpenSides = { "South" },
					FloorColor = Color3.fromRGB(198, 182, 158),
				}),
				room("En-Suite Bath", Vector3.new(20, 0, -36), Vector3.new(24, 2, 18), {
					OpenSides = { "South" },
					FloorColor = Color3.fromRGB(218, 210, 198),
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
				prop("Terrace Walkway", "FloorPad", Vector3.new(0, 2.1, 30), Vector3.new(16, 0.2, 16), {
					Color = Color3.fromRGB(240, 245, 248),
					Material = Enum.Material.Glass,
					Transparency = 0.15,
					HideBillboard = true,
				}),
				prop("Estate Pool", "Pool", Vector3.new(-20, 0, 40), Vector3.new(24, 4, 14), {
					Color = Color3.fromRGB(96, 182, 230),
					Accent = Color3.fromRGB(231, 244, 250),
					Label = "Estate Pool",
					Subtitle = "Pool Deck",
				}),
				prop("Pool Chair A", "PoolChair", Vector3.new(-30, 2, 35), Vector3.new(8, 3, 4), {
					Color = Color3.fromRGB(247, 239, 230),
					Accent = Color3.fromRGB(231, 220, 202),
					HideBillboard = true,
				}),
				prop("Pool Chair B", "PoolChair", Vector3.new(-30, 2, 45), Vector3.new(8, 3, 4), {
					Color = Color3.fromRGB(247, 239, 230),
					Accent = Color3.fromRGB(231, 220, 202),
					HideBillboard = true,
				}),
				prop("Cabana Daybed", "Seat", Vector3.new(-6, 2, 50), Vector3.new(12, 3, 4), {
					Color = Color3.fromRGB(214, 197, 171),
					Material = Enum.Material.Fabric,
					HideBillboard = true,
				}),
				prop("Family Spa", "HotTub", Vector3.new(20, 0, 40), Vector3.new(12, 4, 12), {
					Color = Color3.fromRGB(106, 166, 208),
					Accent = Color3.fromRGB(238, 244, 248),
					Label = "Family Spa",
					Subtitle = "Spa Terrace",
				}),
				prop("Fire Bowl", "Display", Vector3.new(30, 5, 42), Vector3.new(5, 5, 5), {
					Color = Color3.fromRGB(238, 154, 82),
					Material = Enum.Material.Neon,
					Label = "Fire Bowl",
					Shape = Enum.PartType.Ball,
				}),
				prop("Spa Side Table", "Table", Vector3.new(30, 1.5, 48), Vector3.new(4, 3, 4), {
					Color = Color3.fromRGB(156, 124, 93),
					Material = Enum.Material.WoodPlanks,
					HideBillboard = true,
				}),
				prop("Loft Console", "Table", Vector3.new(18, 2, 38), Vector3.new(8, 3, 4), {
					Color = Color3.fromRGB(112, 92, 70),
					Material = Enum.Material.WoodPlanks,
					HideBillboard = true,
				}),
				prop("Loft Screen", "CinemaScreen", Vector3.new(24, 11, 48), Vector3.new(20, 11, 1), {
					Color = Color3.fromRGB(162, 131, 94),
					Accent = Color3.fromRGB(241, 219, 187),
					Label = "Media Loft Screen",
				}),
				prop("Lounge TV", "CinemaScreen", Vector3.new(-14, 10, 22), Vector3.new(14, 9, 1), {
					Color = Color3.fromRGB(50, 40, 30),
					Accent = Color3.fromRGB(241, 219, 187),
					Label = "Family Lounge TV",
				}),
				-- Master Suite
				prop("King Bed", "Seat", Vector3.new(-20, 2, -38), Vector3.new(16, 4, 10), {
					Color = Color3.fromRGB(107, 79, 57),
					Material = Enum.Material.Fabric,
					Label = "King Bed",
				}),
				prop("Bed Headboard", "Display", Vector3.new(-20, 6, -44), Vector3.new(16, 8, 1), {
					Color = Color3.fromRGB(88, 62, 40),
					Label = "Master Suite",
				}),
				prop("Bedside Table A", "Table", Vector3.new(-10, 1.5, -42), Vector3.new(4, 3, 4), {
					Color = Color3.fromRGB(115, 89, 64),
					Material = Enum.Material.WoodPlanks,
					HideBillboard = true,
				}),
				prop("Bedside Table B", "Table", Vector3.new(-30, 1.5, -42), Vector3.new(4, 3, 4), {
					Color = Color3.fromRGB(115, 89, 64),
					Material = Enum.Material.WoodPlanks,
					HideBillboard = true,
				}),
				prop("Bed Lamp", "Display", Vector3.new(-9, 5, -44), Vector3.new(2, 5, 2), {
					Color = Color3.fromRGB(255, 228, 172),
					Material = Enum.Material.Neon,
					Shape = Enum.PartType.Ball,
					HideBillboard = true,
				}),
				prop("Armoire", "Display", Vector3.new(-30, 8, -44), Vector3.new(9, 14, 3), {
					Color = Color3.fromRGB(88, 62, 40),
					Label = "Armoire",
				}),
				-- En-Suite Bath
				prop("Soaking Tub", "HotTub", Vector3.new(24, 0, -38), Vector3.new(10, 3, 8), {
					Color = Color3.fromRGB(120, 172, 210),
					Accent = Color3.fromRGB(238, 234, 228),
					Label = "Soaking Tub",
					Subtitle = "En-Suite",
				}),
				prop("Double Vanity", "Table", Vector3.new(12, 1.5, -44), Vector3.new(14, 4, 4), {
					Color = Color3.fromRGB(210, 200, 185),
					Material = Enum.Material.SmoothPlastic,
					HideBillboard = true,
				}),
				prop("Vanity Mirror", "Display", Vector3.new(12, 8, -44), Vector3.new(14, 8, 1), {
					Color = Color3.fromRGB(180, 175, 168),
					Label = "Vanity Mirror",
				}),
				prop("Towel Rail", "Display", Vector3.new(30, 6, -42), Vector3.new(6, 4, 1), {
					Color = Color3.fromRGB(180, 180, 180),
					Material = Enum.Material.Metal,
					Label = "Towel Rail",
				}),
				-- Family Lounge fills
				prop("Bookshelf Wall", "Display", Vector3.new(-36, 8, 10), Vector3.new(1, 14, 14), {
					Color = Color3.fromRGB(72, 52, 34),
					Label = "Family Bookshelf",
				}),
				prop("Entertainment Console", "Table", Vector3.new(-14, 2, 22), Vector3.new(14, 4, 4), {
					Color = Color3.fromRGB(85, 63, 44),
					Material = Enum.Material.WoodPlanks,
					HideBillboard = true,
				}),
				-- Kitchen Suite fills
				prop("Bar Stools", "Seat", Vector3.new(24, 2, 2), Vector3.new(14, 4, 4), {
					Color = Color3.fromRGB(94, 72, 54),
					Material = Enum.Material.Leather,
					HideBillboard = true,
				}),
				prop("Pantry Cabinet", "Display", Vector3.new(36, 8, 4), Vector3.new(5, 14, 4), {
					Color = Color3.fromRGB(222, 210, 186),
					Label = "Pantry",
				}),
				prop("Refrigerator", "Display", Vector3.new(36, 8, 16), Vector3.new(5, 14, 4), {
					Color = Color3.fromRGB(210, 207, 200),
					Label = "Refrigerator",
				}),
				-- Grand Foyer fills
				prop("Entry Bench", "Seat", Vector3.new(0, 1.5, -14), Vector3.new(12, 3, 4), {
					Color = Color3.fromRGB(115, 89, 64),
					Material = Enum.Material.WoodPlanks,
					HideBillboard = true,
				}),
				prop("Potted Plant A", "Display", Vector3.new(-14, 5, -12), Vector3.new(5, 8, 5), {
					Color = Color3.fromRGB(76, 128, 58),
					Shape = Enum.PartType.Ball,
					HideBillboard = true,
				}),
				prop("Potted Plant B", "Display", Vector3.new(14, 5, -12), Vector3.new(5, 8, 5), {
					Color = Color3.fromRGB(76, 128, 58),
					Shape = Enum.PartType.Ball,
					HideBillboard = true,
				}),
				prop("Pool Slide", "Slide", Vector3.new(-7, 0, 44), Vector3.new(8, 7, 5), {
					Color = Color3.fromRGB(241, 219, 187),
					Accent = Color3.fromRGB(162, 131, 94),
					Label = "Pool Slide",
				}),
				prop("Pool Neon Edge", "FloorPad", Vector3.new(-20, 2.15, 47), Vector3.new(26, 0.2, 0.5), {
					Color = Color3.fromRGB(96, 182, 230),
					Material = Enum.Material.Neon,
					Transparency = 0.2,
					HideBillboard = true,
				}),
				-- Phase 8: Pool Waterfall
				prop("Pool Waterfall", "Display", Vector3.new(-18, 10, 44), Vector3.new(8, 14, 1), {
					Color = Color3.fromRGB(80, 180, 240),
					Material = Enum.Material.Glass,
					Transparency = 0.22,
					HideBillboard = true,
				}),
				prop("Waterfall Foam", "FloorPad", Vector3.new(-18, 2.5, 43.5), Vector3.new(8, 0.3, 2), {
					Color = Color3.fromRGB(200, 235, 255),
					Material = Enum.Material.Neon,
					Transparency = 0.2,
					HideBillboard = true,
				}),
				prop("Waterfall Cascade A", "Display", Vector3.new(-18, 5, 43.5), Vector3.new(6, 6, 0.5), {
					Color = Color3.fromRGB(100, 200, 255),
					Material = Enum.Material.Glass,
					Transparency = 0.45,
					HideBillboard = true,
				}),
				-- Phase 8: Hot Tub Bubbles
				prop("Spa Bubbles", "FloorPad", Vector3.new(20, 2.55, 36), Vector3.new(10, 0.3, 10), {
					Color = Color3.fromRGB(120, 200, 255),
					Material = Enum.Material.Neon,
					Transparency = 0.12,
					HideBillboard = true,
				}),
				prop("Spa Steam", "Display", Vector3.new(20, 5, 36), Vector3.new(10, 4, 10), {
					Color = Color3.fromRGB(200, 230, 255),
					Material = Enum.Material.SmoothPlastic,
					Transparency = 0.88,
					HideBillboard = true,
				}),
				-- Phase 8: Stromblad Treehouse
				prop("Estate Tree Trunk", "Display", Vector3.new(52, 26, -14), Vector3.new(4, 50, 4), {
					Color = Color3.fromRGB(80, 55, 25),
					Material = Enum.Material.Wood,
					HideBillboard = true,
				}),
				prop("Estate Treehouse Platform", "Display", Vector3.new(52, 50, -14), Vector3.new(20, 2, 20), {
					Color = Color3.fromRGB(120, 80, 40),
					Material = Enum.Material.WoodPlanks,
					HideBillboard = true,
				}),
				prop("Estate Treehouse Wall S", "Display", Vector3.new(52, 60, -5), Vector3.new(20, 14, 1), {
					Color = Color3.fromRGB(140, 100, 50),
					Material = Enum.Material.WoodPlanks,
					HideBillboard = true,
				}),
				prop("Estate Treehouse Wall W", "Display", Vector3.new(43, 60, -14), Vector3.new(1, 14, 18), {
					Color = Color3.fromRGB(140, 100, 50),
					Material = Enum.Material.WoodPlanks,
					HideBillboard = true,
				}),
				prop("Estate Treehouse Roof", "Display", Vector3.new(52, 67, -14), Vector3.new(22, 2, 22), {
					Color = Color3.fromRGB(160, 120, 60),
					Material = Enum.Material.WoodPlanks,
					HideBillboard = true,
				}),
				prop("Estate Treehouse Sign", "Display", Vector3.new(52, 58, -4.4), Vector3.new(14, 6, 0.5), {
					Color = Color3.fromRGB(200, 160, 90),
					Material = Enum.Material.Neon,
					Label = "Stromblad Treehouse",
					Message = "Stromblad Estate Treehouse — zipline connects to Girls Hangout!",
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
				sign("Master Suite", "Private quarters", Vector3.new(-20, 14, -44), {
					Size = Vector3.new(14, 8, 1),
				}),
				sign("En-Suite", "Bath and spa", Vector3.new(20, 14, -44), {
					Size = Vector3.new(12, 8, 1),
				}),
			},
		},
		{
			Id = "girls-hangout",
			Name = "Girls Hangout",
			Theme = "Bright social hangout graybox",
			Position = Vector3.new(260, 0, -300),
			Footprint = Vector3.new(140, 30, 126),
			Color = Color3.fromRGB(255, 170, 214),
			Accent = Color3.fromRGB(255, 240, 248),
			SpawnOffset = Vector3.new(0, 3, -32),
			ReturnPadOffset = Vector3.new(-46, 0.5, -44),
			ReturnPadOptions = {
				MarkerOffset = Vector3.new(0, 5, -7),
				MarkerColor = Color3.fromRGB(78, 38, 70),
				Subtitle = "Return",
			},
			AmbientSoundId = 0, -- replace with Roblox pop/party music asset ID
			Rooms = {
				room("Abbie's Birthday Room", Vector3.new(0, 0, -40), Vector3.new(44, 2, 22), {
					OpenSides = { "South" },
					FloorColor = Color3.fromRGB(255, 220, 240),
					WallColor = Color3.fromRGB(255, 140, 200),
					LabelSize = Vector3.new(18, 5, 1),
				}),
				room("Arcade Room", Vector3.new(-36, 0, 0), Vector3.new(36, 2, 30), {
					OpenSides = { "East", "South" },
					FloorColor = Color3.fromRGB(255, 221, 239),
					LabelSize = Vector3.new(16, 5, 1),
				}),
				room("Theater Room", Vector3.new(34, 0, 0), Vector3.new(40, 2, 32), {
					OpenSides = { "West", "South" },
					FloorColor = Color3.fromRGB(248, 206, 232),
					LabelSize = Vector3.new(18, 5, 1),
				}),
				room("Streaming Corner", Vector3.new(-38, 0, 38), Vector3.new(30, 2, 24), {
					OpenSides = { "North", "East" },
					FloorColor = Color3.fromRGB(242, 190, 224),
					LabelSize = Vector3.new(16, 5, 1),
				}),
				room("Lounge Seating", Vector3.new(18, 0, 38), Vector3.new(38, 2, 24), {
					OpenSides = { "North", "West" },
					FloorColor = Color3.fromRGB(255, 230, 242),
					LabelSize = Vector3.new(18, 5, 1),
				}),
			},
			Props = {
				prop("Arcade Cabinet A", "ArcadeCabinet", Vector3.new(-52, 5, -6), Vector3.new(5, 10, 4), {
					Color = Color3.fromRGB(255, 94, 170),
					Accent = Color3.fromRGB(255, 220, 240),
				}),
				prop("Arcade Cabinet B", "ArcadeCabinet", Vector3.new(-52, 5, 4), Vector3.new(5, 10, 4), {
					Color = Color3.fromRGB(200, 60, 160),
					Accent = Color3.fromRGB(255, 220, 240),
				}),
				prop("Arcade Cabinet C", "ArcadeCabinet", Vector3.new(-52, 5, 14), Vector3.new(5, 10, 4), {
					Color = Color3.fromRGB(255, 130, 200),
					Accent = Color3.fromRGB(255, 220, 240),
				}),
				prop("Dance Floor", "FloorPad", Vector3.new(-36, 2.1, 10), Vector3.new(24, 0.2, 20), {
					Color = Color3.fromRGB(255, 80, 180),
					Material = Enum.Material.Neon,
					Transparency = 0.35,
					HideBillboard = true,
				}),
				prop("Prize Counter", "Table", Vector3.new(-34, 2, -12), Vector3.new(16, 4, 4), {
					Color = Color3.fromRGB(230, 160, 210),
					Material = Enum.Material.WoodPlanks,
					HideBillboard = true,
				}),
				prop("DJ Booth", "Table", Vector3.new(-48, 4, -14), Vector3.new(10, 6, 4), {
					Color = Color3.fromRGB(35, 20, 45),
					Material = Enum.Material.Metal,
					Label = "DJ Booth",
				}),
				prop("DJ Light Bar", "Display", Vector3.new(-48, 8, -14), Vector3.new(10, 1.5, 1), {
					Color = Color3.fromRGB(255, 80, 180),
					Material = Enum.Material.Neon,
					HideBillboard = true,
				}),
				prop("Cinema Screen", "CinemaScreen", Vector3.new(34, 10, -8), Vector3.new(26, 12, 1), {
					Color = Color3.fromRGB(255, 170, 214),
					Accent = Color3.fromRGB(255, 240, 248),
				}),
				prop("Front Row Seats", "Seat", Vector3.new(34, 2, 4), Vector3.new(24, 4, 6), {
					Color = Color3.fromRGB(221, 145, 195),
					Material = Enum.Material.Fabric,
				}),
				prop("Back Row Seats", "Seat", Vector3.new(34, 2, 13), Vector3.new(24, 4, 6), {
					Color = Color3.fromRGB(200, 120, 175),
					Material = Enum.Material.Fabric,
				}),
				prop("Popcorn Stand", "Table", Vector3.new(16, 2, 18), Vector3.new(5, 6, 5), {
					Color = Color3.fromRGB(240, 180, 60),
					Material = Enum.Material.SmoothPlastic,
				}),
				prop("Streaming Desk", "Table", Vector3.new(-42, 1.5, 38), Vector3.new(12, 3, 5), {
					Color = Color3.fromRGB(198, 137, 181),
					Material = Enum.Material.WoodPlanks,
				}),
				prop("Ring Light", "Display", Vector3.new(-54, 9, 38), Vector3.new(6, 6, 1), {
					Color = Color3.fromRGB(255, 250, 220),
					Material = Enum.Material.Neon,
					Shape = Enum.PartType.Cylinder,
				}),
				prop("Gaming Chair", "Seat", Vector3.new(-32, 2, 42), Vector3.new(5, 8, 5), {
					Color = Color3.fromRGB(180, 80, 150),
					Material = Enum.Material.Fabric,
				}),
				prop("Pool", "Pool", Vector3.new(10, 0, 46), Vector3.new(28, 4, 14), {
					Color = Color3.fromRGB(104, 193, 255),
					Accent = Color3.fromRGB(235, 247, 255),
				}),
				prop("Water Slide", "Slide", Vector3.new(34, 0, 48), Vector3.new(18, 8, 6), {
					Color = Color3.fromRGB(255, 124, 198),
					Accent = Color3.fromRGB(255, 255, 255),
				}),
				prop("Pool Chair A", "PoolChair", Vector3.new(-10, 2, 40), Vector3.new(8, 3, 4), {
					Color = Color3.fromRGB(255, 240, 240),
					Accent = Color3.fromRGB(255, 170, 214),
				}),
				prop("Pool Chair B", "PoolChair", Vector3.new(-10, 2, 48), Vector3.new(8, 3, 4), {
					Color = Color3.fromRGB(255, 240, 240),
					Accent = Color3.fromRGB(255, 170, 214),
				}),
				prop("Umbrella Post", "Display", Vector3.new(-20, 7, 46), Vector3.new(1.5, 14, 1.5), {
					Color = Color3.fromRGB(255, 240, 248),
					Material = Enum.Material.Metal,
				}),
				prop("VIP Floor Pad", "FloorPad", Vector3.new(50, 2.1, 44), Vector3.new(18, 0.2, 18), {
					Color = Color3.fromRGB(255, 200, 230),
					Material = Enum.Material.Neon,
					Transparency = 0.25,
				}),
				prop("VIP Lounge Chair A", "PoolChair", Vector3.new(44, 2, 40), Vector3.new(7, 3, 4), {
					Color = Color3.fromRGB(255, 200, 230),
					Accent = Color3.fromRGB(255, 170, 214),
					HideBillboard = true,
				}),
				prop("VIP Lounge Chair B", "PoolChair", Vector3.new(44, 2, 48), Vector3.new(7, 3, 4), {
					Color = Color3.fromRGB(255, 200, 230),
					Accent = Color3.fromRGB(255, 170, 214),
					HideBillboard = true,
				}),
				prop("VIP Side Table", "Table", Vector3.new(44, 1.5, 44), Vector3.new(4, 3, 4), {
					Color = Color3.fromRGB(220, 150, 195),
					Material = Enum.Material.WoodPlanks,
					HideBillboard = true,
				}),
				prop("VIP Star Wall", "VIPDisplay", Vector3.new(60, 10, 44), Vector3.new(18, 12, 1), {
					Color = Color3.fromRGB(255, 170, 214),
					Accent = Color3.fromRGB(255, 240, 248),
					Label = "VIP Star Lounge",
					Message = "Welcome, superstar! Abbie, Lue, Emi & Sophia — this spot is yours.",
				}),
				-- === ABBIE'S BIRTHDAY ROOM ===
				prop("Birthday Cake Base", "Display", Vector3.new(0, 3, -40), Vector3.new(8, 2, 8), {
					Color = Color3.fromRGB(255, 220, 150),
					HideBillboard = true,
				}),
				prop("Birthday Cake Mid", "Display", Vector3.new(0, 5.5, -40), Vector3.new(6, 3, 6), {
					Color = Color3.fromRGB(255, 170, 200),
					HideBillboard = true,
				}),
				prop("Birthday Cake Top", "Display", Vector3.new(0, 8.5, -40), Vector3.new(4, 3, 4), {
					Color = Color3.fromRGB(255, 230, 240),
					HideBillboard = true,
				}),
				prop("Birthday Candle Glow", "Display", Vector3.new(0, 11.5, -40), Vector3.new(2.5, 2, 2.5), {
					Color = Color3.fromRGB(255, 240, 60),
					Material = Enum.Material.Neon,
					HideBillboard = true,
				}),
				prop("Balloon Pink", "Display", Vector3.new(-16, 12, -35), Vector3.new(4, 5, 4), {
					Color = Color3.fromRGB(255, 100, 185),
					Shape = Enum.PartType.Ball,
					HideBillboard = true,
				}),
				prop("Balloon Purple", "Display", Vector3.new(-10, 15, -34), Vector3.new(4, 5, 4), {
					Color = Color3.fromRGB(180, 80, 255),
					Shape = Enum.PartType.Ball,
					HideBillboard = true,
				}),
				prop("Balloon Gold", "Display", Vector3.new(0, 16, -37), Vector3.new(5, 6, 5), {
					Color = Color3.fromRGB(255, 215, 0),
					Material = Enum.Material.Neon,
					Shape = Enum.PartType.Ball,
					HideBillboard = true,
				}),
				prop("Balloon Blue", "Display", Vector3.new(10, 14, -34), Vector3.new(4, 5, 4), {
					Color = Color3.fromRGB(80, 185, 255),
					Shape = Enum.PartType.Ball,
					HideBillboard = true,
				}),
				prop("Balloon Teal", "Display", Vector3.new(16, 12, -35), Vector3.new(4, 5, 4), {
					Color = Color3.fromRGB(80, 230, 200),
					Shape = Enum.PartType.Ball,
					HideBillboard = true,
				}),
				prop("Balloon Pink B", "Display", Vector3.new(-12, 15, -47), Vector3.new(4, 5, 4), {
					Color = Color3.fromRGB(255, 150, 210),
					Shape = Enum.PartType.Ball,
					HideBillboard = true,
				}),
				prop("Balloon Yellow", "Display", Vector3.new(12, 15, -47), Vector3.new(4, 5, 4), {
					Color = Color3.fromRGB(255, 235, 80),
					Shape = Enum.PartType.Ball,
					HideBillboard = true,
				}),
				prop("Confetti Floor Pink", "FloorPad", Vector3.new(-12, 2.15, -35), Vector3.new(10, 0.2, 8), {
					Color = Color3.fromRGB(255, 100, 180),
					Material = Enum.Material.Neon,
					Transparency = 0.3,
					HideBillboard = true,
				}),
				prop("Confetti Floor Yellow", "FloorPad", Vector3.new(12, 2.15, -35), Vector3.new(10, 0.2, 8), {
					Color = Color3.fromRGB(255, 235, 60),
					Material = Enum.Material.Neon,
					Transparency = 0.3,
					HideBillboard = true,
				}),
				prop("Confetti Floor Purple", "FloorPad", Vector3.new(-12, 2.15, -45), Vector3.new(10, 0.2, 10), {
					Color = Color3.fromRGB(180, 80, 255),
					Material = Enum.Material.Neon,
					Transparency = 0.3,
					HideBillboard = true,
				}),
				prop("Confetti Floor Blue", "FloorPad", Vector3.new(12, 2.15, -45), Vector3.new(10, 0.2, 10), {
					Color = Color3.fromRGB(80, 185, 255),
					Material = Enum.Material.Neon,
					Transparency = 0.3,
					HideBillboard = true,
				}),
				prop("Birthday Banner", "Display", Vector3.new(0, 11, -51.4), Vector3.new(34, 5, 0.4), {
					Color = Color3.fromRGB(255, 50, 160),
					Material = Enum.Material.Neon,
					Label = "Birthday Banner",
					Message = "Happy 11th Birthday Abbie Jo! Love, Mom, Dad, and Charlie Lue",
				}),
				prop("Birthday Confetti A", "Confetti", Vector3.new(-12, 14, -37), Vector3.new(1, 1, 1), {
					HideBillboard = true,
					Rate = 18,
				}),
				prop("Birthday Confetti B", "Confetti", Vector3.new(12, 14, -37), Vector3.new(1, 1, 1), {
					HideBillboard = true,
					Rate = 18,
				}),
				prop("Birthday Confetti C", "Confetti", Vector3.new(0, 14, -43), Vector3.new(1, 1, 1), {
					HideBillboard = true,
					Rate = 12,
				}),
				prop("Ceiling Star A", "Display", Vector3.new(-12, 17.5, -37), Vector3.new(3, 3, 3), {
					Color = Color3.fromRGB(255, 220, 50),
					Material = Enum.Material.Neon,
					Shape = Enum.PartType.Ball,
					HideBillboard = true,
				}),
				prop("Ceiling Star B", "Display", Vector3.new(12, 17.5, -37), Vector3.new(3, 3, 3), {
					Color = Color3.fromRGB(255, 100, 185),
					Material = Enum.Material.Neon,
					Shape = Enum.PartType.Ball,
					HideBillboard = true,
				}),
				prop("Ceiling Star C", "Display", Vector3.new(0, 17.5, -43), Vector3.new(3, 3, 3), {
					Color = Color3.fromRGB(180, 80, 255),
					Material = Enum.Material.Neon,
					Shape = Enum.PartType.Ball,
					HideBillboard = true,
				}),
				prop("Ceiling Star D", "Display", Vector3.new(-12, 17.5, -49), Vector3.new(3, 3, 3), {
					Color = Color3.fromRGB(80, 230, 200),
					Material = Enum.Material.Neon,
					Shape = Enum.PartType.Ball,
					HideBillboard = true,
				}),
				prop("Ceiling Star E", "Display", Vector3.new(12, 17.5, -49), Vector3.new(3, 3, 3), {
					Color = Color3.fromRGB(255, 235, 80),
					Material = Enum.Material.Neon,
					Shape = Enum.PartType.Ball,
					HideBillboard = true,
				}),
				-- === UNDERGROUND TUNNEL ACCESS ===
				prop("Secret Hatch", "Display", Vector3.new(0, 2.2, 18), Vector3.new(10, 0.3, 10), {
					Color = Color3.fromRGB(120, 60, 220),
					Material = Enum.Material.Neon,
					Transparency = 0.05,
					Label = "Secret Food Court",
					ActionType = "TeleportVenue",
					ActionText = "Enter",
					ObjectText = "Secret Food Court",
					VenueId = "underground-food-court",
				}),
				prop("Tunnel Shaft East", "Display", Vector3.new(5, -14, 18), Vector3.new(1, 34, 10), {
					Color = Color3.fromRGB(75, 50, 100),
					HideBillboard = true,
				}),
				prop("Tunnel Shaft West", "Display", Vector3.new(-5, -14, 18), Vector3.new(1, 34, 10), {
					Color = Color3.fromRGB(75, 50, 100),
					HideBillboard = true,
				}),
				prop("Tunnel Shaft North", "Display", Vector3.new(0, -14, 13), Vector3.new(9, 34, 1), {
					Color = Color3.fromRGB(75, 50, 100),
					HideBillboard = true,
				}),
				prop("Tunnel Shaft South", "Display", Vector3.new(0, -14, 23), Vector3.new(9, 34, 1), {
					Color = Color3.fromRGB(75, 50, 100),
					HideBillboard = true,
				}),
				prop("Tunnel Neon Ring", "Display", Vector3.new(0, -6, 18), Vector3.new(11, 1, 11), {
					Color = Color3.fromRGB(140, 80, 255),
					Material = Enum.Material.Neon,
					HideBillboard = true,
				}),
				-- === TREEHOUSE + ZIPLINE ===
				prop("Tree Trunk", "Display", Vector3.new(58, 26, -18), Vector3.new(4, 50, 4), {
					Color = Color3.fromRGB(80, 55, 25),
					Material = Enum.Material.Wood,
					HideBillboard = true,
				}),
				prop("Treehouse Platform", "Display", Vector3.new(58, 50, -18), Vector3.new(20, 2, 20), {
					Color = Color3.fromRGB(120, 80, 40),
					Material = Enum.Material.WoodPlanks,
					HideBillboard = true,
				}),
				prop("Treehouse Wall N", "Display", Vector3.new(58, 60, -27), Vector3.new(20, 14, 1), {
					Color = Color3.fromRGB(140, 100, 50),
					Material = Enum.Material.WoodPlanks,
					HideBillboard = true,
				}),
				prop("Treehouse Wall E", "Display", Vector3.new(67, 60, -18), Vector3.new(1, 14, 18), {
					Color = Color3.fromRGB(140, 100, 50),
					Material = Enum.Material.WoodPlanks,
					HideBillboard = true,
				}),
				prop("Treehouse Roof", "Display", Vector3.new(58, 67, -18), Vector3.new(22, 2, 22), {
					Color = Color3.fromRGB(160, 120, 60),
					Material = Enum.Material.WoodPlanks,
					HideBillboard = true,
				}),
				prop("Treehouse Sign", "Display", Vector3.new(58, 58, -26.4), Vector3.new(16, 6, 0.5), {
					Color = Color3.fromRGB(200, 160, 90),
					Material = Enum.Material.Neon,
					Label = "Girls Hangout Treehouse",
					Message = "The highest view in Founder's World! Zipline connects to Stromblad Estate.",
				}),
				prop("Zipline Cable", "Display", Vector3.new(-214, 51, -20), Vector3.new(508, 0.4, 0.4), {
					Color = Color3.fromRGB(55, 55, 55),
					Material = Enum.Material.Metal,
					HideBillboard = true,
				}),
			},
			MediaPanels = {
				mediaPanel("Theater Slideshow", "Photo", Vector3.new(48, 8, 2), Vector3.new(20, 10, 1), {
					Title = "Theater Slideshow",
				}),
				mediaPanel("Hangout Stream", "Twitch", Vector3.new(-18, 8, 38), Vector3.new(18, 10, 1), {
					Title = "Streaming Corner",
				}),
				mediaPanel("Girls Playlist", "Spotify", Vector3.new(12, 5, 40), Vector3.new(12, 8, 1), {
					Title = "Girls Playlist",
				}),
			},
			Signs = {
				sign("Girls Hangout", "Abbie · Lue · EmilyPlays · EmiGirl · Sophia", Vector3.new(0, 22, -59), {
					Size = Vector3.new(32, 10, 1),
				}),
				sign("Abbie", "Arcade Captain", Vector3.new(-40, 14, -12), {
					Size = Vector3.new(12, 8, 1),
				}),
				sign("Lue", "Theater Host", Vector3.new(34, 14, -12), {
					Size = Vector3.new(12, 8, 1),
				}),
				sign("EmilyPlays", "Streaming Queen", Vector3.new(-40, 14, 26), {
					Size = Vector3.new(12, 8, 1),
				}),
				sign("EmiGirl", "Lounge Lead", Vector3.new(28, 14, 26), {
					Size = Vector3.new(12, 8, 1),
				}),
				sign("Sophia", "Pool Queen", Vector3.new(10, 14, 56), {
					Size = Vector3.new(12, 8, 1),
				}),
			},
		},
		{
			Id = "underground-food-court",
			Name = "Secret Food Court",
			Theme = "Secret underground food hall beneath Girls Hangout",
			Position = Vector3.new(260, -35, -300),
			Footprint = Vector3.new(90, 22, 70),
			Color = Color3.fromRGB(55, 35, 75),
			Accent = Color3.fromRGB(160, 80, 255),
			RoofTransparency = 0.08,
			SpawnOffset = Vector3.new(0, 5, 0),
			AmbientSoundId = 0, -- replace with lo-fi/chill music asset ID
			Rooms = {
				room("Food Court Hall", Vector3.new(0, 0, 0), Vector3.new(84, 2, 64), {
					FloorColor = Color3.fromRGB(42, 28, 60),
					WallColor = Color3.fromRGB(65, 42, 92),
					WallHeight = 18,
				}),
			},
			Props = {
				prop("Starbucks", "Display", Vector3.new(-28, 8, -22), Vector3.new(14, 12, 6), {
					Color = Color3.fromRGB(0, 112, 70),
					Label = "Starbucks",
					Message = "Starbucks is open! Grab a frap or latte before the next hangout session.",
				}),
				prop("Starbucks Counter", "Table", Vector3.new(-28, 4, -14), Vector3.new(12, 4, 5), {
					Color = Color3.fromRGB(0, 90, 56),
					HideBillboard = true,
				}),
				prop("Chick-fil-A", "Display", Vector3.new(-10, 8, -22), Vector3.new(14, 12, 6), {
					Color = Color3.fromRGB(220, 30, 40),
					Label = "Chick-fil-A",
					Message = "My pleasure! Crispy sandwiches and waffle fries — Chick-fil-A is in the building.",
				}),
				prop("CFA Counter", "Table", Vector3.new(-10, 4, -14), Vector3.new(12, 4, 5), {
					Color = Color3.fromRGB(180, 20, 30),
					HideBillboard = true,
				}),
				prop("Boba Galaxy", "Display", Vector3.new(8, 8, -22), Vector3.new(14, 12, 6), {
					Color = Color3.fromRGB(130, 55, 215),
					Accent = Color3.fromRGB(220, 150, 255),
					Label = "Boba Galaxy",
					Message = "The most cosmic boba in any dimension. Try the Starfruit Slush — it glows!",
				}),
				prop("Boba Counter", "Table", Vector3.new(8, 4, -14), Vector3.new(12, 4, 5), {
					Color = Color3.fromRGB(110, 40, 190),
					HideBillboard = true,
				}),
				prop("Baskin Robbins", "Display", Vector3.new(26, 8, -22), Vector3.new(14, 12, 6), {
					Color = Color3.fromRGB(255, 100, 160),
					Accent = Color3.fromRGB(255, 210, 235),
					Label = "Baskin Robbins",
					Message = "31 flavors plus secret seasonal specials. The Birthday Cake flavor is Abbie's pick!",
				}),
				prop("BR Counter", "Table", Vector3.new(26, 4, -14), Vector3.new(12, 4, 5), {
					Color = Color3.fromRGB(220, 80, 140),
					HideBillboard = true,
				}),
				prop("FC Table A", "Table", Vector3.new(-25, 4, 8), Vector3.new(10, 3, 8), {
					Color = Color3.fromRGB(58, 42, 80),
					Material = Enum.Material.WoodPlanks,
					HideBillboard = true,
				}),
				prop("FC Seat A1", "Seat", Vector3.new(-25, 4, 16), Vector3.new(8, 3, 4), {
					Color = Color3.fromRGB(180, 80, 255),
					Material = Enum.Material.Fabric,
					HideBillboard = true,
				}),
				prop("FC Seat A2", "Seat", Vector3.new(-25, 4, 0), Vector3.new(8, 3, 4), {
					Color = Color3.fromRGB(180, 80, 255),
					Material = Enum.Material.Fabric,
					HideBillboard = true,
				}),
				prop("FC Table B", "Table", Vector3.new(0, 4, 8), Vector3.new(10, 3, 8), {
					Color = Color3.fromRGB(58, 42, 80),
					Material = Enum.Material.WoodPlanks,
					HideBillboard = true,
				}),
				prop("FC Seat B1", "Seat", Vector3.new(0, 4, 16), Vector3.new(8, 3, 4), {
					Color = Color3.fromRGB(100, 200, 255),
					Material = Enum.Material.Fabric,
					HideBillboard = true,
				}),
				prop("FC Seat B2", "Seat", Vector3.new(0, 4, 0), Vector3.new(8, 3, 4), {
					Color = Color3.fromRGB(100, 200, 255),
					Material = Enum.Material.Fabric,
					HideBillboard = true,
				}),
				prop("FC Table C", "Table", Vector3.new(25, 4, 8), Vector3.new(10, 3, 8), {
					Color = Color3.fromRGB(58, 42, 80),
					Material = Enum.Material.WoodPlanks,
					HideBillboard = true,
				}),
				prop("FC Seat C1", "Seat", Vector3.new(25, 4, 16), Vector3.new(8, 3, 4), {
					Color = Color3.fromRGB(255, 200, 100),
					Material = Enum.Material.Fabric,
					HideBillboard = true,
				}),
				prop("FC Seat C2", "Seat", Vector3.new(25, 4, 0), Vector3.new(8, 3, 4), {
					Color = Color3.fromRGB(255, 200, 100),
					Material = Enum.Material.Fabric,
					HideBillboard = true,
				}),
				prop("FC Neon Strip Purple", "FloorPad", Vector3.new(0, 20, 0), Vector3.new(88, 0.5, 0.5), {
					Color = Color3.fromRGB(160, 80, 255),
					Material = Enum.Material.Neon,
					Transparency = 0.1,
					HideBillboard = true,
				}),
				prop("FC Neon Strip Pink", "FloorPad", Vector3.new(0, 20, 8), Vector3.new(0.5, 0.5, 64), {
					Color = Color3.fromRGB(255, 80, 160),
					Material = Enum.Material.Neon,
					Transparency = 0.1,
					HideBillboard = true,
				}),
				prop("Food Court Sign", "Display", Vector3.new(0, 14, -21), Vector3.new(50, 7, 0.5), {
					Color = Color3.fromRGB(130, 60, 200),
					Material = Enum.Material.Neon,
					Label = "Secret Food Court",
					Message = "Welcome to the Secret Food Court! Hidden beneath Girls Hangout — girls only.",
				}),
			},
			Signs = {
				sign("Secret Food Court", "Starbucks | Chick-fil-A | Boba Galaxy | Baskin Robbins", Vector3.new(0, 18, -32), {
					Size = Vector3.new(32, 12, 1),
					Color = Color3.fromRGB(55, 35, 75),
					Accent = Color3.fromRGB(160, 80, 255),
				}),
				sign("Girls Only", "This space belongs to the crew", Vector3.new(0, 10, 31), {
					Size = Vector3.new(20, 8, 1),
					Color = Color3.fromRGB(55, 35, 75),
					Accent = Color3.fromRGB(255, 80, 160),
				}),
			},
		},
		{
			Id = "founder-lounge",
			Name = "Founder Lounge",
			Theme = "Premium founder networking graybox",
			Position = Vector3.new(320, 0, 180),
			Footprint = Vector3.new(102, 36, 88),
			AmbientSoundId = 0, -- replace with lounge/jazz asset ID
			Color = Color3.fromRGB(48, 58, 74),
			Accent = Color3.fromRGB(215, 191, 126),
			RoofTransparency = 0.28,
			SpawnOffset = Vector3.new(0, 3, -22),
			ReturnPadOffset = Vector3.new(-32, 2.5, 28),
			ReturnPadOptions = {
				PadSize = Vector3.new(10, 0.8, 10),
				PadMaterial = Enum.Material.SmoothPlastic,
				PadTransparency = 0.42,
				MarkerSize = Vector3.new(8, 5, 1),
				MarkerOffset = Vector3.new(0, 4, -5),
				MarkerColor = Color3.fromRGB(28, 32, 40),
				MarkerMaterial = Enum.Material.Metal,
				Subtitle = "Return",
			},
			Rooms = {
				room("Founder Wall", Vector3.new(-24, 0, 6), Vector3.new(28, 2, 22), {
					OpenSides = { "East", "South" },
					FloorColor = Color3.fromRGB(62, 73, 89),
					WallHeight = 18,
				}),
				room("VIP Lounge", Vector3.new(20, 0, 6), Vector3.new(30, 2, 22), {
					OpenSides = { "West", "South" },
					FloorColor = Color3.fromRGB(53, 63, 79),
					WallHeight = 18,
				}),
				room("Media Viewing Wall", Vector3.new(20, 0, 34), Vector3.new(30, 2, 22), {
					OpenSides = { "West", "North" },
					FloorColor = Color3.fromRGB(58, 68, 84),
					WallHeight = 18,
				}),
				room("Spotify Station", Vector3.new(-24, 0, 34), Vector3.new(28, 2, 22), {
					OpenSides = { "East", "North" },
					FloorColor = Color3.fromRGB(46, 56, 72),
					WallHeight = 18,
					LabelSize = Vector3.new(12, 6, 1),
					LabelOffset = Vector3.new(0, 13, 10.2),
					LabelFace = Enum.NormalId.Front,
				}),
			},
			Props = {
				prop("Founder Title Display", "Display", Vector3.new(-26, 9, 4), Vector3.new(18, 12, 1), {
					Color = Color3.fromRGB(35, 40, 52),
					Label = "Founder: xD0DgeThiSx",
				}),
				prop("VIP Couch", "Seat", Vector3.new(22, 2, 10), Vector3.new(18, 4, 8), {
					Color = Color3.fromRGB(79, 66, 44),
					Material = Enum.Material.Leather,
					HideBillboard = true,
				}),
				prop("VIP Table", "Table", Vector3.new(22, 1.5, 20), Vector3.new(10, 3, 6), {
					Color = Color3.fromRGB(96, 81, 54),
					Material = Enum.Material.WoodPlanks,
					HideBillboard = true,
				}),
				prop("Founder Names Wall", "Display", Vector3.new(-28, 9, 18), Vector3.new(20, 12, 1), {
					Color = Color3.fromRGB(29, 35, 45),
					Label = "VIP Roll Call",
				}),
				-- Phase 8: Retina Scan Elevator
				prop("Retina Scanner Frame", "Display", Vector3.new(-38, 8, 34), Vector3.new(6, 16, 2), {
					Color = Color3.fromRGB(38, 44, 58),
					Material = Enum.Material.Metal,
					HideBillboard = true,
				}),
				prop("Retina Scanner Screen", "Display", Vector3.new(-38, 10, 33.2), Vector3.new(4, 5, 0.3), {
					Color = Color3.fromRGB(0, 200, 120),
					Material = Enum.Material.Neon,
					Transparency = 0.08,
					Label = "Retina Scan Elevator",
					ActionType = "FounderAction",
					ActionText = "Scan",
					ObjectText = "Retina Scanner",
					RoleRequired = "Founder",
					Message = "Retina scan verified: xD0DgeThiSx. Founder elevator access granted.",
				}),
				prop("Retina Scanner Eye", "Display", Vector3.new(-38, 10, 33.05), Vector3.new(2, 2, 0.2), {
					Color = Color3.fromRGB(0, 255, 160),
					Material = Enum.Material.Neon,
					Shape = Enum.PartType.Ball,
					HideBillboard = true,
				}),
				prop("Elevator Door Left", "Display", Vector3.new(-41, 10, 35), Vector3.new(5, 18, 1), {
					Color = Color3.fromRGB(45, 52, 68),
					Material = Enum.Material.Metal,
					HideBillboard = true,
				}),
				prop("Elevator Door Right", "Display", Vector3.new(-35, 10, 35), Vector3.new(5, 18, 1), {
					Color = Color3.fromRGB(45, 52, 68),
					Material = Enum.Material.Metal,
					HideBillboard = true,
				}),
				prop("Elevator Neon Strip", "FloorPad", Vector3.new(-38, 19.5, 35), Vector3.new(10, 0.4, 1), {
					Color = Color3.fromRGB(215, 191, 126),
					Material = Enum.Material.Neon,
					Transparency = 0.1,
					HideBillboard = true,
				}),
				-- Phase 8: Founder Tablet Control Panel
				prop("Founder Tablet Panel", "CommandCenter", Vector3.new(38, 6, 20), Vector3.new(14, 8, 3), {
					Color = Color3.fromRGB(28, 34, 46),
					Accent = Color3.fromRGB(215, 191, 126),
					Label = "Founder Control Panel",
					ActionType = "FounderAction",
					ActionText = "Open",
					ObjectText = "Founder Tablet",
					RoleRequired = "Founder",
					Message = "Founder control panel active — world settings, VIP roster, and expansion controls.",
				}),
				prop("Tablet Screen Glow", "Display", Vector3.new(38, 7, 18.6), Vector3.new(10, 5, 0.3), {
					Color = Color3.fromRGB(215, 191, 126),
					Material = Enum.Material.Neon,
					Transparency = 0.12,
					HideBillboard = true,
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
				sign("VIP Lounge", "Private founder seating", Vector3.new(20, 14, -4), {
					Size = Vector3.new(12, 7, 1),
				}),
				sign("Founder Wall", "Founder + VIP honors", Vector3.new(-24, 14, -4), {
					Size = Vector3.new(12, 7, 1),
				}),
			},
		},
		{
			Id = "contentforge-studio",
			Name = "ContentForge Studio",
			Theme = "Creator production studio graybox",
			Position = Vector3.new(-360, 0, 210),
			Footprint = Vector3.new(118, 36, 96),
			Color = Color3.fromRGB(68, 94, 123),
			Accent = Color3.fromRGB(181, 224, 255),
			RoofTransparency = 0.26,
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
				prop("Studio Desk", "Table", Vector3.new(-30, 1.5, 4), Vector3.new(14, 3, 6), {
					Color = Color3.fromRGB(42, 62, 84),
					Material = Enum.Material.Metal,
					HideBillboard = true,
				}),
				prop("Podcast Table", "Table", Vector3.new(20, 1.5, 6), Vector3.new(10, 3, 10), {
					Color = Color3.fromRGB(49, 68, 92),
					Material = Enum.Material.WoodPlanks,
					HideBillboard = true,
				}),
				prop("Recording Backdrop", "Display", Vector3.new(-40, 8, 34), Vector3.new(10, 12, 1), {
					Color = Color3.fromRGB(26, 40, 58),
					Label = "Creator Backdrop",
				}),
				prop("AI Command Center", "CommandCenter", Vector3.new(34, 4, 34), Vector3.new(12, 7, 4), {
					Color = Color3.fromRGB(33, 57, 82),
					Label = "Creator Command",
				}),
				prop("Digital Product Showcase", "Display", Vector3.new(40, 7, 18), Vector3.new(8, 11, 1), {
					Color = Color3.fromRGB(28, 44, 64),
					Label = "Creator Tools",
				}),
			},
			MediaPanels = {
				mediaPanel("Studio Slideshow", "Photo", Vector3.new(-40, 8, 22), Vector3.new(12, 9, 1), {
					Title = "Studio Slideshow",
				}),
				mediaPanel("Creator Stream Wall", "Twitch", Vector3.new(40, 8, 40), Vector3.new(12, 9, 1), {
					Title = "Creator Stream Wall",
				}),
				mediaPanel("YouTube Recording Feed", "YouTube", Vector3.new(-40, 8, 44), Vector3.new(12, 9, 1), {
					Title = "YouTube Recording Feed",
				}),
			},
			Signs = {
				sign("ContentForge Studio", "Create. Record. Launch.", Vector3.new(0, 21, -47), {
					Size = Vector3.new(20, 10, 1),
				}),
				sign("Podcast Set", "Mic check and live sessions", Vector3.new(20, 14, -4), {
					Size = Vector3.new(12, 7, 1),
				}),
				sign("Creator Command", "Build tools and launch content", Vector3.new(32, 14, 24), {
					Size = Vector3.new(12, 7, 1),
				}),
			},
		},
		{
			Id = "bo6-gaming-lounge",
			Name = "Black Ops 7 Gaming Lounge",
			Theme = "Tactical creator lounge with Black Ops 7 loadout bays",
			Position = Vector3.new(-360, 0, -40),
			Footprint = Vector3.new(108, 30, 90),
			Color = Color3.fromRGB(40, 40, 40),
			Accent = Color3.fromRGB(255, 111, 0),
			RoofTransparency = 0.24,
			SpawnOffset = Vector3.new(0, 3, -22),
			AmbientSoundId = 0, -- replace with tactical/action music asset ID
			ReturnPadOffset = Vector3.new(0, 2.5, 28),
			ReturnPadOptions = {
				MarkerOffset = Vector3.new(0, 5, -8),
			},
			Rooms = {
				room("Loadout Wall", Vector3.new(-28, 0, 8), Vector3.new(30, 2, 24), {
					OpenSides = { "East", "South" },
					FloorColor = Color3.fromRGB(48, 48, 48),
					WallColor = Color3.fromRGB(255, 111, 0),
					LabelSize = Vector3.new(15, 5, 1),
				}),
				room("Squad Strategy Table", Vector3.new(22, 0, 8), Vector3.new(34, 2, 24), {
					OpenSides = { "West", "South" },
					FloorColor = Color3.fromRGB(62, 62, 62),
					WallColor = Color3.fromRGB(94, 94, 94),
					LabelSize = Vector3.new(18, 5, 1),
				}),
				room("Gaming Stations", Vector3.new(-28, 0, 36), Vector3.new(30, 2, 20), {
					OpenSides = { "East", "North" },
					FloorColor = Color3.fromRGB(44, 44, 44),
					WallColor = Color3.fromRGB(28, 28, 28),
					LabelSize = Vector3.new(15, 5, 1),
				}),
				room("Clip Review Station", Vector3.new(22, 0, 36), Vector3.new(34, 2, 20), {
					OpenSides = { "West", "North" },
					FloorColor = Color3.fromRGB(49, 49, 49),
					WallColor = Color3.fromRGB(255, 111, 0),
					LabelSize = Vector3.new(18, 5, 1),
				}),
			},
			Props = {
				prop("Loadout Wall Rack", "Display", Vector3.new(-40, 7, 8), Vector3.new(12, 10, 1), {
					Color = Color3.fromRGB(24, 24, 24),
					Label = "Loadout Wall",
					Message = "Loadout wall shows Black Ops 7 class ideas, orange-tag perks, and squad prep notes.",
				}),
				prop("Founder Loadout Locker", "Display", Vector3.new(-17, 7, 8), Vector3.new(10, 10, 1), {
					Color = Color3.fromRGB(24, 24, 24),
					Label = "Founder Loadout Locker",
					ActionType = "FounderAction",
					ActionText = "Access",
					ObjectText = "Founder Loadout Locker",
					RoleRequired = "Founder",
					Message = "Founder loadout locker opened with featured Black Ops 7 builds and VIP squad presets.",
				}),
				prop("Bravo Gaming Pods", "GamingStation", Vector3.new(-39, 4, 36), Vector3.new(12, 8, 6), {
					Color = Color3.fromRGB(26, 26, 26),
					Accent = Color3.fromRGB(255, 111, 0),
					Label = "Bravo Pods",
					Message = "Bravo pods are tuned for Warzone warmups, scrims, and quick clip captures.",
				}),
				prop("Alpha Gaming Pods", "GamingStation", Vector3.new(-18, 4, 36), Vector3.new(12, 8, 6), {
					Color = Color3.fromRGB(26, 26, 26),
					Accent = Color3.fromRGB(255, 111, 0),
					Label = "Alpha Pods",
					Message = "Alpha pods keep the main Black Ops 7 lounge grind loop active without blocking the center aisle.",
				}),
				prop("Gaming Chair A", "Seat", Vector3.new(-38, 2, 30), Vector3.new(4, 6, 4), {
					Color = Color3.fromRGB(255, 111, 0),
					Material = Enum.Material.SmoothPlastic,
					HideBillboard = true,
				}),
				prop("Gaming Chair B", "Seat", Vector3.new(-28, 2, 30), Vector3.new(4, 6, 4), {
					Color = Color3.fromRGB(255, 111, 0),
					Material = Enum.Material.SmoothPlastic,
					HideBillboard = true,
				}),
				prop("Gaming Chair C", "Seat", Vector3.new(-18, 2, 30), Vector3.new(4, 6, 4), {
					Color = Color3.fromRGB(255, 111, 0),
					Material = Enum.Material.SmoothPlastic,
					HideBillboard = true,
				}),
				-- Phase 8: Alpha pod desk chairs (in front of Alpha pods)
				prop("Alpha Desk Chair A", "Seat", Vector3.new(-20, 2, 44), Vector3.new(4, 6, 4), {
					Color = Color3.fromRGB(255, 111, 0),
					Material = Enum.Material.SmoothPlastic,
					HideBillboard = true,
				}),
				prop("Alpha Desk Chair B", "Seat", Vector3.new(-14, 2, 44), Vector3.new(4, 6, 4), {
					Color = Color3.fromRGB(200, 85, 0),
					Material = Enum.Material.SmoothPlastic,
					HideBillboard = true,
				}),
				-- Phase 8: Bravo pod desk chairs
				prop("Bravo Desk Chair A", "Seat", Vector3.new(-40, 2, 44), Vector3.new(4, 6, 4), {
					Color = Color3.fromRGB(255, 111, 0),
					Material = Enum.Material.SmoothPlastic,
					HideBillboard = true,
				}),
				prop("Bravo Desk Chair B", "Seat", Vector3.new(-34, 2, 44), Vector3.new(4, 6, 4), {
					Color = Color3.fromRGB(200, 85, 0),
					Material = Enum.Material.SmoothPlastic,
					HideBillboard = true,
				}),
				-- Phase 8: Squad sitting area near strategy table
				prop("Squad Chair A", "Seat", Vector3.new(10, 2, 4), Vector3.new(5, 7, 5), {
					Color = Color3.fromRGB(255, 111, 0),
					Material = Enum.Material.SmoothPlastic,
					HideBillboard = true,
				}),
				prop("Squad Chair B", "Seat", Vector3.new(20, 2, 4), Vector3.new(5, 7, 5), {
					Color = Color3.fromRGB(200, 85, 0),
					Material = Enum.Material.SmoothPlastic,
					HideBillboard = true,
				}),
				prop("Squad Chair C", "Seat", Vector3.new(30, 2, 4), Vector3.new(5, 7, 5), {
					Color = Color3.fromRGB(255, 111, 0),
					Material = Enum.Material.SmoothPlastic,
					HideBillboard = true,
				}),
				prop("Orange Floor Strip", "FloorPad", Vector3.new(-3, 2.15, 22), Vector3.new(0.5, 0.2, 56), {
					Color = Color3.fromRGB(255, 111, 0),
					Material = Enum.Material.Neon,
					Transparency = 0.3,
					HideBillboard = true,
				}),
				prop("Tactical Strategy Table", "Display", Vector3.new(20, 3.5, 8), Vector3.new(18, 5, 10), {
					Color = Color3.fromRGB(54, 54, 54),
					Material = Enum.Material.Metal,
					Label = "Squad Strategy Table",
					Message = "Tactical strategy table maps out drops, rotations, and push calls for the squad.",
				}),
				prop("Caster Bench", "Seat", Vector3.new(35, 2, 8), Vector3.new(10, 4, 8), {
					Color = Color3.fromRGB(82, 82, 82),
					Material = Enum.Material.Metal,
					Label = "Caster Bench",
					HideBillboard = true,
				}),
				prop("Clip Review Console", "Display", Vector3.new(12, 6, 34), Vector3.new(10, 8, 1), {
					Color = Color3.fromRGB(25, 25, 25),
					Label = "Clip Review Console",
					Message = "Clip review console queues creator cuts, stream highlights, and callout reviews.",
				}),
				prop("Streaming Review Desk", "Display", Vector3.new(34, 4, 37), Vector3.new(14, 6, 8), {
					Color = Color3.fromRGB(34, 34, 34),
					Accent = Color3.fromRGB(255, 111, 0),
					Label = "Streaming Desk",
					Message = "Streaming desk keeps comms, overlays, and creator review tools in one zone.",
				}),
				prop("Win Wall Display", "Display", Vector3.new(38, 7, 34), Vector3.new(10, 10, 1), {
					Color = Color3.fromRGB(18, 18, 18),
					Label = "Win Wall",
					Message = "Win wall celebrates Black Ops 7 wins, top clips, and featured squad moments.",
				}),
				prop("Squad Callout Board", "Display", Vector3.new(-27, 7, 44), Vector3.new(18, 10, 1), {
					Color = Color3.fromRGB(24, 24, 24),
					Label = "Squad Callouts",
					Message = "Squad callout board tracks role tags, stack timing, and drop plans.",
				}),
				prop("xD0DgeThiSx Victory Crest", "Display", Vector3.new(37, 7, 14), Vector3.new(16, 10, 1), {
					Color = Color3.fromRGB(26, 26, 26),
					Label = "xD0DgeThiSx Victory Crest",
					Message = "Featured founder wall spotlights xD0DgeThiSx and the Black Ops 7 creator-lounge identity.",
				}),
			},
			MediaPanels = {
				mediaPanel("Black Ops 7 Streaming Wall", "Twitch", Vector3.new(26, 8, 43), Vector3.new(14, 9, 1), {
					Title = "Live Squad Streams",
				}),
				mediaPanel("Black Ops 7 Showcase", "YouTube", Vector3.new(12, 8, 43), Vector3.new(12, 9, 1), {
					Title = "Black Ops 7 Clip Showcase",
				}),
				mediaPanel("Pre-Match Playlist", "Spotify", Vector3.new(-16, 6, 44), Vector3.new(12, 8, 1), {
					Title = "Squad Warmup Playlist",
				}),
			},
			Signs = {
				sign("Black Ops 7 Gaming Lounge", "xD0DgeThiSx Feature Zone", Vector3.new(0, 22, -44), {
					Size = Vector3.new(20, 10, 1),
				}),
				sign("Loadouts Ready", "Founder locker and squad prep", Vector3.new(-28, 13, -10), {
					Size = Vector3.new(16, 8, 1),
					Color = Color3.fromRGB(20, 20, 20),
				}),
				sign("Squad Briefing", "Push plans, rotations, callouts", Vector3.new(22, 13, -10), {
					Size = Vector3.new(16, 8, 1),
					Color = Color3.fromRGB(20, 20, 20),
				}),
				sign("Creator Review", "Streams, clips, and the win wall", Vector3.new(22, 13, 22), {
					Size = Vector3.new(18, 8, 1),
					Color = Color3.fromRGB(20, 20, 20),
				}),
				sign("Gaming Stations", "Alpha + Bravo pods", Vector3.new(-28, 13, 22), {
					Size = Vector3.new(16, 8, 1),
					Color = Color3.fromRGB(20, 20, 20),
				}),
			},
		},
		{
			Id = "outdoor-mall",
			Name = "Outdoor Mall",
			Theme = "Open-air shopping promenade with cafes, boutiques, and creator pop-ups",
			Position = Vector3.new(520, 0, 40),
			Footprint = Vector3.new(136, 28, 104),
			Color = Color3.fromRGB(194, 186, 166),
			Accent = Color3.fromRGB(255, 247, 216),
			RoofTransparency = 0.98,
			SpawnOffset = Vector3.new(0, 3, -32),
			AmbientSoundId = 0, -- replace with soft outdoor retail ambience asset ID
			ReturnPadOffset = Vector3.new(0, 0.5, 30),
			ReturnPadOptions = {
				MarkerOffset = Vector3.new(0, 5, -8),
				MarkerColor = Color3.fromRGB(92, 84, 66),
				Subtitle = "Return",
			},
			Rooms = {
				room("Mall Entrance", Vector3.new(0, 0, -32), Vector3.new(42, 2, 18), {
					OpenSides = { "North", "South" },
					FloorColor = Color3.fromRGB(226, 219, 201),
					WallColor = Color3.fromRGB(255, 247, 216),
				}),
				room("Central Promenade", Vector3.new(0, 0, 0), Vector3.new(46, 2, 52), {
					OpenSides = { "North", "South", "East", "West" },
					FloorColor = Color3.fromRGB(214, 206, 188),
					LabelSize = Vector3.new(18, 5, 1),
				}),
				room("Boutique Row", Vector3.new(-34, 0, 8), Vector3.new(26, 2, 42), {
					OpenSides = { "East", "South", "North" },
					FloorColor = Color3.fromRGB(205, 193, 176),
					WallColor = Color3.fromRGB(220, 192, 156),
				}),
				room("Dessert Court", Vector3.new(34, 0, 8), Vector3.new(26, 2, 42), {
					OpenSides = { "West", "South", "North" },
					FloorColor = Color3.fromRGB(214, 199, 184),
					WallColor = Color3.fromRGB(255, 182, 166),
				}),
				room("Creator Pop-Up", Vector3.new(0, 0, 32), Vector3.new(42, 2, 18), {
					OpenSides = { "North", "East", "West" },
					FloorColor = Color3.fromRGB(204, 194, 176),
					WallColor = Color3.fromRGB(156, 128, 98),
				}),
			},
			Props = {
				prop("Mall Archway", "Display", Vector3.new(0, 10, -24), Vector3.new(34, 12, 2), {
					Color = Color3.fromRGB(160, 146, 120),
					Accent = Color3.fromRGB(255, 247, 216),
					Material = Enum.Material.Metal,
					Label = "Outdoor Mall",
					Message = "Welcome to the Outdoor Mall promenade with cafes, boutiques, and creator showcases.",
				}),
				prop("Promenade Strip", "FloorPad", Vector3.new(0, 2.12, 2), Vector3.new(18, 0.15, 58), {
					Color = Color3.fromRGB(255, 240, 196),
					Material = Enum.Material.Neon,
					Transparency = 0.22,
					HideBillboard = true,
				}),
				prop("Center Fountain", "Display", Vector3.new(0, 4, 2), Vector3.new(14, 8, 14), {
					Color = Color3.fromRGB(182, 176, 168),
					Accent = Color3.fromRGB(255, 247, 216),
					Material = Enum.Material.SmoothPlastic,
					Shape = Enum.PartType.Cylinder,
					Label = "Promenade Fountain",
					Message = "The promenade fountain anchors the mall plaza and evening meetup spot.",
				}),
				prop("Boutique Feature Wall", "Display", Vector3.new(-40, 8, 0), Vector3.new(12, 10, 1), {
					Color = Color3.fromRGB(190, 160, 132),
					Label = "Style Boutique",
					Message = "Boutique row rotates fashion drops, accessories, and seasonal highlights.",
				}),
				prop("Sneaker Wall", "Display", Vector3.new(-40, 8, 16), Vector3.new(12, 10, 1), {
					Color = Color3.fromRGB(156, 132, 110),
					Label = "Sneaker Wall",
					Message = "Sneaker wall shows featured drops, clean colorways, and mall-exclusive looks.",
				}),
				prop("Window Bench Left", "Seat", Vector3.new(-26, 2, 4), Vector3.new(10, 4, 6), {
					Color = Color3.fromRGB(176, 150, 128),
					Material = Enum.Material.Fabric,
					HideBillboard = true,
				}),
				prop("Window Bench Right", "Seat", Vector3.new(-26, 2, 20), Vector3.new(10, 4, 6), {
					Color = Color3.fromRGB(176, 150, 128),
					Material = Enum.Material.Fabric,
					HideBillboard = true,
				}),
				prop("Dessert Counter", "Table", Vector3.new(34, 4, 2), Vector3.new(16, 4, 6), {
					Color = Color3.fromRGB(222, 165, 150),
					Material = Enum.Material.WoodPlanks,
					HideBillboard = true,
				}),
				prop("Boba Bar", "Display", Vector3.new(40, 8, 0), Vector3.new(12, 10, 1), {
					Color = Color3.fromRGB(230, 146, 168),
					Label = "Boba Bar",
					Message = "Boba Bar serves fruit teas, frozen refreshers, and mall-night favorites.",
				}),
				prop("Dessert Neon Menu", "Display", Vector3.new(40, 10, 16), Vector3.new(12, 8, 1), {
					Color = Color3.fromRGB(255, 170, 190),
					Material = Enum.Material.Neon,
					Transparency = 0.08,
					Label = "Dessert Menu",
					Message = "Dessert menu highlights milk teas, cake slices, sundaes, and seasonal sweets.",
				}),
				prop("Cafe Seating Left", "Seat", Vector3.new(24, 2, 22), Vector3.new(8, 4, 6), {
					Color = Color3.fromRGB(220, 198, 186),
					Material = Enum.Material.Fabric,
					HideBillboard = true,
				}),
				prop("Cafe Seating Right", "Seat", Vector3.new(42, 2, 22), Vector3.new(8, 4, 6), {
					Color = Color3.fromRGB(220, 198, 186),
					Material = Enum.Material.Fabric,
					HideBillboard = true,
				}),
				prop("Creator Stage", "Display", Vector3.new(0, 4, 30), Vector3.new(20, 4, 10), {
					Color = Color3.fromRGB(144, 124, 100),
					Material = Enum.Material.WoodPlanks,
					Label = "Creator Pop-Up Stage",
					Message = "Creator pop-up stage hosts mini drops, shoutouts, and weekend spotlight moments.",
				}),
				prop("Selfie Mirror", "Display", Vector3.new(-16, 8, 38), Vector3.new(10, 12, 1), {
					Color = Color3.fromRGB(240, 238, 232),
					Material = Enum.Material.Glass,
					Transparency = 0.2,
					Label = "Selfie Mirror",
					Message = "The selfie mirror is the mall's favorite spot for outfit pics and birthday group shots.",
				}),
				prop("Founder Preview Kiosk", "Display", Vector3.new(18, 8, 38), Vector3.new(12, 10, 1), {
					Color = Color3.fromRGB(146, 118, 86),
					Accent = Color3.fromRGB(255, 247, 216),
					Label = "Founder Preview Kiosk",
					ActionType = "FounderAction",
					ActionText = "Preview",
					ObjectText = "Founder Preview Kiosk",
					RoleRequired = "Founder",
					Message = "Founder preview kiosk opened upcoming mall pop-ups, storefront plans, and featured drops.",
				}),
				prop("Planter Row Left", "Display", Vector3.new(-14, 3, 14), Vector3.new(10, 4, 4), {
					Color = Color3.fromRGB(116, 132, 96),
					Material = Enum.Material.Grass,
					HideBillboard = true,
				}),
				prop("Planter Row Right", "Display", Vector3.new(14, 3, 14), Vector3.new(10, 4, 4), {
					Color = Color3.fromRGB(116, 132, 96),
					Material = Enum.Material.Grass,
					HideBillboard = true,
				}),
			},
			MediaPanels = {
				mediaPanel("Mall Playlist", "Spotify", Vector3.new(-14, 6, 38), Vector3.new(12, 8, 1), {
					Title = "Mall Playlist",
				}),
				mediaPanel("Creator Drop Board", "YouTube", Vector3.new(14, 9, 42), Vector3.new(14, 9, 1), {
					Title = "Creator Drop Board",
				}),
				mediaPanel("Pop-Up Stream", "Twitch", Vector3.new(34, 9, 32), Vector3.new(12, 9, 1), {
					Title = "Pop-Up Stream",
				}),
			},
			Signs = {
				sign("Outdoor Mall", "Boutiques, desserts, and creator pop-ups", Vector3.new(0, 21, -50), {
					Size = Vector3.new(24, 10, 1),
				}),
				sign("Boutique Row", "Style, sneakers, and social stops", Vector3.new(-34, 14, -2), {
					Size = Vector3.new(14, 8, 1),
					Color = Color3.fromRGB(148, 124, 102),
				}),
				sign("Dessert Court", "Boba, sweets, and cafe seating", Vector3.new(34, 14, -2), {
					Size = Vector3.new(14, 8, 1),
					Color = Color3.fromRGB(176, 132, 118),
				}),
				sign("Creator Pop-Up", "Weekend drops and founder previews", Vector3.new(0, 12, 20), {
					Size = Vector3.new(18, 8, 1),
					Color = Color3.fromRGB(148, 124, 102),
				}),
			},
		},
		{
			Id = "drive-in-theater",
			Name = "Drive-In Theater",
			Theme = "Open-air movie lot with snack bar, projection booth, and blanket lounge",
			Position = Vector3.new(0, 0, -560),
			Footprint = Vector3.new(138, 28, 118),
			Color = Color3.fromRGB(48, 42, 62),
			Accent = Color3.fromRGB(222, 205, 255),
			RoofTransparency = 0.97,
			SpawnOffset = Vector3.new(0, 3, -36),
			AmbientSoundId = 0, -- replace with soft outdoor cinema ambience asset ID
			ReturnPadOffset = Vector3.new(0, 0.5, 34),
			ReturnPadOptions = {
				MarkerOffset = Vector3.new(0, 5, -8),
				MarkerColor = Color3.fromRGB(34, 28, 42),
				Subtitle = "Return",
			},
			Rooms = {
				room("Marquee Entrance", Vector3.new(0, 0, -36), Vector3.new(40, 2, 18), {
					OpenSides = { "North", "South" },
					FloorColor = Color3.fromRGB(86, 72, 103),
					WallColor = Color3.fromRGB(222, 205, 255),
				}),
				room("Parking Deck", Vector3.new(0, 0, 2), Vector3.new(92, 2, 52), {
					OpenSides = { "North", "South", "East", "West" },
					FloorColor = Color3.fromRGB(62, 58, 72),
					LabelSize = Vector3.new(18, 5, 1),
				}),
				room("Snack Bar", Vector3.new(-34, 0, 30), Vector3.new(26, 2, 22), {
					OpenSides = { "East", "North" },
					FloorColor = Color3.fromRGB(74, 60, 90),
					WallColor = Color3.fromRGB(255, 162, 110),
				}),
				room("Blanket Lounge", Vector3.new(0, 0, 34), Vector3.new(30, 2, 18), {
					OpenSides = { "North", "East", "West" },
					FloorColor = Color3.fromRGB(70, 61, 85),
					WallColor = Color3.fromRGB(196, 158, 255),
				}),
				room("Projection Booth", Vector3.new(34, 0, 30), Vector3.new(24, 2, 22), {
					OpenSides = { "West", "North" },
					FloorColor = Color3.fromRGB(58, 52, 70),
					WallColor = Color3.fromRGB(160, 140, 196),
				}),
			},
			Props = {
				prop("Drive-In Marquee", "Display", Vector3.new(0, 12, -28), Vector3.new(34, 12, 2), {
					Color = Color3.fromRGB(64, 50, 84),
					Accent = Color3.fromRGB(255, 182, 120),
					Material = Enum.Material.Metal,
					Label = "Tonight's Double Feature",
					Message = "Feature night at the Drive-In: trailers, watch parties, and founder movie moments.",
				}),
				prop("Ticket Booth", "Display", Vector3.new(0, 6, -20), Vector3.new(16, 8, 8), {
					Color = Color3.fromRGB(78, 64, 99),
					Accent = Color3.fromRGB(255, 182, 120),
					Label = "Ticket Booth",
					Message = "Ticket booth is serving popcorn passes, blankets, and movie night access.",
				}),
				prop("Parking Row Front", "FloorPad", Vector3.new(0, 2.1, -2), Vector3.new(92, 0.2, 0.8), {
					Color = Color3.fromRGB(188, 178, 205),
					Material = Enum.Material.Neon,
					Transparency = 0.22,
					HideBillboard = true,
				}),
				prop("Parking Row Rear", "FloorPad", Vector3.new(0, 2.1, 18), Vector3.new(92, 0.2, 0.8), {
					Color = Color3.fromRGB(188, 178, 205),
					Material = Enum.Material.Neon,
					Transparency = 0.22,
					HideBillboard = true,
				}),
				prop("Front Lounge Pad", "FloorPad", Vector3.new(0, 2.15, 30), Vector3.new(28, 0.2, 14), {
					Color = Color3.fromRGB(145, 108, 210),
					Material = Enum.Material.Neon,
					Transparency = 0.26,
					HideBillboard = true,
				}),
				prop("Blanket Couch Left", "Seat", Vector3.new(-10, 2, 30), Vector3.new(12, 4, 6), {
					Color = Color3.fromRGB(96, 72, 132),
					Material = Enum.Material.Fabric,
					HideBillboard = true,
				}),
				prop("Blanket Couch Right", "Seat", Vector3.new(10, 2, 30), Vector3.new(12, 4, 6), {
					Color = Color3.fromRGB(96, 72, 132),
					Material = Enum.Material.Fabric,
					HideBillboard = true,
				}),
				prop("Main Feature Screen", "CinemaScreen", Vector3.new(0, 12, 48), Vector3.new(36, 18, 1), {
					Color = Color3.fromRGB(52, 42, 64),
					Accent = Color3.fromRGB(222, 205, 255),
					Label = "Main Feature Screen",
					HideBillboard = true,
				}),
				prop("Screen Base", "Display", Vector3.new(0, 4, 48), Vector3.new(42, 4, 6), {
					Color = Color3.fromRGB(44, 38, 54),
					Material = Enum.Material.Metal,
					HideBillboard = true,
				}),
				prop("Snack Counter", "Table", Vector3.new(-34, 4, 28), Vector3.new(16, 4, 6), {
					Color = Color3.fromRGB(108, 72, 96),
					Material = Enum.Material.WoodPlanks,
					HideBillboard = true,
				}),
				prop("Popcorn Wall", "Display", Vector3.new(-34, 8, 38), Vector3.new(16, 10, 1), {
					Color = Color3.fromRGB(92, 62, 86),
					Label = "Popcorn + Sweets",
					Message = "Snack bar lineup: popcorn tubs, soda floats, candy bins, and birthday cupcakes.",
				}),
				prop("Neon Menu Board", "Display", Vector3.new(-34, 10, 20), Vector3.new(12, 8, 1), {
					Color = Color3.fromRGB(255, 120, 160),
					Material = Enum.Material.Neon,
					Transparency = 0.08,
					Label = "Late Night Menu",
					Message = "The late-night menu keeps the movie crowd fueled with snacks, sweets, and frozen drinks.",
				}),
				prop("Projection Console", "Display", Vector3.new(34, 7, 28), Vector3.new(14, 10, 4), {
					Color = Color3.fromRGB(62, 58, 78),
					Accent = Color3.fromRGB(222, 205, 255),
					Label = "Projection Console",
					ActionType = "FounderAction",
					ActionText = "Cue Reel",
					ObjectText = "Projection Console",
					RoleRequired = "Founder",
					Message = "Founder projection console queued the next trailer reel and special feature intro.",
				}),
				prop("Clip Review Monitor", "Display", Vector3.new(34, 10, 38), Vector3.new(12, 8, 1), {
					Color = Color3.fromRGB(58, 52, 72),
					Label = "Watch Party Monitor",
					Message = "Watch party monitor rotates fan clips, birthday edits, and feature previews.",
				}),
				prop("Speaker Post Left", "Display", Vector3.new(-44, 6, 10), Vector3.new(3, 12, 3), {
					Color = Color3.fromRGB(74, 68, 86),
					Material = Enum.Material.Metal,
					HideBillboard = true,
				}),
				prop("Speaker Post Right", "Display", Vector3.new(44, 6, 10), Vector3.new(3, 12, 3), {
					Color = Color3.fromRGB(74, 68, 86),
					Material = Enum.Material.Metal,
					HideBillboard = true,
				}),
				prop("Star Lane Strip", "FloorPad", Vector3.new(0, 2.18, 40), Vector3.new(76, 0.15, 0.6), {
					Color = Color3.fromRGB(255, 197, 120),
					Material = Enum.Material.Neon,
					Transparency = 0.18,
					HideBillboard = true,
				}),
			},
			MediaPanels = {
				mediaPanel("Feature Trailer Board", "YouTube", Vector3.new(-34, 9, 44), Vector3.new(14, 9, 1), {
					Title = "Feature Trailer Board",
				}),
				mediaPanel("Snack Bar Playlist", "Spotify", Vector3.new(-18, 6, 38), Vector3.new(12, 8, 1), {
					Title = "Snack Bar Playlist",
				}),
				mediaPanel("Watch Party Feed", "Twitch", Vector3.new(18, 9, 44), Vector3.new(14, 9, 1), {
					Title = "Watch Party Feed",
				}),
			},
			Signs = {
				sign("Drive-In Theater", "Movie nights, trailers, and watch parties", Vector3.new(0, 21, -58), {
					Size = Vector3.new(24, 10, 1),
				}),
				sign("Snack Bar", "Popcorn, sweets, and frozen drinks", Vector3.new(-34, 14, 18), {
					Size = Vector3.new(14, 8, 1),
					Color = Color3.fromRGB(52, 42, 64),
				}),
				sign("Projection Booth", "Founder reel control", Vector3.new(34, 14, 18), {
					Size = Vector3.new(14, 8, 1),
					Color = Color3.fromRGB(52, 42, 64),
				}),
				sign("Blanket Lounge", "Front-row couches and blankets", Vector3.new(0, 12, 20), {
					Size = Vector3.new(16, 8, 1),
					Color = Color3.fromRGB(52, 42, 64),
				}),
			},
		},
		{
			Id = "water-park",
			Name = "Water Park",
			Theme = "Outdoor water park with slides, lazy river, and splash zones",
			Position = Vector3.new(0, 0, 500),
			Footprint = Vector3.new(140, 28, 110),
			Color = Color3.fromRGB(60, 155, 210),
			Accent = Color3.fromRGB(220, 245, 255),
			RoofTransparency = 0.96,
			SpawnOffset = Vector3.new(0, 3, -32),
			AmbientSoundId = 0, -- replace with summer/splash sound asset ID
			Rooms = {
				room("Entrance Hall", Vector3.new(0, 0, -40), Vector3.new(52, 2, 22), {
					OpenSides = { "South", "North" },
					FloorColor = Color3.fromRGB(215, 235, 245),
				}),
				room("Main Pool Deck", Vector3.new(8, 0, 8), Vector3.new(80, 2, 54), {
					OpenSides = { "North", "East", "West", "South" },
					FloorColor = Color3.fromRGB(185, 225, 245),
				}),
				room("Slide Tower Zone", Vector3.new(-36, 0, 36), Vector3.new(32, 2, 30), {
					OpenSides = { "East", "South" },
					FloorColor = Color3.fromRGB(175, 218, 240),
				}),
				room("River Run", Vector3.new(44, 0, 16), Vector3.new(36, 2, 50), {
					OpenSides = { "West", "South" },
					FloorColor = Color3.fromRGB(190, 228, 246),
				}),
			},
			Props = {
				-- === WAVE POOL ===
				prop("Wave Pool", "Pool", Vector3.new(4, 0, 8), Vector3.new(52, 5, 30), {
					Color = Color3.fromRGB(60, 160, 220),
					Accent = Color3.fromRGB(215, 245, 255),
					Label = "Wave Pool",
					Subtitle = "Main Pool",
				}),
				prop("Wave Pool Neon Edge", "FloorPad", Vector3.new(4, 2.15, 23.5), Vector3.new(54, 0.2, 0.5), {
					Color = Color3.fromRGB(80, 200, 255),
					Material = Enum.Material.Neon,
					Transparency = 0.15,
					HideBillboard = true,
				}),
				-- === LAZY RIVER ===
				prop("Lazy River", "Pool", Vector3.new(44, 0, 16), Vector3.new(28, 3, 44), {
					Color = Color3.fromRGB(50, 145, 200),
					Accent = Color3.fromRGB(200, 240, 255),
					Label = "Lazy River",
					Subtitle = "River Run",
				}),
				prop("River Current Foam", "FloorPad", Vector3.new(44, 2.15, 16), Vector3.new(24, 0.2, 40), {
					Color = Color3.fromRGB(180, 235, 255),
					Material = Enum.Material.Neon,
					Transparency = 0.35,
					HideBillboard = true,
				}),
				-- === SLIDE TOWER ===
				prop("Slide Tower Base", "Display", Vector3.new(-36, 12, 38), Vector3.new(22, 26, 22), {
					Color = Color3.fromRGB(45, 120, 175),
					Material = Enum.Material.Metal,
					HideBillboard = true,
				}),
				prop("Slide Tower Top", "Display", Vector3.new(-36, 26, 38), Vector3.new(24, 2, 24), {
					Color = Color3.fromRGB(220, 245, 255),
					Material = Enum.Material.SmoothPlastic,
					HideBillboard = true,
				}),
				prop("Tower Rail A", "Display", Vector3.new(-24, 32, 38), Vector3.new(0.5, 12, 22), {
					Color = Color3.fromRGB(160, 200, 220),
					Material = Enum.Material.Metal,
					HideBillboard = true,
				}),
				prop("Tower Rail B", "Display", Vector3.new(-48, 32, 38), Vector3.new(0.5, 12, 22), {
					Color = Color3.fromRGB(160, 200, 220),
					Material = Enum.Material.Metal,
					HideBillboard = true,
				}),
				-- === WATER SLIDES ===
				prop("Big Blue Slide", "Slide", Vector3.new(-22, 0, 46), Vector3.new(10, 24, 8), {
					Color = Color3.fromRGB(30, 130, 220),
					Accent = Color3.fromRGB(220, 245, 255),
					Label = "Big Blue Slide",
				}),
				prop("Speed Slide", "Slide", Vector3.new(-38, 0, 46), Vector3.new(8, 20, 6), {
					Color = Color3.fromRGB(255, 100, 30),
					Accent = Color3.fromRGB(255, 200, 150),
					Label = "Speed Slide",
				}),
				prop("Family Slide", "Slide", Vector3.new(-30, 0, 24), Vector3.new(12, 14, 10), {
					Color = Color3.fromRGB(200, 80, 220),
					Accent = Color3.fromRGB(240, 200, 255),
					Label = "Family Slide",
				}),
				-- === SPLASH PAD ===
				prop("Splash Pad Floor", "FloorPad", Vector3.new(-26, 2.1, -14), Vector3.new(28, 0.2, 22), {
					Color = Color3.fromRGB(80, 200, 255),
					Material = Enum.Material.Neon,
					Transparency = 0.2,
					Label = "Splash Pad",
				}),
				prop("Splash Jet A", "Display", Vector3.new(-34, 5, -8), Vector3.new(1.5, 8, 1.5), {
					Color = Color3.fromRGB(150, 220, 255),
					Material = Enum.Material.Neon,
					Shape = Enum.PartType.Cylinder,
					HideBillboard = true,
				}),
				prop("Splash Jet B", "Display", Vector3.new(-22, 5, -8), Vector3.new(1.5, 8, 1.5), {
					Color = Color3.fromRGB(150, 220, 255),
					Material = Enum.Material.Neon,
					Shape = Enum.PartType.Cylinder,
					HideBillboard = true,
				}),
				prop("Splash Jet C", "Display", Vector3.new(-34, 5, -20), Vector3.new(1.5, 8, 1.5), {
					Color = Color3.fromRGB(100, 200, 255),
					Material = Enum.Material.Neon,
					Shape = Enum.PartType.Cylinder,
					HideBillboard = true,
				}),
				prop("Splash Jet D", "Display", Vector3.new(-22, 5, -20), Vector3.new(1.5, 8, 1.5), {
					Color = Color3.fromRGB(100, 200, 255),
					Material = Enum.Material.Neon,
					Shape = Enum.PartType.Cylinder,
					HideBillboard = true,
				}),
				prop("Splash Foam Center", "FloorPad", Vector3.new(-28, 2.3, -14), Vector3.new(6, 0.2, 6), {
					Color = Color3.fromRGB(200, 240, 255),
					Material = Enum.Material.Neon,
					Transparency = 0.1,
					HideBillboard = true,
				}),
				-- === AMENITIES ===
				prop("Concession Stand", "Display", Vector3.new(52, 6, -28), Vector3.new(16, 10, 8), {
					Color = Color3.fromRGB(255, 200, 60),
					Accent = Color3.fromRGB(255, 240, 160),
					Label = "Concession Stand",
					Message = "Snacks, drinks, and sunscreen! Open all day at the Water Park.",
				}),
				prop("Concession Counter", "Table", Vector3.new(52, 3, -20), Vector3.new(14, 5, 5), {
					Color = Color3.fromRGB(255, 220, 80),
					Material = Enum.Material.WoodPlanks,
					HideBillboard = true,
				}),
				prop("Lifeguard Chair", "Display", Vector3.new(4, 10, -16), Vector3.new(4, 14, 4), {
					Color = Color3.fromRGB(255, 80, 20),
					Accent = Color3.fromRGB(255, 240, 200),
					Label = "Lifeguard",
					Message = "Lifeguard on duty! Stay safe and have fun.",
				}),
				prop("Lifeguard Seat", "Seat", Vector3.new(4, 14, -16), Vector3.new(5, 3, 4), {
					Color = Color3.fromRGB(255, 100, 30),
					Material = Enum.Material.Fabric,
					HideBillboard = true,
				}),
				prop("Inner Tube Rack", "Display", Vector3.new(-60, 6, -30), Vector3.new(10, 10, 4), {
					Color = Color3.fromRGB(255, 150, 40),
					Accent = Color3.fromRGB(255, 220, 100),
					Label = "Inner Tubes",
					Message = "Grab a tube for the Lazy River! Return when done.",
				}),
				prop("Towel Station", "Table", Vector3.new(58, 3, -4), Vector3.new(8, 5, 4), {
					Color = Color3.fromRGB(240, 240, 240),
					Material = Enum.Material.Fabric,
					Label = "Towel Station",
				}),
				prop("Pool Chairs West A", "PoolChair", Vector3.new(-60, 2, -8), Vector3.new(8, 3, 4), {
					Color = Color3.fromRGB(255, 240, 220),
					Accent = Color3.fromRGB(220, 245, 255),
					HideBillboard = true,
				}),
				prop("Pool Chairs West B", "PoolChair", Vector3.new(-60, 2, 0), Vector3.new(8, 3, 4), {
					Color = Color3.fromRGB(255, 240, 220),
					Accent = Color3.fromRGB(220, 245, 255),
					HideBillboard = true,
				}),
				prop("Pool Chairs East A", "PoolChair", Vector3.new(58, 2, 8), Vector3.new(8, 3, 4), {
					Color = Color3.fromRGB(255, 240, 220),
					Accent = Color3.fromRGB(220, 245, 255),
					HideBillboard = true,
				}),
				prop("Pool Chairs East B", "PoolChair", Vector3.new(58, 2, 16), Vector3.new(8, 3, 4), {
					Color = Color3.fromRGB(255, 240, 220),
					Accent = Color3.fromRGB(220, 245, 255),
					HideBillboard = true,
				}),
				-- === ENTRANCE ARCH ===
				prop("Entrance Arch Left", "Display", Vector3.new(-18, 16, -52), Vector3.new(4, 28, 4), {
					Color = Color3.fromRGB(60, 155, 210),
					Material = Enum.Material.Metal,
					HideBillboard = true,
				}),
				prop("Entrance Arch Right", "Display", Vector3.new(18, 16, -52), Vector3.new(4, 28, 4), {
					Color = Color3.fromRGB(60, 155, 210),
					Material = Enum.Material.Metal,
					HideBillboard = true,
				}),
				prop("Entrance Arch Span", "Display", Vector3.new(0, 30, -52), Vector3.new(40, 4, 4), {
					Color = Color3.fromRGB(80, 180, 240),
					Material = Enum.Material.Neon,
					Transparency = 0.1,
					Label = "Water Park",
					Message = "Welcome to the Founder's World Water Park! Slides, splash pads, and lazy river ahead.",
				}),
			},
			Signs = {
				sign("Water Park", "Slides · Lazy River · Splash Pad", Vector3.new(0, 20, -54), {
					Size = Vector3.new(24, 10, 1),
					Color = Color3.fromRGB(30, 100, 170),
					Accent = Color3.fromRGB(220, 245, 255),
				}),
				sign("Wave Pool", "Main pool area — watch for waves!", Vector3.new(4, 14, -7), {
					Size = Vector3.new(14, 8, 1),
				}),
				sign("Lazy River", "Grab a tube and float", Vector3.new(44, 14, -6), {
					Size = Vector3.new(14, 8, 1),
				}),
				sign("Slides", "Big Blue · Speed · Family", Vector3.new(-36, 14, 8), {
					Size = Vector3.new(14, 8, 1),
				}),
				sign("Splash Pad", "Jet zone for all ages", Vector3.new(-26, 14, -26), {
					Size = Vector3.new(12, 8, 1),
				}),
			},
		},
	},
	Vehicles = {
		vehicle("bronco-xd0dge", "Black Bronco", Vector3.new(-60, 2, 5), {
			VehicleType = "Bronco",
			Color = Color3.fromRGB(18, 18, 18),
			Accent = Color3.fromRGB(48, 48, 48),
			TrimColor = Color3.fromRGB(72, 72, 72),
			PlateText = "xD0DgeThiSx",
			Owner = "xD0DgeThiSx",
			Heading = 0,
		}),
		vehicle("jeep-abbie", "Pink Jeep", Vector3.new(-42, 2, 5), {
			VehicleType = "Jeep",
			Color = Color3.fromRGB(255, 130, 190),
			Accent = Color3.fromRGB(255, 200, 230),
			TrimColor = Color3.fromRGB(255, 255, 255),
			PlateText = "ABBIE",
			Owner = "Abbiejo615",
			Heading = 0,
		}),
		vehicle("jeep-charlie", "Pink Jeep", Vector3.new(-24, 2, 5), {
			VehicleType = "Jeep",
			Color = Color3.fromRGB(255, 130, 190),
			Accent = Color3.fromRGB(255, 200, 230),
			TrimColor = Color3.fromRGB(255, 255, 255),
			PlateText = "CHARLIE",
			Owner = "Charlie",
			Heading = 0,
		}),
		vehicle("jeep-sophia", "Pink Jeep", Vector3.new(-6, 2, 5), {
			VehicleType = "Jeep",
			Color = Color3.fromRGB(255, 130, 190),
			Accent = Color3.fromRGB(255, 200, 230),
			TrimColor = Color3.fromRGB(255, 255, 255),
			PlateText = "SOPHIA",
			Owner = "Sophia",
			Heading = 0,
		}),
		vehicle("suv-emily", "Blacked-Out Luxury SUV", Vector3.new(16, 2, 5), {
			VehicleType = "LuxurySUV",
			Color = Color3.fromRGB(10, 10, 10),
			Accent = Color3.fromRGB(180, 160, 80),
			TrimColor = Color3.fromRGB(140, 120, 60),
			PlateText = "EMILYPLAYS",
			Owner = "Emilyplays902",
			Heading = 0,
		}),
	},
}

return WorldConfig
