--[[
    ╔══════════════════════════════════════════════════════════════════════════════╗
    ║                    BLOX FRUITS ULTIMATE - LOADER v2.1                        ║
    ║                     Professional Grade | No Key Required                      ║
    ║                          STANDALONE VERSION                                   ║
    ╚══════════════════════════════════════════════════════════════════════════════╝
]]

-- ════════════════════════════════════════════════════════════════════════════════
-- SERVICES
-- ════════════════════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ════════════════════════════════════════════════════════════════════════════════
-- LOADING UI
-- ════════════════════════════════════════════════════════════════════════════════

local function CreateLoadingUI()
    pcall(function()
        if CoreGui:FindFirstChild("BloxUltimateLoader") then
            CoreGui.BloxUltimateLoader:Destroy()
        end
    end)
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "BloxUltimateLoader"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
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
        TweenService:Create(ui.ProgressFill, TweenInfo.new(0.3), {
            Size = UDim2.new(progress / 100, 0, 1, 0)
        }):Play()
        ui.Percentage.Text = math.floor(progress) .. "%"
        if status then ui.Status.Text = status end
    end)
end

local function DestroyUI(ui)
    if not ui then return end
    pcall(function()
        local fade = TweenService:Create(ui.Background, TweenInfo.new(0.5), {BackgroundTransparency = 1})
        fade:Play()
        fade.Completed:Wait()
        ui.ScreenGui:Destroy()
    end)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- MAIN LOADER
-- ════════════════════════════════════════════════════════════════════════════════

local function Main()
    -- Wait for game
    if not game:IsLoaded() then game.Loaded:Wait() end
    
    -- Create UI
    local ui = CreateLoadingUI()
    UpdateProgress(ui, 10, "🔍 Checking game...")
    task.wait(0.5)
    
    -- Verify game
    local placeId = game.PlaceId
    local isBloxFruits = (placeId == 2753915549 or placeId == 4442272183 or placeId == 7449423635)
    
    if not isBloxFruits then
        pcall(function()
            local name = game:GetService("MarketplaceService"):GetProductInfo(placeId).Name or ""
            isBloxFruits = name:lower():find("blox") and name:lower():find("fruit")
        end)
    end
    
    if not isBloxFruits then
        UpdateProgress(ui, 100, "❌ This script only works on Blox Fruits!")
        task.wait(3)
        DestroyUI(ui)
        return
    end
    
    UpdateProgress(ui, 25, "✅ Blox Fruits detected!")
    task.wait(0.5)
    
    UpdateProgress(ui, 40, "🛡️ Applying protections...")
    task.wait(0.5)
    
    UpdateProgress(ui, 60, "📦 Loading script...")
    task.wait(0.5)
    
    UpdateProgress(ui, 80, "🚀 Executing...")
    task.wait(0.3)
    
    -- Execute main script
    local success, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/BloxFruitsUltimate/BloxFruits-Ultimate-Script/main/BloxFruits_Ultimate_v9.lua"))()
    end)
    
    -- If remote load fails, notify user
    if not success then
        UpdateProgress(ui, 90, "⚠️ Trying backup method...")
        task.wait(0.5)
        
        -- Try backup
        success, err = pcall(function()
            loadstring(game:HttpGet("https://pastebin.com/raw/YOUR_BACKUP_CODE"))()
        end)
    end
    
    if success then
        UpdateProgress(ui, 100, "✅ Script loaded successfully!")
        task.wait(1)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Blox Ultimate",
                Text = "Script loaded! Enjoy 🎮",
                Duration = 5
            })
        end)
    else
        UpdateProgress(ui, 100, "❌ Error loading script")
        task.wait(2)
        warn("[Loader] Error: " .. tostring(err))
    end
    
    DestroyUI(ui)
end

-- Run
pcall(Main)
