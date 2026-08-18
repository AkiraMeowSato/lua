-- =========================================================
-- A&H HUB v1.1 - LUA UI LIBRARY
-- Features: Soft Animations, Window Controls, Dashboard Layout
-- =========================================================

local AHHubLib = {
    Version = "1.1",
    Author = "Nyrae",
    Title = "A&H HUB"
}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

-- Theme Palette
local Theme = {
    Bg = Color3.fromRGB(18, 12, 10),
    Sidebar = Color3.fromRGB(22, 15, 12),
    CardBg = Color3.fromRGB(28, 20, 16),
    CardBorder = Color3.fromRGB(48, 34, 28),
    TitleBar = Color3.fromRGB(28, 18, 14),
    
    TextBright = Color3.fromRGB(255, 255, 255),
    TextMain = Color3.fromRGB(220, 200, 180),
    TextMuted = Color3.fromRGB(140, 115, 100),
    
    OrangeAccent = Color3.fromRGB(225, 112, 28),
    GreenStatus = Color3.fromRGB(76, 217, 100),
    SearchBg = Color3.fromRGB(32, 22, 18),
    TabSelected = Color3.fromRGB(40, 26, 20)
}

-- UI Parent Helper
local function getGuiParent()
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then return hui end
    return LocalPlayer:WaitForChild("PlayerGui")
end

-- Smooth Tween Helper
local function Tween(object, info, properties)
    local anim = TweenService:Create(object, info, properties)
    anim:Play()
    return anim
end

-- Dragging System
local function MakeDraggable(dragHandle, frame)
    local dragging, dragStart, startPos = false, nil, nil
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Tween(frame, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            })
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- =========================================================
-- WINDOW CREATION
-- =========================================================
function AHHubLib:CreateWindow()
    local ParentGui = getGuiParent()
    local ExistingUI = ParentGui:FindFirstChild("AHHub_Dashboard")
    if ExistingUI then ExistingUI:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AHHub_Dashboard"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = ParentGui

    -- Main Frame
    local Window = Instance.new("Frame")
    Window.Name = "MainWindow"
    Window.Size = UDim2.new(0, 920, 0, 540)
    Window.Position = UDim2.new(0.5, -460, 0.5, -270)
    Window.BackgroundColor3 = Theme.Bg
    Window.BorderSizePixel = 0
    Window.ClipsDescendants = true
    Window.Parent = ScreenGui

    local WindowCorner = Instance.new("UICorner")
    WindowCorner.CornerRadius = UDim.new(0, 8)
    WindowCorner.Parent = Window

    -- Opening Animation (Fade & Scale In)
    Window.Size = UDim2.new(0, 0, 0, 0)
    Window.Position = UDim2.new(0.5, 0, 0.5, 0)
    Tween(Window, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 920, 0, 540),
        Position = UDim2.new(0.5, -460, 0.5, -270)
    })

    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = Theme.TitleBar
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = Window

    local TitleBarCorner = Instance.new("UICorner")
    TitleBarCorner.CornerRadius = UDim.new(0, 8)
    TitleBarCorner.Parent = TitleBar

    MakeDraggable(TitleBar, Window)

    -- Window Control Buttons Container (Close, Minimize, Maximize)
    local DotsHolder = Instance.new("Frame")
    DotsHolder.Size = UDim2.new(0, 60, 1, 0)
    DotsHolder.Position = UDim2.new(0, 10, 0, 0)
    DotsHolder.BackgroundTransparency = 1
    DotsHolder.Parent = TitleBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 12, 0, 12)
    CloseBtn.Position = UDim2.new(0, 0, 0.5, -6)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 95, 86)
    CloseBtn.Text = ""
    CloseBtn.AutoButtonColor = false
    CloseBtn.Parent = DotsHolder
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)

    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 12, 0, 12)
    MinimizeBtn.Position = UDim2.new(0, 18, 0.5, -6)
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 189, 46)
    MinimizeBtn.Text = ""
    MinimizeBtn.AutoButtonColor = false
    MinimizeBtn.Parent = DotsHolder
    Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(1, 0)

    local MaximizeBtn = Instance.new("TextButton")
    MaximizeBtn.Size = UDim2.new(0, 12, 0, 12)
    MaximizeBtn.Position = UDim2.new(0, 36, 0.5, -6)
    MaximizeBtn.BackgroundColor3 = Color3.fromRGB(39, 201, 63)
    MaximizeBtn.Text = ""
    MaximizeBtn.AutoButtonColor = false
    MaximizeBtn.Parent = DotsHolder
    Instance.new("UICorner", MaximizeBtn).CornerRadius = UDim.new(1, 0)

    -- Window Title
    local WindowTitle = Instance.new("TextLabel")
    WindowTitle.Size = UDim2.new(0, 200, 1, 0)
    WindowTitle.Position = UDim2.new(0, 60, 0, 0)
    WindowTitle.BackgroundTransparency = 1
    WindowTitle.Font = Enum.Font.GothamBold
    WindowTitle.Text = self.Title .. "  •  " .. self.Version
    WindowTitle.TextColor3 = Theme.TextMain
    WindowTitle.TextSize = 12
    WindowTitle.TextXAlignment = Enum.TextXAlignment.Left
    WindowTitle.Parent = TitleBar

    -- Sidebar Area
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 140, 1, -30)
    Sidebar.Position = UDim2.new(0, 0, 0, 30)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Window

    local HubBrand = Instance.new("TextLabel")
    HubBrand.Position = UDim2.new(0, 16, 0, 15)
    HubBrand.Size = UDim2.new(1, -16, 0, 18)
    HubBrand.BackgroundTransparency = 1
    HubBrand.Font = Enum.Font.GothamBold
    HubBrand.Text = "A&H HUB"
    HubBrand.TextColor3 = Theme.OrangeAccent
    HubBrand.TextSize = 16
    HubBrand.TextXAlignment = Enum.TextXAlignment.Left
    HubBrand.Parent = Sidebar

    local HubSub = Instance.new("TextLabel")
    HubSub.Position = UDim2.new(0, 16, 0, 33)
    HubSub.Size = UDim2.new(1, -16, 0, 12)
    HubSub.BackgroundTransparency = 1
    HubSub.Font = Enum.Font.GothamBold
    HubSub.Text = "ACCOUNT MONITOR"
    HubSub.TextColor3 = Theme.TextMuted
    HubSub.TextSize = 9
    HubSub.TextXAlignment = Enum.TextXAlignment.Left
    HubSub.Parent = Sidebar

    local NavHolder = Instance.new("Frame")
    NavHolder.Position = UDim2.new(0, 8, 0, 60)
    NavHolder.Size = UDim2.new(1, -16, 1, -90)
    NavHolder.BackgroundTransparency = 1
    NavHolder.Parent = Sidebar

    local NavLayout = Instance.new("UIListLayout")
    NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NavLayout.Padding = UDim.new(0, 4)
    NavLayout.Parent = NavHolder

    local Footer = Instance.new("TextLabel")
    Footer.Position = UDim2.new(0, 12, 1, -20)
    Footer.Size = UDim2.new(1, -12, 0, 14)
    Footer.BackgroundTransparency = 1
    Footer.Font = Enum.Font.GothamMedium
    Footer.Text = "v" .. self.Version .. " • " .. self.Author
    Footer.TextColor3 = Theme.TextMuted
    Footer.TextSize = 11
    Footer.TextXAlignment = Enum.TextXAlignment.Left
    Footer.Parent = Sidebar

    -- Main Content View Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -150, 1, -40)
    ContentContainer.Position = UDim2.new(0, 145, 0, 35)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = Window

    -- =========================================================
    -- WINDOW BUTTON ACTIONS (CLOSE, MINIMIZE, MAXIMIZE)
    -- =========================================================
    local isMinimized = false
    local isMaximized = false
    local originalSize = UDim2.new(0, 920, 0, 540)
    local originalPos = UDim2.new(0.5, -460, 0.5, -270)

    -- Close Action (Shrink & Destroy)
    CloseBtn.MouseButton1Click:Connect(function()
        local anim = Tween(Window, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(Window.Position.X.Scale, Window.Position.X.Offset + (Window.Size.X.Offset / 2), Window.Position.Y.Scale, Window.Position.Y.Offset + (Window.Size.Y.Offset / 2))
        })
        anim.Completed:Connect(function()
            ScreenGui:Destroy()
        end)
    end)

    -- Minimize Action (Collapses to TitleBar only)
    MinimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            Tween(Window, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, Window.Size.X.Offset, 0, 30)
            })
        else
            Tween(Window, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = isMaximized and UDim2.new(1, 0, 1, 0) or originalSize
            })
        end
    end)

    -- Maximize Action (Toggles Fullscreen)
    MaximizeBtn.MouseButton1Click:Connect(function()
        if isMinimized then return end
        isMaximized = not isMaximized
        if isMaximized then
            originalPos = Window.Position
            originalSize = Window.Size
            Tween(Window, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0)
            })
        else
            Tween(Window, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = originalSize,
                Position = originalPos
            })
        end
    end)

    -- Window Button Hover Visual Feedback
    local function AddDotHover(btn, colorNormal, colorHover)
        btn.MouseEnter:Connect(function() Tween(btn, TweenInfo.new(0.15), {BackgroundColor3 = colorHover}) end)
        btn.MouseLeave:Connect(function() Tween(btn, TweenInfo.new(0.15), {BackgroundColor3 = colorNormal}) end)
    end
    AddDotHover(CloseBtn, Color3.fromRGB(255, 95, 86), Color3.fromRGB(200, 60, 50))
    AddDotHover(MinimizeBtn, Color3.fromRGB(255, 189, 46), Color3.fromRGB(200, 140, 30))
    AddDotHover(MaximizeBtn, Color3.fromRGB(39, 201, 63), Color3.fromRGB(20, 150, 40))

    -- Controller Return
    local Controller = {
        CurrentTabBtn = nil,
        Pages = {}
    }

    function Controller:AddTab(tabName)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = tabName .. "_Tab"
        TabBtn.Size = UDim2.new(1, 0, 0, 28)
        TabBtn.BackgroundColor3 = Theme.Sidebar
        TabBtn.BorderSizePixel = 0
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.Text = "   " .. tabName
        TabBtn.TextColor3 = Theme.TextMuted
        TabBtn.TextSize = 12
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.Parent = NavHolder

        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabBtn

        local PageView = Instance.new("ScrollingFrame")
        PageView.Name = tabName .. "_Page"
        PageView.Size = UDim2.new(1, 0, 1, 0)
        PageView.BackgroundTransparency = 1
        PageView.Visible = false
        PageView.ScrollBarThickness = 2
        PageView.ScrollBarImageColor3 = Theme.OrangeAccent
        PageView.Parent = ContentContainer

        self.Pages[tabName] = PageView

        -- Animated Tab Switching
        TabBtn.MouseButton1Click:Connect(function()
            for name, page in pairs(self.Pages) do
                page.Visible = false
            end
            for _, btn in ipairs(NavHolder:GetChildren()) do
                if btn:IsA("TextButton") then
                    Tween(btn, TweenInfo.new(0.15), {
                        BackgroundColor3 = Theme.Sidebar,
                        TextColor3 = Theme.TextMuted
                    })
                end
            end
            
            PageView.Visible = true
            PageView.Position = UDim2.new(0, 10, 0, 0)
            Tween(PageView, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 0, 0, 0)
            })

            Tween(TabBtn, TweenInfo.new(0.15), {
                BackgroundColor3 = Theme.TabSelected,
                TextColor3 = Theme.TextBright
            })
        end)

        -- Default First Tab Selection
        if not self.CurrentTabBtn then
            self.CurrentTabBtn = TabBtn
            PageView.Visible = true
            TabBtn.BackgroundColor3 = Theme.TabSelected
            TabBtn.TextColor3 = Theme.TextBright
        end

        return PageView
    end

    return Controller
end

return AHHubLib
