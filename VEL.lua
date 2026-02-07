local function ensureGuiParent(gui)
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
    end
    if gethui thenlocal Logger       = loadstring(game:HttpGet("https://raw.githubusercontent.com/sinchanthestar/VelouraHUB/refs/heads/main/utils/logger.lua"))()

-- FOR PRODUCTION: Uncomment this line to disable all logging
--Logger.disableAll()

-- FOR DEVELOPMENT: Enable all logging
Logger.enableAll()

local mainLogger = Logger.new("Main")
local featureLogger = Logger.new("FeatureManager")

--// Library
local Noctis = loadstring(game:HttpGet("https://raw.githubusercontent.com/sinchanthestar/VelouraHUB/refs/heads/main/lib.lua"))()

-- ===========================
-- LOAD HELPERS & FEATURE MANAGER
-- ===========================
mainLogger:info("Loading Helpers...")
local Helpers = loadstring(game:HttpGet("https://raw.githubusercontent.com/sinchanthestar/VelouraHUB/refs/heads/main/module/f/helpers.lua"))()

mainLogger:info("Loading FeatureManager...")
local FeatureManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/sinchanthestar/VelouraHUB/refs/heads/main/module/f/featuremanager.lua"))()

-- ===========================
-- GLOBAL SERVICES & VARIABLES
-- ===========================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- Make global for features to access
_G.GameServices = {
    Players = Players,
    ReplicatedStorage = ReplicatedStorage,
    RunService = RunService,
    LocalPlayer = LocalPlayer,
    HttpService = HttpService
}

-- Safe network path access
local NetPath = nil
pcall(function()
    NetPath = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
end)
_G.NetPath = NetPath

-- Load InventoryWatcher globally for features that need it
--[[_G.InventoryWatcher = nil
pcall(function()
    _G.InventoryWatcher = loadstring(game:HttpGet("https://raw.githubusercontent.com/sinchanthestar/VelouraHUB/refs/heads/main/utils/fishit/inventdetect3.lua"))()
end)]]

_G.SpamFishingActive = false

-- Spawn loop langsung
task.spawn(function()
    while task.wait(0.1) do
        if _G.SpamFishingActive and _G.NetPath then
            pcall(function()
                _G.NetPath["RE/FishingCompleted"]:FireServer()
            end)
        end
    end
end)

-- Cache helper results
local listRod = Helpers.getFishingRodNames()
local weatherName = Helpers.getWeatherNames()
local eventNames = Helpers.getEventNames()
local rarityName = Helpers.getTierNames()
local fishName = Helpers.getFishNames()
local enchantName = Helpers.getEnchantName()

local CancelFishingEvent = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net["RF/CancelFishingInputs"]



-- ===========================
-- INITIALIZE FEATURE MANAGER
-- ===========================
mainLogger:info("Initializing features synchronously...")
local loadedCount, totalCount = FeatureManager:InitializeAllFeatures(Noctis, featureLogger)
mainLogger:info(string.format("Features ready: %d/%d", loadedCount, totalCount))

local function gradient(text, startColor, endColor)
    -- Default colors kalo ga dikasih
    startColor = startColor or Color3.fromRGB(0, 255, 255)    -- Cyan
endColor = endColor or Color3.fromRGB(0, 200, 200)        -- Teal


    
    local parts = {}
    local visibleChars = {}
    local i = 1
    
    -- Extract tags dan characters
    while i <= #text do
        if text:sub(i, i) == '<' then
            local closePos = text:find('>', i)
            if closePos then
                table.insert(parts, {type = "tag", content = text:sub(i, closePos)})
                i = closePos + 1
            else
                table.insert(visibleChars, text:sub(i, i))
                i = i + 1
            end
        else
            table.insert(visibleChars, text:sub(i, i))
            i = i + 1
        end
    end
    
    -- Apply gradient ke visible chars
    local coloredChars = {}
    for idx, char in ipairs(visibleChars) do
        local t = (#visibleChars == 1) and 0 or ((idx - 1) / (#visibleChars - 1))
        local r = math.floor((startColor.R + (endColor.R - startColor.R) * t) * 255)
        local g = math.floor((startColor.G + (endColor.G - startColor.G) * t) * 255)
        local b = math.floor((startColor.B + (endColor.B - startColor.B) * t) * 255)
        table.insert(coloredChars, string.format('<font color="rgb(%d,%d,%d)">%s</font>', r, g, b, char))
    end
    
    -- Rebuild string
    local result = ""
    local charIdx = 1
    i = 1
    while i <= #text do
        if text:sub(i, i) == '<' then
            local closePos = text:find('>', i)
            if closePos then
                result = result .. text:sub(i, closePos)
                i = closePos + 1
            else
                result = result .. (coloredChars[charIdx] or text:sub(i, i))
                charIdx = charIdx + 1
                i = i + 1
            end
        else
            result = result .. (coloredChars[charIdx] or "")
            charIdx = charIdx + 1
            i = i + 1
        end
    end
    
    return result
end

local Window = Noctis:Window({
	Title = "Noctis",
	Subtitle = "Fish It | v1.0.9",
	Size = UDim2.fromOffset(600, 300),
	DragStyle = 1,
	DisabledWindowControls = {},
	OpenButtonImage = "rbxassetid://123156553209294", 
	OpenButtonSize = UDim2.fromOffset(32, 32),
	OpenButtonPosition = UDim2.fromScale(0.45, 0.1),
	Keybind = Enum.KeyCode.RightControl,
	AcrylicBlur = true,
})

FeatureManager:InitAll(Window, Logger)
local F = FeatureManager:CreateProxy(Window, Logger)

--- === TAB === ---
local Group      = Window:TabGroup()
local Home       = Group:Tab({ Title = "Home", Image = "house"})
local Main       = Group:Tab({ Title = "Main", Image = "gamepad"})
local Backpack   = Group:Tab({ Title = "Backpack", Image = "backpack"})
local Automation = Group:Tab({ Title = "Automation", Image = "workflow"})
local Shop       = Group:Tab({ Title = "Shop", Image = "shopping-bag"})
local Teleport  = Group:Tab({ Title = "Teleport", Image = "map"})
local Misc       = Group:Tab({ Title = "Misc", Image = "cog"})
local Setting    = Group:Tab({ Title = "Settings", Image = "settings"})

--- === CHANGELOG & DISCORD LINK === ---
local CHANGELOG = table.concat({
    "[+] Added Hide Nickname",
    "[+] Added Auto Finish Fishing",
    "[/] Fixed Auto Send Trade",
    "[/] Fixed Player List",
    "[/] Changed Quest Progress Info, refresh every 60 seconds",
    "[/] Improved Auto Favorite, now support Mutation + Rarity or etc",
    "[/] Fixed & Improved Balatant"
}, "\n")
local DISCORD = table.concat({
    "https://discord.gg/3AzvRJFT3M",
}, "\n")

--- === HOME === ---
--- === INFORMATION === ---
local Information = Home:Section({ Title = "Home", Opened = true })
Information:Paragraph({
	Title = gradient("<b>Information</b>"),
	Desc = CHANGELOG
})
Information:Button({
	Title = "<b>Join Discord</b>",
	Callback = function()
		if typeof(setclipboard) == "function" then
            setclipboard(DISCORD)
            Window:Notify({ Title = "Noctis", Desc = "Discord link copied!", Duration = 2 })
        else
            Window:Notify({ Title = "Noctis", Desc = "Clipboard not available", Duration = 3 })
        end
    end
})
Information:Divider()
--[[local PlayerInfoParagraph = Information:Paragraph({
	Title = gradient("<b>Player Stats</b>"),
	Desc = ""
})
local inventoryWatcher = _G.InventoryWatcher and _G.InventoryWatcher.getShared()

-- Variabel untuk nyimpen nilai-nilai
local caughtValue = "0"
local rarestValue = "-"
local fishesCount = "0"
local itemsCount = "0"

-- ✅ Throttle config
local THROTTLE_INTERVAL = 3  -- Update UI setiap 0.5 detik
local lastUpdateTime = 0
local pendingUpdate = false

-- Function untuk update desc paragraph
local function updatePlayerInfoDesc()
    local descText = string.format(
        "<b>Statistics</b>\nCaught: %s\nRarest Fish: %s\n\n<b>Inventory</b>\nFishes: %s\nItems: %s",
        caughtValue,
        rarestValue,
        fishesCount,
        itemsCount
    )
    PlayerInfoParagraph:SetDesc(descText)
end

-- ✅ Throttled update (schedule max 1x per interval)
local function scheduleUpdate()
    if pendingUpdate then return end
    
    local now = os.clock()
    local timeSinceLastUpdate = now - lastUpdateTime
    
    if timeSinceLastUpdate >= THROTTLE_INTERVAL then
        -- Update immediately
        updatePlayerInfoDesc()
        lastUpdateTime = now
    else
        -- Schedule untuk nanti
        pendingUpdate = true
        local delay = THROTTLE_INTERVAL - timeSinceLastUpdate
        
        task.delay(delay, function()
            updatePlayerInfoDesc()
            lastUpdateTime = os.clock()
            pendingUpdate = false
        end)
    end
end

-- Update inventory counts (throttled)
if inventoryWatcher then
    inventoryWatcher:onReady(function()
        local function updateInventory()
            local counts = inventoryWatcher:getCountsByType()
            fishesCount = tostring(counts["Fishes"] or 0)
            itemsCount = tostring(counts["Items"] or 0)
            scheduleUpdate()  -- ✅ Throttled
        end
        updateInventory()
        inventoryWatcher:onChanged(updateInventory)
    end)
end

-- Update caught value (throttled)
local function updateCaught()
    caughtValue = tostring(Helpers.getCaughtValue())
    scheduleUpdate()  -- ✅ Throttled
end

local function connectToCaughtChanges()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        local caught = leaderstats:FindFirstChild("Caught")
        if caught and caught:IsA("IntValue") then
            caught:GetPropertyChangedSignal("Value"):Connect(updateCaught)
        end
    end
end

-- Update rarest value (throttled)
local function updateRarest()
    rarestValue = tostring(Helpers.getRarestValue())
    scheduleUpdate()  -- ✅ Throttled
end

local function connectToRarestChanges()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        local rarest = leaderstats:FindFirstChild("Rarest Fish")
        if rarest and rarest:IsA("StringValue") then
            rarest:GetPropertyChangedSignal("Value"):Connect(updateRarest)
        end
    end
end

-- Initialize
LocalPlayer:WaitForChild("leaderstats")
connectToCaughtChanges()
connectToRarestChanges()
updateCaught()
updateRarest()]]

--- === MAIN === ---
--- === FISHING === ---
local FishingSection = Main:Section({ Title = "Fishing", Opened = false })

-- State tracking
local currentMethod = "V1" -- default
local isAutoFishActive = false

-- Balatant V5 delay configs
local balatantWaitWindow = 0.6         -- Default 600ms (ReplicateText check window)
local balatantSafetyTimeout = 3        -- Default 3s (Safety net timeout)
-- balatantBaitSpawnedDelay REMOVED - now hardcoded to 0 in module

-- Function untuk stop semua
local function stopAllAutoFish()
    if F.AutoFish and F.AutoFish.Stop then
        F.AutoFish:Stop()
    end
    if F.AutoFishV2 and F.AutoFishV2.Stop then
        F.AutoFishV2:Stop()
    end
    if F.AutoFishV3 and F.AutoFishV3.Stop then
        F.AutoFishV3:Stop()
    end
    if F.Balatant and F.Balatant.Stop then
        F.Balatant:Stop()
    end
end

-- Function untuk start sesuai method
local function startAutoFish(method)
    stopAllAutoFish() -- stop dulu yang lain
    
    if method == "V1" and F.AutoFish and F.AutoFish.Start then
        F.AutoFish:Start({ mode = "Fast" })
    elseif method == "V2" and F.AutoFishV2 and F.AutoFishV2.Start then
        F.AutoFishV2:Start({ mode = "Fast" })
    elseif method == "V3" and F.AutoFishV3 and F.AutoFishV3.Start then
        F.AutoFishV3:Start({ mode = "Fast" })
    elseif method == "Balatant" and F.Balatant and F.Balatant.Start then
        F.Balatant:Start({
            mode = "Fast",
            waitWindow = balatantWaitWindow,
            safetyTimeout = balatantSafetyTimeout
            -- baitSpawnedDelay dihapus - pakai hardcoded value
        })
    end
end

FishingSection:Label({ Title = "<b>Fishing Mode</b>"})

local autofish_dd = FishingSection:Dropdown({
    Title = "<b>Select Mode</b>",
    Search = true,
    Multi = false,
    Required = false,
    Options = {"Balatant (Unstable)", "Fast", "Stable", "Normal"},
    Default = "Fast",
    Callback = function(v)
        -- Map dropdown value ke method
        if v == "Fast" then
            currentMethod = "V1"
        elseif v == "Stable" then
            currentMethod = "V2"
        elseif v == "Normal" then
            currentMethod = "V3"
        elseif v == "Balatant (Unstable)" then
            currentMethod = "Balatant"
        end
        
        -- Kalo lagi aktif, restart dengan method baru
        if isAutoFishActive then
            startAutoFish(currentMethod)
        end
    end
}, "autofishdd")

-- Detection Window Input (WAIT_WINDOW)
local baitdelay_in = FishingSection:Input({
    Name = "<b>Detection Window</b>",
    Placeholder = "e.g 0.6 (seconds)",
    AcceptedCharacters = "Numbers",
    Callback = function(v)
        local n = tonumber(v)
        if n and n >= 0.05 and n <= 5 then
            balatantWaitWindow = n
            
            -- Update runtime kalo Balatant lagi jalan
            if isAutoFishActive and currentMethod == "Balatant" and F.Balatant then
                F.Balatant:SetDelays(balatantWaitWindow, nil)
            end
        end
    end
}, "baitdelayin")

-- Cast Delay Input (SAFETY_TIMEOUT)
local chargedelay_in = FishingSection:Input({
    Name = "<b>Cast Delay</b>",
    Placeholder = "e.g 3 (seconds)",
    AcceptedCharacters = "Numbers",
    Callback = function(v)
        local n = tonumber(v)
        if n and n >= 1 and n <= 30 then
            balatantSafetyTimeout = n
            
            -- Update runtime kalo Balatant lagi jalan
            if isAutoFishActive and currentMethod == "Balatant" and F.Balatant then
                F.Balatant:SetDelays(nil, balatantSafetyTimeout)
            end
        end
    end
}, "chargedelayin")

local autofish_tgl = FishingSection:Toggle({
    Title = "<b>Auto Fishing</b>",
    Default = false,
    Callback = function(v)
        isAutoFishActive = v
        
        if v then
            -- Start dengan method yang dipilih
            startAutoFish(currentMethod)
        else
            -- Stop semua
            stopAllAutoFish()
        end
    end
}, "autofishtgl")

local autofinish_tgl = FishingSection:Toggle({
    Title = "<b>Auto Finish Fishing</b>",
    Default = false,
    Callback = function(v)
        _G.SpamFishingActive = v
    end
}, "autofinishtgl")
        

local noanim_tgl = FishingSection:Toggle({
	Title = "<b>No Animation</b>",
	Default = false,
	Callback = function(v)
        if v then
            -- ENABLE: Stop fishing animations only
            getgenv().NoAnimEnabled = true
            
            getgenv().NoAnimLoop = RunService.Heartbeat:Connect(function()
                pcall(function()
                    local AC = require(ReplicatedStorage.Controllers.AnimationController)
                    -- DestroyActiveAnimationTracks tanpa parameter = destroy semua
                    -- Dengan whitelist = destroy semua KECUALI yang di whitelist
                    -- Kita kasih whitelist kosong biar destroy semua fishing animations
                    AC:DestroyActiveAnimationTracks({})
                end)
            end)
        else
            -- DISABLE: Stop loop
            getgenv().NoAnimEnabled = false
            if getgenv().NoAnimLoop then
                getgenv().NoAnimLoop:Disconnect()
                getgenv().NoAnimLoop = nil
            end
        end
    end
}, "noanimtgl")

local autofixfish_tgl = FishingSection:Toggle({
	Title = "<b>Auto Fix Fishing</b>",
	Default = false,
	Callback = function(v)
        if v then
            F.AutoFixFishing:Start()
        else
            F.AutoFixFishing:Stop()
        end
    end
}, "autofixfishtgl")

FishingSection:Button({
	Title = "<b>Cancel Fishing</b>",
	Callback = function()
        if CancelFishingEvent and CancelFishingEvent.InvokeServer then
            local success, result = pcall(function()
                return CancelFishingEvent:InvokeServer()
            end)

            if success then
                mainLogger:info("[CancelFishingInputs] Fixed", result)
            else
                 mainLogger:warn("[CancelFishingInputs] Error, Report to Dev", result)
            end
        else
             mainLogger:warn("[CancelFishingInputs] Report this bug to Dev")
        end
    end
})

local savepos_tgl = FishingSection:Toggle({
	Title = "<b>Save Current Position</b>",
	Default = false,
	Callback = function(v)
        if v then F.SavePosition:Start() else F.SavePosition:Stop() end
    end
}, "savepostgl")

--- === EVENT === ---
local EventSection = Main:Section({ Title = "Event", Opened = false })
local selectedEventsArray = {}
local eventtele_ddm = EventSection:Dropdown({
    Title = "<b>Select Event</b>",
    Search = true,
    Multi = true,
    Required = false,
    Values = eventNames,
    Callback = function(v)
        selectedEventsArray = Helpers.normalizeList(v or {})   
        if F.AutoTeleportEvent and F.AutoTeleportEvent.SetSelectedEvents then
            F.AutoTeleportEvent:SetSelectedEvents(selectedEventsArray)
        end
    end
}, "eventteleddm")

local eventtele_tgl = EventSection:Toggle({
	Title = "<b>Auto Teleport Event</b>",
	Default = false,
	Callback = function(v)
        if v and F.AutoTeleportEvent then
            local arr = Helpers.normalizeList(selectedEventsArray or {})
            if F.AutoTeleportEvent.SetSelectedEvents then F.AutoTeleportEvent:SetSelectedEvents(arr) end
            if F.AutoTeleportEvent.Start then
                F.AutoTeleportEvent:Start({ selectedEvents = arr, hoverHeight = 12 })
            end
        elseif F.AutoTeleportEvent and F.AutoTeleportEvent.Stop then
            F.AutoTeleportEvent:Stop()
        end
    end
}, "eventteletgl")

--- === BOAT === ---
--[[local BoatSection = Main:Section({ Title = "Boat", Opened = false })
local boat_dd = BoatSection:Dropdown({
    Title = "<b>Select Boat</b>",
    Search = true,
    Multi = false,
    Required = false,
    Values = Helpers.getBoatNames(),
    Callback = function(v)
    local boatName = Helpers.normalizeOption(v)
    if boatName then
        local boatId = Helpers.getBoatIdByName(boatName)
        if boatId then
            F.Boat:SetSelectedBoat(boatId)
        end
    end
end
}, "boatdd")

BoatSection:Button({
	Title = "<b>Spawn Boat</b>",
	Callback = function()
     F.Boat:SpawnBoat()
    end
})

BoatSection:Button({
	Title = "<b>Despawn Boat</b>",
	Callback = function()
     F.Boat:DespawnBoat()
    end
})]]

--- ==== LOCALPLAYER === ---
local LocalPlayerSection = Main:Section({ Title = "LocalPlayer", Opened = false})
local infjump_tgl = LocalPlayerSection:Toggle({
	Title = "<b>Inf Jump</b>",
	Default = false,
	Callback = function(v)
        if v then
                F.PlayerModif:EnableInfJump()
            else
                F.PlayerModif:DisableInfJump()
         end
    end
}, "infjumptgl")

local fly_tgl = LocalPlayerSection:Toggle({
	Title = "<b>Fly</b>",
	Default = false,
	Callback = function(v)
        if v then
                F.PlayerModif:EnableFly()
            else
                F.PlayerModif:DisableFly()
         end
    end
}, "flytgl")

local noclip_tgl = LocalPlayerSection:Toggle({
	Title = "<b>No Clip</b>",
	Default = false,
	Callback = function(v)
    end
}, "nocliptgl")

local walkspeed_sldr = LocalPlayerSection:Slider({
		Title = "Walkspeed",
		Default = 20,
		Minimum = 0,
		Maximum = 100,
		DisplayMethod = "Value",
		Precision = 0,
		Callback = function(v)
			F.PlayerModif:SetWalkSpeed(v)
        end
}, "walkspeedsldr")

--- === BACKPACK === ---
local FavoriteSection = Backpack:Section({ Title = "Favorite", Opened = false })

local isFavActive = false
local selectedRarities = {}
local selectedFishNames = {}
local selectedMutations = {}

FavoriteSection:Label({ Title = "<b>Tip: You can combine filters! (e.g., Rarity + Mutation, Name + Mutation, or all three)</b>"})

local favrarity_ddm = FavoriteSection:Dropdown({
    Title = "<b>Favorite by Rarity</b>",
    Search = true,
    Multi = true,
    Required = false,
    Values = rarityName,
    Callback = function(v)
        selectedRarities = Helpers.normalizeList(v or {})
        
        if isFavActive and F.AutoFavorite and F.AutoFavorite.SetTiers then
            F.AutoFavorite:SetTiers(selectedRarities)
        end
    end
}, "favrarityddm")

FavoriteSection:Divider()

local favfishname_ddm = FavoriteSection:Dropdown({
    Title = "<b>Favorite by Fish Name</b>",
    Search = true,
    Multi = true,
    Required = false,
    Values = fishName,
    Callback = function(v)
        selectedFishNames = Helpers.normalizeList(v or {})
        
        if isFavActive and F.AutoFavorite and F.AutoFavorite.SetFishNames then
            F.AutoFavorite:SetFishNames(selectedFishNames)
        end
    end
}, "favfishnameddm")

FavoriteSection:Divider()

local favfishmutation_ddm = FavoriteSection:Dropdown({
    Title = "<b>Favorite by Fish Mutation</b>",
    Search = true,
    Multi = true,
    Required = false,
    Values = Helpers.getVariantNames(),
    Callback = function(v)
        selectedMutations = Helpers.normalizeList(v or {})
        
        if isFavActive and F.AutoFavorite and F.AutoFavorite.SetVariants then
            F.AutoFavorite:SetVariants(selectedMutations)
        end
    end
}, "favfishmutationddm")

local autofav_tgl = FavoriteSection:Toggle({
    Title = "<b>Auto Favorite</b>",
    Default = false,
    Callback = function(v)
        isFavActive = v
        
        if v then
            if F.AutoFavorite then
                local hasAnyFilter = #selectedRarities > 0 or #selectedFishNames > 0 or #selectedMutations > 0
                
                if not hasAnyFilter then
                    Window:Notify({ 
                        Title = "Auto Favorite", 
                        Desc = "Select at least one filter first!", 
                        Duration = 3 
                    })
                    return
                end
                
                if F.AutoFavorite.SetTiers then
                    F.AutoFavorite:SetTiers(selectedRarities)
                end
                if F.AutoFavorite.SetFishNames then
                    F.AutoFavorite:SetFishNames(selectedFishNames)
                end
                if F.AutoFavorite.SetVariants then
                    F.AutoFavorite:SetVariants(selectedMutations)
                end
                
                if F.AutoFavorite.Start then
                    F.AutoFavorite:Start({
                        tierList = selectedRarities,
                        fishNames = selectedFishNames,
                        variantList = selectedMutations
                    })
                end
                
                local activeFilters = {}
                if #selectedRarities > 0 then table.insert(activeFilters, "Rarity") end
                if #selectedFishNames > 0 then table.insert(activeFilters, "Name") end
                if #selectedMutations > 0 then table.insert(activeFilters, "Mutation") end
                
                Window:Notify({ 
                    Title = "Auto Favorite", 
                    Desc = "Active with: " .. table.concat(activeFilters, " + "), 
                    Duration = 3 
                })
            end
            
        else
            if F.AutoFavorite and F.AutoFavorite.Stop then
                F.AutoFavorite:Stop()
            end
            Window:Notify({ Title = "Auto Favorite", Desc = "Stopped", Duration = 2 })
        end
    end
}, "autofavtgl")

local unfavall_tgl = FavoriteSection:Toggle({
    Title = "<b>Unfavorite All Fish</b>",
    Default = false,
    Callback = function(v)
        if v and F.UnfavoriteAllFish then
            if F.UnfavoriteAllFish.Start then 
                F.UnfavoriteAllFish:Start() 
            end
        elseif F.UnfavoriteAllFish and F.UnfavoriteAllFish.Stop then
            F.UnfavoriteAllFish:Stop()
        end
    end
}, "unfavalltgl")

--- === SELL === ---
local SellSection = Backpack:Section({ Title = "Sell", Opened = false })
local currentSellThreshold   = "Legendary"
local currentSellLimit       = 0
local sellfish_dd = SellSection:Dropdown({
    Title = "<b>Select Rarity</b>",
    Search = true,
    Multi = false,
    Required = false,
    Values = {"Secret", "Mythic", "Legendary"},
    Default = "Legendary",
    Callback = function(v)
        currentSellThreshold = v or {}
        if F.AutoSellFish and F.AutoSellFish.SetMode then
           F.AutoSellFish:SetMode(v)
        end
    end
}, "sellfishdd")

local sellfish_in = SellSection:Input({
	Name = "<b>Input Delay</b>",
	Placeholder = "e.g 60 (seconds)",
	AcceptedCharacters = "All",
	Callback = function(v)
	local n = tonumber(v) or 0
        currentSellLimit = n
        if  F.AutoSellFish and  F.AutoSellFish.SetLimit then
             F.AutoSellFish:SetLimit(n)
        end
    end
}, "sellfishin")

local sellfish_tgl = SellSection:Toggle({
    Title = "<b>Auto Sell Fish</b>",
    Default = false,
    Callback = function(v)
        if v and F.AutoSellFish then
            if F.AutoSellFish.SetMode then F.AutoSellFish:SetMode(currentSellThreshold) end
            if F.AutoSellFish.Start then F.AutoSellFish:Start({ 
                threshold   = currentSellThreshold,
                limit       = currentSellLimit,
                autoOnLimit = true 
            }) end
        elseif F.AutoSellFish and F.AutoSellFish.Stop then
            F.AutoSellFish:Stop()
        end
    end
}, "sellfishtgl")

--- === TRADE === ---
local TradeSection = Backpack:Section({ Title = "Trade", Opened = false })
local selectedTradeItems    = {}
local selectedTradeEnchants = {}
local selectedTargetPlayers = {}

TradeSection:Label({ Title = "<b>Tip: Select ONLY Enchant or Fish, dont use both at same time!</b>"})

local tradeplayer_dd = TradeSection:Dropdown({
    Title = "<b>Select Player</b>",
    Values = Helpers.listPlayers(true, function(list)
        tradeplayer_dd:ClearOptions()
        tradeplayer_dd:SetValues(list)
    end),
    Callback = function(v)
        selectedTargetPlayers = Helpers.normalizeList(v or {})
        if F.AutoSendTrade and F.AutoSendTrade.SetTargetPlayers then
            F.AutoSendTrade:SetTargetPlayers(selectedTargetPlayers)
        end
    end
}, "tradeplayerdd")
TradeSection:Divider()
local tradefish_ddm = TradeSection:Dropdown({
    Title = "<b>Select Fish</b>",
    Search = true,
    Multi = true,
    Required = false,
    Values = Helpers.getFishNamesForTrade(),
    Callback = function(v)
        selectedTradeItems = Helpers.normalizeList(v or {})
        if F.AutoSendTrade and F.AutoSendTrade.SetSelectedFish then
            F.AutoSendTrade:SetSelectedFish(selectedTradeItems)
        end
    end
}, "tradefishddm")
TradeSection:Divider()
local tradeenchant_ddm = TradeSection:Dropdown({
    Title = "<b>Select Enchant</b>",
    Search = true,
    Multi = true,
    Required = false,
    Values = Helpers.getEnchantStonesForTrade(),
    Callback = function(v)
        selectedTradeEnchants = Helpers.normalizeList(v or {})
        if F.AutoSendTrade and F.AutoSendTrade.SetSelectedItems then
            F.AutoSendTrade:SetSelectedItems(selectedTradeEnchants)
        end
    end
}, "tradeenchantddm")

local tradelay_in = TradeSection:Input({
	Name = "<b>Input Delay</b>",
	Placeholder = "e.g 15 (seconds)",
	AcceptedCharacters = "All",
	Callback = function(v)
        local delay = math.max(1, tonumber(v) or 20)
        if F.AutoSendTrade and F.AutoSendTrade.SetTradeDelay then
            F.AutoSendTrade:SetTradeDelay(delay)
        end
    end
}, "tradelayin")

TradeSection:Button({
	Title = "<b>Refresh Player List</b>",
	Callback = function()
        local names = Helpers.listPlayers(true)
        tradeplayer_dd:ClearOptions()
        tradeplayer_dd:SetValues(names)
        Window:Notify({ Title = "Players", Desc = ("Online: %d"):format(#names), Duration = 2 })
    end
})

local tradesend_tgl = TradeSection:Toggle({
    Title = "<b>Auto Send Trade</b>",
    Default = false,
    Callback = function(v)
        if v and F.AutoSendTrade then
            if #selectedTradeItems == 0 and #selectedTradeEnchants == 0 then
                Window:Notify({ Title="Info", Desc ="Select at least 1 fish or enchant stone first", Duration=3 })
                return
            end
            if #selectedTargetPlayers == 0 then
                Window:Notify({ Title="Info", Desc ="Select at least 1 target player", Duration=3 })
                return
            end

            local delay = math.max(1, tonumber(tradelay_in.Value) or 5)
            if F.AutoSendTrade.SetSelectedFish then F.AutoSendTrade:SetSelectedFish(selectedTradeItems) end
            if F.AutoSendTrade.SetSelectedItems then F.AutoSendTrade:SetSelectedItems(selectedTradeEnchants) end
            if F.AutoSendTrade.SetTargetPlayers then F.AutoSendTrade:SetTargetPlayers(selectedTargetPlayers) end
            if F.AutoSendTrade.SetTradeDelay then F.AutoSendTrade:SetTradeDelay(delay) end

            F.AutoSendTrade:Start({
                fishNames  = selectedTradeItems,
                itemNames  = selectedTradeEnchants,
                playerList = selectedTargetPlayers,
                tradeDelay = delay,
            })
        elseif F.AutoSendTrade and F.AutoSendTrade.Stop then
            F.AutoSendTrade:Stop()
        end
    end
}, "tradesendtgl")

local tradeacc_tgl = TradeSection:Toggle({
    Title = "<b>Auto Accept Trade</b>",
    Default = false,
    Callback = function(v)
        if v and F.AutoAcceptTrade and F.AutoAcceptTrade.Start then
            F.AutoAcceptTrade:Start({ 
                ClicksPerSecond = 18,
                EdgePaddingFrac = 0 
            })
        elseif F.AutoAcceptTrade and F.AutoAcceptTrade.Stop then
            F.AutoAcceptTrade:Stop()
        end
    end
}, "tradeacctgl")

--- === AUTOMATION === ---
--- === Enchant === ---
local EnchantSection = Automation:Section({ Title = "Enchant", Opened = false })

-- State tracking untuk enchant
local selectedEnchantsSlot1 = {}
local selectedEnchantsSlot2 = {}
local enchantDelay = 8
local isEnchantActive = false

EnchantSection:Label({ Title = "<b>Tip: Select ONLY slot 1 or slot 2, dont use both at same time!</b>"})

local enchantslot1_ddm = EnchantSection:Dropdown({
    Title = "<b>Enchant Slot 1</b>",
    Search = true,
    Multi = true,
    Required = false,
    Values = enchantName,
    Callback = function(v)
        selectedEnchantsSlot1 = Helpers.normalizeList(v or {})
        
        -- Update config saat jalan (hanya jika slot 1 yang aktif)
        if isEnchantActive and F.AutoEnchantRod and F.AutoEnchantRod.SetDesiredByNames then
            F.AutoEnchantRod:SetDesiredByNames(selectedEnchantsSlot1)
        end
    end
}, "enchantslot1ddm")
EnchantSection:Divider()
-- Dropdown untuk Slot 2 (Second Altar - autoenchantrod2.txt)
local enchantslot2_ddm = EnchantSection:Dropdown({
    Title = "<b>Enchant Slot 2</b>",
    Search = true,
    Multi = true,
    Required = false,
    Values = enchantName,
    Callback = function(v)
        selectedEnchantsSlot2 = Helpers.normalizeList(v or {})
        
        -- Update config saat jalan (hanya jika slot 2 yang aktif)
        if isEnchantActive and F.AutoEnchantRod2 and F.AutoEnchantRod2.SetDesiredByNames then
            F.AutoEnchantRod2:SetDesiredByNames(selectedEnchantsSlot2)
        end
    end
}, "enchantslot2ddm")

-- 1 Toggle untuk aktifkan SALAH SATU slot (prioritas: Slot 1 > Slot 2)
local autoenchant_tgl = EnchantSection:Toggle({
    Title = "<b>Auto Enchant</b>",
    Default = false,
    Callback = function(v)
        isEnchantActive = v
        
        if v then
            -- Stop semua dulu (safety)
            if F.AutoEnchantRod and F.AutoEnchantRod.Stop then
                F.AutoEnchantRod:Stop()
            end
            if F.AutoEnchantRod2 and F.AutoEnchantRod2.Stop then
                F.AutoEnchantRod2:Stop()
            end
            
            -- Logika prioritas: Slot 1 > Slot 2
            if #selectedEnchantsSlot1 > 0 and F.AutoEnchantRod then
                -- START SLOT 1
                if F.AutoEnchantRod.SetDesiredByNames then 
                    F.AutoEnchantRod:SetDesiredByNames(selectedEnchantsSlot1) 
                end
                if F.AutoEnchantRod.Start then
                    F.AutoEnchantRod:Start({
                        delay = enchantDelay,
                        enchantNames = selectedEnchantsSlot1
                    })
                end
                Window:Notify({ Title = "Auto Enchant", Desc = "Slot 1 (Enchant Altar) Active", Duration = 2 })
                
            elseif #selectedEnchantsSlot2 > 0 and F.AutoEnchantRod2 then
                -- START SLOT 2 (hanya jika Slot 1 kosong)
                if F.AutoEnchantRod2.SetDesiredByNames then 
                    F.AutoEnchantRod2:SetDesiredByNames(selectedEnchantsSlot2) 
                end
                if F.AutoEnchantRod2.Start then
                    F.AutoEnchantRod2:Start({
                        delay = enchantDelay,
                        enchantNames = selectedEnchantsSlot2
                    })
                end
                Window:Notify({ Title = "Auto Enchant", Desc = "Slot 2 (Temple Altar) Active", Duration = 2 })
                
            else
                -- Tidak ada enchant yang dipilih
                Window:Notify({ 
                    Title = "Auto Enchant", 
                    Desc = "Select enchants in Slot 1 or Slot 2 first!", 
                    Duration = 3 
                })
                
            end
            
        else
            -- Stop SEMUA
            if F.AutoEnchantRod and F.AutoEnchantRod.Stop then
                F.AutoEnchantRod:Stop()
            end
            if F.AutoEnchantRod2 and F.AutoEnchantRod2.Stop then
                F.AutoEnchantRod2:Stop()
            end
            
            Window:Notify({ Title = "Auto Enchant", Desc = "Stopped", Duration = 2 })
        end
    end
}, "autoenchanttgl")

EnchantSection:Label({ Title = "<b>Tip: Free atleast 2 slot in hotbar for Auto Enchant and Submit SECRET</b>"})

EnchantSection:Divider()
EnchantSection:Label({ Title = "<b>Auto Submit SECRET</b>" })
local selectedSecretFish = {}
local submitsecret_ddm = EnchantSection:Dropdown({
    Title = "<b>Select SECRET Fish</b>",
    Search = true,
    Multi = true,
    Required = false,
    Values = Helpers.getSecretFishNames(),
    Callback = function(v)
        selectedSecretFish = Helpers.normalizeList(v or {})
        if F.AutoSubmitSecret and F.AutoSubmitSecret.SetTargetFishName then
            -- Set first selected fish as target
            if #selectedSecretFish > 0 then
                F.AutoSubmitSecret:SetTargetFishName(selectedSecretFish[1])
            end
        end
    end
}, "submitsecretdm")

local submitsecret_tgl = EnchantSection:Toggle({
    Title = "<b>Auto Submit to Temple Guardian</b>",
    Default = false,
    Callback = function(v)
        if v and F.AutoSubmitSecret then
            if #selectedSecretFish == 0 then
                Window:Notify({ Title="Info", Desc="Select at least 1 SECRET fish", Duration=3 })
                return
            end
            if F.AutoSubmitSecret.SetTargetFishName then
                F.AutoSubmitSecret:SetTargetFishName(selectedSecretFish[1])
            end
            if F.AutoSubmitSecret.Start then
                F.AutoSubmitSecret:Start({
                    fishName = selectedSecretFish[1],
                    delay = 0.5
                })
            end
        elseif F.AutoSubmitSecret and F.AutoSubmitSecret.Stop then
            F.AutoSubmitSecret:Stop()
        end
    end
}, "submitsecrettgl")

--- === QUEST === ---
local QuestSection = Automation:Section({ Title = "Quest", Opened = false })
local deepseainfo = QuestSection:Paragraph({
	Title = gradient("<b>Deep Sea Quest (Ghostfinn)</b>"),
	Desc = Helpers.getDeepSeaQuestProgress()
})

task.spawn(function()
	local progress = Helpers.getDeepSeaQuestProgress()
	deepseainfo:SetDesc(progress)
end)

-- Auto update setiap 5 detik
task.spawn(function()
	while true do
		task.wait(60)
		local progress = Helpers.getDeepSeaQuestProgress()
		deepseainfo:SetDesc(progress)
	end
end)

local deepsea_tgl = QuestSection:Toggle({
    Title = "<b>Auto Quest Deep Sea</b>",
    Default = false,
    Callback = function(v)
         if v then 
            if F.QuestGhostfinn then F.QuestGhostfinn:Start() end
        else
            if F.QuestGhostfinn then F.QuestGhostfinn:Stop() end
        end
    end
}, "deepseatgl")

QuestSection:Divider()

local elementinfo = QuestSection:Paragraph({
	Title = gradient("<b>Element Jungle (Element Rod)</b>"),
	Desc = Helpers.getElemetJungleQuestProgress()
})

task.spawn(function()
	local progress = Helpers.getElemetJungleQuestProgress()
	elementinfo:SetDesc(progress)
end)

-- Auto update setiap 5 detik
task.spawn(function()
	while true do
		task.wait(60)
		local progress = Helpers.getElemetJungleQuestProgress()
		elementinfo:SetDesc(progress)
	end
end)

local elemental_tgl = QuestSection:Toggle({
    Title = "<b>Auto Quest</b>",
    Default = false,
    Callback = function(v)
        if v then 
            if F.QuestElemental then F.QuestElemental:Start() end
        else
            if F.QuestElemental then F.QuestElemental:Stop() end
        end
    end
}, "elementtgl")

--- ==== SHOP === ---
--- === ROD === ---
local RodSection = Shop:Section({ Title = "Rod", Opened = false })
local rodPriceLabel
local selectedRodsSet = {}
local function updateRodPriceLabel()
    local total = Helpers.calculateTotalPrice(selectedRodsSet, Helpers.getRodPrice)
    if rodPriceLabel then
        rodPriceLabel:SetTitle("Total Price: " .. Helpers.abbreviateNumber(total, 1))
    end
end
local shoprod_ddm = RodSection:Dropdown({
    Title = "<b>Select Rod</b>",
    Search = true,
    Multi = true,
    Required = false,
    Values = listRod,
    Callback = function(v)
        selectedRodsSet = Helpers.normalizeList(v or {})
        updateRodPriceLabel()

        if F.AutoBuyRod and F.AutoBuyRod.SetSelectedRodsByName then
            F.AutoBuyRod:SetSelectedRodsByName(selectedRodsSet)
        end
    end
}, "shoproddm")
rodPriceLabel = RodSection:Label({ Title = "Total Price: $0"})
RodSection:Button({
	Title = "<b>Buy Rod</b>",
	Callback = function()
        if F.AutoBuyRod.SetSelectedRodsByName then F.AutoBuyRod:SetSelectedRodsByName(selectedRodsSet) end
        if F.AutoBuyRod.Start then F.AutoBuyRod:Start({ 
            rodList = selectedRodsSet,
            interDelay = 0.5 
        }) end
    end
})

--- === BAIT === ---
local BaitSection = Shop:Section({ Title = "Bait", Opened = false })
local baitName = Helpers.getBaitNames()
local baitPriceLabel
local selectedBaitsSet = {}
local function updateBaitPriceLabel()
    local total = Helpers.calculateTotalPrice(selectedBaitsSet, Helpers.getBaitPrice)
    if baitPriceLabel then
        baitPriceLabel:SetTitle("Total Price: " .. Helpers.abbreviateNumber(total, 1))
    end
end
local shopbait_ddm = BaitSection:Dropdown({
    Title = "<b>Select Bait</b>",
    Search = true,
    Multi = true,
    Required = false,
    Values = baitName,
    Callback = function(v)
        selectedBaitsSet = Helpers.normalizeList(v or {})
        updateBaitPriceLabel()

        if F.AutoBuyBait and F.AutoBuyBait.SetSelectedBaitsByName then
            F.AutoBuyBait:SetSelectedBaitsByName(selectedBaitsSet)
        end
    end
}, "shopbaitdm")

baitPriceLabel = BaitSection:Label({ Title = "Total Price: $0"})

BaitSection:Button({
	Title = "<b>Buy Bait</b>",
	Callback = function()
        if F.AutoBuyBait.SetSelectedBaitsByName then F.AutoBuyBait:SetSelectedBaitsByName(selectedBaitsSet) end
        if F.AutoBuyBait.Start then F.AutoBuyBait:Start({ 
            baitList = selectedBaitsSet,
            interDelay = 0.5 
        }) end
    end
})

--- === WEATHER === ---
local WeatherSection = Shop:Section({ Title = "Weather", Opened = false })
local selectedWeatherSet = {} 
local shopweather_ddm = WeatherSection:Dropdown({
    Title = "<b>Select Weather</b>",
    Search = true,
    Multi = true,
    Required = false,
    Values = weatherName,
    Callback = function(v)
        selectedWeatherSet = v or {}
        if F.AutoBuyWeather and F.AutoBuyWeather.SetWeathers then
           F.AutoBuyWeather:SetWeathers(selectedWeatherSet)
        end
    end
}, "shopweatherdm")

local shopweather_tgl = WeatherSection:Toggle({
    Title = "<b>Auto Buy Weather</b>",
    Default = false,
    Callback = function(v)
    if v and F.AutoBuyWeather then
            if F.AutoBuyWeather.SetWeathers then F.AutoBuyWeather:SetWeathers(selectedWeatherSet) end
            if F.AutoBuyWeather.Start then F.AutoBuyWeather:Start({ 
                weatherList = selectedWeatherSet 
            }) end
        elseif F.AutoBuyWeather and F.AutoBuyWeather.Stop then
            F.AutoBuyWeather:Stop()
        end
    end
}, "shopweathertgl")


--- === MERCHANT === ---
local MerchantSection = Shop:Section({ Title = "Merchant", Opened = false })
local merchantstock = MerchantSection:Paragraph({
	Title = gradient("<b>Merchant Stock</b>"),
	Desc = "CHANGELOG"
})
local merchant_ddm = MerchantSection:Dropdown({
    Title = "<b>Select Item</b>",
    Search = true,
    Multi = true,
    Required = false,
    Values = {"Enchantment Stone", "Mystery Egg", "Treasure Chest", "Golden Rod", "Platinum Rod", "Diamond Rod", "Mythic Rod", "Legendary Rod", "Secret Rod"},
    Callback = function(v)
    end
}, "merchantddm")
MerchantSection:Button({
	Title = "<b>Buy Merchant Item</b>",
	Callback = function()
    end
})

--- ==== TELEPORT ==== ---
--- === ISLAND === ---
local IslandSection = Teleport:Section({ Title = "Island", Opened = false })
local currentIsland = "Fisherman Island"
local teleisland_dd = IslandSection:Dropdown({
    Title = "<b>Select Island</b>",
    Search = true,
    Multi = false,
    Required = false,
    Values = {
        "Fisherman Island",
        "Esoteric Depths",
        "Enchant Altar",
        "Enchant Temple",
        "Ancient Jungle",
        "Kohana",
        "Kohana Volcano",
        "Tropical Grove",
        "Crater Island",
        "Coral Reefs",
        "Sisyphus Statue",
        "Treasure Room",
        "Winter Island",
        "Ice Lake",
        "Weather Machine",
        "Sacred Temple",
        "Underground Cellar",
        "Hallow Bay",
        "Mount Hallow"
    },
       Callback = function(v)
        currentIsland = v or {}
        if F.AutoTeleportIsland and F.AutoTeleportIsland.SetIsland then
           F.AutoTeleportIsland:SetIsland(v)
        end
    end
}, "teleislanddd")

IslandSection:Button({
	Title = "<b>Teleport to Island</b>",
	Callback = function()
    if F.AutoTeleportIsland then
            if F.AutoTeleportIsland.SetIsland then
                F.AutoTeleportIsland:SetIsland(currentIsland)
            end
            if F.AutoTeleportIsland.Teleport then
                F.AutoTeleportIsland:Teleport(currentIsland)
            end
        end
    end
})

--- === PLAYER === ---
local PlayerSection = Teleport:Section({ Title = "Player", Opened = false })
local currentPlayerName = nil
local teleplayer_dd = PlayerSection:Dropdown({
    Title = "<b>Select Player</b>",
    Values = Helpers.listPlayers(true, function(list)
        teleplayer_dd:ClearOptions()
        teleplayer_dd:SetValues(list)
    end),
    Callback = function(v)
        local name = Helpers.normalizeOption(v)
        currentPlayerName = name
        if F.AutoTeleportPlayer and F.AutoTeleportPlayer.SetTarget then
            F.AutoTeleportPlayer:SetTarget(name)
        end
    end
}, "teleplayerdd")

PlayerSection:Button({
	Title = "<b>Teleport to Player</b>",
	Callback = function()
        if F.AutoTeleportPlayer then
            if F.AutoTeleportPlayer.SetTarget then
                F.AutoTeleportPlayer:SetTarget(currentPlayerName)
            end
            if F.AutoTeleportPlayer.Teleport then
                F.AutoTeleportPlayer:Teleport(currentPlayerName)
            end
        end
    end
})

PlayerSection:Button({
	Title = "<b>Refresh Player List</b>",
	Callback = function()
        local names = Helpers.listPlayers(true) 
            teleplayer_dd:ClearOptions()
            teleplayer_dd:SetValues(names)
        Window:Notify({ Title = "Players", Desc = ("Online: %d"):format(#names), Duration = 2 })
    end
})

--- === POSITION === ---
local PositionSection = Teleport:Section({ Title = "Position", Opened = false })
local currentPosName = ""
local currentSelectedPos = ""

local savepos_in = PositionSection:Input({
	Name = "<b>Input Name</b>",
	Placeholder = "e.g Farm",
	AcceptedCharacters = "All",
	Callback = function(v)
		currentPosName = v
	end
}, "saveposin")

PositionSection:Button({
	Title = "<b>Add New Position</b>",
	Callback = function()
		local name = currentPosName
		if not name or name == "" or name == "Position Name" then
			Window:Notify({
				Title = "Position Teleport",
				Desc = "Please enter a valid position name",
				Duration = 3
			})
			return
		end
		local success, message = F.PositionManager:AddPosition(name)
		if success then
			Window:Notify({
				Title = "Position Teleport",
				Desc = "Position '" .. name .. "' added successfully",
				Duration = 2
			})
			currentPosName = ""
			if savepos_in.UpdateText then
				savepos_in:UpdateText("")
			end
			-- auto refresh dropdown setelah add
			local list = F.PositionManager:RefreshDropdown()
            savepos_dd:ClearOptions()
			savepos_dd:SetValues(list)
		else
			Window:Notify({
				Title = "Position Teleport",
				Desc = message or "Failed to add position",
				Duration = 3
			})
		end
	end
})

local savepos_dd = PositionSection:Dropdown({
	Title = "<b>Select Position</b>",
	Search = true,
	Multi = false,
	Required = false,
	Values = {"No Positions"},
	Callback = function(v)
		currentSelectedPos = v
	end
}, "saveposdd")

PositionSection:Button({
	Title = "<b>Delete Selected Position</b>",
	Callback = function()
		local selectedPos = currentSelectedPos
		if not selectedPos or selectedPos == "No Positions" then
			Window:Notify({
				Title = "Position Teleport",
				Desc = "Please select a position to delete",
				Duration = 3
			})
			return
		end
		
		local success, message = F.PositionManager:DeletePosition(selectedPos)
		if success then
			Window:Notify({
				Title = "Position Teleport",
				Desc = "Position '" .. selectedPos .. "' deleted",
				Duration = 2
			})
			-- auto refresh dropdown setelah delete
			local list = F.PositionManager:RefreshDropdown()
            savepos_dd:ClearOptions()
			savepos_dd:SetValues(list)
			currentSelectedPos = ""
		else
			Window:Notify({
				Title = "Position Teleport",
				Desc = message or "Failed to delete position",
				Duration = 3
			})
		end
	end
})

PositionSection:Button({
	Title = "<b>Refresh Position List</b>",
	Callback = function()
		local list = F.PositionManager:RefreshDropdown()
        savepos_dd:ClearOptions()
		savepos_dd:SetValues(list) -- refresh dropdown GUI
		local count = #list
		if list[1] == "No Positions" then count = 0 end
		
		Window:Notify({
			Title = "Position Teleport",
			Desc = count .. " positions found",
			Duration = 2
		})
	end
})

PositionSection:Button({
	Title = "<b>Teleport to Position</b>",
	Callback = function()
		local selectedPos = currentSelectedPos
		if not selectedPos or selectedPos == "No Positions" then
			Window:Notify({
				Title = "Position Teleport",
				Desc = "Please select a position to teleport",
				Duration = 3
			})
			return
		end
		local success, message = F.PositionManager:TeleportToPosition(selectedPos)
		if success then
			Window:Notify({
				Title = "Position Teleport",
				Desc = "Teleported to '" .. selectedPos .. "'",
				Duration = 2
			})
		else
			Window:Notify({
				Title = "Position Teleport",
				Desc = message or "Failed to teleport",
				Duration = 3
			})
		end
	end
})

--- === MISC === ---
--- === VISUAL === ---
local VisualSection = Misc:Section({ Title = "Visual", Opened = false })
-- State variables
local customName = "HouseOfNoctis"  -- Default custom name
local customLevel = "Lv: XXXX"       -- Default custom level
local nameChangerConnection = nil

-- Function untuk change overhead
local function changeOverhead()
    local character = workspace.Characters:FindFirstChild(LocalPlayer.Name)
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local overhead = hrp:FindFirstChild("Overhead")
    if not overhead then return end
    
    -- Ganti Nama
    local header = overhead:FindFirstChild("Content") and overhead.Content:FindFirstChild("Header")
    if header and header:IsA("TextLabel") then
        header.Text = customName
    end
    
    -- Ganti Level
    local levelLabel = overhead:FindFirstChild("LevelContainer") and overhead.LevelContainer:FindFirstChild("Label")
    if levelLabel and levelLabel:IsA("TextLabel") then
        levelLabel.Text = customLevel
    end
end

-- Function untuk reset ke original
local function resetOverhead()
    local character = workspace.Characters:FindFirstChild(LocalPlayer.Name)
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local overhead = hrp:FindFirstChild("Overhead")
    if not overhead then return end
    
    -- Reset ke nama asli
    local header = overhead:FindFirstChild("Content") and overhead.Content:FindFirstChild("Header")
    if header and header:IsA("TextLabel") then
        header.Text = LocalPlayer.DisplayName or LocalPlayer.Name
    end
    
    -- Reset ke level asli
    local level = LocalPlayer:FindFirstChild("leaderstats") and LocalPlayer.leaderstats:FindFirstChild("Level")
    if level then
        local levelLabel = overhead:FindFirstChild("LevelContainer") and overhead.LevelContainer:FindFirstChild("Label")
        if levelLabel and levelLabel:IsA("TextLabel") then
            levelLabel.Text = tostring(level.Value)
        end
    end
end

-- Toggle untuk activate name changer
local hidenick_tgl = VisualSection:Toggle({
    Title = "<b>Hide Name & Level</b>",
    Default = false,
    Callback = function(v)
        if v then
            -- Apply custom name/level
            task.wait(0.5)
            changeOverhead()
            
            -- Setup auto-apply on respawn
            if nameChangerConnection then
                nameChangerConnection:Disconnect()
            end
            
            nameChangerConnection = LocalPlayer.CharacterAdded:Connect(function()
                task.wait(2) -- Wait for overhead to load
                changeOverhead()
            end)
        else
            -- Reset to original
            resetOverhead()
            
            -- Disconnect auto-apply
            if nameChangerConnection then
                nameChangerConnection:Disconnect()
                nameChangerConnection = nil
            end
        end
    end
}, "hidenicktgl")

--- === WEBHOOK === ---
local WebhookSection = Misc:Section({ Title = "Webhook", Opened = false })
local currentWebhookUrl = ""
local selectedWebhookFishTypes = {}
local testmessage = "@everyone Webhook URL valid, All Good!"
local webhookfish_in = WebhookSection:Input({
	Name = "<b>Input Webhook URL</b>",
	Placeholder = "e.g https://discord...",
	AcceptedCharacters = "All",
	Callback = function(v)
        currentWebhookUrl = v
        if F.FishWebhook and F.FishWebhook.SetWebhookUrl then
            F.FishWebhook:SetWebhookUrl(v)
        end
    end
}, "webhookfishin")

local webhookfish_ddm = WebhookSection:Dropdown({
    Title = "<b>Select Rarity</b>",
    Search = true,
    Multi = true,
    Required = false,
    Values = rarityName,
    Callback = function(v)
        selectedWebhookFishTypes = Helpers.normalizeList(v or {})
        if F.FishWebhook and F.FishWebhook.SetSelectedFishTypes then
            F.FishWebhook:SetSelectedFishTypes(selectedWebhookFishTypes)
        end
        if F.FishWebhook and F.FishWebhook.SetSelectedTiers then
            F.FishWebhook:SetSelectedTiers(selectedWebhookFishTypes)
        end
    end
}, "webhookfishddm")

local webhookfish_tgl = WebhookSection:Toggle({
    Title = "<b>Enable Webhook</b>",
    Default = false,
    Callback = function(v)
    if v and F.FishWebhook then
            if F.FishWebhook.SetWebhookUrl then 
                F.FishWebhook:SetWebhookUrl(currentWebhookUrl) 
            end
            
            if F.FishWebhook.SetSelectedFishTypes then 
                F.FishWebhook:SetSelectedFishTypes(selectedWebhookFishTypes) 
            end
            if F.FishWebhook.SetSelectedTiers then 
                F.FishWebhook:SetSelectedTiers(selectedWebhookFishTypes) 
            end
            
            if F.FishWebhook.Start then 
                F.FishWebhook:Start({ 
                    webhookUrl = currentWebhookUrl,
                    selectedTiers = selectedWebhookFishTypes,
                    selectedFishTypes = selectedWebhookFishTypes
                }) 
            end
        elseif F.FishWebhook and F.FishWebhook.Stop then
            F.FishWebhook:Stop()
        end
    end
}, "webhookfishtgl")

WebhookSection:Button({
	Title = "<b>Test Webhook</b>",
	Callback = function()
        if F.FishWebhook then F.FishWebhook:TestWebhook(testmessage) end
    end
})

--- === SERVER === ---
--- === JOIN SERVER, RECONNECT, REEXEC === ---
local ServerSection = Misc:Section({ Title = "Server", Opened = false })
local server_in = ServerSection:Input({
	Name = "<b>Input JobId</b>",
	Placeholder = "e.g XXX-XX-XXX",
	AcceptedCharacters = "All",
	Callback = function(v)
        if F.CopyJoinServer then F.CopyJoinServer:SetTargetJobId(v) end
    end
})

ServerSection:Button({
	Title = "<b>Join Server</b>",
	Callback = function()
    if F.CopyJoinServer then
            local jobId = server_in.v
            F.CopyJoinServer:JoinServer(jobId)
        end
    end
})

ServerSection:Button({
	Title = "<b>Copy Current Server JobId</b>",
	Callback = function()
    if F.CopyJoinServer then F.CopyJoinServer:CopyCurrentJobId() end
    end
})

ServerSection:Divider()

local reconnect_tgl = ServerSection:Toggle({
    Title = "<b>Auto Reconnect</b>",
    Default = false,
    Callback = function(v)
        if v then
            F.AutoReconnect:Start()
        else
            F.AutoReconnect:Stop()
        end
    end
}, "reconnecttgl")

local reexec_tgl = ServerSection:Toggle({
    Title = "<b>Re-Execute on Reconnect</b>",
    Default = false,
    Callback = function(v)
        if v then
            local ok, err = pcall(function() F.AutoReexec:Start() end)
            if not ok then warn("[AutoReexec] Start failed:", err) end
        else
            local ok, err = pcall(function() F.AutoReexec:Stop() end)
            if not ok then warn("[AutoReexec] Stop failed:", err) end
        end
    end
}, "reexectgl")

--- === PERFORMANCE === ---
local PerformanceSection = Misc:Section({ Title = "Performance", Opened = false })
--- === BLACK SCREEN === ---
local blackScreenGui = nil

local function EnableBlackScreen()
    if blackScreenGui then return end
    
    RunService:Set3dRenderingEnabled(false)
    
    blackScreenGui = Instance.new("ScreenGui")
    blackScreenGui.ResetOnSpawn = false
    blackScreenGui.IgnoreGuiInset = true
    blackScreenGui.DisplayOrder = -999999
    blackScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    blackScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(1, 0, 1, 36)
    frame.Position = UDim2.new(0, 0, 0, -36)
    frame.ZIndex = -999999
    frame.Parent = blackScreenGui
end

local function DisableBlackScreen()
    if blackScreenGui then
        blackScreenGui:Destroy()
        blackScreenGui = nil
    end
    RunService:Set3dRenderingEnabled(true)
end

local blackscreen_tgl = PerformanceSection:Toggle({
    Title = "<b>Black Screen</b>",
    Default = false,
    Callback = function(v)
        if v then
            EnableBlackScreen()
        else
            DisableBlackScreen()
        end
    end
}, "blackscreen")

--- === BOOST FPS === ---
local boostfps_tgl = PerformanceSection:Toggle({
    Title = "<b>Boost FPS</b>",
    Default = false,
    Callback = function(v)
        if v then
            if F.BoostFPS and F.BoostFPS.Start then
                F.BoostFPS:Start()
            end
        end
    end
}, "boostfpstgl")

--- === OTHER === ---
local OtherSection = Misc:Section({ Title = "Other", Opened = false })
--- === OXYRADAR === ---
local oxygenOn = false
local radarOn  = false
local eqoxygentank_tgl = OtherSection:Toggle({
    Title = "<b>Enable Diving Gear</b>",
    Default = false,
    Callback = function(v)
        oxygenOn = v
        if v then
            if F.AutoGearOxyRadar and F.AutoGearOxyRadar.Start then
                F.AutoGearOxyRadar:Start()
            end
            if F.AutoGearOxyRadar and F.AutoGearOxyRadar.EnableOxygen then
                F.AutoGearOxyRadar:EnableOxygen(true)
            end
        else
            if F.AutoGearOxyRadar and F.AutoGearOxyRadar.EnableOxygen then
                F.AutoGearOxyRadar:EnableOxygen(false)
            end
        end
        if F.AutoGearOxyRadar and (not oxygenOn) and (not radarOn) and F.AutoGearOxyRadar.Stop then
            F.AutoGearOxyRadar:Stop()
        end
    end
}, "oxygentanktgl")

local eqfishradar_tgl = OtherSection:Toggle({
    Title = "<b>Enable Fish Radar</b>",
    Default = false,
    Callback = function(v)
        radarOn = v
        if v then
            if F.AutoGearOxyRadar and F.AutoGearOxyRadar.Start then
                F.AutoGearOxyRadar:Start()
            end
            if F.AutoGearOxyRadar and F.AutoGearOxyRadar.EnableRadar then
                F.AutoGearOxyRadar:EnableRadar(true)
            end
        else
            if F.AutoGearOxyRadar and F.AutoGearOxyRadar.EnableRadar then
                F.AutoGearOxyRadar:EnableRadar(false)
            end
        end
        if F.AutoGearOxyRadar and (not oxygenOn) and (not radarOn) and F.AutoGearOxyRadar.Stop then
            F.AutoGearOxyRadar:Stop()
        end
    end
}, "fishradartgl")

--- === PLAYER ESP === ---
local playeresp_tgl = OtherSection:Toggle({
    Title = "<b>Player ESP</b>",
    Default = false,
    Callback = function(v)
        if v then F.PlayerEsp:Start() else F.PlayerEsp:Stop() 
       end
end
}, "playeresptgl")

--- === SETTING === ---
local UISection = Setting:Section({ Title = "UI Setting", Opened = false })
local acrylic_tgl = UISection:Toggle({
    Title = "Acrylic",
    Default = true,
    Callback = function(bool)
       Window:SetAcrylicBlurState(bool)
   end
}, "acrylictgl")
Setting:InsertConfigSection()
Home:Select()
Noctis:LoadAutoLoadConfig()

if F.AntiAfk and F.AntiAfk.Start then
                F.AntiAfk:Start()
end

task.defer(function()
    task.wait(0.1)
    Window:Notify({
        Title = "Noctis",
        Desc = "Enjoy! Join Our Discord!",
        Duration = 3
    })
end)
        gui.Parent = gethui()
        return
    end
    local lp = game:GetService("Players").LocalPlayer
    if lp then
        local pg = lp:FindFirstChild("PlayerGui") or lp:WaitForChild("PlayerGui")
        gui.Parent = pg
        return
    end
    gui.Parent = game.CoreGui
end

local function showDebugBanner(text)
    local existing = game.CoreGui:FindFirstChild("FishIt_Debug")
    if existing then
        existing:Destroy()
    end
    local gui = Instance.new("ScreenGui")
    gui.Name = "FishIt_Debug"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ensureGuiParent(gui)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 360, 0, 40)
    label.Position = UDim2.new(0, 20, 0, 20)
    label.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    label.TextColor3 = Color3.fromRGB(255, 200, 120)
    label.BorderSizePixel = 0
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.Text = text
    label.Parent = gui
end

showDebugBanner("FishIt: script running...")

local Library
local function tryLoadLibrary()
    if not loadstring then
        return nil, "loadstring is not available"
    end

    local url = "https://raw.githubusercontent.com/sinchanthestar/VelouraHUB/refs/heads/main/Library.lua"
    local okHttp, bodyOrErr = pcall(function()
        return game:HttpGet(url)
    end)
    if okHttp and type(bodyOrErr) == "string" and #bodyOrErr > 0 then
        local okLoad, libOrErr = pcall(function()
            return loadstring(bodyOrErr)()
        end)
        if okLoad then
            return libOrErr, nil
        end
        return nil, tostring(libOrErr)
    end

    if readfile then
        local okFile, fileBody = pcall(function()
            return readfile("Library.lua")
        end)
        if okFile and type(fileBody) == "string" and #fileBody > 0 then
            local okLoad, libOrErr = pcall(function()
                return loadstring(fileBody)()
            end)
            if okLoad then
                return libOrErr, nil
            end
            return nil, tostring(libOrErr)
        end
        return nil, "readfile failed"
    end

    return nil, tostring(bodyOrErr)
end

local lib, libErr = tryLoadLibrary()
if not lib then
    warn("Library load failed:", libErr)
    showDebugBanner("FishIt: Library load failed - " .. tostring(libErr))
    return
end
Library = lib
showDebugBanner("FishIt: library loaded")

local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    HttpService = game:GetService("HttpService"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    VirtualInputManager = game:GetService("VirtualInputManager"),
    UserInputService = game:GetService("UserInputService"),
    Lighting = game:GetService("Lighting"),
    CoreGui = game:GetService("CoreGui")
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = workspace.CurrentCamera

_G.httpRequest = _G.httpRequest
    or (syn and syn.request)
    or (http and http.request)
    or http_request
    or request

local Modules = {
    Net = nil,
    Replion = nil,
    FishingController = nil,
    TradingController = nil,
    ItemUtility = nil,
    VendorUtility = nil,
    PlayerStatsUtility = nil,
    InputControl = nil
}

pcall(function()
    Modules.Net = Services.ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
end)

pcall(function()
    Modules.Replion = require(Services.ReplicatedStorage.Packages.Replion)
end)

pcall(function()
    Modules.FishingController = require(Services.ReplicatedStorage.Controllers.FishingController)
end)

pcall(function()
    Modules.TradingController = require(Services.ReplicatedStorage.Controllers.ItemTradingController)
end)

pcall(function()
    Modules.ItemUtility = require(Services.ReplicatedStorage.Shared.ItemUtility)
end)

pcall(function()
    Modules.VendorUtility = require(Services.ReplicatedStorage.Shared.VendorUtility)
end)

pcall(function()
    Modules.PlayerStatsUtility = require(Services.ReplicatedStorage.Shared.PlayerStatsUtility)
end)

pcall(function()
    Modules.InputControl = require(Services.ReplicatedStorage.Modules.InputControl)
end)

local function getRemote(name)
    if Modules.Net and Modules.Net[name] then
        return Modules.Net[name]
    end
    return nil
end

local Network = {
    Events = {
        RECutscene = getRemote("RE/ReplicateCutscene"),
        REFav = getRemote("RE/FavoriteItem"),
        REFavChg = getRemote("RE/FavoriteStateChanged"),
        REFishDone = getRemote("RE/FishingCompleted"),
        REFishGot = getRemote("RE/FishCaught"),
        RENotify = getRemote("RE/TextNotification"),
        REEquip = getRemote("RE/EquipToolFromHotbar"),
        REEquipItem = getRemote("RE/EquipItem"),
        REAltar = getRemote("RE/ActivateEnchantingAltar"),
        REAltar2 = getRemote("RE/ActivateSecondEnchantingAltar"),
        UpdateOxygen = getRemote("URE/UpdateOxygen"),
        REObtainedNewFishNotification = getRemote("RE/ObtainedNewFishNotification"),
        FishingMinigameChanged = getRemote("RE/FishingMinigameChanged"),
        FishingStopped = getRemote("RE/FishingStopped")
    },
    Functions = {
        Trade = getRemote("RF/InitiateTrade"),
        BuyRod = getRemote("RF/PurchaseFishingRod"),
        BuyBait = getRemote("RF/PurchaseBait"),
        BuyWeather = getRemote("RF/PurchaseWeatherEvent"),
        ChargeRod = getRemote("RF/ChargeFishingRod"),
        StartMini = getRemote("RF/RequestFishingMinigameStarted"),
        UpdateRadar = getRemote("RF/UpdateFishingRadar"),
        Cancel = getRemote("RF/CancelFishingInputs"),
        SellAll = getRemote("RF/SellAllItems"),
        SellItem = getRemote("RF/SellItem"),
        AutoEnabled = getRemote("RF/UpdateAutoFishingState")
    }
}

local GameData = {
    Data = nil,
    Items = Services.ReplicatedStorage:WaitForChild("Items")
}

pcall(function()
    if Modules.Replion and Modules.Replion.Client then
        GameData.Data = Modules.Replion.Client:WaitReplion("Data")
    end
end)

local function safeFire(remote, ...)
    if remote and remote.FireServer then
        local ok, err = pcall(remote.FireServer, remote, ...)
        if not ok then
            warn("Remote fire failed:", err)
        end
        return ok
    end
    return false
end

local function safeInvoke(remote, ...)
    if remote and remote.InvokeServer then
        local ok, result = pcall(remote.InvokeServer, remote, ...)
        if not ok then
            warn("Remote invoke failed:", result)
            return nil
        end
        return result
    end
    return nil
end

local function notify(msg)
    if type(chloex) == "function" then
        chloex(msg, 3, Color3.fromRGB(255, 131, 74))
    else
        print(msg)
    end
end

local BotConfig = {
    player = LocalPlayer,
    cam = Camera,
    vim = Services.VirtualInputManager,
    autoEquipRod = false,
    autoFavEnabled = false,
    selectedName = {},
    selectedRarity = {},
    selectedVariant = {},
    selectedUnfavRarity = {},
    autoInstant = false,
    canFish = true,
    sellMode = "Delay",
    sellDelay = 60,
    inputSellCount = 50,
    autoSellEnabled = false,
    autoSellThreshold = false,
    autoSellTimer = false,
    sellThreshold = 50,
    boatSpeed = 50,
    safeZoneHeight = 5,
    autoWebhook = false,
    autoWebhookStats = false,
    fishingPanelRunning = false,
    trade = {
        selectedPlayer = nil,
        selectedItem = nil,
        tradeAmount = 1,
        successCount = 0,
        totalToTrade = 0,
        trading = false,
        currentGrouped = {},
        teleportTarget = nil
    }
}

_G.TierFish = _G.TierFish or {
    [1] = "Common",
    [2] = "Uncommon",
    [3] = "Rare",
    [4] = "Epic",
    [5] = "Legendary",
    [6] = "Mythic",
    [7] = "Secret"
}

_G.Variant = _G.Variant or {
    "None",
    "Shiny",
    "Gold",
    "Radioactive",
    "Stone",
    "Holographic",
    "Albino",
    "Bloodmoon",
    "Sandy",
    "Acidic",
    "Color Burn",
    "Festive",
    "Frozen"
}

local function toSet(list)
    local set = {}
    if type(list) == "table" then
        for _, val in ipairs(list) do
            set[val] = true
        end
    end
    return set
end

local function getFishCount()
    local ok, count = pcall(function()
        local bagLabel = LocalPlayer.PlayerGui:WaitForChild("Inventory"):WaitForChild("Main"):WaitForChild("Top")
            :WaitForChild("Options"):WaitForChild("Fish"):WaitForChild("Label"):WaitForChild("BagSize")
        return tonumber((bagLabel.Text or "0/0"):match("(%d+)/")) or 0
    end)
    return ok and count or 0
end

local PositionFilePath = "NineHub/FishIt/Position.json"
local function savePosition(cframe)
    if writefile then
        local data = { cframe:GetComponents() }
        writefile(PositionFilePath, Services.HttpService:JSONEncode(data))
    end
end

local function loadPosition()
    if isfile and isfile(PositionFilePath) then
        local ok, data = pcall(function()
            return Services.HttpService:JSONDecode(readfile(PositionFilePath))
        end)
        if ok and type(data) == "table" then
            return CFrame.new(unpack(data))
        end
    end
    return nil
end

local LocationsList = {
    ["Treasure Room"] = Vector3.new(-3602.01, -266.57, -1577.18),
    ["Sisyphus Statue"] = Vector3.new(-3703.69, -135.57, -1017.17),
    ["Christmas Island"] = Vector3.new(1134.99, 23.93, 1562.07),
    ["Crater Island Top"] = Vector3.new(1011.29, 22.68, 5076.27),
    ["Crater Island Ground"] = Vector3.new(1079.57, 3.64, 5080.35),
    ["Coral Reefs Spot 1"] = Vector3.new(-3031.88, 2.52, 2276.36),
    ["Coral Reefs Spot 2"] = Vector3.new(-3270.86, 2.50, 2228.10),
    ["Coral Reefs Spot 3"] = Vector3.new(-3136.10, 2.61, 2126.11),
    ["Lost Shore"] = Vector3.new(-3737.97, 5.43, -854.68),
    ["Weather Machine"] = Vector3.new(-1524.88, 2.87, 1915.56),
    ["Kohana Volcano"] = Vector3.new(-561.81, 21.24, 156.72),
    ["Kohana Spot 1"] = Vector3.new(-367.77, 6.75, 521.91),
    ["Kohana Spot 2"] = Vector3.new(-623.96, 19.25, 419.36),
    ["Stingray Shores"] = Vector3.new(44.41, 28.83, 3048.93),
    ["Tropical Grove"] = Vector3.new(-2018.91, 9.04, 3750.59),
    ["Ice Sea"] = Vector3.new(2164, 7, 3269),
    ["Tropical Grove Cave 1"] = Vector3.new(-2151, 3, 3671),
    ["Tropical Grove Cave 2"] = Vector3.new(-2018, 5, 3756),
    ["Tropical Grove Highground"] = Vector3.new(-2139, 53, 3624),
    ["Fisherman Island Underground"] = Vector3.new(-62, 3, 2846),
    ["Fisherman Island Mid"] = Vector3.new(33, 3, 2764),
    ["Fisherman Island Rift Left"] = Vector3.new(-26, 10, 2686),
    ["Fisherman Island Rift Right"] = Vector3.new(95, 10, 2684),
    ["Sacred Temple"] = Vector3.new(1475, -22, -632),
    ["Ancient Jungle Outside"] = Vector3.new(1488, 8, -392),
    ["Ancient Jungle"] = Vector3.new(1274, 8, -184),
    ["Underground Cellar"] = Vector3.new(2136, -91, -699),
    ["Crystalline Passage"] = Vector3.new(6051, -539, 4386),
    ["Ancient Ruin"] = Vector3.new(6090, -586, 4634),
    ["Esoteric Deep"] = Vector3.new(3181, -1303, 1425)
}

local locationNames = {}
for name in pairs(LocationsList) do
    table.insert(locationNames, name)
end

table.sort(locationNames, function(a, b)
    return a:lower() < b:lower()
end)

local FishNamesList = {}
for _, itemModule in ipairs(GameData.Items:GetChildren()) do
    if itemModule:IsA("ModuleScript") then
        local ok, mod = pcall(require, itemModule)
        if ok and mod and mod.Data and mod.Data.Type == "Fish" then
            table.insert(FishNamesList, mod.Data.Name)
        end
    end
end

local FavoriteCache = {}
if Network.Events.REFavChg then
    Network.Events.REFavChg.OnClientEvent:Connect(function(uuid, state)
        rawset(FavoriteCache, uuid, state)
    end)
end

local function checkAndFavorite(itemData)
    if not BotConfig.autoFavEnabled or not Modules.ItemUtility then
        return
    end
    local itemInfo = Modules.ItemUtility.GetItemDataFromItemType("Items", itemData.Id)
    if itemInfo and itemInfo.Data.Type == "Fish" then
        local rarity = _G.TierFish[itemInfo.Data.Tier]
        local name = itemInfo.Data.Name
        local variant = itemData.Metadata and (itemData.Metadata.VariantId or "None") or "None"
        local isNameSelected = BotConfig.selectedName[name]
        local isRaritySelected = BotConfig.selectedRarity[rarity]
        local isVariantSelected = BotConfig.selectedVariant[variant]
        local isFavorited = rawget(FavoriteCache, itemData.UUID)
        if isFavorited == nil then
            isFavorited = itemData.Favorited
        end
        local shouldFav = false
        if next(BotConfig.selectedVariant) == nil or next(BotConfig.selectedName) == nil then
            shouldFav = isNameSelected or isRaritySelected
        elseif isNameSelected then
            shouldFav = isVariantSelected
        end
        if shouldFav and not isFavorited then
            safeFire(Network.Events.REFav, itemData.UUID)
            rawset(FavoriteCache, itemData.UUID, true)
        end
    end
end

local function scanInventory()
    if not BotConfig.autoFavEnabled or not GameData.Data then
        return
    end
    for _, itemData in ipairs(GameData.Data:GetExpect({ "Inventory", "Items" })) do
        checkAndFavorite(itemData)
    end
end

local function unfavoriteByRarity()
    if not GameData.Data or not Modules.ItemUtility then
        return
    end
    local invList = GameData.Data:GetExpect({ "Inventory", "Items" })
    for _, item in ipairs(invList) do
        local itemInfo = Modules.ItemUtility.GetItemDataFromItemType("Items", item.Id)
        if itemInfo and itemInfo.Data.Type == "Fish" then
            local rarity = _G.TierFish[itemInfo.Data.Tier]
            if BotConfig.selectedUnfavRarity[rarity] then
                safeFire(Network.Events.REFav, item.UUID)
                rawset(FavoriteCache, item.UUID, false)
            end
        end
    end
end

local function unfavoriteAll()
    if not GameData.Data then
        return
    end
    local invList = GameData.Data:GetExpect({ "Inventory", "Items" })
    for _, item in ipairs(invList) do
        safeFire(Network.Events.REFav, item.UUID)
        rawset(FavoriteCache, item.UUID, false)
    end
end

local function ensureRodEquipped()
    if not GameData.Data or not Modules.PlayerStatsUtility or not Modules.ItemUtility then
        return
    end
    local equippedId = GameData.Data:Get("EquippedId")
    if not equippedId then
        safeFire(Network.Events.REEquip, 1)
        return
    end
    local item = Modules.PlayerStatsUtility:GetItemFromInventory(GameData.Data, function(i)
        return i.UUID == equippedId
    end)
    if not item then
        safeFire(Network.Events.REEquip, 1)
        return
    end
    local itemData = Modules.ItemUtility:GetItemData(item.Id)
    local isRod = itemData and itemData.Data and itemData.Data.Type == "Fishing Rods"
    if not isRod then
        safeFire(Network.Events.REEquip, 1)
    end
end

local function fastCast()
    if not _G.FBlatant then
        return
    end
    safeInvoke(Network.Functions.Cancel)
    Services.RunService.Heartbeat:Wait()
    safeInvoke(Network.Functions.ChargeRod, workspace:GetServerTimeNow())
    task.wait(_G.BlatantCastDelay or 0.05)
    safeInvoke(Network.Functions.StartMini, -1, 0.999)
    task.wait(_G.FishingDelay or 0.05)
    safeFire(Network.Events.REFishDone)
end

local function getGroupedByType(itemType)
    if not GameData.Data or not Modules.ItemUtility then
        return {}, {}
    end
    local inventory = GameData.Data:GetExpect({ "Inventory", "Items" })
    local groupedItems = {}
    local displayList = {}
    for _, item in ipairs(inventory) do
        local itemData = Modules.ItemUtility.GetItemDataFromItemType("Items", item.Id)
        if itemData and (itemData.Data.Type == itemType and not item.Favorited) then
            local name = itemData.Data.Name
            groupedItems[name] = groupedItems[name] or { count = 0, uuids = {} }
            groupedItems[name].count = groupedItems[name].count + (item.Quantity or 1)
            table.insert(groupedItems[name].uuids, item.UUID)
        end
    end
    for name, data in pairs(groupedItems) do
        table.insert(displayList, ("%s x%d"):format(name, data.count))
    end
    return groupedItems, displayList
end

local function autoSellLoop()
    task.spawn(function()
        while BotConfig.autoSellEnabled do
            if BotConfig.autoSellTimer then
                task.wait(BotConfig.sellDelay)
                safeInvoke(Network.Functions.SellAll)
            elseif BotConfig.autoSellThreshold then
                if getFishCount() >= BotConfig.sellThreshold then
                    safeInvoke(Network.Functions.SellAll)
                    task.wait(1)
                else
                    task.wait(0.5)
                end
            else
                task.wait(0.5)
            end
        end
    end)
end

local function setHumanoidProperty(prop, value)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum[prop] = value
    end
end

local function findBoatSeat()
    for _, model in ipairs(workspace:GetChildren()) do
        if model:IsA("Model") and model:FindFirstChildOfClass("VehicleSeat") then
            return model:FindFirstChildOfClass("VehicleSeat")
        end
    end
    return nil
end

local function applyBoatSpeed(speed)
    local seat = findBoatSeat()
    if seat then
        seat.MaxSpeed = speed
        return true
    end
    return false
end

local Window
local okWindow, windowOrErr = pcall(function()
    return Library:Window({
        Title = "FishIt Hub",
        Footer = "NineHub",
        Color = Color3.fromRGB(255, 131, 74),
        Version = 1
    })
end)
if not okWindow then
    warn("Window create failed:", windowOrErr)
    showDebugBanner("FishIt: window failed - " .. tostring(windowOrErr))
    return
end
Window = windowOrErr
if not Window then
    showDebugBanner("FishIt: window nil")
    return
end
showDebugBanner("FishIt: window created")

local Tabs
local okTabs, tabsOrErr = pcall(function()
    return {
        Main = Window:AddTab({ Name = "Main", Icon = "fish" }),
        Blatant = Window:AddTab({ Name = "Blatant Fishing", Icon = "crosshair" }),
        Oxygen = Window:AddTab({ Name = "Oxygen", Icon = "water" }),
        Enchant = Window:AddTab({ Name = "Double Enchant", Icon = "star" }),
        Trade = Window:AddTab({ Name = "Trade", Icon = "cart" }),
        TeleportPos = Window:AddTab({ Name = "Teleport & Position", Icon = "gps" }),
        Selling = Window:AddTab({ Name = "Selling System", Icon = "bag" }),
        Safety = Window:AddTab({ Name = "Safety & Misc", Icon = "alert" }),
        Shop = Window:AddTab({ Name = "Shop", Icon = "shop" }),
        Teleport = Window:AddTab({ Name = "Teleport", Icon = "mappinned" }),
        Boat = Window:AddTab({ Name = "Boat", Icon = "gamepad" }),
        Environment = Window:AddTab({ Name = "Environment", Icon = "strom" }),
        Webhook = Window:AddTab({ Name = "Webhook", Icon = "discord" }),
        Utility = Window:AddTab({ Name = "Utility", Icon = "settings" })
    }
end)
if not okTabs then
    warn("Tab create failed:", tabsOrErr)
    showDebugBanner("FishIt: tabs failed - " .. tostring(tabsOrErr))
    return
end
Tabs = tabsOrErr
showDebugBanner("FishIt: tabs created")

-- MAIN TAB
local MainSection = Tabs.Main:AddSection("Auto Fishing")

MainSection:AddToggle({
    Title = "Auto Fishing V1 (GUI)",
    Default = false,
    Callback = function(enabled)
        if Modules.FishingController then
            Modules.FishingController._autoLoop = enabled
        end
    end
})

MainSection:AddToggle({
    Title = "Auto Fishing V2",
    Default = false,
    Callback = function(enabled)
        BotConfig.autoInstant = enabled
        if enabled then
            task.spawn(function()
                while BotConfig.autoInstant do
                    if BotConfig.canFish then
                        BotConfig.canFish = false
                        local power = safeInvoke(Network.Functions.ChargeRod, workspace:GetServerTimeNow())
                        if typeof(power) == "number" then
                            task.wait(0.3)
                            task.wait(_G.CastDelay or 0)
                            safeInvoke(Network.Functions.StartMini, -1, 0.999, power)
                            task.wait(_G.DelayComplete or 0)
                            safeFire(Network.Events.REFishDone)
                        end
                        safeInvoke(Network.Functions.Cancel)
                        BotConfig.canFish = true
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

MainSection:AddToggle({
    Title = "Legit Fishing",
    Default = false,
    Callback = function(enabled)
        if Modules.FishingController then
            Modules.FishingController._autoLoop = enabled
        end
    end
})

MainSection:AddInput({
    Title = "Wait Delay",
    Default = tostring(_G.DelayComplete or 0),
    Callback = function(val)
        _G.DelayComplete = tonumber(val) or 0
    end
})

MainSection:AddInput({
    Title = "Cast Delay",
    Default = tostring(_G.CastDelay or 0),
    Callback = function(val)
        _G.CastDelay = tonumber(val) or 0
    end
})

MainSection:AddToggle({
    Title = "Auto Equip Rod",
    Default = false,
    Callback = function(enabled)
        BotConfig.autoEquipRod = enabled
        if enabled then
            task.spawn(function()
                while BotConfig.autoEquipRod do
                    ensureRodEquipped()
                    task.wait(1)
                end
            end)
        end
    end
})

MainSection:AddToggle({
    Title = "Remove Fishing Animations",
    Default = false,
    Callback = function(enabled)
        local humanoid = (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):WaitForChild("Humanoid")
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if animator then
            if enabled then
                for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                    track:Stop(0)
                end
                BotConfig.stopAnimConn = animator.AnimationPlayed:Connect(function(track)
                    task.defer(function()
                        pcall(function()
                            track:Stop(0)
                        end)
                    end)
                end)
            else
                if BotConfig.stopAnimConn then
                    BotConfig.stopAnimConn:Disconnect()
                    BotConfig.stopAnimConn = nil
                end
            end
        end
    end
})

MainSection:AddToggle({
    Title = "Fishing Panel",
    Default = false,
    Callback = function(enabled)
        if enabled then
            notify("Fishing panel from Veloura is not embedded here. Use your panel script if needed.")
        else
            local panel = Services.CoreGui:FindFirstChild("ChloeX_FishingPanel")
            if panel then
                panel:Destroy()
            end
        end
    end
})

MainSection:AddToggle({
    Title = "Walk On Water",
    Default = false,
    Callback = function(enabled)
        local root = (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
        if enabled then
            local part = Instance.new("Part")
            part.Name = "WW_Part"
            part.Size = Vector3.new(15, 1, 15)
            part.Anchored = true
            part.CanCollide = false
            part.Transparency = 1
            part.Parent = workspace
            BotConfig.walkWaterPart = part
            BotConfig.walkWaterConn = Services.RunService.Heartbeat:Connect(function()
                if BotConfig.walkWaterPart and root then
                    BotConfig.walkWaterPart.Position = Vector3.new(root.Position.X, -1.8, root.Position.Z)
                    BotConfig.walkWaterPart.CanCollide = -1.8 < root.Position.Y
                end
            end)
        else
            if BotConfig.walkWaterConn then
                BotConfig.walkWaterConn:Disconnect()
                BotConfig.walkWaterConn = nil
            end
            if BotConfig.walkWaterPart then
                BotConfig.walkWaterPart:Destroy()
                BotConfig.walkWaterPart = nil
            end
        end
    end
})

MainSection:AddButton({
    Title = "Fix Rod",
    Callback = function()
        safeInvoke(Network.Functions.Cancel)
        LocalPlayer:SetAttribute("Loading", nil)
        task.wait(0.05)
        LocalPlayer:SetAttribute("Loading", false)
        notify("Rod recovery executed.")
    end
})

local FavSection = Tabs.Main:AddSection("Auto Favorite")
FavSection:AddDropdown({
    Title = "Auto Favorite By Fish Names",
    Multi = true,
    Options = (#FishNamesList > 0 and FishNamesList) or { "No Fish Found" },
    Callback = function(list)
        BotConfig.selectedName = toSet(list)
    end
})

FavSection:AddDropdown({
    Title = "Auto Favorite By Rarity",
    Multi = true,
    Options = { "Rare", "Epic", "Legendary", "Mythic", "Secret" },
    Callback = function(list)
        BotConfig.selectedRarity = toSet(list)
    end
})

FavSection:AddDropdown({
    Title = "Auto Favorite By Variant",
    Multi = true,
    Options = _G.Variant,
    Callback = function(list)
        BotConfig.selectedVariant = toSet(list)
    end
})

FavSection:AddToggle({
    Title = "Enable Auto Favorite",
    Default = false,
    Callback = function(enabled)
        BotConfig.autoFavEnabled = enabled
        if enabled then
            scanInventory()
            if GameData.Data and GameData.Data.OnChange then
                GameData.Data:OnChange({ "Inventory", "Items" }, scanInventory)
            end
        end
    end
})

FavSection:AddDropdown({
    Title = "Unfavorite By Rarity",
    Multi = true,
    Options = { "Rare", "Epic", "Legendary", "Mythic", "Secret" },
    Callback = function(list)
        BotConfig.selectedUnfavRarity = toSet(list)
    end
})

FavSection:AddButton({
    Title = "Unfavorite By Rarity",
    Callback = function()
        unfavoriteByRarity()
    end
})

FavSection:AddButton({
    Title = "Unfavorite All",
    Callback = function()
        unfavoriteAll()
    end
})

-- BLATANT TAB
local BlatantSection = Tabs.Blatant:AddSection("Blatant Fishing")
BlatantSection:AddInput({
    Title = "Fishing Speed (Loop Delay)",
    Default = tostring(_G.Reel or 0.1),
    Callback = function(val)
        _G.Reel = tonumber(val) or 0.1
    end
})

BlatantSection:AddInput({
    Title = "Next Cast Delay",
    Default = tostring(_G.BlatantCastDelay or 0.05),
    Callback = function(val)
        _G.BlatantCastDelay = tonumber(val) or 0.05
    end
})

BlatantSection:AddInput({
    Title = "Catch Delay",
    Default = tostring(_G.FishingDelay or 0.05),
    Callback = function(val)
        _G.FishingDelay = tonumber(val) or 0.05
    end
})

BlatantSection:AddInput({
    Title = "Reset Delay",
    Default = tostring(_G.ResetDelay or 0.05),
    Callback = function(val)
        _G.ResetDelay = tonumber(val) or 0.05
    end
})

BlatantSection:AddToggle({
    Title = "Auto Fishing",
    Default = false,
    Callback = function(enabled)
        _G.FBlatant = enabled
        safeInvoke(Network.Functions.AutoEnabled, enabled)
        if enabled then
            task.spawn(function()
                while _G.FBlatant do
                    fastCast()
                    task.wait(_G.Reel or 0.1)
                    task.wait(_G.ResetDelay or 0.05)
                end
            end)
        end
    end
})

-- OXYGEN TAB
local OxygenSection = Tabs.Oxygen:AddSection("Oxygen")
OxygenSection:AddToggle({
    Title = "Infinite Oxygen",
    Default = false,
    Callback = function(enabled)
        BotConfig.infOxygen = enabled
        if enabled then
            task.spawn(function()
                while BotConfig.infOxygen do
                    safeFire(Network.Events.UpdateOxygen, 100)
                    task.wait(1)
                end
            end)
        end
    end
})

OxygenSection:AddButton({
    Title = "Get Oxygen Tank",
    Callback = function()
        notify("Oxygen tank remote not provided. Add your remote to enable this.")
    end
})

-- DOUBLE ENCHANT TAB
local EnchantSection = Tabs.Enchant:AddSection("Double Enchant")

local function getEnchantStats(targetId)
    if not GameData.Data or not Modules.ItemUtility then
        return "None", "None", 0, {}
    end
    local equipped = GameData.Data:Get("EquippedItems") or {}
    local inventoryRods = GameData.Data:Get({ "Inventory", "Fishing Rods" }) or {}
    local stonesCount = 0
    local stoneUUIDs = {}
    local currentRodName = "None"
    local currentEnchantName = "None"
    for _, equipUUID in pairs(equipped) do
        for _, rodItem in ipairs(inventoryRods) do
            if rodItem.UUID == equipUUID then
                local itemData = Modules.ItemUtility:GetItemData(rodItem.Id)
                currentRodName = itemData and itemData.Data.Name or (rodItem.ItemName or "None")
                if rodItem.Metadata and rodItem.Metadata.EnchantId then
                    local enchantData = Modules.ItemUtility:GetEnchantData(rodItem.Metadata.EnchantId)
                    currentEnchantName = enchantData and enchantData.Data.Name or "None"
                end
            end
        end
    end
    for _, item in pairs(GameData.Data:GetExpect({ "Inventory", "Items" })) do
        local itemInfo = Modules.ItemUtility:GetItemData(item.Id)
        if itemInfo and (itemInfo.Data.Type == "Enchant Stones" and item.Id == targetId) then
            stonesCount = stonesCount + 1
            table.insert(stoneUUIDs, item.UUID)
        end
    end
    return currentRodName, currentEnchantName, stonesCount, stoneUUIDs
end

local EnchantStatus = EnchantSection:AddParagraph({
    Title = "Status",
    Content = "Rod: None | Enchant: None | Stones: 0"
})

local function updateEnchantStatus(targetId)
    local rodName, enchantName, stoneCount = getEnchantStats(targetId)
    EnchantStatus:SetContent(string.format("Rod: %s | Enchant: %s | Stones: %d", rodName, enchantName, stoneCount))
end

EnchantSection:AddButton({
    Title = "Get Enchant Stones",
    Callback = function()
        notify("Add your remote for getting enchant stones.")
    end
})

EnchantSection:AddButton({
    Title = "Double Enchant Rod",
    Callback = function()
        task.spawn(function()
            local rodName, _, stoneCount, stoneUUIDs = getEnchantStats(246)
            if rodName == "None" or stoneCount <= 0 then
                updateEnchantStatus(246)
                return
            end
            safeFire(Network.Events.REEquipItem, stoneUUIDs[1], "Enchant Stones")
            task.wait(0.3)
            safeFire(Network.Events.REEquip, stoneUUIDs[1])
            task.wait(0.2)
            safeFire(Network.Events.REAltar2)
            task.wait(1)
            updateEnchantStatus(246)
        end)
    end
})

EnchantSection:AddToggle({
    Title = "Enable Double Enchant",
    Default = false,
    Callback = function(enabled)
        BotConfig.doubleEnchant = enabled
        if enabled then
            task.spawn(function()
                while BotConfig.doubleEnchant do
                    local _, _, stoneCount = getEnchantStats(246)
                    if stoneCount > 0 then
                        safeFire(Network.Events.REAltar2)
                    end
                    task.wait(2)
                end
            end)
        end
    end
})

-- TRADE TAB
local TradeSection = Tabs.Trade:AddSection("Trade")

local PlayerDropdown = TradeSection:AddDropdown({
    Title = "Select Player To Trade",
    Options = {},
    Callback = function(val)
        BotConfig.trade.selectedPlayer = val
    end
})

TradeSection:AddButton({
    Title = "Refresh Player List",
    Callback = function()
        local list = {}
        for _, p in ipairs(Services.Players:GetPlayers()) do
            if p ~= LocalPlayer then
                table.insert(list, p.Name)
            end
        end
        PlayerDropdown:SetValues(list)
    end
})

local FishDropdown = TradeSection:AddDropdown({
    Title = "Select Fish To Trade",
    Options = {},
    Callback = function(val)
        BotConfig.trade.selectedItem = val
    end
})

TradeSection:AddButton({
    Title = "Refresh Fish List",
    Callback = function()
        local grouped, display = getGroupedByType("Fish")
        BotConfig.trade.currentGrouped = grouped
        FishDropdown:SetValues(display)
    end
})

TradeSection:AddInput({
    Title = "Trade Amount",
    Default = tostring(BotConfig.trade.tradeAmount),
    Callback = function(val)
        BotConfig.trade.tradeAmount = math.max(1, tonumber(val) or 1)
    end
})

TradeSection:AddButton({
    Title = "Send Trade Request",
    Callback = function()
        local tradeData = BotConfig.trade
        if not tradeData.selectedPlayer or not tradeData.selectedItem then
            notify("Select player and fish first.")
            return
        end
        local itemGroup = tradeData.currentGrouped[tradeData.selectedItem:match("^(.-) x") or tradeData.selectedItem]
        if not itemGroup or #itemGroup.uuids == 0 then
            notify("Fish not found.")
            return
        end
        local target = Services.Players:FindFirstChild(tradeData.selectedPlayer)
        if not target then
            notify("Player not found.")
            return
        end
        local itemUUID = itemGroup.uuids[1]
        safeInvoke(Network.Functions.Trade, target.UserId, itemUUID)
    end
})

TradeSection:AddToggle({
    Title = "Auto Accept Trade Request",
    Default = false,
    Callback = function(enabled)
        BotConfig.autoAcceptTrade = enabled
        notify("Auto accept is placeholder. Add your remote to enable.")
    end
})

-- TELEPORT & POSITION TAB
local TelePosSection = Tabs.TeleportPos:AddSection("Teleport & Position")
TelePosSection:AddDropdown({
    Title = "Teleport To Fishing Spots",
    Options = locationNames,
    Callback = function(val)
        BotConfig.teleportTarget = val
    end
})

TelePosSection:AddButton({
    Title = "Teleport To Selected Spot",
    Callback = function()
        local target = BotConfig.teleportTarget
        local coords = LocationsList[target]
        local root = (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
        if coords and root then
            root.CFrame = CFrame.new(coords + Vector3.new(0, 3, 0))
        end
    end
})

TelePosSection:AddButton({
    Title = "Save Position",
    Callback = function()
        local root = (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
        savePosition(root.CFrame)
        notify("Position saved.")
    end,
    SubTitle = "Teleport To Saved Position",
    SubCallback = function()
        local root = (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
        local lastPos = loadPosition()
        if lastPos then
            root.CFrame = lastPos
        end
    end
})

-- SELLING TAB
local SellingSection = Tabs.Selling:AddSection("Selling System")
SellingSection:AddButton({
    Title = "Sell All Fishes At Once",
    Callback = function()
        safeInvoke(Network.Functions.SellAll)
    end
})

SellingSection:AddInput({
    Title = "Sell Interval (Seconds)",
    Default = tostring(BotConfig.sellDelay),
    Callback = function(val)
        BotConfig.sellDelay = tonumber(val) or 60
    end
})

SellingSection:AddInput({
    Title = "Sell Threshold",
    Default = tostring(BotConfig.sellThreshold),
    Callback = function(val)
        BotConfig.sellThreshold = tonumber(val) or 50
    end
})

SellingSection:AddToggle({
    Title = "Auto Sell Timer",
    Default = false,
    Callback = function(enabled)
        BotConfig.autoSellTimer = enabled
        BotConfig.autoSellEnabled = enabled or BotConfig.autoSellThreshold
        if BotConfig.autoSellEnabled then
            autoSellLoop()
        end
    end
})

SellingSection:AddToggle({
    Title = "Auto Sell Threshold",
    Default = false,
    Callback = function(enabled)
        BotConfig.autoSellThreshold = enabled
        BotConfig.autoSellEnabled = enabled or BotConfig.autoSellTimer
        if BotConfig.autoSellEnabled then
            autoSellLoop()
        end
    end
})

-- SAFETY TAB
local SafetySection = Tabs.Safety:AddSection("Safety & Misc")
SafetySection:AddToggle({
    Title = "Freeze Character",
    Default = false,
    Callback = function(enabled)
        BotConfig.freeze = enabled
        local function toggleAnchor(charModel, shouldAnchor)
            if charModel then
                for _, desc in ipairs(charModel:GetDescendants()) do
                    if desc:IsA("BasePart") then
                        desc.Anchored = shouldAnchor
                    end
                end
            end
        end
        local char = LocalPlayer.Character
        toggleAnchor(char, enabled)
    end
})

SafetySection:AddToggle({
    Title = "Bypass Fishing Radar",
    Default = false,
    Callback = function(enabled)
        if Network.Functions.UpdateRadar then
            safeInvoke(Network.Functions.UpdateRadar, not enabled)
        else
            notify("Radar remote not found.")
        end
    end
})

SafetySection:AddInput({
    Title = "Safe Zone Height",
    Default = tostring(BotConfig.safeZoneHeight),
    Callback = function(val)
        BotConfig.safeZoneHeight = tonumber(val) or 5
    end
})

SafetySection:AddButton({
    Title = "Create Safe Zone",
    Callback = function()
        local root = (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
        local zone = Instance.new("Part")
        zone.Name = "SafeZone"
        zone.Anchored = true
        zone.Size = Vector3.new(20, 1, 20)
        zone.Transparency = 0.6
        zone.CanCollide = true
        zone.Position = root.Position + Vector3.new(0, BotConfig.safeZoneHeight, 0)
        zone.Parent = workspace
    end
})

-- SHOP TAB
local ShopSection = Tabs.Shop:AddSection("Shop")

ShopSection:AddButton({
    Title = "Merchant Shop Stock",
    Callback = function()
        notify("Open merchant to see stock.")
    end
})

ShopSection:AddButton({
    Title = "Buy All Rods",
    Callback = function()
        notify("Add remote for buy all rods.")
    end
})

ShopSection:AddButton({
    Title = "Buy All Baits",
    Callback = function()
        notify("Add remote for buy all baits.")
    end
})

ShopSection:AddButton({
    Title = "Buy All Boats",
    Callback = function()
        notify("Add remote for buy all boats.")
    end
})

ShopSection:AddButton({
    Title = "Buy All Weathers",
    Callback = function()
        notify("Add remote for buy all weathers.")
    end
})

-- TELEPORT TAB
local TeleportSection = Tabs.Teleport:AddSection("Teleport")

TeleportSection:AddButton({
    Title = "Crystal Fall Event Timer",
    Callback = function()
        notify("Event timer placeholder.")
    end
})

TeleportSection:AddButton({
    Title = "Teleport To All Islands",
    Callback = function()
        notify("Island list not provided. Add location list to enable.")
    end
})

TeleportSection:AddButton({
    Title = "Teleport To All NPCs",
    Callback = function()
        notify("NPC list not provided.")
    end
})

TeleportSection:AddButton({
    Title = "Teleport To Events",
    Callback = function()
        notify("Event list not provided.")
    end
})

local TeleportPlayerDropdown = TeleportSection:AddDropdown({
    Title = "Teleport To All Players",
    Options = {},
    Callback = function(val)
        BotConfig.trade.teleportTarget = val
    end
})

TeleportSection:AddButton({
    Title = "Refresh Player List",
    Callback = function()
        local list = {}
        for _, p in ipairs(Services.Players:GetPlayers()) do
            if p ~= LocalPlayer then
                table.insert(list, p.Name)
            end
        end
        TeleportPlayerDropdown:SetValues(list)
    end
})

TeleportSection:AddButton({
    Title = "Teleport To Selected Player",
    Callback = function()
        local targetName = BotConfig.trade.teleportTarget
        local targetPlayer = Services.Players:FindFirstChild(targetName)
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local root = (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
            root.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
        end
    end
})

-- BOAT TAB
local BoatSection = Tabs.Boat:AddSection("Boat Controls")
BoatSection:AddSlider({
    Title = "Set Boat Speed",
    Min = 0,
    Max = 1000,
    Default = BotConfig.boatSpeed,
    Increment = 10,
    Callback = function(val)
        BotConfig.boatSpeed = val
    end
})

BoatSection:AddButton({
    Title = "Set Boat Speed",
    Callback = function()
        if not applyBoatSpeed(BotConfig.boatSpeed) then
            notify("Boat seat not found.")
        end
    end,
    SubTitle = "Reset Boat Speed",
    SubCallback = function()
        applyBoatSpeed(50)
    end
})

local BoatManage = Tabs.Boat:AddSection("Boat Management")
BoatManage:AddDropdown({
    Title = "Select Boat To Spawn",
    Options = { "None" },
    Callback = function(val)
        BotConfig.selectedBoat = val
    end
})

BoatManage:AddButton({
    Title = "Spawn Selected Boat",
    Callback = function()
        notify("Boat spawn remote not provided.")
    end,
    SubTitle = "Despawn Boat",
    SubCallback = function()
        notify("Boat despawn remote not provided.")
    end
})

-- ENVIRONMENT TAB
local EnvSection = Tabs.Environment:AddSection("Environment")

EnvSection:AddToggle({
    Title = "Only Day",
    Default = false,
    Callback = function(enabled)
        BotConfig.onlyDay = enabled
        if enabled then
            Services.Lighting.ClockTime = 12
        end
    end
})

EnvSection:AddToggle({
    Title = "Only Night",
    Default = false,
    Callback = function(enabled)
        BotConfig.onlyNight = enabled
        if enabled then
            Services.Lighting.ClockTime = 0
        end
    end
})

EnvSection:AddToggle({
    Title = "Remove Fog",
    Default = false,
    Callback = function(enabled)
        if enabled then
            Services.Lighting.FogStart = 100000
            Services.Lighting.FogEnd = 100000
            for _, obj in ipairs(Services.Lighting:GetChildren()) do
                if obj:IsA("Atmosphere") then
                    obj.Enabled = false
                end
            end
        end
    end
})

EnvSection:AddToggle({
    Title = "Remove Rain",
    Default = false,
    Callback = function(enabled)
        if enabled then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name:lower():find("rain") then
                    pcall(function()
                        obj:Destroy()
                    end)
                end
            end
        end
    end
})

EnvSection:AddToggle({
    Title = "Remove Snow",
    Default = false,
    Callback = function(enabled)
        if enabled then
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name:lower():find("snow") then
                    pcall(function()
                        obj:Destroy()
                    end)
                end
            end
        end
    end
})

-- WEBHOOK TAB
_G.WebhookFlags = _G.WebhookFlags or {
    FishCaught = { Enabled = false, URL = "" },
    Stats = { Enabled = false, URL = "", Delay = 5 }
}

local FishDB = {}
local function buildFishDatabase()
    for _, itemModule in ipairs(GameData.Items:GetChildren()) do
        if itemModule:IsA("ModuleScript") then
            local ok, mod = pcall(require, itemModule)
            if ok and mod and mod.Data and mod.Data.Type == "Fish" then
                FishDB[mod.Data.Id] = {
                    Name = mod.Data.Name,
                    Tier = mod.Data.Tier,
                    Icon = mod.Data.Icon
                }
            end
        end
    end
end

buildFishDatabase()

local WebhookSection = Tabs.Webhook:AddSection("Webhook")

local function sendWebhook(url, payload)
    if _G.httpRequest and url and url ~= "" then
        pcall(function()
            _G.httpRequest({
                Url = url,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = Services.HttpService:JSONEncode(payload)
            })
        end)
    end
end

local function sendFishWebhook(itemId, metadata)
    if not _G.WebhookFlags.FishCaught.Enabled then
        return
    end
    local url = _G.WebhookFlags.FishCaught.URL
    if not (url and url:match("discord.com/api/webhooks")) then
        return
    end
    local fishInfo = FishDB[itemId]
    if not fishInfo then
        return
    end
    local tierName = _G.TierFish[fishInfo.Tier] or "Unknown"
    if type(_G.WebhookRarities) == "table" and #_G.WebhookRarities > 0 then
        if not table.find(_G.WebhookRarities, tierName) then
            return
        end
    end
    local weight = "N/A"
    local variant = "None"
    if type(metadata) == "table" then
        if metadata.Weight then
            weight = string.format("%.2f Kg", metadata.Weight)
        end
        if metadata.VariantId then
            variant = tostring(metadata.VariantId)
        end
    end
    local payload = {
        content = _G.WebhookDiscordId or "",
        embeds = {{
            title = "Fish Caught",
            description = string.format("%s caught a %s", LocalPlayer.Name, tierName),
            color = 52221,
            fields = {
                { name = "Fish", value = fishInfo.Name },
                { name = "Tier", value = tierName },
                { name = "Weight", value = weight },
                { name = "Variant", value = variant }
            }
        }}
    }
    sendWebhook(url, payload)
end

if Network.Events.REObtainedNewFishNotification then
    Network.Events.REObtainedNewFishNotification.OnClientEvent:Connect(function(itemId, metadata)
        if BotConfig.autoWebhook then
            sendFishWebhook(itemId, metadata)
        end
    end)
end

WebhookSection:AddInput({
    Title = "Webhook URL",
    Default = "",
    Callback = function(url)
        _G.WebhookFlags.FishCaught.URL = url
    end
})

WebhookSection:AddInput({
    Title = "Discord Id",
    Default = "",
    Callback = function(text)
        if text and text ~= "" then
            _G.WebhookDiscordId = "<@" .. text:gsub("%D", "") .. ">"
        else
            _G.WebhookDiscordId = ""
        end
    end
})

WebhookSection:AddDropdown({
    Title = "Track Fish Rarities",
    Multi = true,
    Options = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret" },
    Callback = function(list)
        _G.WebhookRarities = list
    end
})

WebhookSection:AddToggle({
    Title = "Enable Fish Webhook",
    Default = false,
    Callback = function(enabled)
        _G.WebhookFlags.FishCaught.Enabled = enabled
        BotConfig.autoWebhook = enabled
    end
})

WebhookSection:AddButton({
    Title = "Ping Webhook",
    Callback = function()
        local url = _G.WebhookFlags.FishCaught.URL
        if url and url:match("discord.com/api/webhooks") then
            sendWebhook(url, { content = "Webhook test" })
        else
            notify("Invalid webhook URL.")
        end
    end
})

WebhookSection:AddInput({
    Title = "Stats Webhook URL",
    Default = "",
    Callback = function(url)
        _G.WebhookFlags.Stats.URL = url
    end
})

WebhookSection:AddInput({
    Title = "Stats Delay (Minutes)",
    Default = tostring(_G.WebhookFlags.Stats.Delay or 5),
    Callback = function(val)
        _G.WebhookFlags.Stats.Delay = tonumber(val) or 5
    end
})

WebhookSection:AddToggle({
    Title = "Session Stats",
    Default = false,
    Callback = function(enabled)
        BotConfig.autoWebhookStats = enabled
        if enabled then
            task.spawn(function()
                local startTime = tick()
                while BotConfig.autoWebhookStats do
                    local elapsed = math.floor((tick() - startTime) / 60)
                    if not (_G.WebhookFlags.Stats.URL and _G.WebhookFlags.Stats.URL ~= "") then
                        notify("Stats webhook URL is empty.")
                        break
                    end
                    local payload = {
                        content = _G.WebhookDiscordId or "",
                        embeds = {{
                            title = "FishIt Session Stats",
                            description = string.format("Minutes: %d\nFish Count: %d", elapsed, getFishCount()),
                            color = 44543
                        }}
                    }
                    sendWebhook(_G.WebhookFlags.Stats.URL, payload)
                    task.wait((_G.WebhookFlags.Stats.Delay or 5) * 60)
                end
            end)
        end
    end
})

-- UTILITY TAB
local UtilitySection = Tabs.Utility:AddSection("Utility")

UtilitySection:AddToggle({
    Title = "Quick Interact",
    Default = false,
    Callback = function(enabled)
        BotConfig.quickInteract = enabled
        if enabled then
            task.spawn(function()
                while BotConfig.quickInteract do
                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        for _, prompt in ipairs(workspace:GetDescendants()) do
                            if prompt:IsA("ProximityPrompt") then
                                local part = prompt.Parent
                                if part and part:IsA("BasePart") and (part.Position - root.Position).Magnitude < 10 then
                                    pcall(function()
                                        fireproximityprompt(prompt)
                                    end)
                                end
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

UtilitySection:AddToggle({
    Title = "Freeze",
    Default = false,
    Callback = function(enabled)
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Anchored = enabled
                end
            end
        end
    end
})

UtilitySection:AddToggle({
    Title = "Anti-AFK",
    Default = false,
    Callback = function(enabled)
        BotConfig.antiAfk = enabled
        if enabled then
            task.spawn(function()
                while BotConfig.antiAfk do
                    BotConfig.vim:SendMouseButtonEvent(0, 0, 0, true, nil, 0)
                    BotConfig.vim:SendMouseButtonEvent(0, 0, 0, false, nil, 0)
                    task.wait(60)
                end
            end)
        end
    end
})

UtilitySection:AddToggle({
    Title = "Infinite Jumps",
    Default = false,
    Callback = function(enabled)
        BotConfig.infJump = enabled
    end
})

Services.UserInputService.JumpRequest:Connect(function()
    if BotConfig.infJump then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

UtilitySection:AddSlider({
    Title = "Walkspeed Slider",
    Min = 16,
    Max = 100,
    Default = 16,
    Increment = 1,
    Callback = function(val)
        setHumanoidProperty("WalkSpeed", val)
    end
})

UtilitySection:AddSlider({
    Title = "Jump Power Slider",
    Min = 50,
    Max = 200,
    Default = 50,
    Increment = 5,
    Callback = function(val)
        setHumanoidProperty("JumpPower", val)
    end
})
