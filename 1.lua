local REPO = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"

local Library = loadstring(game:HttpGet(REPO .. "Library.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local stopped = false
local selling = false
local autoTpEnabled = false
local autoSellEnabled = false

local MAIN_POSITION = Vector3.new(-2580, 11, -1441)
local SELL_POSITION = Vector3.new(-150, 27, -400)

local MAIN_BOUNDS = {
    Min = Vector3.new(-3012, -77, -1705),
    Max = Vector3.new(-2274, 128, -1249),
}

local SELL_BOUNDS = {
    Min = Vector3.new(-162, 11, -411),
    Max = Vector3.new(-142, 34, -388),
}

local TELEPORTS = {
    ["Home beach"] = Vector3.new(-171, 19, -442),
    ["Shipwreck Cove"] = Vector3.new(1386, 19, 47),
    ["Sphinx sands"] = Vector3.new(2555, 31, 1986),
    ["Frozen shores"] = Vector3.new(2187, 22, -2740),
    ["Lava lagoon"] = Vector3.new(-1349, 26, 1140),
    ["Paradise point"] = Vector3.new(-2292, 625, -897),
    ["Tombstone tides"] = Vector3.new(344, 22, 1971),
    ["Ribcage reef"] = Vector3.new(800, 13, -3205),
    ["Galaxy gulf"] = Vector3.new(-8, 2476, -28),
}

local digAreaOriginalSizes = {}
local digArea = nil

pcall(function()
    digArea = workspace.Islands["Halloween Event"].DigAreas
end)

local function getCharacter()
    return LocalPlayer.Character
end

local function getRoot()
    local character = getCharacter()
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function teleport(position)
    local root = getRoot()
    if not root then
        return false
    end

    root.CFrame = CFrame.new(position)
    return true
end

local function isInsideBounds(position, bounds)
    return position.X >= bounds.Min.X
        and position.X <= bounds.Max.X
        and position.Y >= bounds.Min.Y
        and position.Y <= bounds.Max.Y
        and position.Z >= bounds.Min.Z
        and position.Z <= bounds.Max.Z
end

local function updateDigAreaSizes(enabled)
    if not digArea then
        return
    end

    if enabled then
        for _, object in ipairs(digArea:GetDescendants()) do
            if object:IsA("BasePart") then
                if not digAreaOriginalSizes[object] then
                    digAreaOriginalSizes[object] = object.Size
                end

                local originalSize = digAreaOriginalSizes[object]
                pcall(function()
                    object.Size = originalSize * 10
                end)
            end
        end
    else
        for object, originalSize in pairs(digAreaOriginalSizes) do
            if object and object.Parent then
                pcall(function()
                    object.Size = originalSize
                end)
            end
        end
    end
end

local function getInventoryCount()
    local candidates = {
        PlayerGui:FindFirstChild("Inventory"),
        PlayerGui:FindFirstChild("Main"),
        PlayerGui:FindFirstChild("HUD"),
    }

    for _, gui in ipairs(candidates) do
        if gui then
            for _, object in ipairs(gui:GetDescendants()) do
                if object:IsA("TextLabel") or object:IsA("TextButton") then
                    local text = object.Text
                    local number = text:match("[Ii]nventory%s*[:%(]?%s*(%d+)")
                        or text:match("(%d+)%s*/%s*50")

                    if number then
                        return tonumber(number)
                    end
                end
            end
        end
    end

    for _, object in ipairs(PlayerGui:GetDescendants()) do
        if object:IsA("TextLabel") or object:IsA("TextButton") then
            local text = object.Text
            local number = text:match("[Ii]nventory%s*[:%(]?%s*(%d+)")
                or text:match("(%d+)%s*/%s*50")

            if number then
                return tonumber(number)
            end
        end
    end

    return 0
end

local function activateGuiButton(button)
    if not button or not button:IsA("GuiButton") then
        return false
    end

    local fired = false

    if typeof(firesignal) == "function" then
        local ok = pcall(function()
            firesignal(button.Activated)
        end)

        fired = ok
    end

    if not fired then
        local ok = pcall(function()
            button:Activate()
        end)

        fired = ok
    end

    if not fired then
        pcall(function()
            if typeof(mouse1click) == "function" then
                local position = button.AbsolutePosition + button.AbsoluteSize / 2
                mouse1click(position.X, position.Y)
                fired = true
            end
        end)
    end

    return fired
end

local function pressInteract()
    local prompt

    pcall(function()
        local seller = workspace.Islands["Home Beach"].NPCs.Sell.SellerNPC
        local root = seller:FindFirstChild("HumanoidRootPart")
        if root then
            prompt = root:FindFirstChildOfClass("ProximityPrompt")
        end
    end)

    if prompt and prompt.Enabled then
        if typeof(fireproximityprompt) == "function" then
            local ok = pcall(function()
                fireproximityprompt(prompt)
            end)

            if ok then
                return true
            end
        end
    end

    local promptGui = PlayerGui:FindFirstChild("ProximityPrompts")
    local defaultPrompt = promptGui and promptGui:FindFirstChild("Default")
    local button = defaultPrompt and defaultPrompt:FindFirstChild("TextButton")

    if button then
        return activateGuiButton(button)
    end

    warn("[Island Helper] Could not find the seller interaction button.")
    return false
end

local function pressDialogueOption(optionName)
    local dialogue = PlayerGui:FindFirstChild("DialogueOptions")
    local frame = dialogue and dialogue:FindFirstChild("Frame")
    local button = frame and frame:FindFirstChild(optionName)

    if button and button:IsA("GuiButton") then
        return activateGuiButton(button)
    end

    warn("[Island Helper] Could not find dialogue option:", optionName)
    return false
end

local function runSellMacro()
    if selling or stopped then
        return
    end

    selling = true

    local wasAutoTpEnabled = autoTpEnabled
    local startingCount = getInventoryCount()

    local ok, err = pcall(function()
        updateDigAreaSizes(false)

        teleport(SELL_POSITION)
        task.wait(1)

        -- Interact with the seller first.
        pressInteract()
        task.wait(1.2)

        -- Correct dialogue order: Option2, then Option1.
        pressDialogueOption("Option2")
        task.wait(1)

        pressDialogueOption("Option1")
        task.wait(0.7)

        -- Wait briefly for the inventory count to change.
        local deadline = os.clock() + 5

        while not stopped and os.clock() < deadline do
            task.wait(0.25)

            if getInventoryCount() ~= startingCount then
                break
            end
        end
    end)

    if not ok then
        warn("[Island Helper] Sell macro error:", err)
    end

    if wasAutoTpEnabled and autoTpEnabled and not stopped then
        teleport(MAIN_POSITION)
    end

    updateDigAreaSizes(autoTpEnabled)
    selling = false
end

local Window = Library:CreateWindow({
    Title = "Island Helper",
    Footer = "Auto TP / Auto Sell",
    NotifySide = "Right",
    ShowCustomCursor = false,
})

local Tabs = {
    Main = Window:AddTab("Main", "house"),
    Teleports = Window:AddTab("Teleports", "map-pin"),
    Settings = Window:AddTab("Settings", "settings"),
}

local AutomationGroup = Tabs.Main:AddGroupbox({
    Side = "Left",
    Name = "Automation",
})

AutomationGroup:AddToggle("AutoTP", {
    Text = "Auto TP",
    Default = false,
    Callback = function(value)
        autoTpEnabled = value
        updateDigAreaSizes(value)

        if value and not selling then
            teleport(MAIN_POSITION)
        end
    end,
})

AutomationGroup:AddToggle("AutoSell", {
    Text = "Auto Sell",
    Default = false,
    Callback = function(value)
        autoSellEnabled = value
    end,
})

AutomationGroup:AddButton({
    Text = "Sell Now",
    Func = function()
        task.spawn(runSellMacro)
    end,
})

AutomationGroup:AddLabel("Auto Sell triggers at inventory count 50.")

local TeleportGroup = Tabs.Teleports:AddGroupbox({
    Side = "Left",
    Name = "Island Teleports",
})

local teleportNames = {}

for name in pairs(TELEPORTS) do
    table.insert(teleportNames, name)
end

table.sort(teleportNames)

TeleportGroup:AddDropdown("IslandTeleport", {
    Values = teleportNames,
    Default = teleportNames[1],
    Text = "Select Island",
    Callback = function(value)
        local position = TELEPORTS[value]
        if position then
            teleport(position)
        end
    end,
})

TeleportGroup:AddButton({
    Text = "Teleport to Main Area",
    Func = function()
        teleport(MAIN_POSITION)
    end,
})

TeleportGroup:AddButton({
    Text = "Teleport to Sell Area",
    Func = function()
        teleport(SELL_POSITION)
    end,
})

local SettingsGroup = Tabs.Settings:AddGroupbox({
    Side = "Left",
    Name = "Settings",
})

SettingsGroup:AddButton({
    Text = "Restore Dig Area Sizes",
    Func = function()
        updateDigAreaSizes(false)
    end,
})

SettingsGroup:AddButton({
    Text = "Reapply Dig Area Sizes",
    Func = function()
        updateDigAreaSizes(autoTpEnabled)
    end,
})

task.spawn(function()
    while not stopped do
        task.wait(0.25)

        if autoSellEnabled and not selling then
            local count = getInventoryCount()

            if count >= 50 then
                task.spawn(runSellMacro)
            end
        end
    end
end)

task.spawn(function()
    while not stopped do
        task.wait(0.5)

        if autoTpEnabled and not selling then
            local root = getRoot()

            if root then
                local position = root.Position

                if not isInsideBounds(position, MAIN_BOUNDS)
                    and not isInsideBounds(position, SELL_BOUNDS) then
                    teleport(MAIN_POSITION)
                end
            end

            updateDigAreaSizes(true)
        end
    end
end)

Library:OnUnload(function()
    stopped = true
    autoTpEnabled = false
    autoSellEnabled = false
    updateDigAreaSizes(false)
end)
