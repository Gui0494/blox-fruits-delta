--[[
    ╔════════════════════════════════════════════════════════════════════╗
    ║   BLOX FRUITS ULTIMATE - DIAMOND RELEASE (v8.2 HITBOX EDITION)    ║
    ║   Status: Undetected | Features: Auto Bring + Hitbox Expander     ║
    ╚════════════════════════════════════════════════════════════════════╝
]]

-- ════════════════════════════════════════════════════════════
-- 1. BOOTSTRAP & SERVICES
-- ════════════════════════════════════════════════════════════

if not game:IsLoaded() then game.Loaded:Wait() end

-- Limpeza
if getgenv().BloxInstance then
    getgenv().BloxInstance:DisconnectAll()
end

local Services = {
    Players = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    RunService = game:GetService("RunService"),
    VirtualInputManager = game:GetService("VirtualInputManager"),
    TweenService = game:GetService("TweenService"),
    HttpService = game:GetService("HttpService"),
    TeleportService = game:GetService("TeleportService"),
    Stats = game:GetService("Stats")
}

local LP = Services.Players.LocalPlayer
local Mouse = LP:GetMouse()

-- ════════════════════════════════════════════════════════════
-- 2. QUEST DATABASE (MANTIDO)
-- ════════════════════════════════════════════════════════════

local QuestDB = {
    -- SEA 1
    {Min=1, Max=9, ID="BanditQuest1", Mob="Bandit", Level=1, Pos=CFrame.new(1060, 17, 1550)},
    {Min=10, Max=14, ID="JungleQuest", Mob="Monkey", Level=1, Pos=CFrame.new(-1604, 37, 152)},
    {Min=15, Max=29, ID="JungleQuest", Mob="Gorilla", Level=2, Pos=CFrame.new(-1230, 6, -485)},
    {Min=30, Max=39, ID="BuggyQuest1", Mob="Pirate", Level=1, Pos=CFrame.new(-1140, 5, 3828)},
    {Min=40, Max=59, ID="BuggyQuest1", Mob="Brute", Level=2, Pos=CFrame.new(-1140, 5, 3828)},
    {Min=60, Max=74, ID="DesertQuest", Mob="Desert Bandit", Level=1, Pos=CFrame.new(897, 7, 4388)},
    {Min=75, Max=89, ID="DesertQuest", Mob="Desert Officer", Level=2, Pos=CFrame.new(897, 7, 4388)},
    {Min=90, Max=99, ID="SnowQuest", Mob="Snow Bandit", Level=1, Pos=CFrame.new(1386, 87, -1297)},
    {Min=100, Max=119, ID="SnowQuest", Mob="Snowman", Level=2, Pos=CFrame.new(1386, 87, -1297)},
    {Min=120, Max=149, ID="MarineQuest2", Mob="Chief Petty Officer", Level=1, Pos=CFrame.new(-4880, 21, 4273)},
    {Min=150, Max=174, ID="MarineQuest2", Mob="Sky Bandit", Level=2, Pos=CFrame.new(-4880, 21, 4273)},
    {Min=175, Max=189, ID="PrisonerQuest", Mob="Prisoner", Level=1, Pos=CFrame.new(5308, 2, 474)},
    {Min=190, Max=209, ID="PrisonerQuest", Mob="Dangerous Prisoner", Level=2, Pos=CFrame.new(5308, 2, 474)},
    {Min=210, Max=249, ID="ColosseumQuest", Mob="Toga Warrior", Level=1, Pos=CFrame.new(-1576, 8, -2985)},
    {Min=250, Max=274, ID="ColosseumQuest", Mob="Gladiator", Level=2, Pos=CFrame.new(-1576, 8, -2985)},
    {Min=275, Max=299, ID="MagmaQuest", Mob="Military Soldier", Level=1, Pos=CFrame.new(-5313, 12, 8515)},
    {Min=300, Max=324, ID="MagmaQuest", Mob="Military Spy", Level=2, Pos=CFrame.new(-5313, 12, 8515)},
    {Min=325, Max=374, ID="FishmanQuest", Mob="Fishman Warrior", Level=1, Pos=CFrame.new(61123, 19, 1569)},
    {Min=375, Max=399, ID="FishmanQuest", Mob="Fishman Commando", Level=2, Pos=CFrame.new(61123, 19, 1569)},
    {Min=400, Max=449, ID="SkyExp1Quest", Mob="God's Guard", Level=1, Pos=CFrame.new(-4721, 845, -1912)},
    {Min=450, Max=474, ID="SkyExp1Quest", Mob="Shanda", Level=2, Pos=CFrame.new(-7863, 5545, -380)},
    {Min=475, Max=524, ID="SkyExp2Quest", Mob="Royal Squad", Level=1, Pos=CFrame.new(-7906, 5634, -1411)},
    {Min=525, Max=549, ID="SkyExp2Quest", Mob="Royal Soldier", Level=2, Pos=CFrame.new(-7906, 5634, -1411)},
    {Min=550, Max=624, ID="FountainQuest", Mob="Galley Pirate", Level=1, Pos=CFrame.new(5255, 39, 4050)},
    {Min=625, Max=649, ID="FountainQuest", Mob="Galley Captain", Level=2, Pos=CFrame.new(5255, 39, 4050)},
    -- SEA 2
    {Min=700, Max=724, ID="Area1Quest", Mob="Raider", Level=1, Pos=CFrame.new(-428, 73, 1836)},
    {Min=725, Max=774, ID="Area1Quest", Mob="Mercenary", Level=2, Pos=CFrame.new(-428, 73, 1836)},
    {Min=775, Max=799, ID="Area2Quest", Mob="Swan Pirate", Level=1, Pos=CFrame.new(638, 73, 1478)},
    {Min=800, Max=874, ID="Area2Quest", Mob="Factory Staff", Level=2, Pos=CFrame.new(281, 73, 410)},
    {Min=875, Max=899, ID="MarineQuest3", Mob="Marine Lieutenant", Level=1, Pos=CFrame.new(-2440, 73, -3217)},
    {Min=900, Max=949, ID="MarineQuest3", Mob="Marine Captain", Level=2, Pos=CFrame.new(-2440, 73, -3217)},
    {Min=950, Max=974, ID="ZombieQuest", Mob="Zombie", Level=1, Pos=CFrame.new(-5497, 49, -795)},
    {Min=975, Max=999, ID="ZombieQuest", Mob="Vampire", Level=2, Pos=CFrame.new(-5497, 49, -795)},
    {Min=1000, Max=1049, ID="SnowMountainQuest", Mob="Snow Trooper", Level=1, Pos=CFrame.new(607, 401, -5371)},
    {Min=1050, Max=1099, ID="SnowMountainQuest", Mob="Winter Warrior", Level=2, Pos=CFrame.new(607, 401, -5371)},
    {Min=1100, Max=1124, ID="IceSideQuest", Mob="Lab Subordinate", Level=1, Pos=CFrame.new(-6061, 16, -4905)},
    {Min=1125, Max=1174, ID="IceSideQuest", Mob="Horned Warrior", Level=2, Pos=CFrame.new(-6061, 16, -4905)},
    {Min=1175, Max=1199, ID="FireSideQuest", Mob="Magma Ninja", Level=1, Pos=CFrame.new(-5431, 16, -5296)},
    {Min=1200, Max=1249, ID="FireSideQuest", Mob="Lava Pirate", Level=2, Pos=CFrame.new(-5431, 16, -5296)},
    {Min=1250, Max=1274, ID="ShipQuest1", Mob="Ship Deckhand", Level=1, Pos=CFrame.new(1037, 125, 32911)},
    {Min=1275, Max=1299, ID="ShipQuest1", Mob="Ship Engineer", Level=2, Pos=CFrame.new(1037, 125, 32911)},
    {Min=1300, Max=1324, ID="ShipQuest2", Mob="Ship Steward", Level=1, Pos=CFrame.new(971, 125, 33245)},
    {Min=1325, Max=1349, ID="ShipQuest2", Mob="Ship Officer", Level=2, Pos=CFrame.new(971, 125, 33245)},
    {Min=1350, Max=1374, ID="FrostQuest", Mob="Arctic Warrior", Level=1, Pos=CFrame.new(5669, 29, -6482)},
    {Min=1375, Max=1424, ID="FrostQuest", Mob="Snow Lurker", Level=2, Pos=CFrame.new(5669, 29, -6482)},
    {Min=1425, Max=1449, ID="ForgottenQuest", Mob="Sea Soldier", Level=1, Pos=CFrame.new(-3054, 236, -10145)},
    {Min=1450, Max=1474, ID="ForgottenQuest", Mob="Water Fighter", Level=2, Pos=CFrame.new(-3054, 236, -10145)},
    -- SEA 3
    {Min=1500, Max=1524, ID="PiratePortQuest", Mob="Pirate Millionaire", Level=1, Pos=CFrame.new(-290, 44, 5580)},
    {Min=1525, Max=1574, ID="PiratePortQuest", Mob="Pistol Billionaire", Level=2, Pos=CFrame.new(-290, 44, 5580)},
    {Min=1575, Max=1599, ID="AmazonQuest", Mob="Dragon Crew Warrior", Level=1, Pos=CFrame.new(5832, 52, -1100)},
    {Min=1600, Max=1624, ID="AmazonQuest", Mob="Dragon Crew Archer", Level=2, Pos=CFrame.new(5832, 52, -1100)},
    {Min=1625, Max=1649, ID="AmazonQuest2", Mob="Female Islander", Level=1, Pos=CFrame.new(5448, 602, 751)},
    {Min=1650, Max=1699, ID="AmazonQuest2", Mob="Giant Islander", Level=2, Pos=CFrame.new(5448, 602, 751)},
    {Min=1700, Max=1724, ID="MarineTreeIsland", Mob="Marine Commodore", Level=1, Pos=CFrame.new(2180, 29, -6737)},
    {Min=1725, Max=1774, ID="MarineTreeIsland", Mob="Marine Rear Admiral", Level=2, Pos=CFrame.new(2180, 29, -6737)},
    {Min=1775, Max=1799, ID="DeepForestIsland", Mob="Mythological Pirate", Level=1, Pos=CFrame.new(-13234, 332, -7625)},
    {Min=1800, Max=1824, ID="DeepForestIsland2", Mob="Jungle Pirate", Level=1, Pos=CFrame.new(-12680, 390, -9902)},
    {Min=1825, Max=1849, ID="DeepForestIsland3", Mob="Musketeer Pirate", Level=1, Pos=CFrame.new(-13234, 332, -7625)},
    {Min=1850, Max=1899, ID="HauntedQuest1", Mob="Reborn Skeleton", Level=1, Pos=CFrame.new(-9479, 142, 5566)},
    {Min=1900, Max=1924, ID="HauntedQuest1", Mob="Living Zombie", Level=2, Pos=CFrame.new(-9479, 142, 5566)},
    {Min=1925, Max=1974, ID="HauntedQuest2", Mob="Demonic Soul", Level=1, Pos=CFrame.new(-9513, 172, 6078)},
    {Min=1975, Max=1999, ID="HauntedQuest2", Mob="Posessed Mummy", Level=2, Pos=CFrame.new(-9513, 172, 6078)},
    {Min=2000, Max=2024, ID="IceCreamLandQuest", Mob="Peanut Scout", Level=1, Pos=CFrame.new(-716, 38, -12469)},
    {Min=2025, Max=2049, ID="IceCreamLandQuest", Mob="Peanut President", Level=2, Pos=CFrame.new(-716, 38, -12469)},
    {Min=2050, Max=2074, ID="IceCreamLandQuest2", Mob="Ice Cream Chef", Level=1, Pos=CFrame.new(-821, 66, -10965)},
    {Min=2075, Max=2099, ID="IceCreamLandQuest2", Mob="Ice Cream Commander", Level=2, Pos=CFrame.new(-821, 66, -10965)},
    {Min=2100, Max=2124, ID="CakeQuest1", Mob="Cookie Crafter", Level=1, Pos=CFrame.new(-2021, 38, -12028)},
    {Min=2125, Max=2149, ID="CakeQuest1", Mob="Cake Guard", Level=2, Pos=CFrame.new(-2021, 38, -12028)},
    {Min=2150, Max=2199, ID="CakeQuest2", Mob="Baking Staff", Level=1, Pos=CFrame.new(-1927, 38, -12842)},
    {Min=2200, Max=2224, ID="CakeQuest2", Mob="Head Baker", Level=2, Pos=CFrame.new(-1927, 38, -12842)},
    {Min=2225, Max=2249, ID="ChocQuest1", Mob="Cocoa Warrior", Level=1, Pos=CFrame.new(231, 23, -12197)},
    {Min=2250, Max=2274, ID="ChocQuest1", Mob="Chocolate Bar Battler", Level=2, Pos=CFrame.new(231, 23, -12197)},
    {Min=2275, Max=2299, ID="ChocQuest2", Mob="Sweet Thief", Level=1, Pos=CFrame.new(151, 23, -12774)},
    {Min=2300, Max=2324, ID="ChocQuest2", Mob="Candy Rebel", Level=2, Pos=CFrame.new(151, 23, -12774)},
    {Min=2325, Max=2349, ID="CandyQuest1", Mob="Candy Pirate", Level=1, Pos=CFrame.new(-1149, 14, -14445)},
    {Min=2350, Max=2374, ID="CandyQuest1", Mob="Snow Demon", Level=2, Pos=CFrame.new(-1149, 14, -14445)},
    {Min=2375, Max=2399, ID="TikiQuest1", Mob="Isle Outlaw", Level=1, Pos=CFrame.new(-16545, 56, 1051)},
    {Min=2400, Max=2424, ID="TikiQuest1", Mob="Island Boy", Level=2, Pos=CFrame.new(-16545, 56, 1051)},
    {Min=2425, Max=2449, ID="TikiQuest2", Mob="Sun-kissed Warrior", Level=1, Pos=CFrame.new(-16539, 56, -173)},
    {Min=2450, Max=9999, ID="TikiQuest2", Mob="Isle Champion", Level=2, Pos=CFrame.new(-16539, 56, -173)},
}

-- ════════════════════════════════════════════════════════════
-- 3. GERENCIAMENTO DE ESTADO & CONFIG
-- ════════════════════════════════════════════════════════════

getgenv().Config = {
    AutoFarm = false,
    AutoQuest = false,
    AutoFarmMastery = false,
    
    Weapon = "Melee",
    MasteryHealth = 30,
    FastAttack = true,
    Distance = 35,
    
    SafeMode = true,
    WhiteScreen = false,
    ServerHop = true
}

local ConfigName = "BloxDelta_v8_Diamond.json"

local function SaveConfig()
    if writefile then
        pcall(function()
            writefile(ConfigName, Services.HttpService:JSONEncode(getgenv().Config))
        end)
    end
end

local function LoadConfig()
    if readfile and isfile(ConfigName) then
        pcall(function()
            local data = Services.HttpService:JSONDecode(readfile(ConfigName))
            for k,v in pairs(data) do getgenv().Config[k] = v end
        end)
    end
end
LoadConfig()

-- ════════════════════════════════════════════════════════════
-- 4. CORE FRAMEWORK
-- ════════════════════════════════════════════════════════════

local ConnectionManager = {}
ConnectionManager.__index = ConnectionManager

function ConnectionManager.new()
    local self = setmetatable({}, ConnectionManager)
    self.Storage = {Conn = {}, Instances = {}}
    return self
end

function ConnectionManager:Add(name, item)
    if self.Storage.Conn[name] then pcall(function() self.Storage.Conn[name]:Disconnect() end) end
    self.Storage.Conn[name] = item
end

function ConnectionManager:CleanInstance(name)
    if self.Storage.Instances[name] then
        pcall(function() self.Storage.Instances[name]:Destroy() end)
        self.Storage.Instances[name] = nil
    end
end

function ConnectionManager:SetInstance(name, inst)
    self:CleanInstance(name)
    self.Storage.Instances[name] = inst
end

function ConnectionManager:DisconnectAll()
    for _, v in pairs(self.Storage.Conn) do pcall(function() v:Disconnect() end) end
    for _, v in pairs(self.Storage.Instances) do pcall(function() v:Destroy() end) end
    self.Storage = {Conn = {}, Instances = {}}
end

getgenv().BloxInstance = ConnectionManager.new()
local Manager = getgenv().BloxInstance

local CachedRemote = nil
local function SafeRemote(action, ...)
    if not CachedRemote then
        CachedRemote = Services.ReplicatedStorage:FindFirstChild("CommF_") 
            or (Services.ReplicatedStorage:FindFirstChild("Remotes") and Services.ReplicatedStorage.Remotes:FindFirstChild("CommF_"))
    end
    
    if not CachedRemote then return nil end

    local lastCall = getgenv()._LastRemoteCall or 0
    if tick() - lastCall < 0.05 then return nil end
    getgenv()._LastRemoteCall = tick()

    local args = {...}
    local success, res = pcall(function()
        return CachedRemote:InvokeServer(action, unpack(args))
    end)
    
    return success and res
end

-- ════════════════════════════════════════════════════════════
-- 5. MOVIMENTAÇÃO ROBUSTA (Anti-Stuck & Validation)
-- ════════════════════════════════════════════════════════════

local function TogglePhysics(enable)
    local HRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not HRP then return end
    
    if not enable then
        local lv = Instance.new("LinearVelocity")
        lv.MaxForce = 500000 
        lv.VectorVelocity = Vector3.zero
        lv.Attachment0 = HRP:FindFirstChild("RootAttachment") or Instance.new("Attachment", HRP)
        lv.Parent = HRP
        Manager:SetInstance("HoldPhysics", lv)
    else
        Manager:CleanInstance("HoldPhysics")
    end
end

local function TweenTo(targetCFrame)
    if not LP.Character then repeat task.wait(0.5) until LP.Character end
    if not LP.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local HRP = LP.Character.HumanoidRootPart
    local randomOffset = Vector3.new(math.random(-8,8), math.random(10,20), math.random(-8,8))
    local finalCFrame = targetCFrame * CFrame.new(randomOffset)
    
    local dist = (HRP.Position - finalCFrame.Position).Magnitude
    if dist < 10 then return end
    
    local speed = 280 + math.random(-20, 20)
    local info = TweenInfo.new(dist/speed, Enum.EasingStyle.Linear)
    
    local tween = Services.TweenService:Create(HRP, info, {CFrame = finalCFrame})
    
    TogglePhysics(false)
    tween:Play()
    
    local completed = false
    local conn = tween.Completed:Connect(function() completed = true end)
    
    local lastPos = HRP.Position
    local stuckCount = 0

    while not completed do
        if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then
            tween:Cancel()
            break
        end

        if not getgenv().Config.AutoFarm then 
            tween:Cancel()
            break 
        end
        
        if getgenv().Config.SafeMode and LP.Character.Humanoid.Health < (LP.Character.Humanoid.MaxHealth * 0.3) then
            tween:Cancel()
            break
        end

        if (HRP.Position - lastPos).Magnitude < 1 then
            stuckCount = stuckCount + 1
            if stuckCount > 50 then 
                tween:Cancel()
                if LP.Character:FindFirstChild("Humanoid") then
                    LP.Character.Humanoid.Jump = true
                end
                break
            end
        else
            stuckCount = 0
            lastPos = HRP.Position
        end

        task.wait(0.1)
    end
    
    conn:Disconnect()
    TogglePhysics(true)
end

local function ServerHop()
    if not getgenv().Config.ServerHop then return end
    SaveConfig()
    
    local success = pcall(function()
        local maxRetries = 3
        for i = 1, maxRetries do
            local servers = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
            if servers then
                local data = Services.HttpService:JSONDecode(servers)
                for _, s in ipairs(data.data) do
                    if s.id ~= game.JobId and s.playing < s.maxPlayers then
                        Services.TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LP)
                        return
                    end
                end
            end
            task.wait(2)
        end
        Services.TeleportService:Teleport(game.PlaceId, LP)
    end)
    
    if not success then warn("ServerHop Failed") end
end

-- ════════════════════════════════════════════════════════════
-- 6. LÓGICA DE FARM COM HITBOX E BRING
-- ════════════════════════════════════════════════════════════

local function GetQuestData()
    local lvl = LP.Data.Level.Value
    for _, q in ipairs(QuestDB) do
        if lvl >= q.Min and lvl <= q.Max then return q end
    end
    return QuestDB[#QuestDB]
end

local LastAttack = 0
local AttackDelay = 0.15

-- ✅ NOVA FUNÇÃO: Bring Mobs & Hitbox Expander
local function BringAndHitbox(targetName)
    local myHRP = LP.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    for _, v in pairs(workspace.Enemies:GetChildren()) do
        if v.Name == targetName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            local enemyHRP = v:FindFirstChild("HumanoidRootPart")
            if enemyHRP and (enemyHRP.Position - myHRP.Position).Magnitude < 350 then
                
                -- BRING (Client-side)
                enemyHRP.CFrame = myHRP.CFrame * CFrame.new(0, 0, -5) -- Puxa para frente
                enemyHRP.CanCollide = false
                v.Humanoid.WalkSpeed = 0
                v.Humanoid.JumpPower = 0
                
                -- HITBOX (Seguro: 60x60x60)
                if enemyHRP.Size.X < 50 then
                    enemyHRP.Size = Vector3.new(60, 60, 60)
                    enemyHRP.Transparency = 0.5
                end
            end
        end
    end
end

local function AttackHumanized(target)
    if not target then return end
    
    if not LP.Character:FindFirstChild("HasBuso") then SafeRemote("Buso") end
    
    local activeWeapon = getgenv().Config.Weapon
    if getgenv().Config.AutoFarmMastery then
        local hp = target.Humanoid.Health / target.Humanoid.MaxHealth
        if hp < (getgenv().Config.MasteryHealth / 100) then
            activeWeapon = (getgenv().Config.Weapon == "Melee") and "Sword" or "Melee"
        end
    end
    
    for _, t in pairs(LP.Backpack:GetChildren()) do
        if t:IsA("Tool") and (t.ToolTip == activeWeapon or t.Name == activeWeapon) then
            LP.Character.Humanoid:EquipTool(t)
            break
        end
    end

    if tick() - LastAttack >= AttackDelay then
        if getgenv().Config.FastAttack then
            SafeRemote("weaponL1", target, target.HumanoidRootPart)
        else
            Services.VirtualInputManager:SendMouseButtonEvent(0,0, 0, true, game, 1)
            Services.VirtualInputManager:SendMouseButtonEvent(0,0, 0, false, game, 1)
        end
        LastAttack = tick()
        AttackDelay = math.random(12, 18) / 100
    end
end

-- ════════════════════════════════════════════════════════════
-- 7. LOOP PRINCIPAL (AGRESSIVO)
-- ════════════════════════════════════════════════════════════

local function StartFarm()
    local LastLogic = 0
    local NoMobCount = 0
    
    local FarmLoop = Services.RunService.Heartbeat:Connect(function()
        if not getgenv().Config.AutoFarm then return end
        if tick() - LastLogic < 0.1 then return end
        LastLogic = tick()
        
        local status, err = pcall(function()
            if not LP.Character or not LP.Character:FindFirstChild("Humanoid") or LP.Character.Humanoid.Health <= 0 then return end
            
            if getgenv().Config.SafeMode and LP.Character.Humanoid.Health < (LP.Character.Humanoid.MaxHealth * 0.3) then
                LP.Character.HumanoidRootPart.CFrame = LP.Character.HumanoidRootPart.CFrame * CFrame.new(0, 200, 0)
                return
            end
            
            local QData = GetQuestData()
            local hasQuest = LP.PlayerGui.Main.Quest.Visible
            
            -- 1. QUEST CHECK
            if not hasQuest and getgenv().Config.AutoQuest then
                if (LP.Character.HumanoidRootPart.Position - QData.Pos.Position).Magnitude > 2500 then
                    TweenTo(QData.Pos)
                else
                    SafeRemote("StartQuest", QData.ID, QData.Level)
                end
                return
            end
            
            -- 2. TARGET CHECK
            local target = nil
            local dist = 4000
            
            for _, v in ipairs(workspace.Enemies:GetChildren()) do
                if v.Name == QData.Mob and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                    local mag = (v.HumanoidRootPart.Position - LP.Character.HumanoidRootPart.Position).Magnitude
                    if mag < dist then
                        dist = mag
                        target = v
                    end
                end
            end
            
            -- 3. ATTACK LOGIC (UPDATED)
            if target then
                NoMobCount = 0
                
                -- Se estiver longe, usa Tween
                if dist > 250 then
                    TweenTo(target.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                else
                    -- Se estiver perto: PARA, TRAZ TODOS, BATE
                    LP.Character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0) -- Fica em cima (seguro)
                    
                    BringAndHitbox(QData.Mob) -- ✅ PUXA TODOS
                    AttackHumanized(target)   -- ✅ BATE
                end
            else
                NoMobCount = NoMobCount + 1
                TweenTo(QData.Pos)
                
                if NoMobCount > 400 and getgenv().Config.ServerHop then
                    ServerHop()
                end
            end
        end)

        if not status then warn("Farm Error: " .. tostring(err)) end
    end)
    
    Manager:Add("AutoFarm", FarmLoop)
end

-- ════════════════════════════════════════════════════════════
-- 8. UI COMPLETA
-- ════════════════════════════════════════════════════════════

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "💎 Blox Fruits v8.2 | Hitbox Ed.", HidePremium = false, SaveConfig = true, ConfigFolder = "BFDeltaV8"})

local FarmTab = Window:MakeTab({Name = "Auto Farm", Icon = "rbxassetid://4483345998", PremiumOnly = false})

FarmTab:AddToggle({
    Name = "🔥 Auto Farm Level",
    Default = false,
    Callback = function(Value)
        getgenv().Config.AutoFarm = Value
        getgenv().Config.AutoQuest = Value
        if Value then StartFarm() else Manager:DisconnectAll() end
    end
})

FarmTab:AddDropdown({
    Name = "⚔️ Weapon",
    Default = "Melee",
    Options = {"Melee", "Sword", "Blox Fruit"},
    Callback = function(Value) getgenv().Config.Weapon = Value end
})

FarmTab:AddToggle({
    Name = "✨ Auto Farm Mastery",
    Default = false,
    Callback = function(Value) getgenv().Config.AutoFarmMastery = Value end
})

FarmTab:AddSlider({
    Name = "❤️ Mastery Switch HP %",
    Min = 10,
    Max = 60,
    Default = 30,
    Color = Color3.fromRGB(255, 0, 0),
    Increment = 5,
    ValueName = "%",
    Callback = function(Value) getgenv().Config.MasteryHealth = Value end
})

FarmTab:AddToggle({
    Name = "🛡️ Safe Mode",
    Default = true,
    Callback = function(Value) getgenv().Config.SafeMode = Value end
})

local SettingsTab = Window:MakeTab({Name = "Settings", Icon = "rbxassetid://4483345998", PremiumOnly = false})

SettingsTab:AddButton({
    Name = "💾 Salvar Config",
    Callback = function() SaveConfig() OrionLib:MakeNotification({Name="System", Content="Salvo!", Time=3}) end
})

SettingsTab:AddButton({
    Name = "🏳️ Boost FPS",
    Callback = function()
        Services.RunService:Set3dRenderingEnabled(false)
    end
})

OrionLib:Init()
