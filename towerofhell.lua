-- Tower of Hell Cheat Menu
-- LocalScript in StarterPlayer/StarterPlayerScripts
-- god mode / infinite jump / fly

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Character, Humanoid, RootPart

-- ============ STATE ============
local state = {
    godMode = false,
    infiniteJump = false,
    fly = false,
}

local flySpeed = 60
local flyConn, godConn, jumpConn
local flyBodyVelocity, flyBodyGyro

-- ============ CHARACTER TRACKING ============
local function bindCharacter(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    RootPart = char:WaitForChild("HumanoidRootPart")

    Humanoid.BreakJointsOnDeath = false
    Humanoid.HealthChanged:Connect(function(h)
        if state.godMode and h < Humanoid.MaxHealth then
            Humanoid.Health = Humanoid.MaxHealth
        end
    end)
end

if LocalPlayer.Character then
    bindCharacter(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(bindCharacter)

-- ============ GOD MODE ============
local function setGodMode(on)
    state.godMode = on
    if godConn then godConn:Disconnect() godConn = nil end
    if not on or not Humanoid then return end

    Humanoid.MaxHealth = math.huge
    Humanoid.Health = math.huge

    godConn = RunService.Heartbeat:Connect(function()
        if not Humanoid or not Humanoid.Parent then return end
        if Humanoid.Health < Humanoid.MaxHealth then
            Humanoid.Health = Humanoid.MaxHealth
        end
    end)
end

-- ============ INFINITE JUMP ============
local function setInfiniteJump(on)
    state.infiniteJump = on
    if jumpConn then jumpConn:Disconnect() jumpConn = nil end
    if not on then return end

    jumpConn = UserInputService.JumpRequest:Connect(function()
        if state.infiniteJump and Humanoid and Humanoid.Parent then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

-- ============ FLY ============
local function startFly()
    if not RootPart or not Humanoid then return end

    Humanoid.PlatformStand = true

    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyBodyVelocity.Velocity = Vector3.zero
    flyBodyVelocity.Parent = RootPart

    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    flyBodyGyro.P = 9e4
    flyBodyGyro.CFrame = RootPart.CFrame
    flyBodyGyro.Parent = RootPart

    local camera = workspace.CurrentCamera

    flyConn = RunService.RenderStepped:Connect(function()
        if not RootPart or not RootPart.Parent then return end

        local moveDir = Vector3.zero
        local camCF = camera.CFrame

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + camCF.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - camCF.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - camCF.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + camCF.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDir = moveDir + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDir = moveDir - Vector3.new(0, 1, 0)
        end

        if moveDir.Magnitude > 0 then
            flyBodyVelocity.Velocity = moveDir.Unit * flySpeed
        else
            flyBodyVelocity.Velocity = Vector3.zero
        end

        flyBodyGyro.CFrame = camCF
    end)
end

local function stopFly()
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
    if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
    if Humanoid then Humanoid.PlatformStand = false end
end

local function setFly(on)
    state.fly = on
    if on then startFly() else stopFly() end
end

-- ============ GUI ============
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UserTeamMenu"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 220)
frame.Position = UDim2.new(0, 20, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

-- ---- Title bar ----
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
titleBar.BorderSizePixel = 0
titleBar.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

-- cover bottom corners of the title bar with a flat strip
local titleStrip = Instance.new("Frame")
titleStrip.Size = UDim2.new(1, 0, 0, 8)
titleStrip.Position = UDim2.new(0, 0, 1, -8)
titleStrip.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
titleStrip.BorderSizePixel = 0
titleStrip.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "USER TEAM"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- ---- Minimize button ----
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 24, 0, 24)
minBtn.Position = UDim2.new(1, -56, 0, 4)
minBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
minBtn.BorderSizePixel = 0
minBtn.Text = "–"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 16
minBtn.Parent = titleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minBtn

-- ---- Close button ----
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -28, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

-- ---- Content container (holds buttons so minimize is easy) ----
local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 1, -32)
content.Position = UDim2.new(0, 0, 0, 32)
content.BackgroundTransparency = 1
content.Parent = frame

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 8)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.HorizontalAlignment = Enum.HorizontalAlignment.Center
list.Parent = content

local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 8)
pad.Parent = content

-- ---- Buttons ----
local EXPANDED_SIZE = UDim2.new(0, 200, 0, 220)
local MINIMIZED_SIZE = UDim2.new(0, 200, 0, 32)
local minimized = false

local function setMinimized(value)
    minimized = value
    if value then
        content.Visible = false
        frame.Size = MINIMIZED_SIZE
        minBtn.Text = "+"
    else
        content.Visible = true
        frame.Size = EXPANDED_SIZE
        minBtn.Text = "–"
    end
end

local function makeButton(text, order, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 180, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.BorderSizePixel = 0
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.LayoutOrder = order
    btn.Parent = content

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        local newState = not (btn.Text:find("ON") ~= nil)
        callback(newState)
        btn.Text = text .. (newState and ": ON" or ": OFF")
        btn.BackgroundColor3 = newState
            and Color3.fromRGB(60, 140, 60)
            or Color3.fromRGB(45, 45, 45)
    end)

    return btn
end

makeButton("GOD MODE", 1, setGodMode)
makeButton("INFINITE JUMP", 2, setInfiniteJump)
makeButton("FLY", 3, setFly)

-- ---- Button wiring ----
minBtn.MouseButton1Click:Connect(function()
    setMinimized(not minimized)
end)

closeBtn.MouseButton1Click:Connect(function()
    setGodMode(false)
    setInfiniteJump(false)
    setFly(false)
    screenGui:Destroy()
end)

-- ============ CLEANUP ============
LocalPlayer.CharacterAdded:Connect(function()
    if state.fly then setFly(false) end
end)
