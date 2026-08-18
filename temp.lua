-- =========================================================
-- A&H HUB v1.2 - COFFEE THEME EDITION + CONFIG DIALOGS
-- =========================================================

local AHHubLib = {
    Version = "1.2",
    Author = "Nyrae",
    Title = "A&H HUB"
}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

-- Rich Coffee & Espresso Palette
local Theme = {
    Bg = Color3.fromRGB(24, 18, 15),           -- Deep Espresso
    Sidebar = Color3.fromRGB(32, 24, 20),      -- Roasted Coffee Bean
    CardBg = Color3.fromRGB(40, 30, 25),       -- Warm Mocha Card
    CardBorder = Color3.fromRGB(65, 48, 40),   -- Coffee Husk Border
    TitleBar = Color3.fromRGB(36, 26, 21),     -- Dark Brew
    
    TextBright = Color3.fromRGB(255, 248, 240),-- Milk Foam White
    TextMain = Color3.fromRGB(230, 210, 190),  -- Latte
    TextMuted = Color3.fromRGB(160, 135, 120), -- Cinnamon Brown
    
    OrangeAccent = Color3.fromRGB(210, 130, 60),-- Warm Caramel / Amber Accent
    GreenStatus = Color3.fromRGB(110, 180, 100),
    TabSelected = Color3.fromRGB(55, 40, 32)   -- Dark Cream Accent
}

-- Config Storage System
AHHubLib.Flags = {}

function AHHubLib:SaveConfig(folderName, fileName)
    folderName = folderName or "AHHub_Configs"
    fileName = fileName or "default.json"
    if not string.find(fileName, "%.json$") then fileName = fileName .. ".json" end
    
    if not isfolder or not writefile then return false end
    if not isfolder(folderName) then makefolder(folderName) end
    
    local json = HttpService:JSONEncode(AHHubLib.Flags)
    writefile(folderName .. "/" .. fileName, json)
    return true
end

function AHHubLib:LoadConfig(folderName, fileName)
    folderName = folderName or "AHHub_Configs"
    fileName = fileName or "default.json"
    if not string.find(fileName, "%.json$") then fileName = fileName .. ".json" end
    local path = folderName .. "/" .. fileName
    
    if not readfile or not isfile or not isfile(path) then return false end
    local data = readfile(path)
    local decoded = HttpService:JSONDecode(data)
    if decoded then
        AHHubLib.Flags = decoded
        return true
    end
    return false
end

-- Helpers
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

    -- Main Window
    local Window = Instance.new("Frame")
    Window.Name = "MainWindow"
    Window.Size = UDim2.new(0, 850, 0, 500)
    Window.Position = UDim2.new(0.5, -425, 0.5, -250)
    Window.BackgroundColor3 = Theme.Bg
    Window.BorderSizePixel = 0
    Window.ClipsDescendants = true
    Window.Parent = ScreenGui

    Instance.new("UICorner", Window).CornerRadius = UDim.new(0, 10)

    -- Opening Animation
    Window.Size = UDim2.new(0, 0, 0, 0)
    Window.Position = UDim2.new(0.5, 0, 0.5, 0)
    Tween(Window, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 850, 0, 500),
        Position = UDim2.new(0.5, -425, 0.5, -250)
    })

    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 32)
    TitleBar.BackgroundColor3 = Theme.TitleBar
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = Window

    Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)
    MakeDraggable(TitleBar, Window)

    -- Window Controls Container
    local DotsHolder = Instance.new("Frame")
    DotsHolder.Size = UDim2.new(0, 60, 1, 0)
    DotsHolder.Position = UDim2.new(0, 10, 0, 0)
    DotsHolder.BackgroundTransparency = 1
    DotsHolder.Parent = TitleBar

    -- RED = CLOSE
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 12, 0, 12)
    CloseBtn.Position = UDim2.new(0, 0, 0.5, -6)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(225, 85, 75)
    CloseBtn.Text = ""
    CloseBtn.AutoButtonColor = false
    CloseBtn.Parent = DotsHolder
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)

    -- YELLOW = MAXIMISE
    local MaximizeBtn = Instance.new("TextButton")
    MaximizeBtn.Size = UDim2.new(0, 12, 0, 12)
    MaximizeBtn.Position = UDim2.new(0, 18, 0.5, -6)
    MaximizeBtn.BackgroundColor3 = Color3.fromRGB(235, 175, 45)
    MaximizeBtn.Text = ""
    MaximizeBtn.AutoButtonColor = false
    MaximizeBtn.Parent = DotsHolder
    Instance.new("UICorner", MaximizeBtn).CornerRadius = UDim.new(1, 0)

    -- GREEN = MINIMISE
    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 12, 0, 12)
    MinimizeBtn.Position = UDim2.new(0, 36, 0.5, -6)
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(80, 185, 75)
    MinimizeBtn.Text = ""
    MinimizeBtn.AutoButtonColor = false
    MinimizeBtn.Parent = DotsHolder
    Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(1, 0)

    -- Window Title
    local WindowTitle = Instance.new("TextLabel")
    WindowTitle.Size = UDim2.new(0, 250, 1, 0)
    WindowTitle.Position = UDim2.new(0, 60, 0, 0)
    WindowTitle.BackgroundTransparency = 1
    WindowTitle.Font = Enum.Font.GothamBold
    WindowTitle.Text = "☕ " .. self.Title .. "  •  " .. self.Version
    WindowTitle.TextColor3 = Theme.TextMain
    WindowTitle.TextSize = 12
    WindowTitle.TextXAlignment = Enum.TextXAlignment.Left
    WindowTitle.Parent = TitleBar

    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 150, 1, -32)
    Sidebar.Position = UDim2.new(0, 0, 0, 32)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Window

    local HubBrand = Instance.new("TextLabel")
    HubBrand.Position = UDim2.new(0, 16, 0, 15)
    HubBrand.Size = UDim2.new(1, -16, 0, 18)
    HubBrand.BackgroundTransparency = 1
    HubBrand.Font = Enum.Font.GothamBold
    HubBrand.Text = "☕ A&H HUB"
    HubBrand.TextColor3 = Theme.OrangeAccent
    HubBrand.TextSize = 15
    HubBrand.TextXAlignment = Enum.TextXAlignment.Left
    HubBrand.Parent = Sidebar

    local NavHolder = Instance.new("Frame")
    NavHolder.Position = UDim2.new(0, 8, 0, 45)
    NavHolder.Size = UDim2.new(1, -16, 1, -55)
    NavHolder.BackgroundTransparency = 1
    NavHolder.Parent = Sidebar

    local NavLayout = Instance.new("UIListLayout")
    NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NavLayout.Padding = UDim.new(0, 4)
    NavLayout.Parent = NavHolder

    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -165, 1, -42)
    ContentContainer.Position = UDim2.new(0, 160, 0, 37)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = Window

    -- Floating Coffee Logo Button
    local CoffeeWidget = Instance.new("ImageButton")
    CoffeeWidget.Name = "CoffeeWidget"
    CoffeeWidget.Size = UDim2.new(0, 52, 0, 52)
    CoffeeWidget.Position = UDim2.new(1, -70, 1, -70)
    CoffeeWidget.BackgroundColor3 = Theme.CardBg
    CoffeeWidget.BorderSizePixel = 1
    CoffeeWidget.BorderColor3 = Theme.OrangeAccent
    CoffeeWidget.Image = "rbxassetid://10723415903"
    CoffeeWidget.ImageColor3 = Theme.OrangeAccent
    CoffeeWidget.Visible = false
    CoffeeWidget.Parent = ScreenGui

    Instance.new("UICorner", CoffeeWidget).CornerRadius = UDim.new(0.5, 0)
    MakeDraggable(CoffeeWidget, CoffeeWidget)

    -- Window Controls Logic
    local isMaximized = false
    local storedSize = UDim2.new(0, 850, 0, 500)
    local storedPos = UDim2.new(0.5, -425, 0.5, -250)

    CloseBtn.MouseButton1Click:Connect(function()
        local anim = Tween(Window, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(Window.Position.X.Scale, Window.Position.X.Offset + (Window.Size.X.Offset / 2), Window.Position.Y.Scale, Window.Position.Y.Offset + (Window.Size.Y.Offset / 2))
        })
        anim.Completed:Connect(function() ScreenGui:Destroy() end)
    end)

    MaximizeBtn.MouseButton1Click:Connect(function()
        isMaximized = not isMaximized
        if isMaximized then
            storedPos = Window.Position
            storedSize = Window.Size
            Tween(Window, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0)
            })
        else
            Tween(Window, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = storedSize,
                Position = storedPos
            })
        end
    end)

    MinimizeBtn.MouseButton1Click:Connect(function()
        if not isMaximized then
            storedSize = Window.Size
            storedPos = Window.Position
        end

        local anim = Tween(Window, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = CoffeeWidget.Position
        })
        
        anim.Completed:Connect(function()
            Window.Visible = false
            CoffeeWidget.Visible = true
            CoffeeWidget.Size = UDim2.new(0, 0, 0, 0)
            Tween(CoffeeWidget, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 52, 0, 52)
            })
        end)
    end)

    CoffeeWidget.MouseButton1Click:Connect(function()
        CoffeeWidget.Visible = false
        Window.Visible = true
        Tween(Window, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = isMaximized and UDim2.new(1, 0, 1, 0) or storedSize,
            Position = isMaximized and UDim2.new(0, 0, 0, 0) or storedPos
        })
    end)

    -- =========================================================
    -- MESSAGE BOX & PROMPT DIALOG SYSTEM
    -- =========================================================
    local function ShowMessageBox(title, text, confirmCallback)
        local Overlay = Instance.new("Frame")
        Overlay.Size = UDim2.new(1, 0, 1, 0)
        Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Overlay.BackgroundTransparency = 0.5
        Overlay.ZIndex = 10
        Overlay.Parent = Window

        local Box = Instance.new("Frame")
        Box.Size = UDim2.new(0, 320, 0, 160)
        Box.Position = UDim2.new(0.5, -160, 0.5, -80)
        Box.BackgroundColor3 = Theme.CardBg
        Box.BorderSizePixel = 1
        Box.BorderColor3 = Theme.OrangeAccent
        Box.ZIndex = 11
        Box.Parent = Overlay
        Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 8)

        local Header = Instance.new("TextLabel")
        Header.Size = UDim2.new(1, 0, 0, 30)
        Header.Position = UDim2.new(0, 0, 0, 10)
        Header.BackgroundTransparency = 1
        Header.Font = Enum.Font.GothamBold
        Header.Text = title
        Header.TextColor3 = Theme.OrangeAccent
        Header.TextSize = 14
        Header.ZIndex = 12
        Header.Parent = Box

        local Message = Instance.new("TextLabel")
        Message.Size = UDim2.new(1, -20, 0, 50)
        Message.Position = UDim2.new(0, 10, 0, 40)
        Message.BackgroundTransparency = 1
        Message.Font = Enum.Font.GothamMedium
        Message.Text = text
        Message.TextColor3 = Theme.TextMain
        Message.TextSize = 12
        Message.TextWrapped = true
        Message.ZIndex = 12
        Message.Parent = Box

        local OkBtn = Instance.new("TextButton")
        OkBtn.Size = UDim2.new(0, 100, 0, 28)
        OkBtn.Position = UDim2.new(0.5, -50, 1, -38)
        OkBtn.BackgroundColor3 = Theme.OrangeAccent
        OkBtn.Font = Enum.Font.GothamBold
        OkBtn.Text = "OK"
        OkBtn.TextColor3 = Theme.TextBright
        OkBtn.TextSize = 11
        OkBtn.ZIndex = 12
        OkBtn.Parent = Box
        Instance.new("UICorner", OkBtn).CornerRadius = UDim.new(0, 6)

        OkBtn.MouseButton1Click:Connect(function()
            Overlay:Destroy()
            if confirmCallback then confirmCallback() end
        end)
    end

    local function ShowSaveInputDialog(onConfirm)
        local Overlay = Instance.new("Frame")
        Overlay.Size = UDim2.new(1, 0, 1, 0)
        Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Overlay.BackgroundTransparency = 0.5
        Overlay.ZIndex = 10
        Overlay.Parent = Window

        local Box = Instance.new("Frame")
        Box.Size = UDim2.new(0, 320, 0, 170)
        Box.Position = UDim2.new(0.5, -160, 0.5, -85)
        Box.BackgroundColor3 = Theme.CardBg
        Box.BorderSizePixel = 1
        Box.BorderColor3 = Theme.OrangeAccent
        Box.ZIndex = 11
        Box.Parent = Overlay
        Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 8)

        local Header = Instance.new("TextLabel")
        Header.Size = UDim2.new(1, 0, 0, 30)
        Header.Position = UDim2.new(0, 0, 0, 10)
        Header.BackgroundTransparency = 1
        Header.Font = Enum.Font.GothamBold
        Header.Text = "☕ Save Configuration"
        Header.TextColor3 = Theme.OrangeAccent
        Header.TextSize = 14
        Header.ZIndex = 12
        Header.Parent = Box

        local TextBox = Instance.new("TextBox")
        TextBox.Size = UDim2.new(1, -40, 0, 32)
        TextBox.Position = UDim2.new(0, 20, 0, 50)
        TextBox.BackgroundColor3 = Theme.Sidebar
        TextBox.BorderSizePixel = 1
        TextBox.BorderColor3 = Theme.CardBorder
        TextBox.Font = Enum.Font.GothamMedium
        TextBox.PlaceholderText = "Enter file name (e.g., config1)"
        TextBox.PlaceholderColor3 = Theme.TextMuted
        TextBox.Text = ""
        TextBox.TextColor3 = Theme.TextBright
        TextBox.TextSize = 12
        TextBox.ZIndex = 12
        TextBox.Parent = Box
        Instance.new("UICorner", TextBox).CornerRadius = UDim.new(0, 6)

        local SaveBtn = Instance.new("TextButton")
        SaveBtn.Size = UDim2.new(0, 100, 0, 28)
        SaveBtn.Position = UDim2.new(0.5, -105, 1, -38)
        SaveBtn.BackgroundColor3 = Theme.OrangeAccent
        SaveBtn.Font = Enum.Font.GothamBold
        SaveBtn.Text = "Save"
        SaveBtn.TextColor3 = Theme.TextBright
        SaveBtn.TextSize = 11
        SaveBtn.ZIndex = 12
        SaveBtn.Parent = Box
        Instance.new("UICorner", SaveBtn).CornerRadius = UDim.new(0, 6)

        local CancelBtn = Instance.new("TextButton")
        CancelBtn.Size = UDim2.new(0, 100, 0, 28)
        CancelBtn.Position = UDim2.new(0.5, 5, 1, -38)
        CancelBtn.BackgroundColor3 = Theme.Sidebar
        CancelBtn.Font = Enum.Font.GothamBold
        CancelBtn.Text = "Cancel"
        CancelBtn.TextColor3 = Theme.TextMuted
        CancelBtn.TextSize = 11
        CancelBtn.ZIndex = 12
        CancelBtn.Parent = Box
        Instance.new("UICorner", CancelBtn).CornerRadius = UDim.new(0, 6)

        SaveBtn.MouseButton1Click:Connect(function()
            local text = TextBox.Text
            Overlay:Destroy()
            if text and text ~= "" then
                onConfirm(text)
            end
        end)

        CancelBtn.MouseButton1Click:Connect(function()
            Overlay:Destroy()
        end)
    end

    -- Tab Management Controller
    local Controller = { CurrentTabBtn = nil, Pages = {} }

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

        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

        local PageView = Instance.new("ScrollingFrame")
        PageView.Name = tabName .. "_Page"
        PageView.Size = UDim2.new(1, 0, 1, 0)
        PageView.BackgroundTransparency = 1
        PageView.Visible = false
        PageView.ScrollBarThickness = 3
        PageView.ScrollBarImageColor3 = Theme.OrangeAccent
        PageView.Parent = ContentContainer

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout.Parent = PageView

        self.Pages[tabName] = PageView

        TabBtn.MouseButton1Click:Connect(function()
            for _, page in pairs(self.Pages) do page.Visible = false end
            for _, btn in ipairs(NavHolder:GetChildren()) do
                if btn:IsA("TextButton") then
                    Tween(btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Sidebar, TextColor3 = Theme.TextMuted})
                end
            end
            PageView.Visible = true
            Tween(TabBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.TabSelected, TextColor3 = Theme.TextBright})
        end)

        if not self.CurrentTabBtn then
            self.CurrentTabBtn = TabBtn
            PageView.Visible = true
            TabBtn.BackgroundColor3 = Theme.TabSelected
            TabBtn.TextColor3 = Theme.TextBright
        end

        local Elements = {}

        -- 1. ADD LABEL
        function Elements:AddLabel(text)
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -10, 0, 22)
            Label.BackgroundTransparency = 1
            Label.Font = Enum.Font.GothamMedium
            Label.Text = text
            Label.TextColor3 = Theme.TextMain
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = PageView
            return Label
        end

        -- 2. ADD BUTTON
        function Elements:AddButton(text, callback)
            callback = callback or function() end
            local BtnFrame = Instance.new("TextButton")
            BtnFrame.Size = UDim2.new(1, -10, 0, 32)
            BtnFrame.BackgroundColor3 = Theme.CardBg
            BtnFrame.BorderSizePixel = 1
            BtnFrame.BorderColor3 = Theme.CardBorder
            BtnFrame.Font = Enum.Font.GothamMedium
            BtnFrame.Text = text
            BtnFrame.TextColor3 = Theme.TextBright
            BtnFrame.TextSize = 12
            BtnFrame.AutoButtonColor = false
            BtnFrame.Parent = PageView

            Instance.new("UICorner", BtnFrame).CornerRadius = UDim.new(0, 6)

            BtnFrame.MouseEnter:Connect(function() Tween(BtnFrame, TweenInfo.new(0.15), {BackgroundColor3 = Theme.TabSelected}) end)
            BtnFrame.MouseLeave:Connect(function() Tween(BtnFrame, TweenInfo.new(0.15), {BackgroundColor3 = Theme.CardBg}) end)
            BtnFrame.MouseButton1Click:Connect(function()
                Tween(BtnFrame, TweenInfo.new(0.08), {Size = UDim2.new(1, -14, 0, 30)})
                task.wait(0.08)
                Tween(BtnFrame, TweenInfo.new(0.08), {Size = UDim2.new(1, -10, 0, 32)})
                callback()
            end)
        end

        -- 3. ADD TOGGLE
        function Elements:AddToggle(text, flag, defaultState, callback)
            callback = callback or function() end
            local toggled = defaultState or false
            AHHubLib.Flags[flag] = toggled

            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, -10, 0, 34)
            ToggleFrame.BackgroundColor3 = Theme.CardBg
            ToggleFrame.BorderSizePixel = 1
            ToggleFrame.BorderColor3 = Theme.CardBorder
            ToggleFrame.Parent = PageView
            Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)

            local ToggleTitle = Instance.new("TextLabel")
            ToggleTitle.Position = UDim2.new(0, 12, 0, 0)
            ToggleTitle.Size = UDim2.new(0.7, 0, 1, 0)
            ToggleTitle.BackgroundTransparency = 1
            ToggleTitle.Font = Enum.Font.GothamMedium
            ToggleTitle.Text = text
            ToggleTitle.TextColor3 = Theme.TextMain
            ToggleTitle.TextSize = 12
            ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
            ToggleTitle.Parent = ToggleFrame

            local Switch = Instance.new("TextButton")
            Switch.Position = UDim2.new(1, -44, 0.5, -10)
            Switch.Size = UDim2.new(0, 34, 0, 20)
            Switch.BackgroundColor3 = toggled and Theme.OrangeAccent or Theme.Sidebar
            Switch.Text = ""
            Switch.AutoButtonColor = false
            Switch.Parent = ToggleFrame
            Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0, 14, 0, 14)
            Knob.Position = toggled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
            Knob.BackgroundColor3 = Theme.TextBright
            Knob.Parent = Switch
            Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

            Switch.MouseButton1Click:Connect(function()
                toggled = not toggled
                AHHubLib.Flags[flag] = toggled
                Tween(Switch, TweenInfo.new(0.2), {BackgroundColor3 = toggled and Theme.OrangeAccent or Theme.Sidebar})
                Tween(Knob, TweenInfo.new(0.2), {Position = toggled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)})
                callback(toggled)
            end)
        end

        -- 4. ADD SLIDER
        function Elements:AddSlider(text, flag, min, max, default, callback)
            callback = callback or function() end
            local value = default or min
            AHHubLib.Flags[flag] = value

            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, -10, 0, 45)
            SliderFrame.BackgroundColor3 = Theme.CardBg
            SliderFrame.BorderSizePixel = 1
            SliderFrame.BorderColor3 = Theme.CardBorder
            SliderFrame.Parent = PageView
            Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 6)

            local SliderLabel = Instance.new("TextLabel")
            SliderLabel.Position = UDim2.new(0, 12, 0, 6)
            SliderLabel.Size = UDim2.new(0.6, 0, 0, 16)
            SliderLabel.BackgroundTransparency = 1
            SliderLabel.Font = Enum.Font.GothamMedium
            SliderLabel.Text = text
            SliderLabel.TextColor3 = Theme.TextMain
            SliderLabel.TextSize = 12
            SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            SliderLabel.Parent = SliderFrame

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Position = UDim2.new(1, -62, 0, 6)
            ValueLabel.Size = UDim2.new(0, 50, 0, 16)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Font = Enum.Font.GothamBold
            ValueLabel.Text = tostring(value)
            ValueLabel.TextColor3 = Theme.OrangeAccent
            ValueLabel.TextSize = 12
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValueLabel.Parent = SliderFrame

            local Track = Instance.new("Frame")
            Track.Position = UDim2.new(0, 12, 0, 28)
            Track.Size = UDim2.new(1, -24, 0, 6)
            Track.BackgroundColor3 = Theme.Sidebar
            Track.Parent = SliderFrame
            Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((value - min)/(max - min), 0, 1, 0)
            Fill.BackgroundColor3 = Theme.OrangeAccent
            Fill.Parent = Track
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

            local dragging = false
            local function updateSlider(input)
                local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                value = math.floor(min + (max - min) * pos)
                ValueLabel.Text = tostring(value)
                Fill.Size = UDim2.new(pos, 0, 1, 0)
                AHHubLib.Flags[flag] = value
                callback(value)
            end

            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateSlider(input)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
        end

        -- 5. REDESIGNED BEAUTIFUL COFFEE DROPDOWN
        function Elements:AddDropdown(text, flag, options, default, callback)
            callback = callback or function() end
            local selected = default or options[1]
            AHHubLib.Flags[flag] = selected

            local DropFrame = Instance.new("Frame")
            DropFrame.Size = UDim2.new(1, -10, 0, 36)
            DropFrame.BackgroundColor3 = Theme.CardBg
            DropFrame.BorderSizePixel = 1
            DropFrame.BorderColor3 = Theme.CardBorder
            DropFrame.ClipsDescendants = true
            DropFrame.Parent = PageView
            Instance.new("UICorner", DropFrame).CornerRadius = UDim.new(0, 6)

            local DropHeader = Instance.new("TextButton")
            DropHeader.Size = UDim2.new(1, 0, 0, 36)
            DropHeader.BackgroundTransparency = 1
            DropHeader.Text = ""
            DropHeader.Parent = DropFrame

            local TitleText = Instance.new("TextLabel")
            TitleText.Position = UDim2.new(0, 12, 0, 0)
            TitleText.Size = UDim2.new(0.5, 0, 1, 0)
            TitleText.BackgroundTransparency = 1
            TitleText.Font = Enum.Font.GothamMedium
            TitleText.Text = text
            TitleText.TextColor3 = Theme.TextMain
            TitleText.TextSize = 12
            TitleText.TextXAlignment = Enum.TextXAlignment.Left
            TitleText.Parent = DropHeader

            local SelectedText = Instance.new("TextLabel")
            SelectedText.Position = UDim2.new(0.5, 0, 0, 0)
            SelectedText.Size = UDim2.new(0.5, -30, 1, 0)
            SelectedText.BackgroundTransparency = 1
            SelectedText.Font = Enum.Font.GothamBold
            SelectedText.Text = selected
            SelectedText.TextColor3 = Theme.OrangeAccent
            SelectedText.TextSize = 12
            SelectedText.TextXAlignment = Enum.TextXAlignment.Right
            SelectedText.Parent = DropHeader

            local Arrow = Instance.new("TextLabel")
            Arrow.Position = UDim2.new(1, -25, 0, 0)
            Arrow.Size = UDim2.new(0, 20, 1, 0)
            Arrow.BackgroundTransparency = 1
            Arrow.Font = Enum.Font.GothamBold
            Arrow.Text = "▼"
            Arrow.TextColor3 = Theme.TextMuted
            Arrow.TextSize = 10
            Arrow.Parent = DropHeader

            local OptionHolder = Instance.new("Frame")
            OptionHolder.Position = UDim2.new(0, 6, 0, 36)
            OptionHolder.Size = UDim2.new(1, -12, 0, #options * 28)
            OptionHolder.BackgroundTransparency = 1
            OptionHolder.Parent = DropFrame

            local OptionLayout = Instance.new("UIListLayout")
            OptionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            OptionLayout.Padding = UDim.new(0, 2)
            OptionLayout.Parent = OptionHolder

            local isOpen = false
            DropHeader.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                Arrow.Text = isOpen and "▲" or "▼"
                local targetHeight = isOpen and (42 + (#options * 28)) or 36
                Tween(DropFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, -10, 0, targetHeight)
                })
            end)

            for _, option in ipairs(options) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, 0, 0, 26)
                OptBtn.BackgroundColor3 = Theme.Sidebar
                OptBtn.BorderSizePixel = 0
                OptBtn.Font = Enum.Font.GothamMedium
                OptBtn.Text = "   " .. option
                OptBtn.TextColor3 = (option == selected) and Theme.OrangeAccent or Theme.TextMuted
                OptBtn.TextSize = 11
                OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                OptBtn.AutoButtonColor = false
                OptBtn.Parent = OptionHolder

                Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0, 4)

                OptBtn.MouseEnter:Connect(function()
                    if option ~= selected then
                        Tween(OptBtn, TweenInfo.new(0.12), {BackgroundColor3 = Theme.TabSelected, TextColor3 = Theme.TextBright})
                    end
                end)
                OptBtn.MouseLeave:Connect(function()
                    if option ~= selected then
                        Tween(OptBtn, TweenInfo.new(0.12), {BackgroundColor3 = Theme.Sidebar, TextColor3 = Theme.TextMuted})
                    end
                end)

                OptBtn.MouseButton1Click:Connect(function()
                    selected = option
                    AHHubLib.Flags[flag] = selected
                    SelectedText.Text = selected
                    
                    for _, child in ipairs(OptionHolder:GetChildren()) do
                        if child:IsA("TextButton") then
                            child.TextColor3 = Theme.TextMuted
                        end
                    end
                    OptBtn.TextColor3 = Theme.OrangeAccent
                    
                    isOpen = false
                    Arrow.Text = "▼"
                    Tween(DropFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, -10, 0, 36)})
                    callback(selected)
                end)
            end
        end

        -- Config Prompt Helper Extensions
        function Elements:AddSaveConfigButton()
            Elements:AddButton("💾 Save Config File", function()
                ShowSaveInputDialog(function(fileName)
                    local success = AHHubLib:SaveConfig("AHHub_Configs", fileName)
                    if success then
                        ShowMessageBox("☕ Config Saved", "Successfully saved settings to:\n" .. fileName)
                    else
                        ShowMessageBox("❌ Error", "Could not save configuration file.")
                    end
                end)
            end)
        end

        function Elements:AddLoadConfigButton()
            Elements:AddButton("📂 Load Config File", function()
                ShowSaveInputDialog(function(fileName)
                    local success = AHHubLib:LoadConfig("AHHub_Configs", fileName)
                    if success then
                        ShowMessageBox("☕ Config Loaded", "Successfully loaded config:\n" .. fileName)
                    else
                        ShowMessageBox("❌ Error", "Config file not found or corrupted.")
                    end
                end)
            end)
        end

        return Elements
    end

    return Controller
end
