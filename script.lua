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
            local config = getgenv().Config
            if not config or not config.AutoFarm then
                AutoFarm.Running = false
                return
            end
            
            if not Utils.IsAlive() then
                return
            end
            
            -- Safe Mode - Escape if low health
            if config.SafeMode then
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
            if config.AutoQuest and not AutoFarm.HasQuest() then
                AutoFarm.AcceptQuest(questData)
                return
            end
            
            -- Find and attack target
            local target, distance = AutoFarm.GetTarget(questData.MobName)
            
            if target then
                AutoFarm.NoMobCounter = 0
                
                -- Equip weapon
                Combat.EquipWeapon(config.SelectedWeapon or "Combat")
                
                -- Handle mastery farming
                if config.AutoFarmMastery then
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
                if AutoFarm.NoMobCounter > 500 and config.ServerHop then
                    AutoFarm.NoMobCounter = 0
                    pcall(function() ServerHop() end)
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
            local config = getgenv().Config
            if not config or not config.AutoFarmBoss then
                BossFarm.Running = false
                return
            end
            
            if not Utils.IsAlive() then return end
            
            local bossName = config.SelectedBoss or "Auto"
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
                        
                        Combat.EquipWeapon(config.SelectedWeapon or "Combat")
                        Combat.Attack(boss)
                        
                        if config.AutoSkill then
                            Combat.SpamSkills()
                        end
                    end
                end
            else
                if bossName ~= "Auto" then
                    local bossData = BossDatabase.FindBoss(bossName)
                    if bossData and bossData.Pos then
                        Movement.TweenTo(bossData.Pos)
                    end
                else
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
    
    pcall(function()
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
    end)
    
    return fruits
end

function FruitSystem.GetClosestFruit()
    local hrp = Utils.GetHRP()
    if not hrp then return nil, math.huge end
    
    local closest, closestDist = nil, math.huge
    
    for _, fruit in pairs(FruitSystem.GetFruits()) do
        local handle = fruit:FindFirstChild("Handle")
        local pos = handle and handle.Position or (fruit:IsA("BasePart") and fruit.Position)
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
    
    pcall(function()
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
    end)
end

function FruitSystem.StartFarmFruit()
    local fruitLoop = RunService.Heartbeat:Connect(function()
        local config = getgenv().Config
        if not config or not config.AutoFarmFruit then return end
        
        local fruit, dist = FruitSystem.GetClosestFruit()
        if fruit and dist < 5000 then
            if config.FruitNotification then
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
        local config = getgenv().Config
        if not config or not config.FruitSniper then return end
        
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

local CoreGuiESP = nil
pcall(function()
    CoreGuiESP = game:GetService("CoreGui")
end)

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
    
    local adornee = nil
    if object:IsA("BasePart") then
        adornee = object
    else
        adornee = object:FindFirstChild("HumanoidRootPart") or object:FindFirstChild("Handle")
    end
    
    if adornee then
        billboard.Adornee = adornee
        
        local parentSuccess = pcall(function()
            if CoreGuiESP then
                billboard.Parent = CoreGuiESP
            end
        end)
        
        if not parentSuccess or not billboard.Parent then
            pcall(function()
                billboard.Parent = LocalPlayer:WaitForChild("PlayerGui", 3)
            end)
        end
        
        local updateConn = RunService.RenderStepped:Connect(function()
            if not object or not object.Parent then
                pcall(function() billboard:Destroy() end)
                ESP.Objects[object] = nil
                return
            end
            
            local hrp = Utils.GetHRP()
            if hrp and adornee and adornee.Parent then
                local dist = math.floor(Utils.Distance(hrp.Position, adornee.Position))
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
        end)
        pcall(function()
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
    local config = getgenv().Config
    if not config then return end
    
    -- Fruit ESP
    if config.FruitESP then
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
    if config.ESPBoss then
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
    if config.ESPPlayer then
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
    if config.ESPChest then
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
    if config.ESPFlower then
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
    if config.ESPQuestMobs then
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
-- SECTION 16: UTILITY FEATURES
-- ════════════════════════════════════════════════════════════════════════════════

local UtilityFeatures = {}

function UtilityFeatures.AntiAFK()
    pcall(function()
        local vu = game:GetService("VirtualUser")
        local antiAFKConn = LocalPlayer.Idled:Connect(function()
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end)
        Manager:Connect("AntiAFK", antiAFKConn)
    end)
end

function UtilityFeatures.FPSBooster()
    pcall(function()
        local config = getgenv().Config
        if not config or not config.FPSBooster then return end
        
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
    end)
end

function UtilityFeatures.RemoveFog()
    pcall(function()
        local config = getgenv().Config
        if not config or not config.RemoveFog then return end
        if Lighting then
            Lighting.FogEnd = 9e9
            Lighting.FogStart = 9e9
        end
    end)
end

function UtilityFeatures.InfiniteEnergy()
    local energyLoop = RunService.Heartbeat:Connect(function()
        pcall(function()
            local config = getgenv().Config
            if not config or not config.InfiniteEnergy then return end
            
            local char = Utils.GetCharacter()
            if char then
                local energy = char:FindFirstChild("Energy")
                if energy then
                    energy.Value = 1000
                end
            end
        end)
    end)
    
    Manager:Connect("InfiniteEnergy", energyLoop)
end

-- Declaração forward de ServerHop
local ServerHop

ServerHop = function()
    pcall(SaveConfig)
    
    pcall(function()
        local servers = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
        if servers then
            local data = HttpService:JSONDecode(servers)
            if data and data.data then
                for _, s in ipairs(data.data) do
                    if s.id ~= game.JobId and s.playing < s.maxPlayers then
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                        return
                    end
                end
            end
        end
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
end

function UtilityFeatures.StartUtilities()
    pcall(function()
        local config = getgenv().Config
        if config and config.AntiAFK then 
            UtilityFeatures.AntiAFK() 
        end
    end)
    
    pcall(UtilityFeatures.FPSBooster)
    pcall(UtilityFeatures.RemoveFog)
    pcall(UtilityFeatures.InfiniteEnergy)
    
    local movementLoop = RunService.Heartbeat:Connect(function()
        pcall(function()
            local config = getgenv().Config
            if not config then return end
            
            if config.WalkSpeed and config.WalkSpeed > 16 then
                Movement.SetSpeed(config.WalkSpeed)
            end
            if config.JumpPower and config.JumpPower > 50 then
                Movement.SetJumpPower(config.JumpPower)
            end
        end)
    end)
    Manager:Connect("MovementLoop", movementLoop)
    
    pcall(function()
        local config = getgenv().Config
        if config and config.Fly then 
            Movement.Fly(true) 
        end
    end)
    
    pcall(function()
        local config = getgenv().Config
        if config and config.NoClip then 
            Movement.NoClip(true) 
        end
    end)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SECTION 17: HAKI SYSTEM
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
            local config = getgenv().Config
            if not config then return end
            
            if config.AutoBusoHaki then
                HakiSystem.EnableBuso()
            end
            
            if config.AutoKen then
                RemoteHandler.Invoke("Ken")
            end
        end)
    end)
    
    Manager:Connect("HakiLoop", hakiLoop)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SECTION 18: TELEPORT SYSTEM
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
    pcall(function()
        for _, npc in pairs(Workspace:GetDescendants()) do
            if npc.Name == npcName and npc:FindFirstChild("HumanoidRootPart") then
                Movement.Teleport(npc.HumanoidRootPart.CFrame)
                Utils.Notify("Teleport", "Teleported to " .. npcName, 2)
                return
            end
        end
    end)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SECTION 19: UI SYSTEM (ORION LIB)
-- ════════════════════════════════════════════════════════════════════════════════

local function CreateUI()
    local OrionLib = nil
    
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
        Name = "💎 Blox Fruits Ultimate v9.1",
        HidePremium = false,
        SaveConfig = true,
        ConfigFolder = "BloxUltimateV9"
    })
    
    -- TAB: AUTO FARM
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
    
    -- TAB: DEVIL FRUIT
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
    
    -- TAB: COMBAT
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
        Name = "💪 Auto Buso Haki",
        Default = getgenv().Config.AutoBusoHaki,
        Callback = function(Value)
            getgenv().Config.AutoBusoHaki = Value
        end
    })
    
    -- TAB: ESP
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
    
    -- TAB: TELEPORT
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
    
    -- TAB: UTILITY
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
    
    UtilityTab:AddToggle({
        Name = "🕊️ Fly",
        Default = getgenv().Config.Fly,
        Callback = function(Value)
            getgenv().Config.Fly = Value
            Movement.Fly(Value)
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
        Name = "🛡️ Anti AFK",
        Default = getgenv().Config.AntiAFK,
        Callback = function(Value)
            getgenv().Config.AntiAFK = Value
            if Value then UtilityFeatures.AntiAFK() end
        end
    })
    
    UtilityTab:AddButton({
        Name = "🔄 Server Hop",
        Callback = function()
            ServerHop()
        end
    })
    
    -- TAB: SETTINGS
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
        Name = "🛑 Stop All",
        Callback = function()
            getgenv().Config.AutoFarm = false
            getgenv().Config.AutoFarmBoss = false
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
    SettingsTab:AddLabel("Version 9.1 - Fixed Edition")
    
    OrionLib:Init()
    
    return OrionLib
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SECTION 20: INITIALIZATION
-- ════════════════════════════════════════════════════════════════════════════════

local function Initialize()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║     BLOX FRUITS ULTIMATE v9.1 - FIXED EDITION                    ║")
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
        pcall(function()
            local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()
            if OrionLib then
                local Window = OrionLib:MakeWindow({Name = "Blox Fruits Ultimate v9.1", HidePremium = true})
                local Tab = Window:MakeTab({Name = "Info"})
                Tab:AddLabel("UI loaded in fallback mode")
                Tab:AddLabel("Some features may be limited")
                OrionLib:Init()
            end
        end)
    end
    
    -- Notification
    pcall(function()
        Utils.Notify("Blox Ultimate", "Script loaded successfully! v9.1 Fixed", 5)
    end)
    
    print("[Blox Ultimate] ✅ All systems initialized!")
    print("[Blox Ultimate] 📊 Features: 200+")
    print("[Blox Ultimate] 🔧 Version: 9.1 (Bug Fixed)")
end

-- Run initialization with full protection
local initSuccess, initErr = pcall(Initialize)
if not initSuccess then
    warn("[Blox Ultimate] Initialization Error: " .. tostring(initErr))
end

-- ════════════════════════════════════════════════════════════════════════════════
-- END OF SCRIPT
-- ════════════════════════════════════════════════════════════════════════════════
