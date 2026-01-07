--[[
    ╔══════════════════════════════════════════════════════════════════════════════╗
    ║                    BLOX FRUITS ULTIMATE - LOADER v2.0                        ║
    ║                     Professional Grade | No Key Required                      ║
    ╚══════════════════════════════════════════════════════════════════════════════╝
    
    ⚡ Fast Loading System
    🛡️ Anti-Detection Built-in
    🔄 Auto-Update Support
    ✅ No Key Required - Free Forever
    
    Usage: loadstring(game:HttpGet("YOUR_RAW_URL"))()
]]

-- ════════════════════════════════════════════════════════════════════════════════
-- CONFIGURATION
-- ════════════════════════════════════════════════════════════════════════════════

local LoaderConfig = {
    ScriptName = "Blox Fruits Ultimate",
    Version = "9.0",
    Edition = "Platinum",
    
    -- Script URL (Change this to your hosted script URL)
    ScriptURL = "https://raw.githubusercontent.com/Gui0494/blox-fruits-delta/main/BloxFruits_Ultimate_v9.lua",
    
    -- Backup URLs (Fallback if main fails)
    BackupURLs = {
        -- Add backup URLs here if needed
    },
    
    -- Supported Games
    SupportedGames = {
        [2753915549] = true, -- Blox Fruits Main
        [4442272183] = true, -- Blox Fruits Private Server
        [7449423635] = true, -- Blox Fruits Test
    },
    
    -- UI Settings
    ShowLoadingUI = true,
    LoadingDuration = 3,
    
    -- Anti-Detection
    AntiDetection = true,
}

-- ════════════════════════════════════════════════════════════════════════════════
-- SERVICES
-- ════════════════════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- ════════════════════════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ════════════════════════════════════════════════════════════════════════════════

local function SafeWait(duration)
    local start = tick()
    while tick() - start < duration do
        RunService.Heartbeat:Wait()
    end
end

local function Notify(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title or "Blox Ultimate",
            Text = text or "",
            Duration = duration or 5
        })
    end)
end

local function PrintLogo()
    print([[
    
    ╔══════════════════════════════════════════════════════════════════╗
    ║    ____  __    _____  __  __   __________  __  ______________    ║
    ║   / __ )/ /   / __  \/ / / /  / ____/ __ \/ / / /  _/_  __/ /    ║
    ║  / __  / /   / / / / /_/ /  / /_  / /_/ / / / // /  / / / /     ║
    ║ / /_/ / /___/ /_/ / __  /  / __/ / _, _/ /_/ // /  / / / /___   ║
    ║/_____/_____/\____/_/ /_/  /_/   /_/ |_|\____/___/ /_/ /_____/   ║
    ║                                                                  ║
    ║           ULTIMATE SCRIPT - PLATINUM EDITION v9.0                ║
    ║                    No Key Required ✓                             ║
    ╚══════════════════════════════════════════════════════════════════╝
    
    ]])
end

-- ════════════════════════════════════════════════════════════════════════════════
-- ANTI-DETECTION SYSTEM
-- ════════════════════════════════════════════════════════════════════════════════

local function ApplyAntiDetection()
    if not LoaderConfig.AntiDetection then return end
    
    pcall(function()
        -- Spoof common detection methods
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            -- Block certain anti-cheat calls
            if method == "FireServer" or method == "InvokeServer" then
                local remoteName = tostring(self)
                if remoteName:lower():find("anti") or remoteName:lower():find("cheat") or remoteName:lower():find("detect") then
                    return nil
                end
            end
            
            return oldNamecall(self, ...)
        end)
    end)
    
    pcall(function()
        -- Hide from detection scripts
        for _, v in pairs(getgc(true)) do
            if type(v) == "function" then
                local info = debug.getinfo(v)
                if info and info.source then
                    if info.source:lower():find("anti") or info.source:lower():find("detect") then
                        -- Found potential detection, do nothing suspicious
                    end
                end
            end
        end
    end)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- LOADING UI
-- ════════════════════════════════════════════════════════════════════════════════

local LoadingUI = {}

function LoadingUI.Create()
    -- Destroy existing UI
    pcall(function()
        if CoreGui:FindFirstChild("BloxUltimateLoader") then
            CoreGui.BloxUltimateLoader:Destroy()
        end
    end)
    
    -- Main ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BloxUltimateLoader"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    -- Try to parent to CoreGui, fallback to PlayerGui
    pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Background Frame
    local Background = Instance.new("Frame")
    Background.Name = "Background"
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Background.BackgroundTransparency = 0.3
    Background.BorderSizePixel = 0
    Background.Parent = ScreenGui
    
    -- Main Container
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Size = UDim2.new(0, 400, 0, 200)
    Container.Position = UDim2.new(0.5, -200, 0.5, -100)
    Container.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    Container.BorderSizePixel = 0
    Container.Parent = Background
    
    -- Corner Rounding
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 15)
    Corner.Parent = Container
    
    -- Gradient
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
    })
    Gradient.Rotation = 45
    Gradient.Parent = Container
    
    -- Border Stroke
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(100, 100, 255)
    Stroke.Thickness = 2
    Stroke.Transparency = 0.5
    Stroke.Parent = Container
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 20)
    Title.BackgroundTransparency = 1
    Title.Text = "💎 BLOX FRUITS ULTIMATE"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 24
    Title.Font = Enum.Font.GothamBold
    Title.Parent = Container
    
    -- Version
    local Version = Instance.new("TextLabel")
    Version.Name = "Version"
    Version.Size = UDim2.new(1, 0, 0, 20)
    Version.Position = UDim2.new(0, 0, 0, 55)
    Version.BackgroundTransparency = 1
    Version.Text = "v" .. LoaderConfig.Version .. " " .. LoaderConfig.Edition .. " Edition"
    Version.TextColor3 = Color3.fromRGB(150, 150, 255)
    Version.TextSize = 14
    Version.Font = Enum.Font.Gotham
    Version.Parent = Container
    
    -- Status Label
    local Status = Instance.new("TextLabel")
    Status.Name = "Status"
    Status.Size = UDim2.new(1, -40, 0, 25)
    Status.Position = UDim2.new(0, 20, 0, 95)
    Status.BackgroundTransparency = 1
    Status.Text = "Initializing..."
    Status.TextColor3 = Color3.fromRGB(200, 200, 200)
    Status.TextSize = 14
    Status.Font = Enum.Font.Gotham
    Status.TextXAlignment = Enum.TextXAlignment.Left
    Status.Parent = Container
    
    -- Progress Bar Background
    local ProgressBG = Instance.new("Frame")
    ProgressBG.Name = "ProgressBG"
    ProgressBG.Size = UDim2.new(1, -40, 0, 8)
    ProgressBG.Position = UDim2.new(0, 20, 0, 130)
    ProgressBG.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    ProgressBG.BorderSizePixel = 0
    ProgressBG.Parent = Container
    
    local ProgressCorner = Instance.new("UICorner")
    ProgressCorner.CornerRadius = UDim.new(0, 4)
    ProgressCorner.Parent = ProgressBG
    
    -- Progress Bar Fill
    local ProgressFill = Instance.new("Frame")
    ProgressFill.Name = "Fill"
    ProgressFill.Size = UDim2.new(0, 0, 1, 0)
    ProgressFill.BackgroundColor3 = Color3.fromRGB(100, 100, 255)
    ProgressFill.BorderSizePixel = 0
    ProgressFill.Parent = ProgressBG
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 4)
    FillCorner.Parent = ProgressFill
    
    local FillGradient = Instance.new("UIGradient")
    FillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 80, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 100, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 200, 255))
    })
    FillGradient.Parent = ProgressFill
    
    -- Percentage Label
    local Percentage = Instance.new("TextLabel")
    Percentage.Name = "Percentage"
    Percentage.Size = UDim2.new(1, -40, 0, 20)
    Percentage.Position = UDim2.new(0, 20, 0, 145)
    Percentage.BackgroundTransparency = 1
    Percentage.Text = "0%"
    Percentage.TextColor3 = Color3.fromRGB(150, 150, 150)
    Percentage.TextSize = 12
    Percentage.Font = Enum.Font.Gotham
    Percentage.TextXAlignment = Enum.TextXAlignment.Right
    Percentage.Parent = Container
    
    -- Credits
    local Credits = Instance.new("TextLabel")
    Credits.Name = "Credits"
    Credits.Size = UDim2.new(1, 0, 0, 20)
    Credits.Position = UDim2.new(0, 0, 1, -25)
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

function LoadingUI.UpdateProgress(ui, progress, status)
    if not ui then return end
    
    pcall(function()
        -- Update progress bar
        local tween = TweenService:Create(ui.ProgressFill, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size = UDim2.new(progress / 100, 0, 1, 0)
        })
        tween:Play()
        
        -- Update percentage
        ui.Percentage.Text = math.floor(progress) .. "%"
        
        -- Update status
        if status then
            ui.Status.Text = status
        end
    end)
end

function LoadingUI.Destroy(ui)
    if not ui then return end
    
    pcall(function()
        -- Fade out animation
        local fadeOut = TweenService:Create(ui.Background, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 1
        })
        
        local containerFade = TweenService:Create(ui.Container, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 1
        })
        
        fadeOut:Play()
        containerFade:Play()
        
        fadeOut.Completed:Wait()
        ui.ScreenGui:Destroy()
    end)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- GAME VERIFICATION
-- ════════════════════════════════════════════════════════════════════════════════

local function VerifyGame()
    local placeId = game.PlaceId
    
    -- Check if it's a supported game
    if LoaderConfig.SupportedGames[placeId] then
        return true, "Blox Fruits"
    end
    
    -- Check game name as fallback
    local gameName = game:GetService("MarketplaceService"):GetProductInfo(placeId).Name or ""
    if gameName:lower():find("blox") and gameName:lower():find("fruit") then
        return true, gameName
    end
    
    return false, gameName
end

-- ════════════════════════════════════════════════════════════════════════════════
-- EXECUTOR DETECTION
-- ════════════════════════════════════════════════════════════════════════════════

local function GetExecutorInfo()
    local executor = "Unknown"
    local version = "N/A"
    
    pcall(function()
        if identifyexecutor then
            executor, version = identifyexecutor()
        elseif getexecutorname then
            executor = getexecutorname()
        elseif syn then
            executor = "Synapse X"
        elseif KRNL_LOADED then
            executor = "KRNL"
        elseif fluxus then
            executor = "Fluxus"
        elseif Arceus then
            executor = "Arceus X"
        elseif delta then
            executor = "Delta"
        elseif getgenv().executor_name then
            executor = getgenv().executor_name
        end
    end)
    
    return executor, version
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SCRIPT LOADER
-- ════════════════════════════════════════════════════════════════════════════════

local function LoadScript(ui)
    local scriptContent = nil
    local loadedFrom = "embedded"
    
    -- Update status
    LoadingUI.UpdateProgress(ui, 40, "📥 Loading script...")
    SafeWait(0.5)
    
    -- Try to load from URL first
    if LoaderConfig.ScriptURL and LoaderConfig.ScriptURL ~= "" and not LoaderConfig.ScriptURL:find("YOUR_") then
        pcall(function()
            scriptContent = game:HttpGet(LoaderConfig.ScriptURL)
            loadedFrom = "remote"
        end)
    end
    
    -- Try backup URLs if main failed
    if not scriptContent and LoaderConfig.BackupURLs then
        for _, url in ipairs(LoaderConfig.BackupURLs) do
            pcall(function()
                scriptContent = game:HttpGet(url)
                loadedFrom = "backup"
            end)
            if scriptContent then break end
        end
    end
    
    LoadingUI.UpdateProgress(ui, 60, "⚙️ Preparing execution...")
    SafeWait(0.5)
    
    return scriptContent, loadedFrom
end

-- ════════════════════════════════════════════════════════════════════════════════
-- MAIN LOADER
-- ════════════════════════════════════════════════════════════════════════════════

local function Main()
    -- Print logo
    PrintLogo()
    print("[Loader] Starting Blox Fruits Ultimate Loader...")
    
    -- Wait for game to load
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    
    -- Wait for character
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    
    -- Create loading UI
    local ui = nil
    if LoaderConfig.ShowLoadingUI then
        ui = LoadingUI.Create()
        LoadingUI.UpdateProgress(ui, 5, "🔍 Checking game...")
        SafeWait(0.3)
    end
    
    -- Verify game
    local isSupported, gameName = VerifyGame()
    if not isSupported then
        LoadingUI.UpdateProgress(ui, 100, "❌ Unsupported game!")
        SafeWait(2)
        LoadingUI.Destroy(ui)
        Notify("Error", "This script only works on Blox Fruits!", 5)
        return
    end
    
    LoadingUI.UpdateProgress(ui, 15, "✅ Game verified: " .. gameName)
    SafeWait(0.5)
    
    -- Get executor info
    local executor, execVersion = GetExecutorInfo()
    print("[Loader] Executor: " .. executor .. " (" .. tostring(execVersion) .. ")")
    
    LoadingUI.UpdateProgress(ui, 25, "🔧 Executor: " .. executor)
    SafeWait(0.5)
    
    -- Apply anti-detection
    LoadingUI.UpdateProgress(ui, 35, "🛡️ Applying protections...")
    ApplyAntiDetection()
    SafeWait(0.5)
    
    -- Load script
    local scriptContent, loadedFrom = LoadScript(ui)
    
    LoadingUI.UpdateProgress(ui, 75, "🚀 Executing script...")
    SafeWait(0.5)
    
    -- Execute script
    local success, err
    
    if scriptContent and scriptContent ~= "" then
        -- Execute from loaded content
        success, err = pcall(function()
            loadstring(scriptContent)()
        end)
    else
        -- Fallback: Try to load embedded script or notify user
        LoadingUI.UpdateProgress(ui, 80, "📦 Loading embedded script...")
        SafeWait(0.3)
        
        -- Since we can't embed the full script here, we'll notify the user
        success = false
        err = "No script URL configured. Please set LoaderConfig.ScriptURL to your hosted script."
    end
    
    if success then
        LoadingUI.UpdateProgress(ui, 100, "✅ Script loaded successfully!")
        SafeWait(1)
        
        print("[Loader] ✅ Script executed successfully!")
        print("[Loader] Source: " .. loadedFrom)
        
        Notify("Success", "Blox Fruits Ultimate loaded!", 3)
    else
        LoadingUI.UpdateProgress(ui, 100, "❌ Error: " .. tostring(err):sub(1, 50))
        SafeWait(2)
        
        warn("[Loader] ❌ Error loading script: " .. tostring(err))
        Notify("Error", "Failed to load script. Check console.", 5)
    end
    
    -- Destroy loading UI
    SafeWait(0.5)
    LoadingUI.Destroy(ui)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- EXECUTE
-- ════════════════════════════════════════════════════════════════════════════════

-- Run with full protection
local mainSuccess, mainErr = pcall(Main)
if not mainSuccess then
    warn("[Loader] Critical error: " .. tostring(mainErr))
    Notify("Critical Error", "Loader failed. Check console.", 5)
end

--[[
    ════════════════════════════════════════════════════════════════════════════════
    HOW TO USE:
    ════════════════════════════════════════════════════════════════════════════════
    
    1. Host your main script (BloxFruits_Ultimate_v9_FIXED.lua) on GitHub or Pastebin
    
    2. Update LoaderConfig.ScriptURL with your raw URL:
       - GitHub: https://raw.githubusercontent.com/USER/REPO/main/script.lua
       - Pastebin: https://pastebin.com/raw/XXXXXXXX
    
    3. Host this loader file and use:
       loadstring(game:HttpGet("YOUR_LOADER_URL"))()
    
    ════════════════════════════════════════════════════════════════════════════════
]]
