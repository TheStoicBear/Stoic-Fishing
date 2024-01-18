Config = {}

Config.DebugMode = true  -- Set to true to enable debug messages, false to disable
Config.useOxNoty = true
Config.FishingLocations = {
    { coords = vector3(28.11, 852.58, 197.73), name = "Lake" },
	{ coords = vector3(1869.83, 247.5, 162.43), name = "Lake" },
	{ coords = vector3(1423.98, 3825.8, 31.46), name = "Lake" },
	{ coords = vector3(-2077.89, 2605.25, 2.03), name = "Lake" },
    { coords = vector3(-3399.12, 946.28, 8.29), name = "Sea" },
	{ coords = vector3(-1480.07, -1518.04, 2.29), name = "Sea" },
	{ coords = vector3(962.7, -2668.13, 3.13), name = "Sea" },
    { coords = vector3(2000.0, 3000.0, 0.0), name = "Sea" },
    -- Add more fishing locations as needed
}

Config.SellNpcCoords = {
    { coords = vector4(36.85, 861.17, 197.73, 310.09), name = "Lake" },
    { coords = vector4(1855.34, 225.9, 161.96, 286.14), name = "Lake" },
    { coords = vector4(1427.15, 3817.84, 31.67, 306.71), name = "Lake" },
    { coords = vector4(-2081.82, 2615.79, 3.08, 83.15), name = "Lake" },
    { coords = vector4(-3409.38, 952.26, 8.35, 225.03), name = "Sea" },
    { coords = vector4(-1014.65, -1753.12, 2.36, 109.99), name = "Sea" },
    { coords = vector4(-1488.49, -1506.04, 3.16, 49.56), name = "Sea" },
    { coords = vector4(979.56, -2680.29, 3.12, 182.02), name = "Sea" },
}

Config.WaterTypes = {
    Lake = {
        FishTypes = {
			{ name = "Bass", price = 10 },
			{ name = "Trout", price = 8 },
			{ name = "Catfish", price = 12 },
			{ name = "Perch", price = 6 },
			{ name = "Salmon", price = 15 },
			{ name = "Bluegill", price = 5 },
			{ name = "Walleye", price = 14 },
			{ name = "Crappie", price = 7 },
			{ name = "Pike", price = 18 },
			{ name = "Sunfish", price = 4 },
			{ name = "Carp", price = 3 },
			{ name = "Rainbow Trout", price = 9 },
			{ name = "Largemouth Bass", price = 11 },
			{ name = "Smallmouth Bass", price = 13 },
			{ name = "Yellow Perch", price = 5 },
			{ name = "White Crappie", price = 8 },
			{ name = "Channel Catfish", price = 16 },
			{ name = "Brown Trout", price = 10 },
			{ name = "Brook Trout", price = 9 },
			{ name = "Cutthroat Trout", price = 11 },
			{ name = "Striped Bass", price = 17 },
			{ name = "Muskie", price = 20 },
			{ name = "Redear Sunfish", price = 5 },
			{ name = "Rock Bass", price = 6 },
			{ name = "Yellow Bullhead", price = 12 },
			{ name = "Northern Pike", price = 18 },
			{ name = "Saugeye", price = 14 },
			{ name = "Blue Catfish", price = 22 },
			{ name = "Flathead Catfish", price = 25 }
        },
    },
    Sea = {
        FishTypes = {
			{ name = "Tuna", price = 19.99 },
			{ name = "Salmon", price = 16.99 },
			{ name = "Snapper", price = 14.99 },
			{ name = "Grouper", price = 18.99 },
			{ name = "Mackerel", price = 12.99 },
			{ name = "Mahi Mahi", price = 21.99 },
			{ name = "Swordfish", price = 29.99 },
			{ name = "Barracuda", price = 26.99 },
			{ name = "Redfish", price = 17.99 },
			{ name = "Halibut", price = 23.99 },
			{ name = "Yellowtail", price = 20.99 },
			{ name = "Cod", price = 13.99 },
			{ name = "Flounder", price = 15.99 },
			{ name = "Shark", price = 32.99 },
			{ name = "Wahoo", price = 30.99 },
			{ name = "Blue Marlin", price = 35.99 },
			{ name = "Striped Bass", price = 14.99 },
			{ name = "Sea Bass", price = 17.99 },
			{ name = "Amberjack", price = 25.99 },
			{ name = "Triggerfish", price = 11.99 },
			{ name = "Cobia", price = 22.99 },
			{ name = "Tilefish", price = 26.99 },
			{ name = "Kingfish", price = 19.99 },
			{ name = "Yellowfin Tuna", price = 28.99 },
			{ name = "Black Drum", price = 18.99 },
			{ name = "Porgy", price = 13.99 },
			{ name = "Lingcod", price = 20.99 },
			{ name = "Rockfish", price = 16.99 },
			{ name = "Fluke", price = 14.99 }
        },
    },
}
