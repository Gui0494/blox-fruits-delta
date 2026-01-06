--[[
    ╔════════════════════════════════════════════════════════════════════╗
    ║   BLOX FRUITS ULTIMATE - LOADER v8.0                              ║
    ║   Made by: [SEU NOME]                                              ║
    ╚════════════════════════════════════════════════════════════════════╝
]]

-- ════════════════════════════════════════════════════════════
-- SISTEMA DE LOADING AVANÇADO
-- ════════════════════════════════════════════════════════════

local LoadingUI = Instance.new("ScreenGui")
LoadingUI.Name = "BloxLoader"
LoadingUI.ResetOnSpawn = false
LoadingUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Proteção contra múltiplas execuções
if game:GetService("CoreGui"):FindFirstChild("BloxLoader") then
    game:GetService("CoreGui"):FindFirstChild("BloxLoader"):Destroy()
end

LoadingUI.Parent = game:GetService("CoreGui")

-- Frame Principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 200)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = LoadingUI

-- Borda Gradiente
local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(138, 43, 226)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(75, 0, 130))
}
UIGradient.Rotation = 45
UIGradient.Parent = MainFrame

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundTransparency = 1
Title.Text = "💎 BLOX FRUITS DIAMOND"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 24
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Status Text
local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -40, 0, 30)
StatusText.Position = UDim2.new(0, 20, 0, 70)
StatusText.BackgroundTransparency = 1
StatusText.Text = "Initializing..."
StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusText.TextSize = 16
StatusText.Font = Enum.Font.Gotham
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = MainFrame

-- Progress Bar Background
local ProgressBG = Instance.new("Frame")
ProgressBG.Size = UDim2.new(1, -40, 0, 8)
ProgressBG.Position = UDim2.new(0, 20, 0, 120)
ProgressBG.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ProgressBG.BorderSizePixel = 0
ProgressBG.Parent = MainFrame

local ProgressCorner = Instance.new("UICorner")
ProgressCorner.CornerRadius = UDim.new(0, 4)
ProgressCorner.Parent = ProgressBG

-- Progress Bar Fill
local ProgressFill = Instance.new("Frame")
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
ProgressFill.BorderSizePixel = 0
ProgressFill.Parent = ProgressBG

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(0, 4)
FillCorner.Parent = ProgressFill

-- Version Text
local VersionText = Instance.new("TextLabel")
VersionText.Size = UDim2.new(1, 0, 0, 30)
VersionText.Position = UDim2.new(0, 0, 1, -40)
VersionText.BackgroundTransparency = 1
VersionText.Text = "v8.0 Diamond | Loading..."
VersionText.TextColor3 = Color3.fromRGB(150, 150, 150)
VersionText.TextSize = 12
VersionText.Font = Enum.Font.Gotham
VersionText.Parent = MainFrame

-- ════════════════════════════════════════════════════════════
-- FUNÇÕES DE LOADING
-- ════════════════════════════════════════════════════════════

local function UpdateProgress(percent, text)
    StatusText.Text = text
    ProgressFill:TweenSize(
        UDim2.new(percent, 0, 1, 0),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Quad,
        0.3,
        true
    )
    task.wait(0.3)
end

local function ShowError(errorMsg)
    StatusText.Text = "❌ Error: " .. errorMsg
    StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
    ProgressFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    task.wait(3)
    LoadingUI:Destroy()
end

-- ════════════════════════════════════════════════════════════
-- PROCESSO DE LOADING
-- ════════════════════════════════════════════════════════════

UpdateProgress(0.1, "🔍 Verificando executor...")
task.wait(0.5)

-- Verificar se o executor suporta as funções necessárias
if not game.HttpGet or not loadstring then
    ShowError("Executor incompatível!")
    return
end

UpdateProgress(0.3, "🌐 Conectando ao servidor...")
task.wait(0.5)

-- URL DO SEU SCRIPT NO GITHUB
local ScriptURL = "https://raw.githubusercontent.com/Gui0494/blox-fruits-delta/main/script.lua"

UpdateProgress(0.5, "📥 Baixando script...")

local success, scriptContent = pcall(function()
    return game:HttpGet(ScriptURL, true)
end)

if not success then
    ShowError("Falha ao baixar o script!")
    return
end

UpdateProgress(0.7, "🔐 Verificando integridade...")
task.wait(0.3)

-- Verificação básica (opcional)
if #scriptContent < 1000 then
    ShowError("Script corrompido ou vazio!")
    return
end

UpdateProgress(0.85, "⚙️ Inicializando sistemas...")
task.wait(0.3)

UpdateProgress(1.0, "✅ Carregado com sucesso!")
task.wait(0.5)

-- ════════════════════════════════════════════════════════════
-- EXECUTAR O SCRIPT
-- ════════════════════════════════════════════════════════════

local executeSuccess, executeError = pcall(function()
    loadstring(scriptContent)()
end)

if not executeSuccess then
    ShowError("Erro ao executar: " .. tostring(executeError))
    return
end

-- Remover UI de loading após 2 segundos
task.wait(2)
LoadingUI:Destroy()

print("✅ Blox Fruits Diamond v8.0 carregado com sucesso!")
