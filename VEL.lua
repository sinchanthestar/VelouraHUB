local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/sinchanthestar/VelouraHUB/refs/heads/main/Library.lua"))()
if not Library then
    return
end

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

local Window = Library:Window({
    Title = "FishIt Hub",
    Footer = "NineHub",
    Color = Color3.fromRGB(255, 131, 74),
    Version = 1
})

local Tabs = {
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
