-- =========================================================================
-- A&H HUB v1.9.9 - ULTIMATE COMPREHENSIVE TEST & LIBRARY SCRIPT
-- =========================================================================

local AHHubLib = {
    Version = "1.9.9",
    Author = "Nyrae",
    Title = "A&H HUB",
    Defaults = {}
}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Theme = {
    Bg = Color3.fromRGB(20, 14, 11),
    WindowBg = Color3.fromRGB(28, 20, 16),
    Sidebar = Color3.fromRGB(24, 18, 14),
    CardBg = Color3.fromRGB(42, 32, 26),
    CardBorder = Color3.fromRGB(80, 60, 48),
    TitleBar = Color3.fromRGB(36, 26, 21),
    PopupBg = Color3.fromRGB(55, 42, 35),       
    PopupBtn = Color3.fromRGB(68, 52, 43),      
    PopupBorder = Color3.fromRGB(110, 85, 68),  
    TextBright = Color3.fromRGB(255, 255, 255),
    TextMain = Color3.fromRGB(240, 225, 210),
    TextMuted = Color3.fromRGB(190, 165, 145),
    OrangeAccent = Color3.fromRGB(230, 140, 60),
    TabSelected = Color3.fromRGB(58, 42, 33),
    Disabled = Color3.fromRGB(50, 40, 35),
    RedDanger = Color3.fromRGB(200, 60, 60),
    YellowWarn = Color3.fromRGB(220, 160, 50),
    GreenOk = Color3.fromRGB(60, 180, 80)
}

AHHubLib.Flags = {}
AHHubLib.ToggleCallbacks = {}
AHHubLib.SliderCallbacks = {}
AHHubLib.ColorCallbacks = {}

local function getGuiParent()
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then return hui end
    return CoreGui:FindFirstChild("RobloxGui") or LocalPlayer:WaitForChild("PlayerGui")
end

local function Tween(object, info, properties)
    local anim = TweenService:Create(object, info, properties)
    anim:Play()
    return anim
end

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
            Tween(frame, TweenInfo.new(0.04, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
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

function AHHubLib:CreateWindow()
    local ParentGui = getGuiParent()
    local ExistingUI = ParentGui:FindFirstChild("AHHub_Dashboard")
    if ExistingUI then ExistingUI:Destroy() end

    local ExistingDock = ParentGui:FindFirstChild("AHHub_DockIcon")
    if ExistingDock then ExistingDock:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AHHub_Dashboard"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = ParentGui

    local DefaultSize = UDim2.new(0, 850, 0, 520)
    local DefaultPos = UDim2.new(0.5, -425, 0.5, -260)

    local Window = Instance.new("Frame")
    Window.Name = "MainWindow"
    Window.Size = UDim2.new(0, 0, 0, 0)
    Window.Position = UDim2.new(0.5, 0, 0.5, 0)
    Window.BackgroundColor3 = Theme.WindowBg
    Window.BorderSizePixel = 0
    Window.ClipsDescendants = true
    Window.Parent = ScreenGui
    Instance.new("UICorner", Window).CornerRadius = UDim.new(0, 14)

    Tween(Window, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = DefaultSize,
        Position = DefaultPos
    })

    local DockIcon = Instance.new("TextButton")
    DockIcon.Name = "AHHub_DockIcon"
    DockIcon.Size = UDim2.new(0, 48, 0, 48)
    DockIcon.Position = UDim2.new(1, -64, 1, -64)
    DockIcon.BackgroundColor3 = Theme.Sidebar
    DockIcon.BorderColor3 = Theme.OrangeAccent
    DockIcon.BorderSizePixel = 1
    DockIcon.Font = Enum.Font.GothamBold
    DockIcon.Text = "☕"
    DockIcon.TextSize = 22
    DockIcon.Visible = false
    DockIcon.ZIndex = 600
    DockIcon.Parent = ScreenGui
    Instance.new("UICorner", DockIcon).CornerRadius = UDim.new(1, 0)

    local activePopup = nil
    
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
            if activePopup and activePopup.Parent then
                local mousePos = UserInputService:GetMouseLocation()
                local absPos = activePopup.AbsolutePosition
                local absSize = activePopup.AbsoluteSize
                
                local insidePopup = (mousePos.X >= absPos.X and mousePos.X <= absPos.X + absSize.X and
                                     mousePos.Y >= absPos.Y and mousePos.Y <= absPos.Y + absSize.Y)
                
                if not insidePopup then
                    Tween(activePopup, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)})
                    task.delay(0.15, function() if activePopup then activePopup:Destroy() activePopup = nil end end)
                end
            end
        end
    end)

    local TooltipLabel = Instance.new("TextLabel")
    TooltipLabel.Size = UDim2.new(0, 120, 0, 22)
    TooltipLabel.BackgroundColor3 = Theme.TitleBar
    TooltipLabel.BorderColor3 = Theme.OrangeAccent
    TooltipLabel.BorderSizePixel = 1
    TooltipLabel.Font = Enum.Font.GothamMedium
    TooltipLabel.TextColor3 = Theme.TextBright
    TooltipLabel.TextSize = 11
    TooltipLabel.Visible = false
    TooltipLabel.ZIndex = 900
    TooltipLabel.Parent = ScreenGui
    Instance.new("UICorner", TooltipLabel).CornerRadius = UDim.new(0, 6)

    local function BindTooltip(object, text)
        if not text or text == "" then return end
        object.MouseEnter:Connect(function()
            TooltipLabel.Text = " " .. text .. " "
            TooltipLabel.Size = UDim2.new(0, TooltipLabel.TextBounds.X + 12, 0, 22)
            TooltipLabel.Visible = true
        end)
        object.MouseMoved:Connect(function()
            local mousePos = UserInputService:GetMouseLocation()
            TooltipLabel.Position = UDim2.new(0, mousePos.X + 12, 0, mousePos.Y + 12)
        end)
        object.MouseLeave:Connect(function() TooltipLabel.Visible = false end)
    end

    BindTooltip(DockIcon, "A&H Hub (Click to Restore)")

    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 32)
    TitleBar.BackgroundColor3 = Theme.TitleBar
    TitleBar.BorderSizePixel = 0
    TitleBar.ZIndex = 10
    TitleBar.Parent = Window
    Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 14)
    MakeDraggable(TitleBar, Window)

    local CoffeeLogoBtn = Instance.new("TextButton")
    CoffeeLogoBtn.Size = UDim2.new(0, 24, 0, 24)
    CoffeeLogoBtn.Position = UDim2.new(0, 6, 0.5, -12)
    CoffeeLogoBtn.BackgroundColor3 = Theme.Sidebar
    CoffeeLogoBtn.Font = Enum.Font.GothamBold
    CoffeeLogoBtn.Text = "☕"
    CoffeeLogoBtn.TextSize = 12
    CoffeeLogoBtn.ZIndex = 12
    CoffeeLogoBtn.Parent = TitleBar
    Instance.new("UICorner", CoffeeLogoBtn).CornerRadius = UDim.new(1, 0)
    BindTooltip(CoffeeLogoBtn, "A&H Hub Coffee Icon")

    local WindowTitle = Instance.new("TextLabel")
    WindowTitle.Size = UDim2.new(0, 250, 1, 0)
    WindowTitle.Position = UDim2.new(0, 36, 0, 0)
    WindowTitle.BackgroundTransparency = 1
    WindowTitle.Font = Enum.Font.GothamBold
    WindowTitle.Text = self.Title .. "  •  " .. self.Version
    WindowTitle.TextColor3 = Theme.TextBright
    WindowTitle.TextSize = 12
    WindowTitle.TextXAlignment = Enum.TextXAlignment.Left
    WindowTitle.ZIndex = 11
    WindowTitle.Parent = TitleBar

    local ControlsHolder = Instance.new("Frame")
    ControlsHolder.Size = UDim2.new(0, 75, 0, 32)
    ControlsHolder.Position = UDim2.new(1, -80, 0, 0)
    ControlsHolder.BackgroundTransparency = 1
    ControlsHolder.ZIndex = 15
    ControlsHolder.Parent = TitleBar

    local function MakeCircularButton(color, hoverColor, xPos, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 16, 0, 16)
        btn.Position = UDim2.new(0, xPos, 0.5, -8)
        btn.BackgroundColor3 = color
        btn.Text = ""
        btn.ZIndex = 16
        btn.Parent = ControlsHolder
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

        btn.MouseEnter:Connect(function() Tween(btn, TweenInfo.new(0.15), {BackgroundColor3 = hoverColor, Size = UDim2.new(0, 18, 0, 18)}) end)
        btn.MouseLeave:Connect(function() Tween(btn, TweenInfo.new(0.15), {BackgroundColor3 = color, Size = UDim2.new(0, 16, 0, 16)}) end)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    local isMinimized = false
    local isMaximized = false
    local savedPosition = DefaultPos
    local savedSize = DefaultSize

    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 160, 1, -32)
    Sidebar.Position = UDim2.new(0, 0, 0, 32)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Window

    local ProfileFrame = Instance.new("Frame")
    ProfileFrame.Size = UDim2.new(1, -12, 0, 42)
    ProfileFrame.Position = UDim2.new(0, 6, 1, -48)
    ProfileFrame.BackgroundColor3 = Theme.CardBg
    ProfileFrame.BorderSizePixel = 1
    ProfileFrame.BorderColor3 = Theme.CardBorder
    ProfileFrame.Parent = Sidebar
    Instance.new("UICorner", ProfileFrame).CornerRadius = UDim.new(0, 8)

    local AvatarImg = Instance.new("ImageLabel")
    AvatarImg.Size = UDim2.new(0, 30, 0, 30)
    AvatarImg.Position = UDim2.new(0, 6, 0.5, -15)
    AvatarImg.BackgroundTransparency = 1
    AvatarImg.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    AvatarImg.Parent = ProfileFrame
    Instance.new("UICorner", AvatarImg).CornerRadius = UDim.new(1, 0)

    local UserNameLbl = Instance.new("TextLabel")
    UserNameLbl.Size = UDim2.new(1, -42, 1, 0)
    UserNameLbl.Position = UDim2.new(0, 40, 0, 0)
    UserNameLbl.BackgroundTransparency = 1
    UserNameLbl.Font = Enum.Font.GothamBold
    UserNameLbl.Text = LocalPlayer.DisplayName
    UserNameLbl.TextColor3 = Theme.TextBright
    UserNameLbl.TextSize = 11
    UserNameLbl.TextTruncate = Enum.TextTruncate.AtEnd
    UserNameLbl.TextXAlignment = Enum.TextXAlignment.Left
    UserNameLbl.Parent = ProfileFrame

    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, -170, 1, -32)
    ContentContainer.Position = UDim2.new(0, 165, 0, 32)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = Window

    local ShowConfirmation, ResetToDefaultsAndClose

    ResetToDefaultsAndClose = function()
        for flag, defaultVal in pairs(AHHubLib.Defaults) do
            AHHubLib.Flags[flag] = defaultVal
            if AHHubLib.ToggleCallbacks[flag] then
                pcall(function() AHHubLib.ToggleCallbacks[flag](defaultVal) end)
            end
            if AHHubLib.SliderCallbacks[flag] then
                pcall(function() AHHubLib.SliderCallbacks[flag](defaultVal) end)
            end
            if AHHubLib.ColorCallbacks[flag] then
                pcall(function() AHHubLib.ColorCallbacks[flag](defaultVal) end)
            end
        end
        Tween(Window, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)})
        task.delay(0.25, function() ScreenGui:Destroy() end)
    end

    local function ToggleMinimize()
        isMinimized = not isMinimized
        if isMinimized then
            if not isMaximized then savedSize = Window.Size end
            Sidebar.Visible = false
            ContentContainer.Visible = false
            Tween(Window, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
            task.delay(0.2, function() Window.Visible = false DockIcon.Visible = true end)
        else
            Window.Visible = true
            DockIcon.Visible = false
            Tween(Window, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = isMaximized and UDim2.new(1, 0, 1, 0) or savedSize})
            task.delay(0.1, function() Sidebar.Visible = true ContentContainer.Visible = true end)
        end
    end

    MakeCircularButton(Theme.YellowWarn, Color3.fromRGB(240, 190, 80), 0, ToggleMinimize)
    DockIcon.MouseButton1Click:Connect(ToggleMinimize)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
            ToggleMinimize()
        end
    end)

    MakeCircularButton(Theme.GreenOk, Color3.fromRGB(90, 220, 110), 22, function()
        if isMinimized then return end
        isMaximized = not isMaximized
        if isMaximized then
            savedPosition = Window.Position
            savedSize = Window.Size
            Tween(Window, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, 0, 1, 0)})
            Window.BorderSizePixel = 0
        else
            Tween(Window, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = savedPosition, Size = savedSize})
        end
    end)

    MakeCircularButton(Theme.RedDanger, Color3.fromRGB(240, 80, 80), 44, function()
        ShowConfirmation("Close A&H Hub?", "Are you sure? This will reset all configurations to default and close the hub.", ResetToDefaultsAndClose)
    end)

    local NotificationHolder = Instance.new("Frame")
    NotificationHolder.Size = UDim2.new(0, 260, 1, -40)
    NotificationHolder.Position = UDim2.new(1, -270, 0, 35)
    NotificationHolder.BackgroundTransparency = 1
    NotificationHolder.ZIndex = 500
    NotificationHolder.Parent = ScreenGui

    local NotifLayout = Instance.new("UIListLayout")
    NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    NotifLayout.Padding = UDim.new(0, 8)
    NotifLayout.Parent = NotificationHolder

    function AHHubLib:Notify(title, desc, duration)
        duration = duration or 3
        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(0, 250, 0, 55)
        Card.BackgroundColor3 = Theme.CardBg
        Card.BackgroundTransparency = 0.1
        Card.BorderSizePixel = 1
        Card.BorderColor3 = Theme.OrangeAccent
        Card.ZIndex = 501
        Card.Parent = NotificationHolder
        Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)

        local Txt = Instance.new("TextLabel")
        Txt.Position = UDim2.new(0, 12, 0, 6)
        Txt.Size = UDim2.new(1, -24, 0, 18)
        Txt.BackgroundTransparency = 1
        Txt.Font = Enum.Font.GothamBold
        Txt.Text = "☕ " .. title
        Txt.TextColor3 = Theme.OrangeAccent
        Txt.TextSize = 12
        Txt.TextXAlignment = Enum.TextXAlignment.Left
        Txt.ZIndex = 502
        Txt.Parent = Card

        local Sub = Instance.new("TextLabel")
        Sub.Position = UDim2.new(0, 12, 0, 24)
        Sub.Size = UDim2.new(1, -24, 0, 26)
        Sub.BackgroundTransparency = 1
        Sub.Font = Enum.Font.GothamMedium
        Sub.Text = desc
        Sub.TextColor3 = Theme.TextBright
        Sub.TextSize = 10
        Sub.TextXAlignment = Enum.TextXAlignment.Left
        Sub.TextWrapped = true
        Sub.ZIndex = 502
        Sub.Parent = Card

        task.delay(duration, function()
            if Card and Card.Parent then
                Tween(Card, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {BackgroundTransparency = 1})
                for _, child in ipairs(Card:GetDescendants()) do
                    if child:IsA("TextLabel") then
                        Tween(child, TweenInfo.new(0.3), {TextTransparency = 1})
                    end
                end
                task.delay(0.3, function()
                    if Card and Card.Parent then
                        Card:Destroy()
                    end
                end)
            end
        end)
    end

    ShowConfirmation = function(title, message, onAccept)
        local Overlay = Instance.new("Frame")
        Overlay.Size = UDim2.new(1, 0, 1, 0)
        Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Overlay.BackgroundTransparency = 0.7
        Overlay.ZIndex = 250
        Overlay.Parent = Window

        local Box = Instance.new("Frame")
        Box.Size = UDim2.new(0, 0, 0, 0)
        Box.Position = UDim2.new(0.5, 0, 0.5, 0)
        Box.BackgroundColor3 = Theme.CardBg
        Box.BackgroundTransparency = 0.1
        Box.BorderSizePixel = 1
        Box.BorderColor3 = Theme.RedDanger
        Box.ZIndex = 251
        Box.Parent = Overlay
        Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 10)

        Tween(Box, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 300, 0, 140),
            Position = UDim2.new(0.5, -150, 0.5, -70)
        })

        local T = Instance.new("TextLabel")
        T.Size = UDim2.new(1, 0, 0, 30)
        T.Position = UDim2.new(0, 0, 0, 10)
        T.BackgroundTransparency = 1
        T.Font = Enum.Font.GothamBold
        T.Text = title
        T.TextColor3 = Theme.RedDanger
        T.TextSize = 13
        T.ZIndex = 252
        T.Parent = Box

        local M = Instance.new("TextLabel")
        M.Size = UDim2.new(1, -20, 0, 40)
        M.Position = UDim2.new(0, 10, 0, 40)
        M.BackgroundTransparency = 1
        M.Font = Enum.Font.GothamMedium
        M.Text = message
        M.TextColor3 = Theme.TextBright
        M.TextSize = 11
        M.TextWrapped = true
        M.ZIndex = 252
        M.Parent = Box

        local ConfirmBtn = Instance.new("TextButton")
        ConfirmBtn.Size = UDim2.new(0, 90, 0, 26)
        ConfirmBtn.Position = UDim2.new(0.5, -95, 1, -34)
        ConfirmBtn.BackgroundColor3 = Theme.RedDanger
        ConfirmBtn.Font = Enum.Font.GothamBold
        ConfirmBtn.Text = "Confirm"
        ConfirmBtn.TextColor3 = Theme.TextBright
        ConfirmBtn.TextSize = 10
        ConfirmBtn.ZIndex = 252
        ConfirmBtn.Parent = Box
        Instance.new("UICorner", ConfirmBtn).CornerRadius = UDim.new(0, 6)

        local CancelBtn = Instance.new("TextButton")
        CancelBtn.Size = UDim2.new(0, 90, 0, 26)
        CancelBtn.Position = UDim2.new(0.5, 5, 1, -34)
        CancelBtn.BackgroundColor3 = Theme.Sidebar
        CancelBtn.Font = Enum.Font.GothamBold
        CancelBtn.Text = "Cancel"
        CancelBtn.TextColor3 = Theme.TextMuted
        CancelBtn.TextSize = 10
        CancelBtn.ZIndex = 252
        CancelBtn.Parent = Box
        Instance.new("UICorner", CancelBtn).CornerRadius = UDim.new(0, 6)

        ConfirmBtn.MouseButton1Click:Connect(function() 
            Tween(Box, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5,0,0.5,0)})
            task.delay(0.2, function() Overlay:Destroy() onAccept() end)
        end)
        CancelBtn.MouseButton1Click:Connect(function() 
            Tween(Box, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0), Position = UDim2.new(0.5,0,0.5,0)})
            task.delay(0.2, function() Overlay:Destroy() end)
        end)
    end

    local NavHolder = Instance.new("Frame")
    NavHolder.Position = UDim2.new(0, 8, 0, 6)
    NavHolder.Size = UDim2.new(1, -16, 1, -60)
    NavHolder.BackgroundTransparency = 1
    NavHolder.Parent = Sidebar

    local NavLayout = Instance.new("UIListLayout")
    NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NavLayout.Padding = UDim.new(0, 4)
    NavLayout.Parent = NavHolder

    local WindowObj = {}
    local Controller = { CurrentTabBtn = nil, Pages = {} }

    local function CreateElementBuilder(PageView)
        local Elements = {}

        local function RegisterScrollAutoResize()
            if PageView:IsA("ScrollingFrame") then
                local layout = PageView:FindFirstChildOfClass("UIListLayout")
                if layout then
                    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                        PageView.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 15)
                    end)
                end
            end
        end
        RegisterScrollAutoResize()

        local function CreatePopupElementBuilder(SubPageView)
            local SubElements = {}

            function SubElements:AddButton(text, tooltipText, callback)
                callback = callback or function() end
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, -10, 0, 30)
                Btn.BackgroundColor3 = Theme.PopupBtn
                Btn.BorderSizePixel = 1
                Btn.BorderColor3 = Theme.PopupBorder
                Btn.Font = Enum.Font.GothamMedium
                Btn.Text = text
                Btn.TextColor3 = Theme.TextBright
                Btn.TextSize = 11
                Btn.AutoButtonColor = false
                Btn.ZIndex = 810
                Btn.Parent = SubPageView
                Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
                BindTooltip(Btn, tooltipText)

                Btn.MouseEnter:Connect(function() Tween(Btn, TweenInfo.new(0.12), {BackgroundColor3 = Theme.TabSelected, BorderColor3 = Theme.OrangeAccent}) end)
                Btn.MouseLeave:Connect(function() Tween(Btn, TweenInfo.new(0.12), {BackgroundColor3 = Theme.PopupBtn, BorderColor3 = Theme.PopupBorder}) end)

                Btn.MouseButton1Click:Connect(callback)
                return SubElements
            end

            function SubElements:AddToggle(text, flag, defaultState, tooltipText, callback)
                callback = callback or function() end
                local toggled = defaultState or false
                AHHubLib.Flags[flag] = toggled
                AHHubLib.Defaults[flag] = defaultState
                AHHubLib.ToggleCallbacks[flag] = callback

                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, -10, 0, 30)
                Frame.BackgroundColor3 = Theme.PopupBtn
                Frame.BorderSizePixel = 1
                Frame.BorderColor3 = Theme.PopupBorder
                Frame.ZIndex = 810
                Frame.Parent = SubPageView
                Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
                BindTooltip(Frame, tooltipText)

                local Title = Instance.new("TextLabel")
                Title.Position = UDim2.new(0, 10, 0, 0)
                Title.Size = UDim2.new(0.6, 0, 1, 0)
                Title.BackgroundTransparency = 1
                Title.Font = Enum.Font.GothamMedium
                Title.Text = text
                Title.TextColor3 = Theme.TextBright
                Title.TextSize = 11
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.ZIndex = 811
                Title.Parent = Frame

                local Switch = Instance.new("TextButton")
                Switch.Position = UDim2.new(1, -36, 0.5, -8)
                Switch.Size = UDim2.new(0, 28, 0, 16)
                Switch.BackgroundColor3 = toggled and Theme.OrangeAccent or Theme.Sidebar
                Switch.Text = ""
                Switch.ZIndex = 811
                Switch.Parent = Frame
                Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

                local function setToggle(state)
                    toggled = state
                    AHHubLib.Flags[flag] = toggled
                    Tween(Switch, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = toggled and Theme.OrangeAccent or Theme.Sidebar})
                    callback(toggled)
                end

                Switch.MouseButton1Click:Connect(function() setToggle(not toggled) end)
                return SubElements
            end

            return SubElements
        end

        function Elements:AddSection(sectionTitle)
            local SecFrame = Instance.new("Frame")
            SecFrame.Size = UDim2.new(1, -10, 0, 26)
            SecFrame.BackgroundColor3 = Theme.Sidebar
            SecFrame.BorderSizePixel = 0
            SecFrame.Parent = PageView
            Instance.new("UICorner", SecFrame).CornerRadius = UDim.new(0, 6)

            local Header = Instance.new("TextButton")
            Header.Size = UDim2.new(1, 0, 0, 26)
            Header.BackgroundTransparency = 1
            Header.Font = Enum.Font.GothamBold
            Header.Text = "  ▼ " .. sectionTitle
            Header.TextColor3 = Theme.OrangeAccent
            Header.TextSize = 11
            Header.TextXAlignment = Enum.TextXAlignment.Left
            Header.Parent = SecFrame

            local Container = Instance.new("Frame")
            Container.Position = UDim2.new(0, 0, 0, 30)
            Container.Size = UDim2.new(1, 0, 0, 0)
            Container.BackgroundTransparency = 1
            Container.Parent = SecFrame

            local CLayout = Instance.new("UIListLayout")
            CLayout.SortOrder = Enum.SortOrder.LayoutOrder
            CLayout.Padding = UDim.new(0, 6)
            CLayout.Parent = Container

            local collapsed = false
            Header.MouseButton1Click:Connect(function()
                collapsed = not collapsed
                Header.Text = (collapsed and "  ► " or "  ▼ ") .. sectionTitle
                Container.Visible = not collapsed
                SecFrame.Size = UDim2.new(1, -10, 0, collapsed and 26 or (32 + CLayout.AbsoluteContentSize.Y))
            end)

            CLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if not collapsed then
                    SecFrame.Size = UDim2.new(1, -10, 0, 32 + CLayout.AbsoluteContentSize.Y)
                end
            end)

            return CreateElementBuilder(Container)
        end

        local function OpenFloatingPopup(parentButton, configureCallback)
            if activePopup then activePopup:Destroy() activePopup = nil end

            local Popup = Instance.new("Frame")
            Popup.Size = UDim2.new(0, 0, 0, 0)
            local mouseLoc = UserInputService:GetMouseLocation()
            local targetPos = UDim2.new(0, math.clamp(mouseLoc.X + 10, 10, Camera.ViewportSize.X - 230), 0, math.clamp(mouseLoc.Y, 10, Camera.ViewportSize.Y - 170))
            Popup.Position = targetPos
            Popup.BackgroundColor3 = Theme.PopupBg
            Popup.BackgroundTransparency = 0
            Popup.BorderSizePixel = 1
            Popup.BorderColor3 = Theme.PopupBorder
            Popup.ZIndex = 800
            Popup.Parent = ScreenGui
            Instance.new("UICorner", Popup).CornerRadius = UDim.new(0, 8)

            Tween(Popup, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 220, 0, 160)})
            
            local TopBar = Instance.new("Frame")
            TopBar.Size = UDim2.new(1, 0, 0, 24)
            TopBar.BackgroundColor3 = Theme.TitleBar
            TopBar.BorderSizePixel = 0
            TopBar.ZIndex = 801
            TopBar.Parent = Popup
            Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)
            MakeDraggable(TopBar, Popup)

            activePopup = Popup

            local TitleTxt = Instance.new("TextLabel")
            TitleTxt.Size = UDim2.new(1, -10, 1, 0)
            TitleTxt.Position = UDim2.new(0, 8, 0, 0)
            TitleTxt.BackgroundTransparency = 1
            TitleTxt.Font = Enum.Font.GothamBold
            TitleTxt.Text = "☕ Settings Sub-Menu"
            TitleTxt.TextColor3 = Theme.OrangeAccent
            TitleTxt.TextSize = 10
            TitleTxt.TextXAlignment = Enum.TextXAlignment.Left
            TitleTxt.ZIndex = 802
            TitleTxt.Parent = TopBar

            local ScrollSub = Instance.new("ScrollingFrame")
            ScrollSub.Size = UDim2.new(1, -8, 1, -30)
            ScrollSub.Position = UDim2.new(0, 4, 0, 28)
            ScrollSub.BackgroundTransparency = 1
            ScrollSub.ScrollBarThickness = 2
            ScrollSub.ZIndex = 801
            ScrollSub.Parent = Popup

            local SubLayout = Instance.new("UIListLayout")
            SubLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SubLayout.Padding = UDim.new(0, 4)
            SubLayout.Parent = ScrollSub

            SubLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                ScrollSub.CanvasSize = UDim2.new(0, 0, 0, SubLayout.AbsoluteContentSize.Y + 10)
            end)

            configureCallback(CreatePopupElementBuilder(ScrollSub))
        end

        function Elements:AddButton(text, tooltipText, callback)
            callback = callback or function() end
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, -10, 0, 32)
            Btn.BackgroundColor3 = Theme.CardBg
            Btn.BorderSizePixel = 1
            Btn.BorderColor3 = Theme.CardBorder
            Btn.Font = Enum.Font.GothamMedium
            Btn.Text = text
            Btn.TextColor3 = Theme.TextBright
            Btn.TextSize = 11
            Btn.AutoButtonColor = false
            Btn.Parent = PageView
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
            BindTooltip(Btn, tooltipText)

            Btn.MouseEnter:Connect(function() Tween(Btn, TweenInfo.new(0.12), {BackgroundColor3 = Theme.TabSelected, BorderColor3 = Theme.OrangeAccent}) end)
            Btn.MouseLeave:Connect(function() Tween(Btn, TweenInfo.new(0.12), {BackgroundColor3 = Theme.CardBg, BorderColor3 = Theme.CardBorder}) end)

            local Obj = {}
            function Obj:AddSubMenu(configFunc)
                local Gear = Instance.new("TextButton")
                Gear.Size = UDim2.new(0, 24, 0, 24)
                Gear.Position = UDim2.new(1, -28, 0.5, -12)
                Gear.BackgroundTransparency = 1
                Gear.Font = Enum.Font.GothamBold
                Gear.Text = "⚙"
                Gear.TextColor3 = Theme.TextMuted
                Gear.TextSize = 12
                Gear.ZIndex = 805
                Gear.Parent = Btn
                Gear.MouseButton1Click:Connect(function()
                    task.spawn(function()
                        task.wait()
                        OpenFloatingPopup(Btn, configFunc)
                    end)
                end)
                return Obj
            end

            Btn.MouseButton1Click:Connect(function()
                Tween(Btn, TweenInfo.new(0.06), {Size = UDim2.new(1, -12, 0, 30)})
                Tween(Btn, TweenInfo.new(0.06), {Size = UDim2.new(1, -10, 0, 32)})
                callback()
            end)
            return Obj
        end

        function Elements:AddToggle(text, flag, defaultState, tooltipText, callback)
            callback = callback or function() end
            local toggled = defaultState or false
            AHHubLib.Flags[flag] = toggled
            AHHubLib.Defaults[flag] = defaultState
            AHHubLib.ToggleCallbacks[flag] = callback

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -10, 0, 32)
            Frame.BackgroundColor3 = Theme.CardBg
            Frame.BorderSizePixel = 1
            Frame.BorderColor3 = Theme.CardBorder
            Frame.Parent = PageView
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
            BindTooltip(Frame, tooltipText)

            local Title = Instance.new("TextLabel")
            Title.Position = UDim2.new(0, 10, 0, 0)
            Title.Size = UDim2.new(0.6, 0, 1, 0)
            Title.BackgroundTransparency = 1
            Title.Font = Enum.Font.GothamMedium
            Title.Text = text
            Title.TextColor3 = Theme.TextBright
            Title.TextSize = 11
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.Parent = Frame

            local Switch = Instance.new("TextButton")
            Switch.Position = UDim2.new(1, -38, 0.5, -8)
            Switch.Size = UDim2.new(0, 28, 0, 16)
            Switch.BackgroundColor3 = toggled and Theme.OrangeAccent or Theme.Sidebar
            Switch.Text = ""
            Switch.Parent = Frame
            Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

            local function setToggle(state)
                toggled = state
                AHHubLib.Flags[flag] = toggled
                Tween(Switch, TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = toggled and Theme.OrangeAccent or Theme.Sidebar})
                callback(toggled)
            end

            Switch.MouseButton1Click:Connect(function() setToggle(not toggled) end)

            local Obj = {}
            function Obj:AddSubMenu(configFunc)
                local Gear = Instance.new("TextButton")
                Gear.Size = UDim2.new(0, 24, 0, 24)
                Gear.Position = UDim2.new(1, -66, 0.5, -12)
                Gear.BackgroundTransparency = 1
                Gear.Font = Enum.Font.GothamBold
                Gear.Text = "⚙"
                Gear.TextColor3 = Theme.TextMuted
                Gear.TextSize = 12
                Gear.ZIndex = 805
                Gear.Parent = Frame
                Gear.MouseButton1Click:Connect(function()
                    task.spawn(function()
                        task.wait()
                        OpenFloatingPopup(Frame, configFunc)
                    end)
                end)
                return Obj
            end

            return Obj
        end

        function Elements:AddSlider(text, flag, min, max, defaultState, tooltipText, callback)
            callback = callback or function() end
            local val = defaultState or min
            AHHubLib.Flags[flag] = val
            AHHubLib.Defaults[flag] = defaultState
            AHHubLib.SliderCallbacks[flag] = callback

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -10, 0, 46)
            Frame.BackgroundColor3 = Theme.CardBg
            Frame.BorderSizePixel = 1
            Frame.BorderColor3 = Theme.CardBorder
            Frame.Parent = PageView
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
            BindTooltip(Frame, tooltipText)

            local Title = Instance.new("TextLabel")
            Title.Position = UDim2.new(0, 10, 0, 4)
            Title.Size = UDim2.new(1, -20, 0, 18)
            Title.BackgroundTransparency = 1
            Title.Font = Enum.Font.GothamMedium
            Title.Text = text
            Title.TextColor3 = Theme.TextBright
            Title.TextSize = 11
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.Parent = Frame

            local ValLbl = Instance.new("TextLabel")
            ValLbl.Position = UDim2.new(1, -110, 0, 4)
            ValLbl.Size = UDim2.new(0, 100, 0, 18)
            ValLbl.BackgroundTransparency = 1
            ValLbl.Font = Enum.Font.GothamBold
            ValLbl.Text = tostring(val)
            ValLbl.TextColor3 = Theme.OrangeAccent
            ValLbl.TextSize = 11
            ValLbl.TextXAlignment = Enum.TextXAlignment.Right
            ValLbl.Parent = Frame

            local GearBtn = Instance.new("TextButton")
            GearBtn.Size = UDim2.new(0, 24, 0, 24)
            GearBtn.Position = UDim2.new(1, -28, 0, 0)
            GearBtn.BackgroundTransparency = 1
            GearBtn.Font = Enum.Font.GothamBold
            GearBtn.Text = "⚙"
            GearBtn.TextColor3 = Theme.TextMuted
            GearBtn.TextSize = 12
            GearBtn.ZIndex = 805
            GearBtn.Parent = Frame

            -- Automatically adjust and place the settings gear closely right next to the dynamic text number
            local function updateGearPosition()
                local textWidth = ValLbl.TextBounds.X
                ValLbl.Size = UDim2.new(0, textWidth + 5, 0, 18)
                ValLbl.Position = UDim2.new(1, -textWidth - 34, 0, 4)
                GearBtn.Position = UDim2.new(1, -28, 0, 0)
            end

            ValLbl:GetPropertyChangedSignal("Text"):Connect(updateGearPosition)
            task.spawn(updateGearPosition)

            local SliderBar = Instance.new("TextButton")
            SliderBar.Position = UDim2.new(0, 10, 0, 28)
            SliderBar.Size = UDim2.new(1, -20, 0, 8)
            SliderBar.BackgroundColor3 = Theme.Sidebar
            SliderBar.AutoButtonColor = false
            SliderBar.Text = ""
            SliderBar.Parent = Frame
            Instance.new("UICorner", SliderBar).CornerRadius = UDim.new(1, 0)

            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new(math.clamp((val - min) / (max - min), 0, 1), 0, 1, 0)
            Fill.BackgroundColor3 = Theme.OrangeAccent
            Fill.BorderSizePixel = 0
            Fill.Parent = SliderBar
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

            local sliding = false
            local function updateSlider(input)
                local posRatio = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                local newVal = math.floor(min + ((max - min) * posRatio))
                val = newVal
                AHHubLib.Flags[flag] = val
                Fill.Size = UDim2.new(posRatio, 0, 1, 0)
                ValLbl.Text = tostring(val)
                callback(val)
            end

            SliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    updateSlider(input)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = false
                end
            end)

            local Obj = {}
            function Obj:AddSubMenu(configFunc)
                GearBtn.MouseButton1Click:Connect(function()
                    task.spawn(function()
                        task.wait()
                        OpenFloatingPopup(Frame, configFunc)
                    end)
                end)
                return Obj
            end

            return Obj
        end

        function Elements:AddColorPicker(text, flag, defaultColor, tooltipText, callback)
            callback = callback or function() end
            local currentColor = defaultColor or Color3.fromRGB(255, 255, 255)
            AHHubLib.Flags[flag] = currentColor
            AHHubLib.Defaults[flag] = defaultColor
            AHHubLib.ColorCallbacks[flag] = callback

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -10, 0, 32)
            Frame.BackgroundColor3 = Theme.CardBg
            Frame.BorderSizePixel = 1
            Frame.BorderColor3 = Theme.CardBorder
            Frame.Parent = PageView
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
            BindTooltip(Frame, tooltipText)

            local Title = Instance.new("TextLabel")
            Title.Position = UDim2.new(0, 10, 0, 0)
            Title.Size = UDim2.new(0.6, 0, 1, 0)
            Title.BackgroundTransparency = 1
            Title.Font = Enum.Font.GothamMedium
            Title.Text = text
            Title.TextColor3 = Theme.TextBright
            Title.TextSize = 11
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.Parent = Frame

            local Preview = Instance.new("TextButton")
            Preview.Position = UDim2.new(1, -38, 0.5, -8)
            Preview.Size = UDim2.new(0, 28, 0, 16)
            Preview.BackgroundColor3 = currentColor
            Preview.Text = ""
            Preview.Parent = Frame
            Instance.new("UICorner", Preview).CornerRadius = UDim.new(0, 4)

            Preview.MouseButton1Click:Connect(function()
                if activePopup then activePopup:Destroy() activePopup = nil end

                local PickerPopup = Instance.new("Frame")
                PickerPopup.Size = UDim2.new(0, 0, 0, 0)
                local mouseLoc = UserInputService:GetMouseLocation()
                PickerPopup.Position = UDim2.new(0, math.clamp(mouseLoc.X - 110, 10, Camera.ViewportSize.X - 220), 0, math.clamp(mouseLoc.Y - 10, 10, Camera.ViewportSize.Y - 220))
                PickerPopup.BackgroundColor3 = Theme.PopupBg
                PickerPopup.BorderSizePixel = 1
                PickerPopup.BorderColor3 = Theme.PopupBorder
                PickerPopup.ZIndex = 850
                PickerPopup.Parent = ScreenGui
                Instance.new("UICorner", PickerPopup).CornerRadius = UDim.new(0, 8)

                Tween(PickerPopup, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 200, 0, 210)})
                activePopup = PickerPopup

                local TopBar = Instance.new("Frame")
                TopBar.Size = UDim2.new(1, 0, 0, 24)
                TopBar.BackgroundColor3 = Theme.TitleBar
                TopBar.BorderSizePixel = 0
                TopBar.ZIndex = 851
                TopBar.Parent = PickerPopup
                Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)
                MakeDraggable(TopBar, PickerPopup)

                local TitleTxt = Instance.new("TextLabel")
                TitleTxt.Size = UDim2.new(1, -10, 1, 0)
                TitleTxt.Position = UDim2.new(0, 8, 0, 0)
                TitleTxt.BackgroundTransparency = 1
                TitleTxt.Font = Enum.Font.GothamBold
                TitleTxt.Text = "🎨 True Color Wheel"
                TitleTxt.TextColor3 = Theme.OrangeAccent
                TitleTxt.TextSize = 10
                TitleTxt.TextXAlignment = Enum.TextXAlignment.Left
                TitleTxt.ZIndex = 852
                TitleTxt.Parent = TopBar

                local WheelContainer = Instance.new("Frame")
                WheelContainer.Size = UDim2.new(0, 140, 0, 140)
                WheelContainer.Position = UDim2.new(0.5, -70, 0, 30)
                WheelContainer.BackgroundTransparency = 1
                WheelContainer.ZIndex = 851
                WheelContainer.Parent = PickerPopup

                local CenterIndicator = Instance.new("Frame")
                CenterIndicator.Size = UDim2.new(0, 10, 0, 10)
                CenterIndicator.AnchorPoint = Vector2.new(0.5, 0.5)
                CenterIndicator.BackgroundColor3 = Color3.new(1, 1, 1)
                CenterIndicator.BorderSizePixel = 1
                CenterIndicator.BorderColor3 = Color3.new(0, 0, 0)
                CenterIndicator.ZIndex = 855
                CenterIndicator.Parent = WheelContainer
                Instance.new("UICorner", CenterIndicator).CornerRadius = UDim.new(1, 0)

                local h, s, v = currentColor:ToHSV()

                local slices = 36
                for i = 1, slices do
                    local angle1 = (i - 1) / slices * math.pi * 2
                    local angle2 = i / slices * math.pi * 2
                    
                    local sliceBtn = Instance.new("TextButton")
                    sliceBtn.Size = UDim2.new(1, 0, 1, 0)
                    sliceBtn.BackgroundTransparency = 1
                    sliceBtn.AutoButtonColor = false
                    sliceBtn.Text = ""
                    sliceBtn.ZIndex = 852
                    sliceBtn.Parent = WheelContainer

                    local sliceHue = (i - 1) / slices
                    sliceBtn.BackgroundColor3 = Color3.fromHSV(sliceHue, 1, 1)

                    sliceBtn.MouseButton1Down:Connect(function()
                        h = sliceHue
                        s = 1.0
                        local updatePosFromHSV = function()
                            local radius = s * 70
                            local radAngle = h * math.pi * 2
                            CenterIndicator.Position = UDim2.new(0.5, math.cos(radAngle) * radius, 0.5, math.sin(radAngle) * radius)
                        end
                        updatePosFromHSV()
                        
                        local conn
                        conn = UserInputService.InputChanged:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                                local relX = input.Position.X - WheelContainer.AbsolutePosition.X - 70
                                local relY = input.Position.Y - WheelContainer.AbsolutePosition.Y - 70
                                local dist = math.sqrt(relX*relX + relY*relY)
                                s = math.clamp(dist / 70, 0, 1)
                                h = (math.atan2(relY, relX) / (math.pi * 2)) % 1
                                CenterIndicator.Position = UDim2.new(0.5, math.cos(h * math.pi * 2) * (s * 70), 0.5, math.sin(h * math.pi * 2) * (s * 70))
                                
                                currentColor = Color3.fromHSV(h, s, v)
                                Preview.BackgroundColor3 = currentColor
                                AHHubLib.Flags[flag] = currentColor
                                callback(currentColor)
                            end
                        end)

                        local releaseConn
                        releaseConn = UserInputService.InputEnded:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                                if conn then conn:Disconnect() end
                                if releaseConn then releaseConn:Disconnect() end
                            end
                        end)

                        currentColor = Color3.fromHSV(h, s, v)
                        Preview.BackgroundColor3 = currentColor
                        AHHubLib.Flags[flag] = currentColor
                        callback(currentColor)
                    end)
                end

                local radAngleInit = h * math.pi * 2
                local radiusInit = s * 70
                CenterIndicator.Position = UDim2.new(0.5, math.cos(radAngleInit) * radiusInit, 0.5, math.sin(radAngleInit) * radiusInit)

                local BrightnessBar = Instance.new("TextButton")
                BrightnessBar.Size = UDim2.new(0, 160, 0, 14)
                BrightnessBar.Position = UDim2.new(0.5, -80, 0, 180)
                BrightnessBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                BrightnessBar.AutoButtonColor = false
                BrightnessBar.Text = ""
                BrightnessBar.ZIndex = 851
                BrightnessBar.Parent = PickerPopup
                Instance.new("UICorner", BrightnessBar).CornerRadius = UDim.new(0, 4)

                local BrightGrad = Instance.new("UIGradient")
                BrightGrad.Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.fromHSV(h, s, 1))
                BrightGrad.Parent = BrightnessBar

                local function updateColorOutput()
                    currentColor = Color3.fromHSV(h, s, v)
                    Preview.BackgroundColor3 = currentColor
                    AHHubLib.Flags[flag] = currentColor
                    BrightGrad.Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.fromHSV(h, s, 1))
                    callback(currentColor)
                end

                local pickingBright = false
                BrightnessBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        pickingBright = true
                        local relX = math.clamp((input.Position.X - BrightnessBar.AbsolutePosition.X) / BrightnessBar.AbsoluteSize.X, 0, 1)
                        v = relX
                        updateColorOutput()
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if pickingBright and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local relX = math.clamp((input.Position.X - BrightnessBar.AbsolutePosition.X) / BrightnessBar.AbsoluteSize.X, 0, 1)
                        v = relX
                        updateColorOutput()
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        pickingBright = false
                    end
                end)
            end)

            return Elements
        end

        function Elements:AddCosmeticAccessory(name, id, callback)
            return Elements:AddButton(name, "Catalog Asset ID: " + tostring(id), callback)
        end

        return Elements
    end

    function WindowObj:AddTab(tabName)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 32)
        TabBtn.BackgroundColor3 = Theme.Sidebar
        TabBtn.BorderSizePixel = 0
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.Text = "  " .. tabName
        TabBtn.TextColor3 = Theme.TextMuted
        TabBtn.TextSize = 11
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.Parent = NavHolder
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 3
        Page.Visible = false
        Page.Parent = ContentContainer

        local PLayout = Instance.new("UIListLayout")
        PLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PLayout.Padding = UDim.new(0, 8)
        PLayout.Parent = Page

        if not Controller.CurrentTabBtn then
            Controller.CurrentTabBtn = TabBtn
            TabBtn.BackgroundColor3 = Theme.TabSelected
            TabBtn.TextColor3 = Theme.OrangeAccent
            Page.Visible = true
        end

        TabBtn.MouseButton1Click:Connect(function()
            if Controller.CurrentTabBtn == TabBtn then return end
            if Controller.CurrentTabBtn then
                Tween(Controller.CurrentTabBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Sidebar})
                Controller.CurrentTabBtn.TextColor3 = Theme.TextMuted
            end
            for _, p in pairs(Controller.Pages) do p.Visible = false end
            Controller.CurrentTabBtn = TabBtn
            Tween(TabBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.TabSelected})
            TabBtn.TextColor3 = Theme.OrangeAccent
            Page.Visible = true
        end)

        table.insert(Controller.Pages, Page)

        return CreateElementBuilder(Page)
    end

    function WindowObj:AddESPRenderer()
        local ESPManager = {}
        function ESPManager:UpdatePlayer(data)
        end
        return ESPManager
    end

    return WindowObj
end

return AHHubLib
