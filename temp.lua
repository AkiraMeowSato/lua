-- =========================================================
-- A&H Hub - Version 1.1
-- Integrated Soft Coffee UI & ESP Library
-- =========================================================

local AHHub = {
    Version = "1.1",
    Name = "A&H Hub"
}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- =========================================================
-- CONSTANTS & COMPATIBILITY
-- =========================================================
local uiAnimationIntensity = 100

local function animationDuration(duration)
    local intensity = math.clamp(tonumber(uiAnimationIntensity) or 100, 25, 150)
    return math.max(0, (tonumber(duration) or 0) * (100 / intensity))
end

-- =========================================================
-- THEME CONFIGURATION (SOFT COFFEE THEME)
-- =========================================================
local UIThemeState = {
    name = "Soft Coffee",
    colors = {
        bg = Color3.fromRGB(34, 29, 27),
        panel = Color3.fromRGB(44, 38, 35),
        card = Color3.fromRGB(56, 48, 44),
        accent = Color3.fromRGB(198, 156, 109),
        text = Color3.fromRGB(240, 230, 220),
        muted = Color3.fromRGB(160, 145, 135),
        hover = Color3.fromRGB(70, 60, 55),
        active = Color3.fromRGB(85, 72, 66),
        divider = Color3.fromRGB(80, 68, 62),
    }
}

-- User Info Handling
local userinfo = {}
pcall(function()
    if readfile and isfile and isfile("ahhub_info.txt") then
        userinfo = HttpService:JSONDecode(readfile("ahhub_info.txt"))
    end
end)

AHHub.UserInfo = {
    pfp = userinfo["pfp"] or "https://www.roblox.com/headshot-thumbnail/image?userId=".. LocalPlayer.UserId .."&width=420&height=420&format=png",
    user = userinfo["user"] or LocalPlayer.Name,
    tag = userinfo["tag"] or tostring(math.random(1000, 9999))
}

function AHHub:SaveInfo()
    if writefile then
        writefile("ahhub_info.txt", HttpService:JSONEncode(self.UserInfo))
    end
end

-- =========================================================
-- ESP & FEATURE ENGINE
-- =========================================================
AHHub.ESPState = {
    Boxes = false,
    Names = false,
    Tracer = false,
    Distance = false,
    TeamCheck = false,
    Color = UIThemeState.colors.accent,
}

local ESPObjects = {}

local function createESP(plr)
    if plr == LocalPlayer then return end
    local drawings = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Tracer = Drawing.new("Line")
    }

    drawings.Box.Visible = false
    drawings.Box.Thickness = 1.5
    drawings.Box.Filled = false

    drawings.Name.Visible = false
    drawings.Name.Center = true
    drawings.Name.Outline = true
    drawings.Name.Size = 14

    drawings.Distance.Visible = false
    drawings.Distance.Center = true
    drawings.Distance.Outline = true
    drawings.Distance.Size = 12

    drawings.Tracer.Visible = false
    drawings.Tracer.Thickness = 1

    ESPObjects[plr] = drawings
end

local function removeESP(plr)
    if ESPObjects[plr] then
        for _, drawing in pairs(ESPObjects[plr]) do
            pcall(function() drawing:Remove() end)
        end
        ESPObjects[plr] = nil
    end
end

for _, plr in ipairs(Players:GetPlayers()) do createESP(plr) end
Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

RunService.RenderStepped:Connect(function()
    for plr, drawings in pairs(ESPObjects) do
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")

        if char and hrp and hum and hum.Health > 0 then
            if AHHub.ESPState.TeamCheck and plr.Team == LocalPlayer.Team then
                drawings.Box.Visible = false
                drawings.Name.Visible = false
                drawings.Distance.Visible = false
                drawings.Tracer.Visible = false
                continue
            end

            local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)

            if onScreen then
                local head = char:FindFirstChild("Head")
                local headPos = head and Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0)) or vector
                local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))

                local height = math.abs(headPos.Y - legPos.Y)
                local width = height / 2

                -- Box ESP
                if AHHub.ESPState.Boxes then
                    drawings.Box.Size = Vector2.new(width, height)
                    drawings.Box.Position = Vector2.new(vector.X - width / 2, vector.Y - height / 2)
                    drawings.Box.Color = AHHub.ESPState.Color
                    drawings.Box.Visible = true
                else
                    drawings.Box.Visible = false
                end

                -- Name ESP
                if AHHub.ESPState.Names then
                    drawings.Name.Text = plr.Name
                    drawings.Name.Position = Vector2.new(vector.X, vector.Y - height / 2 - 16)
                    drawings.Name.Color = AHHub.ESPState.Color
                    drawings.Name.Visible = true
                else
                    drawings.Name.Visible = false
                end

                -- Distance ESP
                if AHHub.ESPState.Distance then
                    local dist = math.floor((LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude) or 0)
                    drawings.Distance.Text = "[" .. tostring(dist) .. "m]"
                    drawings.Distance.Position = Vector2.new(vector.X, vector.Y + height / 2 + 2)
                    drawings.Distance.Color = UIThemeState.colors.muted
                    drawings.Distance.Visible = true
                else
                    drawings.Distance.Visible = false
                end

                -- Tracer ESP
                if AHHub.ESPState.Tracer then
                    drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    drawings.Tracer.To = Vector2.new(vector.X, vector.Y)
                    drawings.Tracer.Color = AHHub.ESPState.Color
                    drawings.Tracer.Visible = true
                else
                    drawings.Tracer.Visible = false
                end
            else
                drawings.Box.Visible = false
                drawings.Name.Visible = false
                drawings.Distance.Visible = false
                drawings.Tracer.Visible = false
            end
        else
            drawings.Box.Visible = false
            drawings.Name.Visible = false
            drawings.Distance.Visible = false
            drawings.Tracer.Visible = false
        end
    end
end)

-- Dragging Mechanics
local function MakeDraggable(topbarobject, object)
    local dragging, dragStart, startOffset = false, nil, nil
    local targetOffset = Vector2.zero

    local function clampOffset(offset)
        local viewport = Camera.ViewportSize
        local halfW, halfH = object.AbsoluteSize.X * 0.5, object.AbsoluteSize.Y * 0.5
        local maxX = math.max(0, viewport.X * 0.5 - halfW - 8)
        local maxY = math.max(0, viewport.Y * 0.5 - halfH - 8)
        return Vector2.new(math.clamp(offset.X, -maxX, maxX), math.clamp(offset.Y, -maxY, maxY))
    end

    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startOffset = clampOffset(Vector2.new(object.Position.X.Offset, object.Position.Y.Offset))
            targetOffset = startOffset
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = Vector2.new(input.Position.X - dragStart.X, input.Position.Y - dragStart.Y)
            targetOffset = clampOffset(startOffset + delta)
        end
    end)

    RunService.RenderStepped:Connect(function(dt)
        if dragging and object and object.Parent then
            local current = clampOffset(Vector2.new(object.Position.X.Offset, object.Position.Y.Offset))
            local alpha = 1 - math.exp(-math.min(math.max(dt, 0), 0.05) * 22)
            local nextOffset = current:Lerp(clampOffset(targetOffset), alpha)
            object.Position = UDim2.new(0.5, nextOffset.X, 0.5, nextOffset.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- GUI Setup
local function getGuiParent()
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then return hui end
    return CoreGui
end

local GUI_PARENT = getGuiParent()
local existingHub = GUI_PARENT:FindFirstChild("AHHub_UI")
if existingHub then pcall(function() existingHub:Destroy() end) end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AHHub_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = GUI_PARENT
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

function AHHub:Window(text)
    local MainFrame = Instance.new("Frame")
    local TopFrame = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local CloseBtn = Instance.new("TextButton")

    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = UIThemeState.colors.bg
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(0, 681, 0, 396)

    TopFrame.Name = "TopFrame"
    TopFrame.Parent = MainFrame
    TopFrame.BackgroundColor3 = UIThemeState.colors.panel
    TopFrame.BorderSizePixel = 0
    TopFrame.Size = UDim2.new(1, 0, 0, 26)

    Title.Name = "Title"
    Title.Parent = TopFrame
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.Font = Enum.Font.GothamSemibold
    Title.Text = (text or self.Name) .. "  v" .. self.Version
    Title.TextColor3 = UIThemeState.colors.text
    Title.TextSize = 12
    Title.TextXAlignment = Enum.TextXAlignment.Left

    CloseBtn.Name = "CloseBtn"
    CloseBtn.Parent = TopFrame
    CloseBtn.BackgroundColor3 = UIThemeState.colors.panel
    CloseBtn.Position = UDim2.new(1, -28, 0, 0)
    CloseBtn.Size = UDim2.new(0, 28, 1, 0)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = UIThemeState.colors.text
    CloseBtn.BorderSizePixel = 0

    CloseBtn.MouseButton1Click:Connect(function()
        for plr, _ in pairs(ESPObjects) do removeESP(plr) end
        ScreenGui:Destroy()
    end)

    MakeDraggable(TopFrame, MainFrame)

    return {
        SetESPBox = function(self, state) AHHub.ESPState.Boxes = state end,
        SetESPName = function(self, state) AHHub.ESPState.Names = state end,
        SetESPDistance = function(self, state) AHHub.ESPState.Distance = state end,
        SetESPTracer = function(self, state) AHHub.ESPState.Tracer = state end,
        SetESPTeamCheck = function(self, state) AHHub.ESPState.TeamCheck = state end,
    }
end

return AHHub
