--[[
    ╔══════════════════════════════════════════════════════════════════════════════╗
    ║                    BLOX FRUITS ULTIMATE - LOADER v2.2                        ║
    ║                     Professional Grade | No Key Required                      ║
    ║                          STANDALONE VERSION - FIXED                          ║
    ╚══════════════════════════════════════════════════════════════════════════════╝
]]

-- ════════════════════════════════════════════════════════════════════════════════
-- SERVICES
-- ════════════════════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local StarterGui = game:GetService("StarterGui")

local CoreGui = nil
pcall(function()
    CoreGui = game:GetService("CoreGui")
end)

local LocalPlayer = Players.LocalPlayer

-- ════════════════════════════════════════════════════════════════════════════════
-- CONFIGURATION
-- ════════════════════════════════════════════════════════════════════════════════

local CONFIG = {
    MAIN_SCRIPT_URL = "https://raw.githubusercontent.com/BloxFruitsUltimate/BloxFruits-Ultimate-Script/main/BloxFruits_Ultimate_v9.lua",
    BACKUP_URLS = {
        "https://raw.githubusercontent.com/BloxFruitsUltimate/BloxFruits-Ultimate-Script/main/BloxFruits_Ultimate_v9.lua",
        -- Adicione URLs de backup reais aqui
    },
    VALID_PLACE_IDS = {
        2753915549, -- Blox Fruits Main
        4442272183, -- Blox Fruits Private Server
        7449423635, -- Blox Fruits Test
    },
    GAME_KEYWORDS = {"blox", "fruit"},
}

-- ════════════════════════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ════════════════════════════════════════════════════════════════════════════════

local function SafeCall(func, ...)
    local args = {...}
    local success, result = pcall(function()
        return func(unpack(args))
    end)
    return success, result
end

local function IsValidPlaceId(placeId)
    for _, validId in ipairs(CONFIG.VALID_PLACE_IDS) do
        if placeId == validId then
            return true
        end
    end
    return false
end

local function IsBloxFruitsByName(placeId)
    local success, productInfo = SafeCall(function()
        return MarketplaceService:GetProductInfo(placeId)
    end)
    
    if success and productInfo and productInfo.Name then
        local name = productInfo.Name:lower()
        local hasAllKeywords = true
        for _, keyword in ipairs(CONFIG.GAME_KEYWORDS) do
            if not name:find(keyword) then
                hasAllKeywords = false
                break
            end
        end
        return hasAllKeywords
    end
    return false
end

local function HttpGet(url)
    local success, result = pcall(function()
        return game:HttpGet(url, true)
    end)
    
    if success and result and #result > 100 then
        return result
    end
    return nil
end

local function ExecuteScript(scriptContent)
    if not scriptContent or #scriptContent < 100 then
        return false, "Invalid script content"
    end
    
    local loadSuccess, loadedFunc = pcall(function()
        return loadstring(scriptContent)
    end)
    
    if not loadSuccess or not loadedFunc then
        return false, "Failed to compile script"
    end
    
    local execSuccess, execError = pcall(loadedFunc)
    
    if not execSuccess then
        return false, "Execution error: " .. tostring(execError)
    end
    
    return true, nil
end

-- ════════════════════════════════════════════════════════════════════════════════
-- LOADING UI
-- ════════════════════════════════════════════════════════════════════════════════

local function CreateLoadingUI()
    -- Limpa UI anterior se existir
    pcall(function()
        if CoreGui and CoreGui:FindFirstChild("BloxUltimateLoader") then
            CoreGui.BloxUltimateLoader:Destroy()
        end
        if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
            local pg = LocalPlayer.PlayerGui:FindFirstChild("BloxUltimateLoader")
            if pg then pg:Destroy() end
        end
    end)
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BloxUltimateLoader"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    
    -- Tenta parenting no CoreGui primeiro
    local parentSuccess = pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    
    if not parentSuccess or not ScreenGui.Parent then
        pcall(function()
            ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui", 5)
        end)
    end
    
    if not ScreenGui.Parent then
        warn("[Loader] Failed to create UI")
        return nil
    end
    
    local Background = Instance.new("Frame")
    Background.Name = "Background"
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Background.BackgroundTransparency = 0.3
    Background.BorderSizePixel = 0
    Background.Parent = ScreenGui
    
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Size = UDim2.new(0, 400, 0, 180)
    Container.Position = UDim2.new(0.5, -200, 0.5, -90)
    Container.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    Container.BorderSizePixel = 0
    Container.Parent = Background
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 15)
    Corner.Parent = Container
    
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(100, 100, 255)
    Stroke.Thickness = 2
    Stroke.Parent = Container
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 20)
    Title.BackgroundTransparency = 1
    Title.Text = "💎 BLOX FRUITS ULTIMATE"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 22
    Title.Font = Enum.Font.GothamBold
    Title.Parent = Container
    
    local Version = Instance.new("TextLabel")
    Version.Size = UDim2.new(1, 0, 0, 20)
    Version.Position = UDim2.new(0, 0, 0, 55)
    Version.BackgroundTransparency = 1
    Version.Text = "v9.0 Platinum Edition"
    Version.TextColor3 = Color3.fromRGB(150, 150, 255)
    Version.TextSize = 14
    Version.Font = Enum.Font.Gotham
    Version.Parent = Container
    
    local Status = Instance.new("TextLabel")
    Status.Name = "Status"
    Status.Size = UDim2.new(1, -40, 0, 25)
    Status.Position = UDim2.new(0, 20, 0, 85)
    Status.BackgroundTransparency = 1
    Status.Text = "Initializing..."
    Status.TextColor3 = Color3.fromRGB(200, 200, 200)
    Status.TextSize = 14
    Status.Font = Enum.Font.Gotham
    Status.TextXAlignment = Enum.TextXAlignment.Left
    Status.Parent = Container
    
    local ProgressBG = Instance.new("Frame")
    ProgressBG.Size = UDim2.new(1, -40, 0, 8)
    ProgressBG.Position = UDim2.new(0, 20, 0, 115)
    ProgressBG.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    ProgressBG.BorderSizePixel = 0
    ProgressBG.Parent = Container
    
    local ProgressCorner = Instance.new("UICorner")
    ProgressCorner.CornerRadius = UDim.new(0, 4)
    ProgressCorner.Parent = ProgressBG
    
    local ProgressFill = Instance.new("Frame")
    ProgressFill.Name = "Fill"
    ProgressFill.Size = UDim2.new(0, 0, 1, 0)
    ProgressFill.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
    ProgressFill.BorderSizePixel = 0
    ProgressFill.Parent = ProgressBG
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 4)
    FillCorner.Parent = ProgressFill
    
    local Percentage = Instance.new("TextLabel")
    Percentage.Name = "Percentage"
    Percentage.Size = UDim2.new(1, -40, 0, 20)
    Percentage.Position = UDim2.new(0, 20, 0, 128)
    Percentage.BackgroundTransparency = 1
    Percentage.Text = "0%"
    Percentage.TextColor3 = Color3.fromRGB(150, 150, 150)
    Percentage.TextSize = 12
    Percentage.Font = Enum.Font.Gotham
    Percentage.TextXAlignment = Enum.TextXAlignment.Right
    Percentage.Parent = Container
    
    local Credits = Instance.new("TextLabel")
    Credits.Size = UDim2.new(1, 0, 0, 20)
    Credits.Position = UDim2.new(0, 0, 1, -22)
    Credits.BackgroundTransparency = 1
    Credits.Text = "Free Script • No Key Required"
    Credits.TextColor3 = Color3.fromRGB(100, 100, 100)
    Credits.TextSize = 11
    Credits.Font = Enum.Font.Gotham
    Credits.Parent = Container
    
    return {
        ScreenGui = ScreenGui,
        Container = Container,
        Status = Status,
        ProgressFill = ProgressFill,
        Percentage = Percentage,
        Background = Background
    }
end

local function UpdateProgress(ui, progress, status)
    if not ui then return end
    
    pcall(function()
        local targetSize = UDim2.new(math.clamp(progress / 100, 0, 1), 0, 1, 0)
        local tween = TweenService:Create(
            ui.ProgressFill, 
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
            {Size = targetSize}
        )
        tween:Play()
        
        ui.Percentage.Text = math.floor(math.clamp(progress, 0, 100)) .. "%"
        
        if status then 
            ui.Status.Text = status 
        end
    end)
end

local function DestroyUI(ui, delay)
    if not ui then return end
    
    delay = delay or 0.5
    
    pcall(function()
        task.wait(delay)
        
        local fade = TweenService:Create(
            ui.Background, 
            TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
            {BackgroundTransparency = 1}
        )
        
        local containerFade = TweenService:Create(
            ui.Container,
            TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundTransparency = 1}
        )
        
        fade:Play()
        containerFade:Play()
        
        fade.Completed:Wait()
        
        if ui.ScreenGui and ui.ScreenGui.Parent then
            ui.ScreenGui:Destroy()
        end
    end)
end

local function SendNotification(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Blox Ultimate",
            Text = text or "",
            Duration = duration or 5
        })
    end)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- MAIN LOADER
-- ════════════════════════════════════════════════════════════════════════════════

local function Main()
    -- Aguarda o jogo carregar completamente
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    
    -- Aguarda o player estar pronto
    if not LocalPlayer then
        LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    end
    
    -- Pequeno delay para garantir estabilidade
    task.wait(0.5)
    
    -- Cria UI
    local ui = CreateLoadingUI()
    
    if ui then
        UpdateProgress(ui, 10, "🔍 Checking game...")
    end
    task.wait(0.3)
    
    -- Verifica se é Blox Fruits
    local placeId = game.PlaceId
    local isBloxFruits = IsValidPlaceId(placeId)
    
    if not isBloxFruits then
        if ui then
            UpdateProgress(ui, 20, "🔍 Verifying game name...")
        end
        task.wait(0.2)
        isBloxFruits = IsBloxFruitsByName(placeId)
    end
    
    if not isBloxFruits then
        if ui then
            UpdateProgress(ui, 100, "❌ This script only works on Blox Fruits!")
        end
        warn("[Loader] This script only works on Blox Fruits!")
        warn("[Loader] Current Place ID: " .. tostring(placeId))
        task.wait(3)
        DestroyUI(ui, 0)
        return
    end
    
    if ui then
        UpdateProgress(ui, 30, "✅ Blox Fruits detected!")
    end
    task.wait(0.3)
    
    if ui then
        UpdateProgress(ui, 45, "🛡️ Applying protections...")
    end
    task.wait(0.3)
    
    if ui then
        UpdateProgress(ui, 60, "📦 Downloading script...")
    end
    
    -- Tenta carregar o script principal
    local scriptContent = nil
    local downloadError = nil
    
    -- Tenta URL principal
    scriptContent = HttpGet(CONFIG.MAIN_SCRIPT_URL)
    
    -- Se falhar, tenta backups
    if not scriptContent then
        if ui then
            UpdateProgress(ui, 65, "⚠️ Trying backup sources...")
        end
        
        for i, backupUrl in ipairs(CONFIG.BACKUP_URLS) do
            if backupUrl ~= CONFIG.MAIN_SCRIPT_URL then
                task.wait(0.5)
                scriptContent = HttpGet(backupUrl)
                if scriptContent then
                    break
                end
            end
        end
    end
    
    if not scriptContent then
        if ui then
            UpdateProgress(ui, 100, "❌ Failed to download script!")
        end
        warn("[Loader] Failed to download script from all sources")
        SendNotification("Blox Ultimate", "Failed to download script. Check your internet connection.", 5)
        task.wait(3)
        DestroyUI(ui, 0)
        return
    end
    
    if ui then
        UpdateProgress(ui, 80, "🚀 Executing script...")
    end
    task.wait(0.3)
    
    -- Executa o script
    local execSuccess, execError = ExecuteScript(scriptContent)
    
    if execSuccess then
        if ui then
            UpdateProgress(ui, 100, "✅ Script loaded successfully!")
        end
        task.wait(0.5)
        SendNotification("Blox Ultimate", "Script loaded! Enjoy 🎮", 5)
    else
        if ui then
            UpdateProgress(ui, 100, "❌ Error: " .. tostring(execError):sub(1, 50))
        end
        warn("[Loader] Execution Error: " .. tostring(execError))
        SendNotification("Blox Ultimate", "Error loading script. Check console.", 5)
        task.wait(3)
    end
    
    DestroyUI(ui, 1)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- EXECUTION
-- ════════════════════════════════════════════════════════════════════════════════

local mainSuccess, mainError = pcall(Main)

if not mainSuccess then
    warn("[Loader] Critical Error: " .. tostring(mainError))
    SendNotification("Blox Ultimate", "Critical error occurred. Check console.", 5)
end
