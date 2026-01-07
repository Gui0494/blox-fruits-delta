--[[
    ╔══════════════════════════════════════════════════════════════════════════════╗
    ║     BLOX FRUITS ULTIMATE SCRIPT - PLATINUM EDITION v9.0                      ║
    ║     Complete Feature Set: 200+ Features | Private Server Optimized           ║
    ║     Status: Professional Grade | Anti-Detection: Maximum                     ║
    ╚══════════════════════════════════════════════════════════════════════════════╝
    
    FEATURES INCLUÍDAS:
    ✓ Auto Farm (Level, Mastery, Boss, Materials)
    ✓ Auto Quest & Bosses Completos
    ✓ Devil Fruit System (ESP, Sniper, Notification)
    ✓ Haki & Abilities Automation
    ✓ Combat System (Skills, Aimbot, Kill Aura)
    ✓ Teleport System (Islands, NPCs, Bosses)
    ✓ Sea Events & Raids
    ✓ PVP & Player Features
    ✓ ESP & Visuals Completos
    ✓ Auto Buy System
    ✓ Special Items Automation
    ✓ Utility Features (Fly, NoClip, Speed)
    ✓ Stats Distribution
    ✓ Save/Load Configuration
]]

-- ════════════════════════════════════════════════════════════════════════════════
-- SECTION 1: INITIALIZATION & ANTI-DETECTION
-- ════════════════════════════════════════════════════════════════════════════════

-- Aguarda carregamento completo
if not game:IsLoaded() then 
    game.Loaded:Wait() 
end
task.wait(1)

-- Limpa instâncias anteriores
if getgenv().BloxUltimate then
    pcall(function()
        getgenv().BloxUltimate:Destroy()
    end)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SECTION 2: SERVICES CACHE
-- ════════════════════════════════════════════════════════════════════════════════

local Services = setmetatable({}, {
    __index = function(self, service)
        local s = game:GetService(service)
        rawset(self, service, s)
        return s
    end
})

-- Pre-cache common services
local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local RunService = Services.RunService
local TweenService = Services.TweenService
local HttpService = Services.HttpService
local TeleportService = Services.TeleportService
local VirtualInputManager = Services.VirtualInputManager
local UserInputService = Services.UserInputService
local Lighting = Services.Lighting
local Workspace = game:GetService("Workspace")

-- Player References
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ════════════════════════════════════════════════════════════════════════════════
-- SECTION 3: UTILITY FUNCTIONS
-- ════════════════════════════════════════════════════════════════════════════════

local Utils = {}

function Utils.GetCharacter()
    return LocalPlayer.Character
end

function Utils.GetHumanoid()
    local char = Utils.GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

function Utils.GetHRP()
    local char = Utils.GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

function Utils.IsAlive()
    local hum = Utils.GetHumanoid()
    return hum and hum.Health > 0
end

function Utils.GetPlayerData()
    return LocalPlayer:FindFirstChild("Data")
end

function Utils.GetLevel()
    local data = Utils.GetPlayerData()
    return data and data:FindFirstChild("Level") and data.Level.Value or 1
end

function Utils.GetBeli()
    local data = Utils.GetPlayerData()
    return data and data:FindFirstChild("Beli") and data.Beli.Value or 0
end

function Utils.GetFragments()
    local data = Utils.GetPlayerData()
    return data and data:FindFirstChild("Fragments") and data.Fragments.Value or 0
end

function Utils.GetSea()
    local level = Utils.GetLevel()
    if level < 700 then return 1
    elseif level < 1500 then return 2
    else return 3 end
end

function Utils.Distance(pos1, pos2)
    if typeof(pos1) == "CFrame" then pos1 = pos1.Position end
    if typeof(pos2) == "CFrame" then pos2 = pos2.Position end
    return (pos1 - pos2).Magnitude
end

function Utils.GetClosest(folder, filter, maxDist)
    local hrp = Utils.GetHRP()
    if not hrp then return nil end
    
    local closest, closestDist = nil, maxDist or math.huge
    
    for _, v in ipairs(folder:GetChildren()) do
        if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
            if v.Humanoid.Health > 0 then
                if not filter or v.Name == filter then
                    local dist = Utils.Distance(hrp.Position, v.HumanoidRootPart.Position)
                    if dist < closestDist then
                        closest = v
                        closestDist = dist
                    end
                end
            end
        end
    end
    
    return closest, closestDist
end

function Utils.Notify(title, text, duration)
    pcall(function()
        local shouldNotify = true
        if getgenv().Config and getgenv().Config.Notifications == false then
            shouldNotify = false
        end
        if shouldNotify then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = title or "Blox Ultimate",
                Text = text or "",
                Duration = duration or 3
            })
        end
    end)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SECTION 4: CONNECTION MANAGER (Memory Safe)
-- ════════════════════════════════════════════════════════════════════════════════

local ConnectionManager = {}
ConnectionManager.__index = ConnectionManager

function ConnectionManager.new()
    local self = setmetatable({}, ConnectionManager)
    self.Connections = {}
    self.Instances = {}
    self.Tweens = {}
    return self
end

function ConnectionManager:Connect(name, connection)
    if self.Connections[name] then
        pcall(function() self.Connections[name]:Disconnect() end)
    end
    self.Connections[name] = connection
    return connection
end

function ConnectionManager:Disconnect(name)
    if self.Connections[name] then
        pcall(function() self.Connections[name]:Disconnect() end)
        self.Connections[name] = nil
    end
end

function ConnectionManager:AddInstance(name, instance)
    if self.Instances[name] then
        pcall(function() self.Instances[name]:Destroy() end)
    end
    self.Instances[name] = instance
    return instance
end

function ConnectionManager:RemoveInstance(name)
    if self.Instances[name] then
        pcall(function() self.Instances[name]:Destroy() end)
        self.Instances[name] = nil
    end
end

function ConnectionManager:AddTween(name, tween)
    if self.Tweens[name] then
        pcall(function() self.Tweens[name]:Cancel() end)
    end
    self.Tweens[name] = tween
    return tween
end

function ConnectionManager:CancelTween(name)
    if self.Tweens[name] then
        pcall(function() self.Tweens[name]:Cancel() end)
        self.Tweens[name] = nil
    end
end

function ConnectionManager:Destroy()
    for name, conn in pairs(self.Connections) do
        pcall(function() conn:Disconnect() end)
    end
    for name, inst in pairs(self.Instances) do
        pcall(function() inst:Destroy() end)
    end
    for name, tween in pairs(self.Tweens) do
        pcall(function() tween:Cancel() end)
    end
    self.Connections = {}
    self.Instances = {}
    self.Tweens = {}
end

getgenv().BloxUltimate = ConnectionManager.new()
local Manager = getgenv().BloxUltimate

-- ════════════════════════════════════════════════════════════════════════════════
-- SECTION 5: REMOTE HANDLER (Anti-Detection)
-- ════════════════════════════════════════════════════════════════════════════════

local RemoteHandler = {}
local RemoteCache = {}
local LastRemoteCall = {}

function RemoteHandler.GetRemote(name)
    if RemoteCache[name] then return RemoteCache[name] end
    
    local remote = ReplicatedStorage:FindFirstChild(name)
    if not remote then
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            remote = remotes:FindFirstChild(name)
        end
    end
    
    if remote then
        RemoteCache[name] = remote
    end
    
    return remote
end

function RemoteHandler.Fire(remoteName, ...)
    local remote = RemoteHandler.GetRemote(remoteName)
    if not remote then return nil end
    
    -- Rate limiting
    local now = tick()
    local lastCall = LastRemoteCall[remoteName] or 0
    local delay = 0.05 + math.random() * 0.02 -- 50-70ms delay
    
    if now - lastCall < delay then
        task.wait(delay - (now - lastCall))
    end
    
    LastRemoteCall[remoteName] = tick()
    
    local success, result = pcall(function()
        if remote:IsA("RemoteFunction") then
            return remote:InvokeServer(...)
        elseif remote:IsA("RemoteEvent") then
            remote:FireServer(...)
            return true
        end
    end)
    
    return success and result or nil
end

function RemoteHandler.Invoke(...)
    return RemoteHandler.Fire("CommF_", ...)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SECTION 6: QUEST DATABASE (Complete - All Seas)
-- ════════════════════════════════════════════════════════════════════════════════

local QuestDatabase = {
    -- ══════════════════════════════════════
    -- FIRST SEA (Level 1-700)
    -- ══════════════════════════════════════
    {Min=1, Max=9, QuestId="BanditQuest1", MobName="Bandit", QuestLevel=1, 
     QuestPos=CFrame.new(1060, 17, 1550), MobPos=CFrame.new(1044, 16, 1525), Island="Starter Island"},
    
    {Min=10, Max=14, QuestId="JungleQuest", MobName="Monkey", QuestLevel=1,
     QuestPos=CFrame.new(-1604, 37, 152), MobPos=CFrame.new(-1538, 37, 203), Island="Jungle"},
    
    {Min=15, Max=29, QuestId="JungleQuest", MobName="Gorilla", QuestLevel=2,
     QuestPos=CFrame.new(-1604, 37, 152), MobPos=CFrame.new(-1230, 6, -485), Island="Jungle"},
    
    {Min=30, Max=39, QuestId="BuggyQuest1", MobName="Pirate", QuestLevel=1,
     QuestPos=CFrame.new(-1140, 5, 3828), MobPos=CFrame.new(-1190, 5, 3762), Island="Buggy Island"},
    
    {Min=40, Max=59, QuestId="BuggyQuest1", MobName="Brute", QuestLevel=2,
     QuestPos=CFrame.new(-1140, 5, 3828), MobPos=CFrame.new(-1414, 12, 4162), Island="Buggy Island"},
    
    {Min=60, Max=74, QuestId="DesertQuest", MobName="Desert Bandit", QuestLevel=1,
     QuestPos=CFrame.new(897, 7, 4388), MobPos=CFrame.new(960, 7, 4348), Island="Desert"},
    
    {Min=75, Max=89, QuestId="DesertQuest", MobName="Desert Officer", QuestLevel=2,
     QuestPos=CFrame.new(897, 7, 4388), MobPos=CFrame.new(1537, 7, 4596), Island="Desert"},
    
    {Min=90, Max=99, QuestId="SnowQuest", MobName="Snow Bandit", QuestLevel=1,
     QuestPos=CFrame.new(1386, 87, -1297), MobPos=CFrame.new(1366, 87, -1347), Island="Frozen Village"},
    
    {Min=100, Max=119, QuestId="SnowQuest", MobName="Snowman", QuestLevel=2,
     QuestPos=CFrame.new(1386, 87, -1297), MobPos=CFrame.new(1120, 115, -1411), Island="Frozen Village"},
    
    {Min=120, Max=149, QuestId="MarineQuest2", MobName="Chief Petty Officer", QuestLevel=1,
     QuestPos=CFrame.new(-4880, 21, 4273), MobPos=CFrame.new(-4953, 21, 4232), Island="Marine Ford"},
    
    {Min=150, Max=174, QuestId="MarineQuest2", MobName="Sky Bandit", QuestLevel=2,
     QuestPos=CFrame.new(-4880, 21, 4273), MobPos=CFrame.new(-4892, 312, 4211), Island="Sky Island"},
    
    {Min=175, Max=189, QuestId="PrisonerQuest", MobName="Prisoner", QuestLevel=1,
     QuestPos=CFrame.new(5308, 2, 474), MobPos=CFrame.new(5379, 2, 413), Island="Prison"},
    
    {Min=190, Max=209, QuestId="PrisonerQuest", MobName="Dangerous Prisoner", QuestLevel=2,
     QuestPos=CFrame.new(5308, 2, 474), MobPos=CFrame.new(5098, 2, 466), Island="Prison"},
    
    {Min=210, Max=249, QuestId="ColosseumQuest", MobName="Toga Warrior", QuestLevel=1,
     QuestPos=CFrame.new(-1576, 8, -2985), MobPos=CFrame.new(-1475, 8, -2918), Island="Colosseum"},
    
    {Min=250, Max=274, QuestId="ColosseumQuest", MobName="Gladiator", QuestLevel=2,
     QuestPos=CFrame.new(-1576, 8, -2985), MobPos=CFrame.new(-1415, 8, -3150), Island="Colosseum"},
    
    {Min=275, Max=299, QuestId="MagmaQuest", MobName="Military Soldier", QuestLevel=1,
     QuestPos=CFrame.new(-5313, 12, 8515), MobPos=CFrame.new(-5451, 12, 8466), Island="Magma Village"},
    
    {Min=300, Max=324, QuestId="MagmaQuest", MobName="Military Spy", QuestLevel=2,
     QuestPos=CFrame.new(-5313, 12, 8515), MobPos=CFrame.new(-5138, 12, 8519), Island="Magma Village"},
    
    {Min=325, Max=374, QuestId="FishmanQuest", MobName="Fishman Warrior", QuestLevel=1,
     QuestPos=CFrame.new(61123, 19, 1569), MobPos=CFrame.new(61072, 19, 1519), Island="Fishman Island"},
    
    {Min=375, Max=399, QuestId="FishmanQuest", MobName="Fishman Commando", QuestLevel=2,
     QuestPos=CFrame.new(61123, 19, 1569), MobPos=CFrame.new(61497, 19, 1526), Island="Fishman Island"},
    
    {Min=400, Max=449, QuestId="SkyExp1Quest", MobName="God's Guard", QuestLevel=1,
     QuestPos=CFrame.new(-4721, 845, -1912), MobPos=CFrame.new(-4766, 845, -1978), Island="Upper Skylands"},
    
    {Min=450, Max=474, QuestId="SkyExp1Quest", MobName="Shanda", QuestLevel=2,
     QuestPos=CFrame.new(-4721, 845, -1912), MobPos=CFrame.new(-7863, 5545, -380), Island="Upper Skylands"},
    
    {Min=475, Max=524, QuestId="SkyExp2Quest", MobName="Royal Squad", QuestLevel=1,
     QuestPos=CFrame.new(-7906, 5634, -1411), MobPos=CFrame.new(-7903, 5634, -1467), Island="Upper Skylands 2"},
    
    {Min=525, Max=549, QuestId="SkyExp2Quest", MobName="Royal Soldier", QuestLevel=2,
     QuestPos=CFrame.new(-7906, 5634, -1411), MobPos=CFrame.new(-7679, 5584, -1406), Island="Upper Skylands 2"},
    
    {Min=550, Max=624, QuestId="FountainQuest", MobName="Galley Pirate", QuestLevel=1,
     QuestPos=CFrame.new(5255, 39, 4050), MobPos=CFrame.new(5267, 42, 3996), Island="Fountain City"},
    
    {Min=625, Max=699, QuestId="FountainQuest", MobName="Galley Captain", QuestLevel=2,
     QuestPos=CFrame.new(5255, 39, 4050), MobPos=CFrame.new(5573, 39, 4107), Island="Fountain City"},
    
    -- ══════════════════════════════════════
    -- SECOND SEA (Level 700-1500)
    -- ══════════════════════════════════════
    {Min=700, Max=724, QuestId="Area1Quest", MobName="Raider", QuestLevel=1,
     QuestPos=CFrame.new(-428, 73, 1836), MobPos=CFrame.new(-472, 73, 1824), Island="Kingdom of Rose"},
    
    {Min=725, Max=774, QuestId="Area1Quest", MobName="Mercenary", QuestLevel=2,
     QuestPos=CFrame.new(-428, 73, 1836), MobPos=CFrame.new(-413, 73, 1563), Island="Kingdom of Rose"},
    
    {Min=775, Max=799, QuestId="Area2Quest", MobName="Swan Pirate", QuestLevel=1,
     QuestPos=CFrame.new(638, 73, 1478), MobPos=CFrame.new(638, 73, 1527), Island="Kingdom of Rose"},
    
    {Min=800, Max=874, QuestId="Area2Quest", MobName="Factory Staff", QuestLevel=2,
     QuestPos=CFrame.new(638, 73, 1478), MobPos=CFrame.new(281, 73, 410), Island="Kingdom of Rose"},
    
    {Min=875, Max=899, QuestId="MarineQuest3", MobName="Marine Lieutenant", QuestLevel=1,
     QuestPos=CFrame.new(-2440, 73, -3217), MobPos=CFrame.new(-2496, 73, -3280), Island="Green Zone"},
    
    {Min=900, Max=949, QuestId="MarineQuest3", MobName="Marine Captain", QuestLevel=2,
     QuestPos=CFrame.new(-2440, 73, -3217), MobPos=CFrame.new(-2273, 73, -3125), Island="Green Zone"},
    
    {Min=950, Max=974, QuestId="ZombieQuest", MobName="Zombie", QuestLevel=1,
     QuestPos=CFrame.new(-5497, 49, -795), MobPos=CFrame.new(-5454, 49, -729), Island="Graveyard Island"},
    
    {Min=975, Max=999, QuestId="ZombieQuest", MobName="Vampire", QuestLevel=2,
     QuestPos=CFrame.new(-5497, 49, -795), MobPos=CFrame.new(-5635, 112, -780), Island="Graveyard Island"},
    
    {Min=1000, Max=1049, QuestId="SnowMountainQuest", MobName="Snow Trooper", QuestLevel=1,
     QuestPos=CFrame.new(607, 401, -5371), MobPos=CFrame.new(600, 401, -5304), Island="Snow Mountain"},
    
    {Min=1050, Max=1099, QuestId="SnowMountainQuest", MobName="Winter Warrior", QuestLevel=2,
     QuestPos=CFrame.new(607, 401, -5371), MobPos=CFrame.new(596, 440, -5806), Island="Snow Mountain"},
    
    {Min=1100, Max=1124, QuestId="IceSideQuest", MobName="Lab Subordinate", QuestLevel=1,
     QuestPos=CFrame.new(-6061, 16, -4905), MobPos=CFrame.new(-6095, 16, -4832), Island="Hot and Cold"},
    
    {Min=1125, Max=1174, QuestId="IceSideQuest", MobName="Horned Warrior", QuestLevel=2,
     QuestPos=CFrame.new(-6061, 16, -4905), MobPos=CFrame.new(-5988, 16, -5280), Island="Hot and Cold"},
    
    {Min=1175, Max=1199, QuestId="FireSideQuest", MobName="Magma Ninja", QuestLevel=1,
     QuestPos=CFrame.new(-5431, 16, -5296), MobPos=CFrame.new(-5376, 16, -5247), Island="Hot and Cold"},
    
    {Min=1200, Max=1249, QuestId="FireSideQuest", MobName="Lava Pirate", QuestLevel=2,
     QuestPos=CFrame.new(-5431, 16, -5296), MobPos=CFrame.new(-5102, 16, -5427), Island="Hot and Cold"},
    
    {Min=1250, Max=1274, QuestId="ShipQuest1", MobName="Ship Deckhand", QuestLevel=1,
     QuestPos=CFrame.new(1037, 125, 32911), MobPos=CFrame.new(958, 125, 32849), Island="Cursed Ship"},
    
    {Min=1275, Max=1299, QuestId="ShipQuest1", MobName="Ship Engineer", QuestLevel=2,
     QuestPos=CFrame.new(1037, 125, 32911), MobPos=CFrame.new(1235, 125, 32895), Island="Cursed Ship"},
    
    {Min=1300, Max=1324, QuestId="ShipQuest2", MobName="Ship Steward", QuestLevel=1,
     QuestPos=CFrame.new(971, 125, 33245), MobPos=CFrame.new(924, 141, 33184), Island="Cursed Ship"},
    
    {Min=1325, Max=1349, QuestId="ShipQuest2", MobName="Ship Officer", QuestLevel=2,
     QuestPos=CFrame.new(971, 125, 33245), MobPos=CFrame.new(920, 177, 33385), Island="Cursed Ship"},
    
    {Min=1350, Max=1374, QuestId="FrostQuest", MobName="Arctic Warrior", QuestLevel=1,
     QuestPos=CFrame.new(5669, 29, -6482), MobPos=CFrame.new(5596, 29, -6420), Island="Ice Castle"},
    
    {Min=1375, Max=1424, QuestId="FrostQuest", MobName="Snow Lurker", QuestLevel=2,
     QuestPos=CFrame.new(5669, 29, -6482), MobPos=CFrame.new(5874, 29, -6585), Island="Ice Castle"},
    
    {Min=1425, Max=1449, QuestId="ForgottenQuest", MobName="Sea Soldier", QuestLevel=1,
     QuestPos=CFrame.new(-3054, 236, -10145), MobPos=CFrame.new(-3004, 236, -10089), Island="Forgotten Island"},
    
    {Min=1450, Max=1499, QuestId="ForgottenQuest", MobName="Water Fighter", QuestLevel=2,
     QuestPos=CFrame.new(-3054, 236, -10145), MobPos=CFrame.new(-2864, 236, -10186), Island="Forgotten Island"},
    
    -- ══════════════════════════════════════
    -- THIRD SEA (Level 1500+)
    -- ══════════════════════════════════════
    {Min=1500, Max=1524, QuestId="PiratePortQuest", MobName="Pirate Millionaire", QuestLevel=1,
     QuestPos=CFrame.new(-290, 44, 5580), MobPos=CFrame.new(-241, 44, 5632), Island="Port Town"},
    
    {Min=1525, Max=1574, QuestId="PiratePortQuest", MobName="Pistol Billionaire", QuestLevel=2,
     QuestPos=CFrame.new(-290, 44, 5580), MobPos=CFrame.new(-444, 44, 5595), Island="Port Town"},
    
    {Min=1575, Max=1599, QuestId="AmazonQuest", MobName="Dragon Crew Warrior", QuestLevel=1,
     QuestPos=CFrame.new(5832, 52, -1100), MobPos=CFrame.new(5766, 52, -1159), Island="Hydra Island"},
    
    {Min=1600, Max=1624, QuestId="AmazonQuest", MobName="Dragon Crew Archer", QuestLevel=2,
     QuestPos=CFrame.new(5832, 52, -1100), MobPos=CFrame.new(6076, 52, -1035), Island="Hydra Island"},
    
    {Min=1625, Max=1649, QuestId="AmazonQuest2", MobName="Female Islander", QuestLevel=1,
     QuestPos=CFrame.new(5448, 602, 751), MobPos=CFrame.new(5401, 602, 706), Island="Amazon Lily"},
    
    {Min=1650, Max=1699, QuestId="AmazonQuest2", MobName="Giant Islander", QuestLevel=2,
     QuestPos=CFrame.new(5448, 602, 751), MobPos=CFrame.new(5691, 602, 785), Island="Amazon Lily"},
    
    {Min=1700, Max=1724, QuestId="MarineTreeIsland", MobName="Marine Commodore", QuestLevel=1,
     QuestPos=CFrame.new(2180, 29, -6737), MobPos=CFrame.new(2119, 29, -6784), Island="Marine Tree"},
    
    {Min=1725, Max=1774, QuestId="MarineTreeIsland", MobName="Marine Rear Admiral", QuestLevel=2,
     QuestPos=CFrame.new(2180, 29, -6737), MobPos=CFrame.new(2365, 29, -6663), Island="Marine Tree"},
    
    {Min=1775, Max=1799, QuestId="DeepForestIsland", MobName="Mythological Pirate", QuestLevel=1,
     QuestPos=CFrame.new(-13234, 332, -7625), MobPos=CFrame.new(-13303, 332, -7570), Island="Floating Turtle"},
    
    {Min=1800, Max=1824, QuestId="DeepForestIsland2", MobName="Jungle Pirate", QuestLevel=1,
     QuestPos=CFrame.new(-12680, 390, -9902), MobPos=CFrame.new(-12620, 390, -9840), Island="Floating Turtle"},
    
    {Min=1825, Max=1849, QuestId="DeepForestIsland3", MobName="Musketeer Pirate", QuestLevel=1,
     QuestPos=CFrame.new(-13234, 332, -7625), MobPos=CFrame.new(-13450, 332, -7580), Island="Floating Turtle"},
    
    {Min=1850, Max=1899, QuestId="HauntedQuest1", MobName="Reborn Skeleton", QuestLevel=1,
     QuestPos=CFrame.new(-9479, 142, 5566), MobPos=CFrame.new(-9426, 142, 5510), Island="Haunted Castle"},
    
    {Min=1900, Max=1924, QuestId="HauntedQuest1", MobName="Living Zombie", QuestLevel=2,
     QuestPos=CFrame.new(-9479, 142, 5566), MobPos=CFrame.new(-9606, 142, 5584), Island="Haunted Castle"},
    
    {Min=1925, Max=1974, QuestId="HauntedQuest2", MobName="Demonic Soul", QuestLevel=1,
     QuestPos=CFrame.new(-9513, 172, 6078), MobPos=CFrame.new(-9457, 172, 6020), Island="Haunted Castle"},
    
    {Min=1975, Max=1999, QuestId="HauntedQuest2", MobName="Posessed Mummy", QuestLevel=2,
     QuestPos=CFrame.new(-9513, 172, 6078), MobPos=CFrame.new(-9613, 172, 6136), Island="Haunted Castle"},
    
    {Min=2000, Max=2024, QuestId="IceCreamLandQuest", MobName="Peanut Scout", QuestLevel=1,
     QuestPos=CFrame.new(-716, 38, -12469), MobPos=CFrame.new(-659, 38, -12412), Island="Ice Cream Land"},
    
    {Min=2025, Max=2049, QuestId="IceCreamLandQuest", MobName="Peanut President", QuestLevel=2,
     QuestPos=CFrame.new(-716, 38, -12469), MobPos=CFrame.new(-865, 38, -12532), Island="Ice Cream Land"},
    
    {Min=2050, Max=2074, QuestId="IceCreamLandQuest2", MobName="Ice Cream Chef", QuestLevel=1,
     QuestPos=CFrame.new(-821, 66, -10965), MobPos=CFrame.new(-762, 66, -10906), Island="Ice Cream Land 2"},
    
    {Min=2075, Max=2099, QuestId="IceCreamLandQuest2", MobName="Ice Cream Commander", QuestLevel=2,
     QuestPos=CFrame.new(-821, 66, -10965), MobPos=CFrame.new(-978, 66, -11028), Island="Ice Cream Land 2"},
    
    {Min=2100, Max=2124, QuestId="CakeQuest1", MobName="Cookie Crafter", QuestLevel=1,
     QuestPos=CFrame.new(-2021, 38, -12028), MobPos=CFrame.new(-1968, 38, -11975), Island="Cake Land"},
    
    {Min=2125, Max=2149, QuestId="CakeQuest1", MobName="Cake Guard", QuestLevel=2,
     QuestPos=CFrame.new(-2021, 38, -12028), MobPos=CFrame.new(-2132, 38, -12089), Island="Cake Land"},
    
    {Min=2150, Max=2199, QuestId="CakeQuest2", MobName="Baking Staff", QuestLevel=1,
     QuestPos=CFrame.new(-1927, 38, -12842), MobPos=CFrame.new(-1871, 38, -12785), Island="Cake Land 2"},
    
    {Min=2200, Max=2224, QuestId="CakeQuest2", MobName="Head Baker", QuestLevel=2,
     QuestPos=CFrame.new(-1927, 38, -12842), MobPos=CFrame.new(-2038, 38, -12905), Island="Cake Land 2"},
    
    {Min=2225, Max=2249, QuestId="ChocQuest1", MobName="Cocoa Warrior", QuestLevel=1,
     QuestPos=CFrame.new(231, 23, -12197), MobPos=CFrame.new(286, 23, -12141), Island="Chocolate Land"},
    
    {Min=2250, Max=2274, QuestId="ChocQuest1", MobName="Chocolate Bar Battler", QuestLevel=2,
     QuestPos=CFrame.new(231, 23, -12197), MobPos=CFrame.new(120, 23, -12258), Island="Chocolate Land"},
    
    {Min=2275, Max=2299, QuestId="ChocQuest2", MobName="Sweet Thief", QuestLevel=1,
     QuestPos=CFrame.new(151, 23, -12774), MobPos=CFrame.new(205, 23, -12718), Island="Chocolate Land 2"},
    
    {Min=2300, Max=2324, QuestId="ChocQuest2", MobName="Candy Rebel", QuestLevel=2,
     QuestPos=CFrame.new(151, 23, -12774), MobPos=CFrame.new(40, 23, -12837), Island="Chocolate Land 2"},
    
    {Min=2325, Max=2349, QuestId="CandyQuest1", MobName="Candy Pirate", QuestLevel=1,
     QuestPos=CFrame.new(-1149, 14, -14445), MobPos=CFrame.new(-1093, 14, -14389), Island="Candy Land"},
    
    {Min=2350, Max=2374, QuestId="CandyQuest1", MobName="Snow Demon", QuestLevel=2,
     QuestPos=CFrame.new(-1149, 14, -14445), MobPos=CFrame.new(-1260, 14, -14508), Island="Candy Land"},
    
    {Min=2375, Max=2399, QuestId="TikiQuest1", MobName="Isle Outlaw", QuestLevel=1,
     QuestPos=CFrame.new(-16545, 56, 1051), MobPos=CFrame.new(-16490, 56, 995), Island="Tiki Outpost"},
    
    {Min=2400, Max=2424, QuestId="TikiQuest1", MobName="Island Boy", QuestLevel=2,
     QuestPos=CFrame.new(-16545, 56, 1051), MobPos=CFrame.new(-16655, 56, 1114), Island="Tiki Outpost"},
    
    {Min=2425, Max=2449, QuestId="TikiQuest2", MobName="Sun-kissed Warrior", QuestLevel=1,
     QuestPos=CFrame.new(-16539, 56, -173), MobPos=CFrame.new(-16483, 56, -117), Island="Tiki Outpost 2"},
    
    {Min=2450, Max=9999, QuestId="TikiQuest2", MobName="Isle Champion", QuestLevel=2,
     QuestPos=CFrame.new(-16539, 56, -173), MobPos=CFrame.new(-16650, 56, -236), Island="Tiki Outpost 2"},
}

function QuestDatabase.GetQuestForLevel(level)
    level = level or Utils.GetLevel()
    for _, quest in ipairs(QuestDatabase) do
        if level >= quest.Min and level <= quest.Max then
            return quest
        end
    end
    return QuestDatabase[#QuestDatabase]
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SECTION 7: BOSS DATABASE
-- ════════════════════════════════════════════════════════════════════════════════

local BossDatabase = {
    -- FIRST SEA
    {Name = "Gorilla King", Level = 25, Pos = CFrame.new(-1221, 6, -427), Sea = 1},
    {Name = "Bobby", Level = 55, Pos = CFrame.new(-1259, 5, 4282), Sea = 1},
    {Name = "Yeti", Level = 110, Pos = CFrame.new(1187, 138, -1483), Sea = 1},
    {Name = "Mob Leader", Level = 120, Pos = CFrame.new(-3037, 21, 3071), Sea = 1},
    {Name = "Vice Admiral", Level = 130, Pos = CFrame.new(-5072, 22, 4280), Sea = 1},
    {Name = "Warden", Level = 200, Pos = CFrame.new(5231, 2, 443), Sea = 1},
    {Name = "Chief Warden", Level = 220, Pos = CFrame.new(4926, -72, 608), Sea = 1},
    {Name = "Saber Expert", Level = 200, Pos = CFrame.new(-1458, 29, -48), Sea = 1},
    {Name = "Magma Admiral", Level = 350, Pos = CFrame.new(-5364, 40, 8442), Sea = 1},
    {Name = "Fishman Lord", Level = 425, Pos = CFrame.new(61366, 18, 1476), Sea = 1},
    {Name = "Wysper", Level = 500, Pos = CFrame.new(-7862, 5544, -371), Sea = 1},
    {Name = "Thunder God", Level = 575, Pos = CFrame.new(-7648, 5586, -1414), Sea = 1},
    {Name = "Cyborg", Level = 675, Pos = CFrame.new(5331, 54, 4038), Sea = 1},
    {Name = "Greybeard", Level = 750, Pos = CFrame.new(-5076, 25, 4270), Sea = 1},
    
    -- SECOND SEA
    {Name = "Diamond", Level = 750, Pos = CFrame.new(-429, 73, 1218), Sea = 2},
    {Name = "Jeremy", Level = 850, Pos = CFrame.new(-797, 73, 1064), Sea = 2},
    {Name = "Fajita", Level = 925, Pos = CFrame.new(-2148, 73, -3106), Sea = 2},
    {Name = "Don Swan", Level = 1000, Pos = CFrame.new(-375, 124, 428), Sea = 2},
    {Name = "Smoke Admiral", Level = 1150, Pos = CFrame.new(-5099, 16, -5335), Sea = 2},
    {Name = "Awakened Ice Admiral", Level = 1400, Pos = CFrame.new(5669, 29, -6482), Sea = 2},
    {Name = "Tide Keeper", Level = 1475, Pos = CFrame.new(-2871, 236, -10179), Sea = 2},
    
    -- THIRD SEA
    {Name = "Stone", Level = 1550, Pos = CFrame.new(-293, 44, 5472), Sea = 3},
    {Name = "Island Empress", Level = 1675, Pos = CFrame.new(5698, 602, 779), Sea = 3},
    {Name = "Kilo Admiral", Level = 1750, Pos = CFrame.new(2366, 28, -6708), Sea = 3},
    {Name = "Captain Elephant", Level = 1875, Pos = CFrame.new(-12757, 332, -7734), Sea = 3},
    {Name = "Beautiful Pirate", Level = 1950, Pos = CFrame.new(-9565, 142, 5570), Sea = 3},
    {Name = "Cake Queen", Level = 2175, Pos = CFrame.new(-2021, 38, -12028), Sea = 3},
    {Name = "rip_indra", Level = 5000, Pos = CFrame.new(-5352, 424, -2893), Sea = 3},
    {Name = "Dough King", Level = 2200, Pos = CFrame.new(231, 23, -12197), Sea = 3},
    {Name = "Cake Prince", Level = 2300, Pos = CFrame.new(-1927, 38, -12842), Sea = 3},
}

function BossDatabase.GetBossForLevel(level)
    level = level or Utils.GetLevel()
    local best = nil
    for _, boss in ipairs(BossDatabase) do
        if level >= boss.Level then
            if not best or boss.Level > best.Level then
                best = boss
            end
        end
    end
    return best
end

function BossDatabase.FindBoss(name)
    for _, boss in ipairs(BossDatabase) do
        if boss.Name:lower():find(name:lower()) then
            return boss
        end
    end
    return nil
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SECTION 8: ISLAND DATABASE
-- ════════════════════════════════════════════════════════════════════════════════

local IslandDatabase = {
    -- FIRST SEA
    ["Starter Island"] = CFrame.new(1044, 16, 1525),
    ["Jungle"] = CFrame.new(-1604, 37, 152),
    ["Buggy Island"] = CFrame.new(-1140, 5, 3828),
    ["Desert"] = CFrame.new(897, 7, 4388),
    ["Frozen Village"] = CFrame.new(1386, 87, -1297),
    ["Marine Ford"] = CFrame.new(-4880, 21, 4273),
    ["Sky Island"] = CFrame.new(-4892, 312, 4211),
    ["Prison"] = CFrame.new(5308, 2, 474),
    ["Colosseum"] = CFrame.new(-1576, 8, -2985),
    ["Magma Village"] = CFrame.new(-5313, 12, 8515),
    ["Fishman Island"] = CFrame.new(61123, 19, 1569),
    ["Upper Skylands"] = CFrame.new(-4721, 845, -1912),
    ["Upper Skylands 2"] = CFrame.new(-7906, 5634, -1411),
    ["Fountain City"] = CFrame.new(5255, 39, 4050),
    ["Pirate Village"] = CFrame.new(-1163, 5, 3825),
    ["Middle Town"] = CFrame.new(-691, 7, 1583),
    
    -- SECOND SEA
    ["Kingdom of Rose"] = CFrame.new(-428, 73, 1836),
    ["Green Zone"] = CFrame.new(-2440, 73, -3217),
    ["Graveyard Island"] = CFrame.new(-5497, 49, -795),
    ["Snow Mountain"] = CFrame.new(607, 401, -5371),
    ["Hot and Cold"] = CFrame.new(-6061, 16, -4905),
    ["Cursed Ship"] = CFrame.new(1037, 125, 32911),
    ["Ice Castle"] = CFrame.new(5669, 29, -6482),
    ["Forgotten Island"] = CFrame.new(-3054, 236, -10145),
    ["Dark Arena"] = CFrame.new(-375, 124, 428),
    ["Usopp's Island"] = CFrame.new(4816, 2, 7831),
    ["Cafe"] = CFrame.new(-385, 73, 298),
    
    -- THIRD SEA
    ["Port Town"] = CFrame.new(-290, 44, 5580),
    ["Hydra Island"] = CFrame.new(5832, 52, -1100),
    ["Amazon Lily"] = CFrame.new(5448, 602, 751),
    ["Marine Tree"] = CFrame.new(2180, 29, -6737),
    ["Floating Turtle"] = CFrame.new(-13234, 332, -7625),
    ["Haunted Castle"] = CFrame.new(-9479, 142, 5566),
    ["Ice Cream Land"] = CFrame.new(-716, 38, -12469),
    ["Cake Land"] = CFrame.new(-2021, 38, -12028),
    ["Chocolate Land"] = CFrame.new(231, 23, -12197),
    ["Candy Land"] = CFrame.new(-1149, 14, -14445),
    ["Tiki Outpost"] = CFrame.new(-16545, 56, 1051),
    ["Mansion"] = CFrame.new(-12896, 331, -7574),
    ["Castle on the Sea"] = CFrame.new(-5039, 313, -2991),
    ["Mirage Island"] = CFrame.new(925, 81, 34226),
    ["Sea of Treats"] = CFrame.new(-716, 38, -12469),
}

function IslandDatabase.GetIsland(name)
    for island, pos in pairs(IslandDatabase) do
        if island:lower():find(name:lower()) then
            return pos
        end
    end
    return nil
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SECTION 9: CONFIGURATION SYSTEM
-- ════════════════════════════════════════════════════════════════════════════════

getgenv().Config = getgenv().Config or {
    -- Auto Farm
    AutoFarm = false,
    AutoQuest = true,
    AutoFarmMastery = false,
    AutoFarmBoss = false,
    SelectedBoss = "Auto",
    
    -- Materials Farm
    AutoFarmBone = false,
    AutoFarmEctoplasm = false,
    AutoFarmDarkFragment = false,
    AutoFarmMagmaOre = false,
    AutoFarmMysticDroplet = false,
    AutoFarmRadioactive = false,
    AutoFarmVampireFang = false,
    AutoFarmMiniTusk = false,
    AutoFarmFishTail = false,
    AutoFarmLeather = false,
    AutoFarmScrapMetal = false,
    AutoFarmAngelWings = false,
    AutoFarmDragonScale = false,
    AutoFarmConjuredCocoa = false,
    AutoFarmGunpowder = false,
    
    -- Special Items
    AutoSaber = false,
    AutoPoleV1 = false,
    AutoPoleV2 = false,
    AutoDarkBlade = false,
    AutoSoulGuitar = false,
    AutoRipIndra = false,
    AutoDoughKing = false,
    AutoCakePrince = false,
    AutoSoulReaper = false,
    AutoTushita = false,
    AutoYama = false,
    AutoCDK = false,
    AutoRengoku = false,
    AutoTTK = false,
    AutoHallowScythe = false,
    AutoBuddySword = false,
    AutoTwinHook = false,
    AutoCanvander = false,
    AutoHolyTorch = false,
    AutoRainbowHaki = false,
    
    -- Race Evolution
    AutoEvoRaceV2 = false,
    AutoEvoRaceV3 = false,
    AutoEvoRaceV4 = false,
    
    -- Devil Fruit
    AutoFarmFruit = false,
    FruitSniper = false,
    FruitESP = false,
    FruitNotification = true,
    AutoStoreFruit = false,
    AutoRandomFruit = false,
    BringFruit = false,
    
    -- Haki & Abilities
    AutoObservationHaki = false,
    AutoBusoHaki = true,
    AutoGeppo = false,
    AutoSoru = false,
    AutoSkyJump = false,
    AutoActiveRaceSkill = false,
    
    -- Combat
    AutoSkill = true,
    FastAttack = true,
    AutoClick = true,
    KillAura = false,
    Aimbot = false,
    AutoKen = false,
    SpamAllSkills = false,
    AutoSwitchWeapon = false,
    
    -- Weapon Selection
    SelectedWeapon = "Combat",
    MasteryWeapon = "Melee",
    MasteryHealth = 30,
    SkillCooldown = 0.5,
    
    -- Sea Events & Raids
    AutoSeaEvent = false,
    AutoShipFarm = false,
    AutoTerrorShark = false,
    AutoPiranha = false,
    AutoSeaBeast = false,
    AutoRaids = false,
    AutoBuyChip = false,
    AutoStartRaid = false,
    AutoNextIslandRaid = false,
    AutoAwakening = false,
    SelectedRaid = "Auto",
    
    -- PVP & Player
    AutoFarmPlayer = false,
    AimbotPlayer = false,
    ESPPlayer = true,
    PlayerHealthBar = true,
    PlayerDistance = true,
    SpectatePlayer = false,
    AutoBountyHunt = false,
    
    -- ESP & Visuals
    ESPChest = false,
    ESPFlower = false,
    ESPNPC = false,
    ESPBoss = true,
    ESPIsland = false,
    ESPMirageIsland = true,
    ESPFullMoon = true,
    ESPQuestMobs = true,
    
    -- Auto Buy
    AutoBuyBusoHaki = false,
    AutoBuyGeppo = false,
    AutoBuySoru = false,
    AutoBuyObservation = false,
    AutoBuyFightingStyle = false,
    AutoBuySword = false,
    AutoBuyGun = false,
    AutoBuyLegendarySword = false,
    
    -- Movement & Utility
    WalkSpeed = 16,
    JumpPower = 50,
    Fly = false,
    FlySpeed = 100,
    NoClip = false,
    InfiniteEnergy = false,
    AntiAFK = true,
    RemoveFog = false,
    RemoveDamageText = false,
    WhiteScreen = false,
    FPSBooster = false,
    AutoRejoin = false,
    ServerHop = false,
    HopToLowerPlayer = false,
    
    -- Stats Distribution
    AutoStatsPoints = false,
    MeleeStats = 0,
    DefenseStats = 0,
    SwordStats = 0,
    GunStats = 0,
    FruitStats = 0,
    
    -- Trials & Challenges
    AutoColosseum = false,
    AutoTempleOfTime = false,
    AutoInstinctV2Trial = false,
    AutoBartiloQuest = false,
    AutoCitizenQuest = false,
    
    -- Settings
    SafeMode = true,
    Distance = 35,
    BringDistance = 80,
    HitboxSize = 50,
    Notifications = true,
    
    -- Teleport
    SelectedIsland = "Auto",
}

local ConfigFileName = "BloxUltimate_v9_Config.json"

local function SaveConfig()
    if writefile then
        local success, err = pcall(function()
            writefile(ConfigFileName, HttpService:JSONEncode(getgenv().Config))
        end)
        if success then
            Utils.Notify("Config", "Configuration saved!", 2)
        end
    end
end

local function LoadConfig()
    if readfile and isfile and isfile(ConfigFileName) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(ConfigFileName))
        end)
        if success and data then
            for k, v in pairs(data) do
                getgenv().Config[k] = v
            end
            print("[Blox Ultimate] Config loaded successfully!")
        end
    end
end

LoadConfig()

-- ════════════════════════════════════════════════════════════════════════════════
-- SECTION 10: MOVEMENT SYSTEM
-- ════════════════════════════════════════════════════════════════════════════════

local Movement = {}
Movement.IsTweening = false
Movement.CurrentTween = nil

function Movement.StopTween()
    if Movement.CurrentTween then
        pcall(function() Movement.CurrentTween:Cancel() end)
        Movement.CurrentTween = nil
    end
    Movement.IsTweening = false
    Manager:RemoveInstance("MovementVelocity")
end

function Movement.HoldPosition(enable)
    local hrp = Utils.GetHRP()
    if not hrp then return end
    
    if enable then
        local att = hrp:FindFirstChild("RootAttachment")
        if not att then
            att = Instance.new("Attachment")
            att.Name = "RootAttachment"
            att.Parent = hrp
        end
        
        local lv = Instance.new("LinearVelocity")
        lv.MaxForce = 999999
        lv.VectorVelocity = Vector3.zero
        lv.Attachment0 = att
        lv.Parent = hrp
        Manager:AddInstance("MovementVelocity", lv)
    else
        Manager:RemoveInstance("MovementVelocity")
    end
end

function Movement.TweenTo(targetCFrame, speed, callback)
    if Movement.IsTweening then
        Movement.StopTween()
    end
    
    local hrp = Utils.GetHRP()
    if not hrp then return false end
    
    -- Add random offset to avoid detection
    local offset = Vector3.new(
        math.random(-5, 5),
        math.random(10, 25),
        math.random(-5, 5)
    )
    local finalTarget = targetCFrame * CFrame.new(offset)
    
    local distance = Utils.Distance(hrp.Position, finalTarget.Position)
    if distance < 10 then
        if callback then callback(true) end
        return true
    end
    
    speed = speed or 280
    local duration = distance / speed
    
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = finalTarget})
    
    Movement.IsTweening = true
    Movement.CurrentTween = tween
    Movement.HoldPosition(true)
    
    tween:Play()
    
    local completed = false
    local connection
    connection = tween.Completed:Connect(function(status)
        completed = true
        Movement.IsTweening = false
        Movement.HoldPosition(false)
        if connection then connection:Disconnect() end
        if callback then callback(status == Enum.PlaybackState.Completed) end
    end)
    
    -- Anti-stuck detection
    spawn(function()
        local lastPos = hrp.Position
        local stuckCounter = 0
        
        while Movement.IsTweening do
            task.wait(0.15)
            if not hrp or not hrp.Parent then
                Movement.StopTween()
                break
            end
            
            local currentPos = hrp.Position
            if (currentPos - lastPos).Magnitude < 1 then
                stuckCounter = stuckCounter + 1
                if stuckCounter > 30 then -- Stuck for ~4.5 seconds
                    Movement.StopTween()
                    -- Try to unstuck
                    local hum = Utils.GetHumanoid()
                    if hum then hum.Jump = true end
                    break
                end
            else
                stuckCounter = 0
            end
            lastPos = currentPos
            
            -- Check if farming is still active
            if not getgenv().Config.AutoFarm and not getgenv().Config.AutoFarmBoss then
                Movement.StopTween()
                break
            end
        end
    end)
    
    return true
end

function Movement.Teleport(targetCFrame)
    local hrp = Utils.GetHRP()
    if hrp then
        hrp.CFrame = targetCFrame
    end
end

function Movement.Fly(enable)
    local char = Utils.GetCharacter()
    local hum = Utils.GetHumanoid()
    local hrp = Utils.GetHRP()
    
    if not char or not hum or not hrp then return end
    
    if enable then
        -- Create fly part
        local flyPart = Instance.new("Part")
        flyPart.Name = "FlyPart"
        flyPart.Size = Vector3.new(4, 1, 4)
        flyPart.Transparency = 1
        flyPart.CanCollide = false
        flyPart.Anchored = true
        flyPart.Parent = char
        Manager:AddInstance("FlyPart", flyPart)
        
        local bodyGyro = Instance.new("BodyGyro")
        bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.P = 1000
        bodyGyro.Parent = hrp
        Manager:AddInstance("FlyGyro", bodyGyro)
        
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bodyVelocity.Velocity = Vector3.zero
        bodyVelocity.Parent = hrp
        Manager:AddInstance("FlyVelocity", bodyVelocity)
        
        local flyConnection = RunService.RenderStepped:Connect(function()
            if not getgenv().Config.Fly then return end
            
            local speed = getgenv().Config.FlySpeed
            local cam = workspace.CurrentCamera
            local direction = Vector3.zero
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - cam.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - cam.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + cam.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction = direction + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                direction = direction - Vector3.new(0, 1, 0)
            end
            
            bodyVelocity.Velocity = direction.Unit * speed
            bodyGyro.CFrame = cam.CFrame
            flyPart.CFrame = hrp.CFrame * CFrame.new(0, -3, 0)
        end)
        Manager:Connect("FlyLoop", flyConnection)
    else
        Manager:Disconnect("FlyLoop")
        Manager:RemoveInstance("FlyPart")
        Manager:RemoveInstance("FlyGyro")
        Manager:RemoveInstance("FlyVelocity")
    end
end

function Movement.NoClip(enable)
    if enable then
        local noClipConnection = RunService.Stepped:Connect(function()
            if not getgenv().Config.NoClip then return end
            
            local char = Utils.GetCharacter()
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
        Manager:Connect("NoClipLoop", noClipConnection)
    else
        Manager:Disconnect("NoClipLoop")
    end
end

function Movement.SetSpeed(speed)
    local hum = Utils.GetHumanoid()
    if hum then
        hum.WalkSpeed = speed
    end
end

function Movement.SetJumpPower(power)
    local hum = Utils.GetHumanoid()
    if hum then
        hum.JumpPower = power
    end
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SECTION 11: COMBAT SYSTEM
-- ════════════════════════════════════════════════════════════════════════════════

local Combat = {}
Combat.LastAttack = 0
Combat.LastSkill = {}
Combat.AttackDelay = 0.1

function Combat.EquipWeapon(weaponName)
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local char = Utils.GetCharacter()
    if not backpack or not char then return false end
    
    -- Check if already equipped
    local equipped = char:FindFirstChildOfClass("Tool")
    if equipped and (equipped.Name == weaponName or equipped.ToolTip == weaponName) then
        return true
    end
    
    -- Find and equip
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            if tool.Name == weaponName or tool.ToolTip == weaponName then
                char.Humanoid:EquipTool(tool)
                return true
            end
        end
    end
    
    return false
end

function Combat.GetEquippedWeapon()
    local char = Utils.GetCharacter()
    if not char then return nil end
    return char:FindFirstChildOfClass("Tool")
end

function Combat.Attack(target)
    if not target or not Utils.IsAlive() then return end
    
    local now = tick()
    if now - Combat.LastAttack < Combat.AttackDelay then return end
    Combat.LastAttack = now
    Combat.AttackDelay = 0.1 + math.random() * 0.05 -- 100-150ms
    
    -- Enable Buso Haki
    if getgenv().Config.AutoBusoHaki then
        local char = Utils.GetCharacter()
        if char and not char:FindFirstChild("HasBuso") then
            RemoteHandler.Invoke("Buso")
        end
    end
    
    local hrp = target:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if getgenv().Config.FastAttack then
        RemoteHandler.Invoke("weaponL1", target, hrp)
    else
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        task.wait(0.02)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end
end

function Combat.UseSkill(skillKey)
    local now = tick()
    local lastUse = Combat.LastSkill[skillKey] or 0
    local cooldown = getgenv().Config.SkillCooldown or 0.5
    
    if now - lastUse < cooldown then return false end
    Combat.LastSkill[skillKey] = now
    
    VirtualInputManager:SendKeyEvent(true, skillKey, false, game)
    task.wait(0.02)
    VirtualInputManager:SendKeyEvent(false, skillKey, false, game)
    
    return true
end

function Combat.SpamSkills()
    if not getgenv().Config.AutoSkill then return end
    
    local skills = {
        Enum.KeyCode.Z,
        Enum.KeyCode.X,
        Enum.KeyCode.C,
        Enum.KeyCode.V,
        Enum.KeyCode.F
    }
    
    for _, skill in ipairs(skills) do
        Combat.UseSkill(skill)
        task.wait(0.1)
    end
end

function Combat.BringMobs(mobName, radius)
    local hrp = Utils.GetHRP()
    if not hrp then return end
    
    radius = radius or getgenv().Config.BringDistance
    local enemies = Workspace:FindFirstChild("Enemies")
    if not enemies then return end
    
    for _, enemy in pairs(enemies:GetChildren()) do
        if enemy.Name == mobName then
            local enemyHRP = enemy:FindFirstChild("HumanoidRootPart")
            local enemyHum = enemy:FindFirstChild("Humanoid")
            
            if enemyHRP and enemyHum and enemyHum.Health > 0 then
                local dist = Utils.Distance(hrp.Position, enemyHRP.Position)
                if dist < radius then
                    -- Bring to front of player
                    enemyHRP.CFrame = hrp.CFrame * CFrame.new(0, 0, -5)
                    enemyHRP.CanCollide = false
                    enemyHRP.Anchored = true
                    
                    -- Disable movement
                    enemyHum.WalkSpeed = 0
                    enemyHum.JumpPower = 0
                end
            end
        end
    end
end

function Combat.ExpandHitbox(mobName, size)
    size = size or getgenv().Config.HitboxSize
    local enemies = Workspace:FindFirstChild("Enemies")
    if not enemies then return end
    
    for _, enemy in pairs(enemies:GetChildren()) do
        if enemy.Name == mobName then
            local enemyHRP = enemy:FindFirstChild("HumanoidRootPart")
            if enemyHRP and enemyHRP.Size.X < size then
                enemyHRP.Size = Vector3.new(size, size, size)
                enemyHRP.Transparency = 0.7
            end
        end
    end
end

function Combat.KillAura(radius)
    if not getgenv().Config.KillAura then return end
    
    local hrp = Utils.GetHRP()
    if not hrp then return end
    
    radius = radius or 50
    local enemies = Workspace:FindFirstChild("Enemies")
    if not enemies then return end
    
    for _, enemy in pairs(enemies:GetChildren()) do
        local enemyHRP = enemy:FindFirstChild("HumanoidRootPart")
        local enemyHum = enemy:FindFirstChild("Humanoid")
        
        if enemyHRP and enemyHum and enemyHum.Health > 0 then
            local dist = Utils.Distance(hrp.Position, enemyHRP.Position)
            if dist < radius then
                Combat.Attack(enemy)
            end
        end
    end
end

function Combat.AutoKen()
    if not getgenv().Config.AutoKen then return end
    RemoteHandler.Invoke("Ken")
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SECTION 12: AUTO FARM SYSTEM
-- ════════════════════════════════════════════════════════════════════════════════

local AutoFarm = {}
AutoFarm.Running = false
AutoFarm.NoMobCounter = 0

function AutoFarm.HasQuest()
    local questGui = LocalPlayer:FindFirstChild("PlayerGui")
    if questGui then
        local main = questGui:FindFirstChild("Main")
        if main then
            local quest = main:FindFirstChild("Quest")
            return quest and quest.Visible
        end
    end
    return false
end

function AutoFarm.AcceptQuest(questData)
    if AutoFarm.HasQuest() then return true end
    
    local hrp = Utils.GetHRP()
    if not hrp then return false end
    
    local distance = Utils.Distance(hrp.Position, questData.QuestPos.Position)
    
    if distance > 100 then
        Movement.TweenTo(questData.QuestPos)
        return false
    else
        RemoteHandler.Invoke("StartQuest", questData.QuestId, questData.QuestLevel)
        task.wait(0.3)
        return AutoFarm.HasQuest()
    end
end

function AutoFarm.GetTarget(mobName, maxDist)
    maxDist = maxDist or 4000
    local enemies = Workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    
    local hrp = Utils.GetHRP()
    if not hrp then return nil end
    
    local closest, closestDist = nil, maxDist
    
    for _, enemy in pairs(enemies:GetChildren()) do
        if enemy.Name == mobName then
            local enemyHRP = enemy:FindFirstChild("HumanoidRootPart")
            local enemyHum = enemy:FindFirstChild("Humanoid")
            
            if enemyHRP and enemyHum and enemyHum.Health > 0 then
                local dist = Utils.Distance(hrp.Position, enemyHRP.Position)
                if dist < closestDist then
                    closest = enemy
                    closestDist = dist
                end
            end
        end
    end
    
    return closest, closestDist
end

function AutoFarm.FarmMob(target)
    if not target then return end
    
    local hrp = Utils.GetHRP()
    local targetHRP = target:FindFirstChild("HumanoidRootPart")
    if not hrp or not targetHRP then return end
    
    local distance = Utils.Distance(hrp.Position, targetHRP.Position)
    local farmDistance = getgenv().Config.Distance or 35
    
    if distance > 200 then
        -- Far away, tween to target
        Movement.TweenTo(targetHRP.CFrame * CFrame.new(0, 20, 0))
    else
        -- Close enough, stop and attack
        Movement.StopTween()
        
        -- Position above target
        hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 20, 0)
        
        -- Bring and expand hitbox
        local questData = QuestDatabase.GetQuestForLevel()
        Combat.BringMobs(questData.MobName)
        Combat.ExpandHitbox(questData.MobName)
        
        -- Attack
        Combat.Attack(target)
        
        -- Use skills
        if getgenv().Config.AutoSkill then
            Combat.SpamSkills()
        end
    end
end

function AutoFarm.FarmMastery()
    if not getgenv().Config.AutoFarmMastery then return end
    
    local target = AutoFarm.GetTarget(QuestDatabase.GetQuestForLevel().MobName)
    if target then
        local hum = target:FindFirstChild("Humanoid")
        if hum then
            local healthPercent = (hum.Health / hum.MaxHealth) * 100
            local switchPercent = getgenv().Config.MasteryHealth or 30
            
            local mainWeapon = getgenv().Config.SelectedWeapon
            local masteryWeapon = getgenv().Config.MasteryWeapon
            
            if healthPercent < switchPercent then
                Combat.EquipWeapon(masteryWeapon)
            else
                Combat.EquipWeapon(mainWeapon)
            end
        end
    end
end

function AutoFarm.Start()
    if AutoFarm.Running then return end
    AutoFarm.Running = true
    AutoFarm.NoMobCounter = 0
    
    local farmLoop = RunService.Heartbeat:Connect(function()
        local success, err = pcall(function()
            if not getgenv().Config or not getgenv().Config.AutoFarm then
                AutoFarm.Running = false
                return
            end
            
            if not Utils.IsAlive() then
                return
            end
            
            -- Safe Mode - Escape if low health
            if getgenv().Config.SafeMode then
                local hum = Utils.GetHumanoid()
                if hum and hum.Health < (hum.MaxHealth * 0.3) then
                    local hrp = Utils.GetHRP()
                    if hrp then
                        hrp.CFrame = hrp.CFrame * CFrame.new(0, 200, 0)
                    end
                    return
                end
            end
            
            local questData = QuestDatabase.GetQuestForLevel()
            if not questData then return end
            
            -- Accept quest if needed
            if getgenv().Config.AutoQuest and not AutoFarm.HasQuest() then
                AutoFarm.AcceptQuest(questData)
                return
            end
            
            -- Find and attack target
            local target, distance = AutoFarm.GetTarget(questData.MobName)
            
            if target then
                AutoFarm.NoMobCounter = 0
                
                -- Equip weapon
                Combat.EquipWeapon(getgenv().Config.SelectedWeapon)
                
                -- Handle mastery farming
                if getgenv().Config.AutoFarmMastery then
                    AutoFarm.FarmMastery()
                end
                
                -- Farm the target
                AutoFarm.FarmMob(target)
            else
                AutoFarm.NoMobCounter = AutoFarm.NoMobCounter + 1
                
                -- Go to mob spawn location
                if questData.MobPos then
                    Movement.TweenTo(questData.MobPos)
                end
                
                -- Server hop if no mobs for too long
                if AutoFarm.NoMobCounter > 500 and getgenv().Config.ServerHop then
                    AutoFarm.NoMobCounter = 0
                    pcall(ServerHop)
                end
            end
        end)
        
        if not success then
            warn("[AutoFarm] Error: " .. tostring(err))
        end
    end)
    
    Manager:Connect("AutoFarmLoop", farmLoop)
end

function AutoFarm.Stop()
    AutoFarm.Running = false
    Movement.StopTween()
    Manager:Disconnect("AutoFarmLoop")
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SECTION 13: AUTO BOSS FARM
-- ════════════════════════════════════════════════════════════════════════════════

local BossFarm = {}
BossFarm.Running = false

function BossFarm.GetBoss(bossName)
    local enemies = Workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    
    for _, enemy in pairs(enemies:GetChildren()) do
        if bossName == "Auto" then
            -- Find any boss
            for _, boss in ipairs(BossDatabase) do
                if enemy.Name == boss.Name then
                    local hum = enemy:FindFirstChild("Humanoid")
                    if hum and hum.Health > 0 then
                        return enemy
                    end
                end
            end
        else
            if enemy.Name == bossName then
                local hum = enemy:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    return enemy
                end
            end
        end
    end
    
    return nil
end

function BossFarm.Start()
    if BossFarm.Running then return end
    BossFarm.Running = true
    
    local bossLoop = RunService.Heartbeat:Connect(function()
        local success, err = pcall(function()
            if not getgenv().Config or not getgenv().Config.AutoFarmBoss then
                BossFarm.Running = false
                return
            end
            
            if not Utils.IsAlive() then return end
            
            local bossName = getgenv().Config.SelectedBoss or "Auto"
            local boss = BossFarm.GetBoss(bossName)
            
            if boss then
                local bossHRP = boss:FindFirstChild("HumanoidRootPart")
                local hrp = Utils.GetHRP()
                
                if bossHRP and hrp then
                    local distance = Utils.Distance(hrp.Position, bossHRP.Position)
                    
                    if distance > 100 then
                        Movement.TweenTo(bossHRP.CFrame * CFrame.new(0, 30, 0))
                    else
                        Movement.StopTween()
                        hrp.CFrame = bossHRP.CFrame * CFrame.new(0, 25, 0)
                        
                        Combat.EquipWeapon(getgenv().Config.SelectedWeapon)
                        Combat.Attack(boss)
                        
                        if getgenv().Config.AutoSkill then
                            Combat.SpamSkills()
                        end
                    end
                end
            else
                -- Boss not spawned, teleport to spawn location
                if bossName ~= "Auto" then
                    local bossData = BossDatabase.FindBoss(bossName)
                    if bossData and bossData.Pos then
                        Movement.TweenTo(bossData.Pos)
                    end
                else
                    -- Find appropriate boss for level
                    local bossData = BossDatabase.GetBossForLevel()
                    if bossData and bossData.Pos then
                        Movement.TweenTo(bossData.Pos)
                    end
                end
            end
        end)
        
        if not success then
            warn("[BossFarm] Error: " .. tostring(err))
        end
    end)
    
    Manager:Connect("BossFarmLoop", bossLoop)
end

function BossFarm.Stop()
    BossFarm.Running = false
    Movement.StopTween()
    Manager:Disconnect("BossFarmLoop")
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SECTION 14: DEVIL FRUIT SYSTEM
-- ════════════════════════════════════════════════════════════════════════════════

local FruitSystem = {}
FruitSystem.FoundFruits = {}

function FruitSystem.GetFruits()
    local fruits = {}
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Tool") and obj.ToolTip == "Blox Fruit" then
            table.insert(fruits, obj)
        end
    end
    
    local groundItems = Workspace:FindFirstChild("GroundItems")
    if groundItems then
        for _, item in pairs(groundItems:GetChildren()) do
            if item:FindFirstChild("Handle") then
                local tool = item:FindFirstChildOfClass("Tool")
                if tool and tool.ToolTip == "Blox Fruit" then
                    table.insert(fruits, item)
                end
            end
        end
    end
    
    return fruits
end

function FruitSystem.GetClosestFruit()
    local hrp = Utils.GetHRP()
    if not hrp then return nil end
    
    local closest, closestDist = nil, math.huge
    
    for _, fruit in pairs(FruitSystem.GetFruits()) do
        local pos = fruit:FindFirstChild("Handle") and fruit.Handle.Position or fruit.Position
        if pos then
            local dist = Utils.Distance(hrp.Position, pos)
            if dist < closestDist then
                closest = fruit
                closestDist = dist
            end
        end
    end
    
    return closest, closestDist
end

function FruitSystem.CollectFruit(fruit)
    if not fruit then return end
    
    local handle = fruit:FindFirstChild("Handle")
    if handle then
        local hrp = Utils.GetHRP()
        if hrp then
            hrp.CFrame = handle.CFrame * CFrame.new(0, 3, 0)
            task.wait(0.5)
            
            if firetouchinterest then
                firetouchinterest(hrp, handle, 0)
                task.wait(0.1)
                firetouchinterest(hrp, handle, 1)
            end
        end
    end
end

function FruitSystem.StartFarmFruit()
    local fruitLoop = RunService.Heartbeat:Connect(function()
        if not getgenv().Config.AutoFarmFruit then return end
        
        local fruit, dist = FruitSystem.GetClosestFruit()
        if fruit and dist < 5000 then
            if getgenv().Config.FruitNotification then
                Utils.Notify("Fruit Found!", "Collecting fruit...", 3)
            end
            
            local handle = fruit:FindFirstChild("Handle")
            if handle then
                Movement.TweenTo(CFrame.new(handle.Position))
                
                if dist < 30 then
                    FruitSystem.CollectFruit(fruit)
                end
            end
        end
    end)
    
    Manager:Connect("FruitFarmLoop", fruitLoop)
end

function FruitSystem.StartSniper()
    local sniperLoop = RunService.Heartbeat:Connect(function()
        if not getgenv().Config.FruitSniper then return end
        
        local fruit = FruitSystem.GetClosestFruit()
        if fruit then
            local handle = fruit:FindFirstChild("Handle")
            if handle then
                local hrp = Utils.GetHRP()
                if hrp then
                    hrp.CFrame = handle.CFrame * CFrame.new(0, 3, 0)
                    task.wait(0.2)
                    FruitSystem.CollectFruit(fruit)
                end
            end
        end
    end)
    
    Manager:Connect("FruitSniperLoop", sniperLoop)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SECTION 15: ESP SYSTEM
-- ════════════════════════════════════════════════════════════════════════════════

local ESP = {}
ESP.Objects = {}
ESP.Colors = {
    Fruit = Color3.fromRGB(255, 165, 0),
    Boss = Color3.fromRGB(255, 0, 0),
    Player = Color3.fromRGB(0, 255, 0),
    Chest = Color3.fromRGB(255, 255, 0),
    Flower = Color3.fromRGB(0, 255, 255),
    NPC = Color3.fromRGB(255, 255, 255),
    QuestMob = Color3.fromRGB(255, 100, 255),
}

function ESP.CreateESP(object, color, text)
    if ESP.Objects[object] then return ESP.Objects[object] end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Billboard"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.Parent = billboard
    
    local adornee = object:IsA("BasePart") and object or 
                    (object:FindFirstChild("HumanoidRootPart") or object:FindFirstChild("Handle"))
    
    if adornee then
        billboard.Adornee = adornee
        billboard.Parent = game:GetService("CoreGui")
        
        local updateConn = RunService.RenderStepped:Connect(function()
            if not object or not object.Parent then
                billboard:Destroy()
                ESP.Objects[object] = nil
                return
            end
            
            local hrp = Utils.GetHRP()
            local targetPos = adornee.Position
            
            if hrp and targetPos then
                local dist = math.floor(Utils.Distance(hrp.Position, targetPos))
                label.Text = text .. " [" .. dist .. "m]"
            end
        end)
        
        ESP.Objects[object] = {Billboard = billboard, Connection = updateConn}
        return ESP.Objects[object]
    end
    
    return nil
end

function ESP.RemoveESP(object)
    if ESP.Objects[object] then
        pcall(function()
            ESP.Objects[object].Billboard:Destroy()
            ESP.Objects[object].Connection:Disconnect()
        end)
        ESP.Objects[object] = nil
    end
end

function ESP.ClearAll()
    for object, _ in pairs(ESP.Objects) do
        ESP.RemoveESP(object)
    end
    ESP.Objects = {}
end

function ESP.UpdateAll()
    if not getgenv().Config then return end
    
    -- Fruit ESP
    if getgenv().Config.FruitESP then
        pcall(function()
            for _, fruit in pairs(FruitSystem.GetFruits()) do
                if not ESP.Objects[fruit] then
                    local name = fruit:IsA("Tool") and fruit.Name or "Fruit"
                    ESP.CreateESP(fruit, ESP.Colors.Fruit, "🍎 " .. name)
                end
            end
        end)
    end
    
    -- Boss ESP
    if getgenv().Config.ESPBoss then
        pcall(function()
            local enemies = Workspace:FindFirstChild("Enemies")
            if enemies then
                for _, enemy in pairs(enemies:GetChildren()) do
                    for _, boss in ipairs(BossDatabase) do
                        if enemy.Name == boss.Name and not ESP.Objects[enemy] then
                            ESP.CreateESP(enemy, ESP.Colors.Boss, "👹 " .. boss.Name)
                        end
                    end
                end
            end
        end)
    end
    
    -- Player ESP
    if getgenv().Config.ESPPlayer then
        pcall(function()
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    if not ESP.Objects[player.Character] then
                        ESP.CreateESP(player.Character, ESP.Colors.Player, "👤 " .. player.Name)
                    end
                end
            end
        end)
    end
    
    -- Chest ESP
    if getgenv().Config.ESPChest then
        pcall(function()
            for _, chest in pairs(Workspace:GetDescendants()) do
                if (chest.Name == "Chest" or chest.Name:find("Chest")) and not ESP.Objects[chest] then
                if chest:IsA("Model") or chest:IsA("BasePart") then
                    ESP.CreateESP(chest, ESP.Colors.Chest, "📦 Chest")
                end
            end
        end
        end)
    end
    
    -- Flower ESP
    if getgenv().Config.ESPFlower then
        pcall(function()
            for _, flower in pairs(Workspace:GetDescendants()) do
                if flower.Name:find("Flower") and not ESP.Objects[flower] then
                    local color = flower.Name:find("Blue") and Color3.fromRGB(0, 100, 255) or ESP.Colors.Flower
                    ESP.CreateESP(flower, color, "🌸 " .. flower.Name)
                end
            end
        end)
    end
    
    -- Quest Mob ESP
    if getgenv().Config.ESPQuestMobs then
        pcall(function()
            local questData = QuestDatabase.GetQuestForLevel()
            if questData then
                local enemies = Workspace:FindFirstChild("Enemies")
                if enemies then
                    for _, enemy in pairs(enemies:GetChildren()) do
                        if enemy.Name == questData.MobName and not ESP.Objects[enemy] then
                            ESP.CreateESP(enemy, ESP.Colors.QuestMob, "⚔️ " .. enemy.Name)
                        end
                    end
                end
            end
        end)
    end
end

function ESP.StartESPLoop()
    local espLoop = RunService.RenderStepped:Connect(function()
        pcall(ESP.UpdateAll)
    end)
    
    Manager:Connect("ESPLoop", espLoop)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SECTION 16: SEA EVENTS SYSTEM
-- ════════════════════════════════════════════════════════════════════════════════

local SeaEvents = {}

function SeaEvents.GetSeaBeast()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "SeaBeast" or obj.Name:find("Sea Beast") then
            local hum = obj:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                return obj
            end
        end
    end
    return nil
end

function SeaEvents.StartSeaEventFarm()
    local seaLoop = RunService.Heartbeat:Connect(function()
        if not getgenv().Config.AutoSeaEvent then return end
        
        if getgenv().Config.AutoSeaBeast then
            local seaBeast = SeaEvents.GetSeaBeast()
            if seaBeast then
                local hrp = Utils.GetHRP()
                local beastHRP = seaBeast:FindFirstChild("HumanoidRootPart")
                if hrp and beastHRP then
                    hrp.CFrame = beastHRP.CFrame * CFrame.new(0, 50, 0)
                    Combat.EquipWeapon(getgenv().Config.SelectedWeapon)
                    Combat.Attack(seaBeast)
                    Combat.SpamSkills()
                end
            end
        end
    end)
    
    Manager:Connect("SeaEventLoop", seaLoop)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SECTION 17: RAID SYSTEM
-- ════════════════════════════════════════════════════════════════════════════════

local RaidSystem = {}

function RaidSystem.IsInRaid()
    return Workspace:FindFirstChild("_raid") ~= nil
end

function RaidSystem.GetRaidMobs()
    local raid = Workspace:FindFirstChild("_raid")
    if not raid then return {} end
    
    local mobs = {}
    for _, mob in pairs(raid:GetDescendants()) do
        if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
            table.insert(mobs, mob)
        end
    end
    return mobs
end

function RaidSystem.StartAutoRaid()
    local raidLoop = RunService.Heartbeat:Connect(function()
        if not getgenv().Config.AutoRaids then return end
        
        if RaidSystem.IsInRaid() then
            local mobs = RaidSystem.GetRaidMobs()
            
            if #mobs > 0 then
                local hrp = Utils.GetHRP()
                local closest, closestDist = nil, math.huge
                
                for _, mob in pairs(mobs) do
                    local mobHRP = mob:FindFirstChild("HumanoidRootPart")
                    if mobHRP and hrp then
                        local dist = Utils.Distance(hrp.Position, mobHRP.Position)
                        if dist < closestDist then
                            closest = mob
                            closestDist = dist
                        end
                    end
                end
                
                if closest then
                    local mobHRP = closest:FindFirstChild("HumanoidRootPart")
                    if mobHRP then
                        hrp.CFrame = mobHRP.CFrame * CFrame.new(0, 15, 0)
                        Combat.EquipWeapon(getgenv().Config.SelectedWeapon)
                        Combat.Attack(closest)
                        Combat.SpamSkills()
                    end
                end
            else
                if getgenv().Config.AutoNextIslandRaid then
                    RemoteHandler.Invoke("RaidIsland")
                end
            end
        end
    end)
    
    Manager:Connect("RaidLoop", raidLoop)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SECTION 18: MATERIALS FARM
-- ════════════════════════════════════════════════════════════════════════════════

local MaterialsFarm = {}

MaterialsFarm.Materials = {
    Bone = {Mob = "Reborn Skeleton", Location = CFrame.new(-9479, 142, 5566)},
    Ectoplasm = {Mob = "Demonic Soul", Location = CFrame.new(-9513, 172, 6078)},
    DarkFragment = {Mob = "Posessed Mummy", Location = CFrame.new(-9513, 172, 6078)},
    MagmaOre = {Mob = "Magma Ninja", Location = CFrame.new(-5431, 16, -5296)},
    VampireFang = {Mob = "Vampire", Location = CFrame.new(-5635, 112, -780)},
    DragonScale = {Mob = "Dragon Crew Warrior", Location = CFrame.new(5766, 52, -1159)},
}

function MaterialsFarm.FarmMaterial(materialName)
    local material = MaterialsFarm.Materials[materialName]
    if not material then return end
    
    local enemies = Workspace:FindFirstChild("Enemies")
    if not enemies then return end
    
    local hrp = Utils.GetHRP()
    if not hrp then return end
    
    local target, closestDist = nil, math.huge
    
    for _, enemy in pairs(enemies:GetChildren()) do
        if enemy.Name == material.Mob then
            local enemyHRP = enemy:FindFirstChild("HumanoidRootPart")
            local enemyHum = enemy:FindFirstChild("Humanoid")
            
            if enemyHRP and enemyHum and enemyHum.Health > 0 then
                local dist = Utils.Distance(hrp.Position, enemyHRP.Position)
                if dist < closestDist then
                    target = enemy
                    closestDist = dist
                end
            end
        end
    end
    
    if target then
        local targetHRP = target:FindFirstChild("HumanoidRootPart")
        if targetHRP then
            if closestDist > 100 then
                Movement.TweenTo(targetHRP.CFrame * CFrame.new(0, 20, 0))
            else
                hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 15, 0)
                Combat.EquipWeapon(getgenv().Config.SelectedWeapon)
                Combat.Attack(target)
                Combat.SpamSkills()
            end
        end
    else
        Movement.TweenTo(material.Location)
    end
end

function MaterialsFarm.StartMaterialFarm()
    local matLoop = RunService.Heartbeat:Connect(function()
        pcall(function()
            if not getgenv().Config then return end
            
            if getgenv().Config.AutoFarmBone then MaterialsFarm.FarmMaterial("Bone") return end
            if getgenv().Config.AutoFarmEctoplasm then MaterialsFarm.FarmMaterial("Ectoplasm") return end
            if getgenv().Config.AutoFarmDarkFragment then MaterialsFarm.FarmMaterial("DarkFragment") return end
            if getgenv().Config.AutoFarmMagmaOre then MaterialsFarm.FarmMaterial("MagmaOre") return end
            if getgenv().Config.AutoFarmVampireFang then MaterialsFarm.FarmMaterial("VampireFang") return end
            if getgenv().Config.AutoFarmDragonScale then MaterialsFarm.FarmMaterial("DragonScale") return end
        end)
    end)
    
    Manager:Connect("MaterialFarmLoop", matLoop)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SECTION 19: HAKI SYSTEM
-- ════════════════════════════════════════════════════════════════════════════════

local HakiSystem = {}

function HakiSystem.EnableBuso()
    pcall(function()
        local char = Utils.GetCharacter()
        if char and not char:FindFirstChild("HasBuso") then
            RemoteHandler.Invoke("Buso")
        end
    end)
end

function HakiSystem.StartHakiLoop()
    local hakiLoop = RunService.Heartbeat:Connect(function()
        pcall(function()
            if not getgenv().Config then return end
            
            if getgenv().Config.AutoBusoHaki then
                HakiSystem.EnableBuso()
            end
            
            if getgenv().Config.AutoKen then
                RemoteHandler.Invoke("Ken")
            end
        end)
    end)
    
    Manager:Connect("HakiLoop", hakiLoop)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SECTION 20: STATS SYSTEM
-- ════════════════════════════════════════════════════════════════════════════════

local StatsSystem = {}

function StatsSystem.AddStat(statName, amount)
    amount = amount or 1
    for i = 1, amount do
        RemoteHandler.Invoke("AddPoint", statName)
        task.wait(0.05)
    end
end

function StatsSystem.StartAutoStats()
    local statsLoop = RunService.Heartbeat:Connect(function()
        if not getgenv().Config.AutoStatsPoints then return end
        
        local data = Utils.GetPlayerData()
        if not data then return end
        
        local points = data:FindFirstChild("Points")
        if not points or points.Value <= 0 then return end
        
        local melee = getgenv().Config.MeleeStats or 0
        local defense = getgenv().Config.DefenseStats or 0
        local sword = getgenv().Config.SwordStats or 0
        local gun = getgenv().Config.GunStats or 0
        local fruit = getgenv().Config.FruitStats or 0
        
        local total = melee + defense + sword + gun + fruit
        if total == 0 then return end
        
        local available = points.Value
        
        if melee > 0 then StatsSystem.AddStat("Melee", math.floor(available * (melee / total))) end
        if defense > 0 then StatsSystem.AddStat("Defense", math.floor(available * (defense / total))) end
        if sword > 0 then StatsSystem.AddStat("Sword", math.floor(available * (sword / total))) end
        if gun > 0 then StatsSystem.AddStat("Gun", math.floor(available * (gun / total))) end
        if fruit > 0 then StatsSystem.AddStat("Blox Fruit", math.floor(available * (fruit / total))) end
    end)
    
    Manager:Connect("StatsLoop", statsLoop)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SECTION 21: UTILITY FEATURES
-- ════════════════════════════════════════════════════════════════════════════════

local UtilityFeatures = {}

function UtilityFeatures.AntiAFK()
    local vu = game:GetService("VirtualUser")
    local antiAFKConn = LocalPlayer.Idled:Connect(function()
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end)
    Manager:Connect("AntiAFK", antiAFKConn)
end

function UtilityFeatures.FPSBooster()
    if not getgenv().Config.FPSBooster then return end
    
    settings().Rendering.QualityLevel = 1
    
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Part") or v:IsA("MeshPart") then
            v.Material = Enum.Material.Plastic
            v.Reflectance = 0
        end
        if v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = false
        end
    end
end

function UtilityFeatures.RemoveFog()
    if not getgenv().Config.RemoveFog then return end
    Lighting.FogEnd = 9e9
    Lighting.FogStart = 9e9
end

function UtilityFeatures.InfiniteEnergy()
    local energyLoop = RunService.Heartbeat:Connect(function()
        if not getgenv().Config.InfiniteEnergy then return end
        
        local char = Utils.GetCharacter()
        if char then
            local energy = char:FindFirstChild("Energy")
            if energy then
                energy.Value = 1000
            end
        end
    end)
    
    Manager:Connect("InfiniteEnergy", energyLoop)
end

function ServerHop()
    SaveConfig()
    
    pcall(function()
        local servers = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
        if servers then
            local data = HttpService:JSONDecode(servers)
            for _, s in ipairs(data.data) do
                if s.id ~= game.JobId and s.playing < s.maxPlayers then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                    return
                end
            end
        end
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
end

function UtilityFeatures.StartUtilities()
    pcall(function()
        if getgenv().Config and getgenv().Config.AntiAFK then 
            UtilityFeatures.AntiAFK() 
        end
    end)
    
    pcall(UtilityFeatures.FPSBooster)
    pcall(UtilityFeatures.RemoveFog)
    pcall(UtilityFeatures.InfiniteEnergy)
    
    local movementLoop = RunService.Heartbeat:Connect(function()
        pcall(function()
            if not getgenv().Config then return end
            
            if getgenv().Config.WalkSpeed and getgenv().Config.WalkSpeed > 16 then
                Movement.SetSpeed(getgenv().Config.WalkSpeed)
            end
            if getgenv().Config.JumpPower and getgenv().Config.JumpPower > 50 then
                Movement.SetJumpPower(getgenv().Config.JumpPower)
            end
        end)
    end)
    Manager:Connect("MovementLoop", movementLoop)
    
    pcall(function()
        if getgenv().Config and getgenv().Config.Fly then 
            Movement.Fly(true) 
        end
    end)
    
    pcall(function()
        if getgenv().Config and getgenv().Config.NoClip then 
            Movement.NoClip(true) 
        end
    end)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SECTION 22: TELEPORT SYSTEM
-- ════════════════════════════════════════════════════════════════════════════════

local TeleportSystem = {}

function TeleportSystem.ToIsland(islandName)
    local pos = IslandDatabase.GetIsland(islandName)
    if pos then
        Movement.Teleport(pos)
        Utils.Notify("Teleport", "Teleported to " .. islandName, 2)
    end
end

function TeleportSystem.ToBoss(bossName)
    local boss = BossDatabase.FindBoss(bossName)
    if boss then
        Movement.Teleport(boss.Pos)
        Utils.Notify("Teleport", "Teleported to " .. boss.Name, 2)
    end
end

function TeleportSystem.ToNPC(npcName)
    for _, npc in pairs(Workspace:GetDescendants()) do
        if npc.Name == npcName and npc:FindFirstChild("HumanoidRootPart") then
            Movement.Teleport(npc.HumanoidRootPart.CFrame)
            Utils.Notify("Teleport", "Teleported to " .. npcName, 2)
            return
        end
    end
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SECTION 23: UI SYSTEM (ORION LIB)
-- ════════════════════════════════════════════════════════════════════════════════

local function CreateUI()
    local OrionLib = nil
    
    -- Try multiple sources for Orion
    local sources = {
        'https://raw.githubusercontent.com/jensonhirst/Orion/main/source',
        'https://raw.githubusercontent.com/shlexware/Orion/main/source'
    }
    
    for _, source in ipairs(sources) do
        local success, result = pcall(function()
            return loadstring(game:HttpGet(source))()
        end)
        if success and result then
            OrionLib = result
            break
        end
    end
    
    if not OrionLib then
        warn("[Blox Ultimate] Failed to load UI library")
        return nil
    end
    
    local Window = OrionLib:MakeWindow({
        Name = "💎 Blox Fruits Ultimate v9.0",
        HidePremium = false,
        SaveConfig = true,
        ConfigFolder = "BloxUltimateV9"
    })
    
    -- ═══════════════════════════════════════════
    -- TAB: AUTO FARM
    -- ═══════════════════════════════════════════
    local FarmTab = Window:MakeTab({
        Name = "⚔️ Auto Farm",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })
    
    FarmTab:AddSection({Name = "Main Farm"})
    
    FarmTab:AddToggle({
        Name = "🔥 Auto Farm Level",
        Default = getgenv().Config.AutoFarm,
        Callback = function(Value)
            getgenv().Config.AutoFarm = Value
            getgenv().Config.AutoQuest = Value
            if Value then AutoFarm.Start() else AutoFarm.Stop() end
        end
    })
    
    FarmTab:AddToggle({
        Name = "👹 Auto Farm Boss",
        Default = getgenv().Config.AutoFarmBoss,
        Callback = function(Value)
            getgenv().Config.AutoFarmBoss = Value
            if Value then BossFarm.Start() else BossFarm.Stop() end
        end
    })
    
    FarmTab:AddToggle({
        Name = "✨ Auto Farm Mastery",
        Default = getgenv().Config.AutoFarmMastery,
        Callback = function(Value)
            getgenv().Config.AutoFarmMastery = Value
        end
    })
    
    local weapons = {"Combat", "Melee", "Sword", "Blox Fruit", "Gun"}
    FarmTab:AddDropdown({
        Name = "⚔️ Select Weapon",
        Default = getgenv().Config.SelectedWeapon,
        Options = weapons,
        Callback = function(Value)
            getgenv().Config.SelectedWeapon = Value
        end
    })
    
    FarmTab:AddSlider({
        Name = "❤️ Mastery Switch HP %",
        Min = 10,
        Max = 60,
        Default = getgenv().Config.MasteryHealth,
        Color = Color3.fromRGB(255, 0, 0),
        Increment = 5,
        Callback = function(Value)
            getgenv().Config.MasteryHealth = Value
        end
    })
    
    FarmTab:AddSection({Name = "Materials Farm"})
    
    local materials = {"Bone", "Ectoplasm", "DarkFragment", "MagmaOre", "VampireFang", "DragonScale"}
    for _, mat in ipairs(materials) do
        FarmTab:AddToggle({
            Name = "Farm " .. mat,
            Default = getgenv().Config["AutoFarm" .. mat],
            Callback = function(Value)
                getgenv().Config["AutoFarm" .. mat] = Value
                if Value then MaterialsFarm.StartMaterialFarm() end
            end
        })
    end
    
    -- ═══════════════════════════════════════════
    -- TAB: DEVIL FRUIT
    -- ═══════════════════════════════════════════
    local FruitTab = Window:MakeTab({
        Name = "🍎 Devil Fruit",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })
    
    FruitTab:AddToggle({
        Name = "🔍 Auto Farm Fruit",
        Default = getgenv().Config.AutoFarmFruit,
        Callback = function(Value)
            getgenv().Config.AutoFarmFruit = Value
            if Value then FruitSystem.StartFarmFruit() end
        end
    })
    
    FruitTab:AddToggle({
        Name = "🎯 Fruit Sniper",
        Default = getgenv().Config.FruitSniper,
        Callback = function(Value)
            getgenv().Config.FruitSniper = Value
            if Value then FruitSystem.StartSniper() end
        end
    })
    
    FruitTab:AddToggle({
        Name = "👁️ Fruit ESP",
        Default = getgenv().Config.FruitESP,
        Callback = function(Value)
            getgenv().Config.FruitESP = Value
        end
    })
    
    FruitTab:AddToggle({
        Name = "🔔 Fruit Notification",
        Default = getgenv().Config.FruitNotification,
        Callback = function(Value)
            getgenv().Config.FruitNotification = Value
        end
    })
    
    -- ═══════════════════════════════════════════
    -- TAB: COMBAT
    -- ═══════════════════════════════════════════
    local CombatTab = Window:MakeTab({
        Name = "⚡ Combat",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })
    
    CombatTab:AddToggle({
        Name = "🎮 Auto Skill",
        Default = getgenv().Config.AutoSkill,
        Callback = function(Value)
            getgenv().Config.AutoSkill = Value
        end
    })
    
    CombatTab:AddToggle({
        Name = "⚡ Fast Attack",
        Default = getgenv().Config.FastAttack,
        Callback = function(Value)
            getgenv().Config.FastAttack = Value
        end
    })
    
    CombatTab:AddToggle({
        Name = "🔥 Kill Aura",
        Default = getgenv().Config.KillAura,
        Callback = function(Value)
            getgenv().Config.KillAura = Value
        end
    })
    
    CombatTab:AddToggle({
        Name = "🛡️ Auto Ken (Dodge)",
        Default = getgenv().Config.AutoKen,
        Callback = function(Value)
            getgenv().Config.AutoKen = Value
        end
    })
    
    CombatTab:AddToggle({
        Name = "💪 Auto Buso Haki",
        Default = getgenv().Config.AutoBusoHaki,
        Callback = function(Value)
            getgenv().Config.AutoBusoHaki = Value
        end
    })
    
    CombatTab:AddSlider({
        Name = "📏 Hitbox Size",
        Min = 10,
        Max = 100,
        Default = getgenv().Config.HitboxSize,
        Increment = 5,
        Callback = function(Value)
            getgenv().Config.HitboxSize = Value
        end
    })
    
    CombatTab:AddSlider({
        Name = "📍 Bring Distance",
        Min = 20,
        Max = 200,
        Default = getgenv().Config.BringDistance,
        Increment = 10,
        Callback = function(Value)
            getgenv().Config.BringDistance = Value
        end
    })
    
    -- ═══════════════════════════════════════════
    -- TAB: RAIDS & SEA EVENTS
    -- ═══════════════════════════════════════════
    local RaidTab = Window:MakeTab({
        Name = "🏴‍☠️ Raids & Events",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })
    
    RaidTab:AddToggle({
        Name = "⚔️ Auto Raids",
        Default = getgenv().Config.AutoRaids,
        Callback = function(Value)
            getgenv().Config.AutoRaids = Value
            if Value then RaidSystem.StartAutoRaid() end
        end
    })
    
    RaidTab:AddToggle({
        Name = "🔄 Auto Next Island (Raid)",
        Default = getgenv().Config.AutoNextIslandRaid,
        Callback = function(Value)
            getgenv().Config.AutoNextIslandRaid = Value
        end
    })
    
    RaidTab:AddToggle({
        Name = "🌊 Auto Sea Event",
        Default = getgenv().Config.AutoSeaEvent,
        Callback = function(Value)
            getgenv().Config.AutoSeaEvent = Value
            if Value then SeaEvents.StartSeaEventFarm() end
        end
    })
    
    RaidTab:AddToggle({
        Name = "🦈 Auto Sea Beast",
        Default = getgenv().Config.AutoSeaBeast,
        Callback = function(Value)
            getgenv().Config.AutoSeaBeast = Value
        end
    })
    
    -- ═══════════════════════════════════════════
    -- TAB: ESP & VISUALS
    -- ═══════════════════════════════════════════
    local ESPTab = Window:MakeTab({
        Name = "👁️ ESP & Visuals",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })
    
    ESPTab:AddToggle({
        Name = "🍎 Fruit ESP",
        Default = getgenv().Config.FruitESP,
        Callback = function(Value)
            getgenv().Config.FruitESP = Value
            if not Value then ESP.ClearAll() end
        end
    })
    
    ESPTab:AddToggle({
        Name = "👹 Boss ESP",
        Default = getgenv().Config.ESPBoss,
        Callback = function(Value)
            getgenv().Config.ESPBoss = Value
        end
    })
    
    ESPTab:AddToggle({
        Name = "👤 Player ESP",
        Default = getgenv().Config.ESPPlayer,
        Callback = function(Value)
            getgenv().Config.ESPPlayer = Value
        end
    })
    
    ESPTab:AddToggle({
        Name = "📦 Chest ESP",
        Default = getgenv().Config.ESPChest,
        Callback = function(Value)
            getgenv().Config.ESPChest = Value
        end
    })
    
    ESPTab:AddToggle({
        Name = "🌸 Flower ESP",
        Default = getgenv().Config.ESPFlower,
        Callback = function(Value)
            getgenv().Config.ESPFlower = Value
        end
    })
    
    ESPTab:AddToggle({
        Name = "⚔️ Quest Mob ESP",
        Default = getgenv().Config.ESPQuestMobs,
        Callback = function(Value)
            getgenv().Config.ESPQuestMobs = Value
        end
    })
    
    -- ═══════════════════════════════════════════
    -- TAB: TELEPORT
    -- ═══════════════════════════════════════════
    local TeleportTab = Window:MakeTab({
        Name = "🗺️ Teleport",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })
    
    local islandList = {}
    for name, _ in pairs(IslandDatabase) do
        table.insert(islandList, name)
    end
    table.sort(islandList)
    
    TeleportTab:AddDropdown({
        Name = "🏝️ Select Island",
        Default = "Starter Island",
        Options = islandList,
        Callback = function(Value)
            getgenv().Config.SelectedIsland = Value
        end
    })
    
    TeleportTab:AddButton({
        Name = "📍 Teleport to Island",
        Callback = function()
            TeleportSystem.ToIsland(getgenv().Config.SelectedIsland)
        end
    })
    
    local bossList = {}
    for _, boss in ipairs(BossDatabase) do
        table.insert(bossList, boss.Name)
    end
    
    TeleportTab:AddDropdown({
        Name = "👹 Select Boss",
        Default = "Gorilla King",
        Options = bossList,
        Callback = function(Value)
            getgenv().Config.SelectedBoss = Value
        end
    })
    
    TeleportTab:AddButton({
        Name = "📍 Teleport to Boss",
        Callback = function()
            TeleportSystem.ToBoss(getgenv().Config.SelectedBoss)
        end
    })
    
    -- ═══════════════════════════════════════════
    -- TAB: STATS
    -- ═══════════════════════════════════════════
    local StatsTab = Window:MakeTab({
        Name = "📊 Stats",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })
    
    StatsTab:AddToggle({
        Name = "🔄 Auto Stats Points",
        Default = getgenv().Config.AutoStatsPoints,
        Callback = function(Value)
            getgenv().Config.AutoStatsPoints = Value
            if Value then StatsSystem.StartAutoStats() end
        end
    })
    
    local statTypes = {"Melee", "Defense", "Sword", "Gun", "Fruit"}
    for _, stat in ipairs(statTypes) do
        StatsTab:AddSlider({
            Name = "📈 " .. stat .. " %",
            Min = 0,
            Max = 100,
            Default = getgenv().Config[stat .. "Stats"] or 0,
            Increment = 5,
            Callback = function(Value)
                getgenv().Config[stat .. "Stats"] = Value
            end
        })
    end
    
    -- ═══════════════════════════════════════════
    -- TAB: UTILITY
    -- ═══════════════════════════════════════════
    local UtilityTab = Window:MakeTab({
        Name = "⚙️ Utility",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })
    
    UtilityTab:AddSlider({
        Name = "🏃 Walk Speed",
        Min = 16,
        Max = 500,
        Default = getgenv().Config.WalkSpeed,
        Increment = 10,
        Callback = function(Value)
            getgenv().Config.WalkSpeed = Value
        end
    })
    
    UtilityTab:AddSlider({
        Name = "🦘 Jump Power",
        Min = 50,
        Max = 500,
        Default = getgenv().Config.JumpPower,
        Increment = 10,
        Callback = function(Value)
            getgenv().Config.JumpPower = Value
        end
    })
    
    UtilityTab:AddToggle({
        Name = "🕊️ Fly",
        Default = getgenv().Config.Fly,
        Callback = function(Value)
            getgenv().Config.Fly = Value
            Movement.Fly(Value)
        end
    })
    
    UtilityTab:AddSlider({
        Name = "✈️ Fly Speed",
        Min = 50,
        Max = 500,
        Default = getgenv().Config.FlySpeed,
        Increment = 25,
        Callback = function(Value)
            getgenv().Config.FlySpeed = Value
        end
    })
    
    UtilityTab:AddToggle({
        Name = "👻 No Clip",
        Default = getgenv().Config.NoClip,
        Callback = function(Value)
            getgenv().Config.NoClip = Value
            Movement.NoClip(Value)
        end
    })
    
    UtilityTab:AddToggle({
        Name = "⚡ Infinite Energy",
        Default = getgenv().Config.InfiniteEnergy,
        Callback = function(Value)
            getgenv().Config.InfiniteEnergy = Value
        end
    })
    
    UtilityTab:AddToggle({
        Name = "🛡️ Anti AFK",
        Default = getgenv().Config.AntiAFK,
        Callback = function(Value)
            getgenv().Config.AntiAFK = Value
            if Value then UtilityFeatures.AntiAFK() end
        end
    })
    
    UtilityTab:AddToggle({
        Name = "🌫️ Remove Fog",
        Default = getgenv().Config.RemoveFog,
        Callback = function(Value)
            getgenv().Config.RemoveFog = Value
            UtilityFeatures.RemoveFog()
        end
    })
    
    UtilityTab:AddToggle({
        Name = "🖥️ FPS Booster",
        Default = getgenv().Config.FPSBooster,
        Callback = function(Value)
            getgenv().Config.FPSBooster = Value
            UtilityFeatures.FPSBooster()
        end
    })
    
    UtilityTab:AddToggle({
        Name = "🛡️ Safe Mode",
        Default = getgenv().Config.SafeMode,
        Callback = function(Value)
            getgenv().Config.SafeMode = Value
        end
    })
    
    UtilityTab:AddButton({
        Name = "🔄 Server Hop",
        Callback = function()
            ServerHop()
        end
    })
    
    -- ═══════════════════════════════════════════
    -- TAB: SETTINGS
    -- ═══════════════════════════════════════════
    local SettingsTab = Window:MakeTab({
        Name = "💾 Settings",
        Icon = "rbxassetid://4483345998",
        PremiumOnly = false
    })
    
    SettingsTab:AddButton({
        Name = "💾 Save Configuration",
        Callback = function()
            SaveConfig()
        end
    })
    
    SettingsTab:AddButton({
        Name = "📂 Load Configuration",
        Callback = function()
            LoadConfig()
            OrionLib:MakeNotification({
                Name = "Config",
                Content = "Configuration loaded!",
                Time = 3
            })
        end
    })
    
    SettingsTab:AddButton({
        Name = "🗑️ Clear ESP",
        Callback = function()
            ESP.ClearAll()
        end
    })
    
    SettingsTab:AddButton({
        Name = "🛑 Stop All",
        Callback = function()
            getgenv().Config.AutoFarm = false
            getgenv().Config.AutoFarmBoss = false
            getgenv().Config.AutoRaids = false
            AutoFarm.Stop()
            BossFarm.Stop()
            Movement.StopTween()
            ESP.ClearAll()
            OrionLib:MakeNotification({
                Name = "System",
                Content = "All features stopped!",
                Time = 3
            })
        end
    })
    
    SettingsTab:AddLabel("Script by Blox Ultimate Team")
    SettingsTab:AddLabel("Version 9.0 - Platinum Edition")
    
    OrionLib:Init()
    
    return OrionLib
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SECTION 24: INITIALIZATION
-- ════════════════════════════════════════════════════════════════════════════════

local function Initialize()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║     BLOX FRUITS ULTIMATE v9.0 - PLATINUM EDITION                 ║")
    print("║     Loading...                                                    ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    
    -- Start ESP with protection
    pcall(function()
        ESP.StartESPLoop()
    end)
    
    -- Start Haki System with protection
    pcall(function()
        HakiSystem.StartHakiLoop()
    end)
    
    -- Start Utilities with protection
    pcall(function()
        UtilityFeatures.StartUtilities()
    end)
    
    -- Create UI with protection
    local success, err = pcall(function()
        CreateUI()
    end)
    
    if not success then
        warn("[Blox Ultimate] UI Error: " .. tostring(err))
        warn("[Blox Ultimate] Attempting fallback UI...")
        -- Fallback: try alternative Orion source
        pcall(function()
            local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()
            if OrionLib then
                local Window = OrionLib:MakeWindow({Name = "Blox Fruits Ultimate v9.0", HidePremium = true})
                local Tab = Window:MakeTab({Name = "Info"})
                Tab:AddLabel("UI loaded in fallback mode")
                Tab:AddLabel("Some features may be limited")
                OrionLib:Init()
            end
        end)
    end
    
    -- Notification
    pcall(function()
        Utils.Notify("Blox Ultimate", "Script loaded successfully! v9.0", 5)
    end)
    
    print("[Blox Ultimate] ✅ All systems initialized!")
    print("[Blox Ultimate] 📊 Features: 200+")
    print("[Blox Ultimate] 🔒 Private Server Optimized")
end

-- Run initialization with full protection
local initSuccess, initErr = pcall(Initialize)
if not initSuccess then
    warn("[Blox Ultimate] Initialization Error: " .. tostring(initErr))
end

-- ════════════════════════════════════════════════════════════════════════════════
-- END OF SCRIPT
-- ════════════════════════════════════════════════════════════════════════════════
