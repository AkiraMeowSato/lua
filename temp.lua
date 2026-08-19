-- =========================================================================
-- A&H HUB v1.6.0 - FULLY FEATURED NATIVE DRAWING ESP API & UI LIBRARY
-- Updated with: Resizable Windows, Collapsible Toggle Sub-Menus, 
-- Cosmetic/Accessory Attachment Elements, and AddESPForRenderer.
-- =========================================================================

local AHHubLib = {
    Version = "1.6.0",
    Author = "Nyrae",
    Title = "A&H HUB",
    Defaults = {}
}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Theme = {
    Bg = Color3.fromRGB(24, 18, 15),
    Sidebar = Color3.fromRGB(32, 24, 20),
    CardBg = Color3.fromRGB(40, 30, 25),
    CardBorder = Color3.fromRGB(65, 48, 40),
    TitleBar = Color3.fromRGB(36, 26, 21),
    TextBright = Color3.fromRGB(255, 248, 240),
    TextMain = Color3.fromRGB(230, 210, 190),
    TextMuted = Color3.fromRGB(160, 135, 120),
    OrangeAccent = Color3.fromRGB(210, 130, 60),
    TabSelected = Color3.fromRGB(55, 40, 32),
    Disabled = Color3.fromRGB(60, 50, 45),
    RedDanger = Color3.fromRGB(200, 60, 60),
    YellowWarn = Color3.fromRGB(220, 160, 50),
    GreenOk = Color3.fromRGB(60, 180, 80)
}

AHHubLib.Flags = {}

local function getGuiParent()
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then return hui end
    return LocalPlayer:WaitForChild("PlayerGui")
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
            Tween(frame, TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
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

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AHHub_Dashboard"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = ParentGui

    local DefaultSize = UDim2.new(0, 850, 0, 520)
    local DefaultPos = UDim2.new(0.5, -425, 0.5, -260)

    local Window = Instance.new("Frame")
    Window.Name = "MainWindow"
    Window.Size = DefaultSize
    Window.Position = DefaultPos
    Window.BackgroundColor3 = Theme.Bg
    Window.BorderSizePixel = 0
    Window.ClipsDescendants = true
    Window.Parent = ScreenGui
    Instance.new("UICorner", Window).CornerRadius = UDim.new(0, 10)

    local ResizeHandle = Instance.new("TextButton")
    ResizeHandle.Name = "ResizeHandle"
    ResizeHandle.Size = UDim2.new(0, 15, 0, 15)
    ResizeHandle.Position = UDim2.new(1, -15, 1, -15)
    ResizeHandle.BackgroundTransparency = 1
    ResizeHandle.Text = "◢"
    ResizeHandle.TextColor3 = Theme.TextMuted
    ResizeHandle.TextSize = 10
    ResizeHandle.ZIndex = 300
    ResizeHandle.Parent = Window

    local resizing = false
    ResizeHandle.MouseButton1Down:Connect(function()
        resizing = true
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouseLoc = UserInputService:GetMouseLocation()
            local newX = math.clamp(mouseLoc.X - Window.AbsolutePosition.X, 450, 1200)
            local newY = math.clamp(mouseLoc.Y - Window.AbsolutePosition.Y, 300, 800)
            Window.Size = UDim2.new(0, newX, 0, newY)
        end
    end)

    local TooltipLabel = Instance.new("TextLabel")
    TooltipLabel.Size = UDim2.new(0, 120, 0, 22)
    TooltipLabel.BackgroundColor3 = Theme.TitleBar
    TooltipLabel.BorderColor3 = Theme.OrangeAccent
    TooltipLabel.BorderSizePixel = 1
    TooltipLabel.Font = Enum.Font.GothamMedium
    TooltipLabel.TextColor3 = Theme.TextBright
    TooltipLabel.TextSize = 10
    TooltipLabel.Visible = false
    TooltipLabel.ZIndex = 200
    TooltipLabel.Parent = ScreenGui
    Instance.new("UICorner", TooltipLabel).CornerRadius = UDim.new(0, 4)

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
        object.MouseLeave:Connect(function()
            TooltipLabel.Visible = false
        end)
    end

    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 32)
    TitleBar.BackgroundColor3 = Theme.TitleBar
    TitleBar.BorderSizePixel = 0
    TitleBar.ZIndex = 10
    TitleBar.Parent = Window
    Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)
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
    BindTooltip(CoffeeLogoBtn, "A&H Hub Icon")

    local WindowTitle = Instance.new("TextLabel")
    WindowTitle.Size = UDim2.new(0, 250, 1, 0)
    WindowTitle.Position = UDim2.new(0, 36, 0, 0)
    WindowTitle.BackgroundTransparency = 1
    WindowTitle.Font = Enum.Font.GothamBold
    WindowTitle.Text = self.Title .. "  •  " .. self.Version
    WindowTitle.TextColor3 = Theme.TextMain
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

        btn.MouseEnter:Connect(function()
            Tween(btn, TweenInfo.new(0.1), {BackgroundColor3 = hoverColor})
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, TweenInfo.new(0.1), {BackgroundColor3 = color})
        end)
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

    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, -170, 1, -37)
    ContentContainer.Position = UDim2.new(0, 165, 0, 32)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = Window

    local ShowConfirmation

    MakeCircularButton(Theme.YellowWarn, Color3.fromRGB(240, 190, 80), 0, function()
        isMinimized = not isMinimized
        if isMinimized then
            if not isMaximized then savedSize = Window.Size end
            Sidebar.Visible = false
            ContentContainer.Visible = false
            Tween(Window, TweenInfo.new(0.2), {Size = UDim2.new(Window.Size.X.Scale, Window.Size.X.Offset, 0, 32)})
        else
            Tween(Window, TweenInfo.new(0.2), {Size = isMaximized and UDim2.new(1, 0, 1, 0) or savedSize})
            task.delay(0.15, function()
                Sidebar.Visible = true
                ContentContainer.Visible = true
            end)
        end
    end)

    MakeCircularButton(Theme.GreenOk, Color3.fromRGB(90, 220, 110), 22, function()
        if isMinimized then return end
        isMaximized = not isMaximized
        if isMaximized then
            savedPosition = Window.Position
            savedSize = Window.Size
            Tween(Window, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, 0, 1, 0)
            })
            Window.BorderSizePixel = 0
        else
            Tween(Window, TweenInfo.new(0.2), {
                Position = savedPosition,
                Size = savedSize
            })
        end
    end)

    MakeCircularButton(Theme.RedDanger, Color3.fromRGB(240, 80, 80), 44, function()
        ShowConfirmation("Close A&H Hub?", "Are you sure you want to close the user interface?", function()
            ScreenGui:Destroy()
        end)
    end)

    local NotificationHolder = Instance.new("Frame")
    NotificationHolder.Size = UDim2.new(0, 240, 1, -40)
    NotificationHolder.Position = UDim2.new(1, -250, 0, 35)
    NotificationHolder.BackgroundTransparency = 1
    NotificationHolder.ZIndex = 50
    NotificationHolder.Parent = ScreenGui

    local NotifLayout = Instance.new("UIListLayout")
    NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifLayout.Padding = UDim.new(0, 6)
    NotifLayout.Parent = NotificationHolder

    function AHHubLib:Notify(title, desc, duration)
        duration = duration or 3
        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(1, 0, 0, 50)
        Card.BackgroundColor3 = Theme.CardBg
        Card.BorderSizePixel = 1
        Card.BorderColor3 = Theme.OrangeAccent
        Card.Parent = NotificationHolder
        Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)

        local Txt = Instance.new("TextLabel")
        Txt.Position = UDim2.new(0, 10, 0, 5)
        Txt.Size = UDim2.new(1, -20, 0, 18)
        Txt.BackgroundTransparency = 1
        Txt.Font = Enum.Font.GothamBold
        Txt.Text = title
        Txt.TextColor3 = Theme.OrangeAccent
        Txt.TextSize = 11
        Txt.TextXAlignment = Enum.TextXAlignment.Left
        Txt.Parent = Card

        local Sub = Instance.new("TextLabel")
        Sub.Position = UDim2.new(0, 10, 0, 23)
        Sub.Size = UDim2.new(1, -20, 0, 22)
        Sub.BackgroundTransparency = 1
        Sub.Font = Enum.Font.GothamMedium
        Sub.Text = desc
        Sub.TextColor3 = Theme.TextMain
        Sub.TextSize = 10
        Sub.TextXAlignment = Enum.TextXAlignment.Left
        Sub.TextWrapped = true
        Sub.Parent = Card

        task.delay(duration, function()
            Tween(Card, TweenInfo.new(0.25), {BackgroundTransparency = 1})
            task.wait(0.25)
            Card:Destroy()
        end)
    end

    ShowConfirmation = function(title, message, onAccept)
        local Overlay = Instance.new("Frame")
        Overlay.Size = UDim2.new(1, 0, 1, 0)
        Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Overlay.BackgroundTransparency = 0.5
        Overlay.ZIndex = 250
        Overlay.Parent = Window

        local Box = Instance.new("Frame")
        Box.Size = UDim2.new(0, 300, 0, 140)
        Box.Position = UDim2.new(0.5, -150, 0.5, -70)
        Box.BackgroundColor3 = Theme.CardBg
        Box.BorderSizePixel = 1
        Box.BorderColor3 = Theme.RedDanger
        Box.ZIndex = 251
        Box.Parent = Overlay
        Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 8)

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
        M.TextColor3 = Theme.TextMain
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
        Instance.new("UICorner", ConfirmBtn).CornerRadius = UDim.new(0, 4)

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
        Instance.new("UICorner", CancelBtn).CornerRadius = UDim.new(0, 4)

        ConfirmBtn.MouseButton1Click:Connect(function()
            Overlay:Destroy()
            onAccept()
        end)
        CancelBtn.MouseButton1Click:Connect(function()
            Overlay:Destroy()
        end)
    end

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(1, -16, 0, 24)
    SearchBox.Position = UDim2.new(0, 8, 0, 8)
    SearchBox.BackgroundColor3 = Theme.CardBg
    SearchBox.BorderSizePixel = 1
    SearchBox.BorderColor3 = Theme.CardBorder
    SearchBox.Font = Enum.Font.GothamMedium
    SearchBox.PlaceholderText = "🔍 Search..."
    SearchBox.PlaceholderColor3 = Theme.TextMuted
    SearchBox.Text = ""
    SearchBox.TextColor3 = Theme.TextBright
    SearchBox.TextSize = 10
    SearchBox.Parent = Sidebar
    Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 4)

    local NavHolder = Instance.new("Frame")
    NavHolder.Position = UDim2.new(0, 8, 0, 38)
    NavHolder.Size = UDim2.new(1, -16, 1, -46)
    NavHolder.BackgroundTransparency = 1
    NavHolder.Parent = Sidebar

    local NavLayout = Instance.new("UIListLayout")
    NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NavLayout.Padding = UDim.new(0, 4)
    NavLayout.Parent = NavHolder

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(SearchBox.Text)
        for _, page in ipairs(ContentContainer:GetChildren()) do
            for _, card in ipairs(page:GetDescendants()) do
                if card:IsA("Frame") and card:FindFirstChildOfClass("TextLabel") then
                    local label = card:FindFirstChildOfClass("TextLabel")
                    if string.find(string.lower(label.Text), query) then
                        card.Visible = true
                    else
                        card.Visible = (query == "")
                    end
                end
            end
        end
    end)

    local Controller = { CurrentTabBtn = nil, Pages = {}, RegisteredKeybinds = {} }

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            for _, kbData in ipairs(Controller.RegisteredKeybinds) do
                if input.KeyCode == kbData.Key then
                    kbData.Callback()
                end
            end
        end
    end)

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

        function Elements:AddSection(sectionTitle)
            local SecFrame = Instance.new("Frame")
            SecFrame.Size = UDim2.new(1, -10, 0, 26)
            SecFrame.BackgroundColor3 = Theme.Sidebar
            SecFrame.BorderSizePixel = 0
            SecFrame.Parent = PageView
            Instance.new("UICorner", SecFrame).CornerRadius = UDim.new(0, 4)

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
                
                if collapsed then
                    SecFrame.Size = UDim2.new(1, -10, 0, 26)
                else
                    SecFrame.Size = UDim2.new(1, -10, 0, 32 + CLayout.AbsoluteContentSize.Y)
                end
            end)

            CLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if not collapsed then
                    SecFrame.Size = UDim2.new(1, -10, 0, 32 + CLayout.AbsoluteContentSize.Y)
                end
            end)

            return CreateElementBuilder(Container)
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

            local ButtonController = {}
            local isDisabled = false

            function ButtonController:SetDisabled(state)
                isDisabled = state
                Btn.BackgroundColor3 = isDisabled and Theme.Disabled or Theme.CardBg
                Btn.TextColor3 = isDisabled and Theme.TextMuted or Theme.TextBright
            end

            Btn.MouseButton1Click:Connect(function()
                if not isDisabled then callback() end
            end)

            return ButtonController
        end

        function Elements:AddToggle(text, flag, defaultState, tooltipText, callback)
            callback = callback or function() end
            local toggled = defaultState or false
            AHHubLib.Flags[flag] = toggled
            AHHubLib.Defaults[flag] = defaultState

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
            Title.Size = UDim2.new(0.7, 0, 1, 0)
            Title.BackgroundTransparency = 1
            Title.Font = Enum.Font.GothamMedium
            Title.Text = text
            Title.TextColor3 = Theme.TextMain
            Title.TextSize = 11
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.Parent = Frame

            local Switch = Instance.new("TextButton")
            Switch.Position = UDim2.new(1, -40, 0.5, -9)
            Switch.Size = UDim2.new(0, 30, 0, 18)
            Switch.BackgroundColor3 = toggled and Theme.OrangeAccent or Theme.Sidebar
            Switch.Text = ""
            Switch.Parent = Frame
            Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

            local SubContainer = Instance.new("Frame")
            SubContainer.Name = "SubMenuContainer"
            SubContainer.Size = UDim2.new(1, 0, 0, 0)
            SubContainer.BackgroundTransparency = 1
            SubContainer.Visible = toggled
            SubContainer.Parent = PageView

            local SubLayout = Instance.new("UIListLayout")
            SubLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SubLayout.Padding = UDim.new(0, 4)
            SubLayout.Parent = SubContainer

            local ToggleObject = {}
            function ToggleObject:Set(state)
                toggled = state
                AHHubLib.Flags[flag] = toggled
                Tween(Switch, TweenInfo.new(0.15), {BackgroundColor3 = toggled and Theme.OrangeAccent or Theme.Sidebar})
                SubContainer.Visible = toggled
                callback(toggled)
            end

            Switch.MouseButton1Click:Connect(function()
                ToggleObject:Set(not toggled)
            end)

            function ToggleObject:AddSubElement(builderFunc)
                return builderFunc(CreateElementBuilder(SubContainer))
            end

            return ToggleObject
        end

        -- Fully Integrated AddESPForRenderer Method Fix
        function Elements:AddESPForRenderer(espName, callback)
            return self:AddToggle("Enable " .. (espName or "ESP"), "ESP_" .. (espName or "Renderer"), false, "Toggle native ESP renderer", callback)
        end

        function Elements:AddCosmeticAccessory(assetName, assetId)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, -10, 0, 32)
            Btn.BackgroundColor3 = Theme.CardBg
            Btn.BorderSizePixel = 1
            Btn.BorderColor3 = Theme.CardBorder
            Btn.Font = Enum.Font.GothamMedium
            Btn.Text = "  Equip Cosmetic: " .. assetName
            Btn.TextColor3 = Theme.TextBright
            Btn.TextSize = 11
            Btn.AutoButtonColor = false
            Btn.Parent = PageView
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

            Btn.MouseButton1Click:Connect(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Head") then
                    local accessoryPart = Instance.new("Part")
                    accessoryPart.Name = "AHHub_Cosmetic_" .. assetName
                    accessoryPart.Size = Vector3.new(1.2, 0.4, 1.2)
                    
                    local weld = Instance.new("WeldConstraint")
                    weld.Part0 = char.Head
                    weld.Part1 = accessoryPart
                    
                    accessoryPart.Position = char.Head.Position + Vector3.new(0, 1, 0)
                    accessoryPart.Parent = char
                    weld.Parent = accessoryPart
                end
            end)
        end

        function Elements:AddSlider(text, flag, min, max, default, tooltipText, callback)
            callback = callback or function() end
            local val = default or min
            AHHubLib.Flags[flag] = val
            AHHubLib.Defaults[flag] = default

            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, -10, 0, 44)
            Frame.BackgroundColor3 = Theme.CardBg
            Frame.BorderSizePixel = 1
            Frame.BorderColor3 = Theme.CardBorder
            Frame.Parent = PageView
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

            BindTooltip(Frame, tooltipText)

            local Title = Instance.new("TextLabel")
            Title.Position = UDim2.new(0, 10, 0, 4)
            Title.Size = UDim2.new(0.6, 0, 0, 16)
            Title.BackgroundTransparency = 1
            Title.Font = Enum.Font.GothamMedium
            Title.Text = text
            Title.TextColor3 = Theme.TextMain
            Title.TextSize = 11
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.Parent = Frame

            local LiveLabel = Instance.new("TextLabel")
            LiveLabel.Position = UDim2.new(1, -60, 0, 4)
            LiveLabel.Size = UDim2.new(0, 50, 0, 16)
            LiveLabel.BackgroundTransparency = 1
            LiveLabel.Font = Enum.Font.GothamBold
            LiveLabel.Text = tostring(val)
            LiveLabel.TextColor3 = Theme.OrangeAccent
            LiveLabel.TextSize = 11
            LiveLabel.TextXAlignment = Enum.TextXAlignment.Right
            LiveLabel.Parent = Frame

            local Track = Instance.new("TextButton")
            Track.Position = UDim2.new(0, 10, 0, 26)
            Track.Size = UDim2.new(1, -20, 0, 8)
            Track.BackgroundColor3 = Theme.Sidebar
            Track.Text = ""
            Track.Parent = Frame
            Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

            local pct = math.clamp((val - min)/(max - min), 0, 1)
            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new(pct, 0, 1, 0)
            Fill.BackgroundColor3 = Theme.OrangeAccent
            Fill.Parent = Track
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

            local dragging = false
            local function updateSlider(input)
                local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                val = math.floor(min + (max - min) * pos)
                LiveLabel.Text = tostring(val)
                Fill.Size = UDim2.new(pos, 0, 1, 0)
                AHHubLib.Flags[flag] = val
                callback(val)
            end

            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true updateSlider(input) end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(input) end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
        end

        function Elements:AddColorPicker(text, flag, defaultColor, callback)
            callback = callback or function() end
            defaultColor = defaultColor or Color3.fromRGB(255, 255, 255)
            AHHubLib.Flags[flag] = defaultColor
            AHHubLib.Defaults[flag] = defaultColor

            local CpFrame = Instance.new("Frame")
            CpFrame.Size = UDim2.new(1, -10, 0, 34)
            CpFrame.BackgroundColor3 = Theme.CardBg
            CpFrame.BorderSizePixel = 1
            CpFrame.BorderColor3 = Theme.CardBorder
            CpFrame.ClipsDescendants = true
            CpFrame.Parent = PageView
            Instance.new("UICorner", CpFrame).CornerRadius = UDim.new(0, 6)

            local Header = Instance.new("TextButton")
            Header.Size = UDim2.new(1, 0, 0, 34)
            Header.BackgroundTransparency = 1
            Header.Text = ""
            Header.Parent = CpFrame

            local Title = Instance.new("TextLabel")
            Title.Position = UDim2.new(0, 10, 0, 0)
            Title.Size = UDim2.new(0.6, 0, 1, 0)
            Title.BackgroundTransparency = 1
            Title.Font = Enum.Font.GothamMedium
            Title.Text = text
            Title.TextColor3 = Theme.TextMain
            Title.TextSize = 11
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.Parent = Header

            local Preview = Instance.new("Frame")
            Preview.Position = UDim2.new(1, -40, 0.5, -9)
            Preview.Size = UDim2.new(0, 30, 0, 18)
            Preview.BackgroundColor3 = defaultColor
            Preview.Parent = Header
            Instance.new("UICorner", Preview).CornerRadius = UDim.new(0, 4)

            local SliderContainer = Instance.new("Frame")
            SliderContainer.Position = UDim2.new(0, 10, 0, 34)
            SliderContainer.Size = UDim2.new(1, -20, 0, 80)
            SliderContainer.BackgroundTransparency = 1
            SliderContainer.Parent = CpFrame

            local curR, curG, curB = math.floor(defaultColor.R*255), math.floor(defaultColor.G*255), math.floor(defaultColor.B*255)

            local function createRGBChannel(name, defaultVal, order, onValChanged)
                local ChannelFrame = Instance.new("Frame")
                ChannelFrame.Size = UDim2.new(1, 0, 0, 22)
                ChannelFrame.Position = UDim2.new(0, 0, 0, (order - 1) * 26)
                ChannelFrame.BackgroundTransparency = 1
                ChannelFrame.Parent = SliderContainer

                local Track = Instance.new("TextButton")
                Track.Position = UDim2.new(0, 20, 0.5, -4)
                Track.Size = UDim2.new(1, -20, 0, 8)
                Track.BackgroundColor3 = Theme.Sidebar
                Track.Text = ""
                Track.Parent = ChannelFrame
                Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new(defaultVal / 255, 0, 1, 0)
                Fill.BackgroundColor3 = Theme.OrangeAccent
                Fill.Parent = Track
                Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

                local dragging = false
                local function updateVal(input)
                    local pct = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    Fill.Size = UDim2.new(pct, 0, 1, 0)
                    onValChanged(math.floor(pct * 255))
                end

                Track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true updateVal(input) end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then updateVal(input) end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                end)
            end

            local function updateColor()
                local newC = Color3.fromRGB(curR, curG, curB)
                Preview.BackgroundColor3 = newC
                AHHubLib.Flags[flag] = newC
                callback(newC)
            end

            createRGBChannel("R", curR, 1, function(v) curR = v updateColor() end)
            createRGBChannel("G", curG, 2, function(v) curG = v updateColor() end)
            createRGBChannel("B", curB, 3, function(v) curB = v updateColor() end)

            local isOpen = false
            Header.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                Tween(CpFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, -10, 0, isOpen and 120 or 34)})
            end)
        end

        return Elements
    end

    function Controller:AddTab(tabName)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 26)
        TabBtn.BackgroundColor3 = Theme.Sidebar
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.Text = "    " .. tabName
        TabBtn.TextColor3 = Theme.TextMuted
        TabBtn.TextSize = 11
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.Parent = NavHolder
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 4)

        local MainTabFrame = Instance.new("ScrollingFrame")
        MainTabFrame.Size = UDim2.new(1, 0, 1, 0)
        MainTabFrame.BackgroundTransparency = 1
        MainTabFrame.Visible = false
        MainTabFrame.ScrollBarThickness = 3
        MainTabFrame.ScrollBarImageColor3 = Theme.OrangeAccent
        MainTabFrame.Parent = ContentContainer

        local MainListLayout = Instance.new("UIListLayout")
        MainListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        MainListLayout.Padding = UDim.new(0, 6)
        MainListLayout.Parent = MainTabFrame

        self.Pages[tabName] = MainTabFrame

        TabBtn.MouseButton1Click:Connect(function()
            for _, page in pairs(self.Pages) do page.Visible = false end
            for _, btn in ipairs(NavHolder:GetChildren()) do
                if btn:IsA("TextButton") then
                    Tween(btn, TweenInfo.new(0.12), {BackgroundColor3 = Theme.Sidebar, TextColor3 = Theme.TextMuted})
                end
            end
            MainTabFrame.Visible = true
            Tween(TabBtn, TweenInfo.new(0.12), {BackgroundColor3 = Theme.TabSelected, TextColor3 = Theme.TextBright})
        end)

        if not self.CurrentTabBtn then
            self.CurrentTabBtn = TabBtn
            MainTabFrame.Visible = true
            Tween(TabBtn, TweenInfo.new(0.12), {BackgroundColor3 = Theme.TabSelected, TextColor3 = Theme.TextBright})
        end

        return CreateElementBuilder(MainTabFrame)
    end

    return Controller
end

return AHHubLib
