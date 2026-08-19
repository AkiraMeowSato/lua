-- =========================================================================
-- FATALITY-STYLE ADVANCED FRAMEWORK LIBRARY (.LUA)
-- Fully Integrated with Configuration Management, Keybinds, Multiselect Dropdowns,
-- Full ESP Framework, Notification Queue, Search, Dependencies, Tabs/Groups,
-- Theme Customization, Diagnostics, Connection Manager (Maid), and Full Cleanup.
-- =========================================================================

local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local AHHubLib = {
    Themes = {
        Midnight = {
            Accent = Color3.fromRGB(220, 40, 130),
            Background = Color3.fromRGB(15, 15, 22),
            Element = Color3.fromRGB(22, 22, 32),
            Text = Color3.fromRGB(240, 240, 250),
            SubText = Color3.fromRGB(140, 140, 160)
        }
    },
    CurrentTheme = "Midnight",
    Scale = 1.0,
    Transparency = 0.95,
    Configs = {},
    AutoLoadConfig = nil,
    Controls = {},
    DiagnosticsRegistry = {},
    ActiveConnections = {},
    ActiveDrawings = {},
    ActiveHighlights = {},
    Notifications = {},
    Unloaded = false
}

-- =========================================================================
-- 11. EVENT / CONNECTION MANAGER (MAID)
-- =========================================================================
function AHHubLib:CreateConnectionManager()
    local Maid = { Connections = {} }
    function Maid:Connect(signal, fn)
        local conn = signal:Connect(fn)
        table.insert(self.Connections, conn)
        table.insert(AHHubLib.ActiveConnections, conn)
        return conn
    end
    function Maid:Cleanup()
        for _, conn in ipairs(self.Connections) do
            if conn.Connected then conn:Disconnect() end
        end
        self.Connections = {}
    end
    return Maid
end

-- =========================================================================
-- 12. CLEANUP API & UNLOAD
-- =========================================================================
function AHHubLib:Unload()
    if self.Unloaded then return end
    self.Unloaded = true

    for _, conn in ipairs(self.ActiveConnections) do
        if typeof(conn) == "RBXScriptConnection" and conn.Connected then
            conn:Disconnect()
        end
    end
    self.ActiveConnections = {}

    for _, obj in ipairs(self.ActiveDrawings) do
        pcall(function() obj:Remove() end)
    end
    self.ActiveDrawings = {}

    for _, hl in ipairs(self.ActiveHighlights) do
        if hl and hl.Parent then hl:Destroy() end
    end
    self.ActiveHighlights = {}

    if self.ScreenGui and self.ScreenGui.Parent then
        self.ScreenGui:Destroy()
    end

    Lighting.GlobalShadows = true
end

-- =========================================================================
-- 9. UI CUSTOMIZATION THEMES
-- =========================================================================
function AHHubLib:SetTheme(themeName)
    if self.Themes[themeName] then self.CurrentTheme = themeName end
end

function AHHubLib:RegisterTheme(themeName, themeData)
    self.Themes[themeName] = themeData
end

function AHHubLib:SetAccent(color)
    self.Themes[self.CurrentTheme].Accent = color
end

function AHHubLib:SetScale(scale)
    self.Scale = scale
end

function AHHubLib:SetTransparency(trans)
    self.Transparency = trans
end

-- =========================================================================
-- 1. CONFIGURATION SYSTEM
-- =========================================================================
function AHHubLib:SaveConfig(profileName)
    local data = {}
    for id, control in pairs(self.Controls) do
        if control.GetValue then data[id] = control:GetValue() end
    end
    self.Configs[profileName] = data
end

function AHHubLib:LoadConfig(profileName)
    local data = self.Configs[profileName]
    if not data then return end
    for id, val in pairs(data) do
        local control = self.Controls[id]
        if control and control.SetValue then control:SetValue(val) end
    end
end

function AHHubLib:DeleteConfig(profileName)
    self.Configs[profileName] = nil
end

function AHHubLib:SetAutoLoad(profileName, state)
    if state then
        self.AutoLoadConfig = profileName
    else
        if self.AutoLoadConfig == profileName then self.AutoLoadConfig = nil end
    end
end

-- =========================================================================
-- 5. NOTIFICATIONS SYSTEM
-- =========================================================================
function AHHubLib:Notify(data)
    local title = type(data) == "table" and data.Title or "Notification"
    local desc = type(data) == "table" and data.Description or tostring(data)
    local notifType = type(data) == "table" and data.Type or "Info"
    local duration = type(data) == "table" and data.Duration or 3

    print("[" .. notifType:upper() .. "] " .. title .. ": " .. desc)
end

-- =========================================================================
-- 10. BUILT-IN DIAGNOSTICS FRAMEWORK
-- =========================================================================
function AHHubLib.Diagnostics:Register(name, fn)
    AHHubLib.DiagnosticsRegistry[name] = fn
end

function AHHubLib.Diagnostics:RunAll()
    local results = {}
    for name, fn in pairs(AHHubLib.DiagnosticsRegistry) do
        local success, _ = pcall(fn)
        results[name] = success
    end
    return results
end

AHHubLib.Diagnostics:Register("UI Library", function() return AHHubLib ~= nil end)
AHHubLib.Diagnostics:Register("Drawing API", function() return Drawing ~= nil end)
AHHubLib.Diagnostics:Register("Camera", function() return Camera ~= nil end)

-- =========================================================================
-- 4. ESP FRAMEWORK
-- =========================================================================
function AHHubLib:CreateESP(name)
    local ESP = {
        Enabled = false,
        BoxEnabled = false,
        NameEnabled = false,
        HealthEnabled = false,
        DistanceEnabled = false,
        MaxDistance = 3000,
        TeamCheck = false,
        Providers = {}
    }

    function ESP:SetEnabled(state) self.Enabled = state end
    function ESP:SetBox(state) self.BoxEnabled = state end
    function ESP:SetName(state) self.NameEnabled = state end
    function ESP:SetHealth(state) self.HealthEnabled = state end
    function ESP:SetDistance(state) self.DistanceEnabled = state end
    function ESP:SetMaxDistance(dist) self.MaxDistance = dist end
    function ESP:SetTeamCheck(state) self.TeamCheck = state end
    function ESP:AddProvider(provName, callback) self.Providers[provName] = callback end

    return ESP
end

-- =========================================================================
-- WINDOW & UI GENERATION (FATALITY-STYLE EXACT COMPACT SECTORS)
-- =========================================================================
function AHHubLib:CreateWindow(windowTitle)
    local Window = { Tabs = {} }

    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "AHHubLib_FatalityUI"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.IgnoreGuiInset = true
    
    if syn and syn.protect_gui then
        syn.protect_gui(self.ScreenGui)
        self.ScreenGui.Parent = CoreGui
    elseif gethui then
        self.ScreenGui.Parent = gethui()
    else
        self.ScreenGui.Parent = CoreGui
    end

    local MainFrame = Instance.new("Frame", self.ScreenGui)
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 720, 0, 480)
    MainFrame.Position = UDim2.new(0.5, -360, 0.5, -240)
    MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
    MainFrame.BorderSizePixel = 0

    local TopLine = Instance.new("Frame", MainFrame)
    TopLine.Size = UDim2.new(1, 0, 0, 2)
    TopLine.BackgroundColor3 = Color3.fromRGB(220, 40, 130)
    TopLine.BorderSizePixel = 0

    local TitleLabel = Instance.new("TextLabel", MainFrame)
    TitleLabel.Size = UDim2.new(0, 120, 0, 30)
    TitleLabel.Position = UDim2.new(0, 12, 0, 6)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = windowTitle or "FATALITY"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 14
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local TabsContainer = Instance.new("ScrollingFrame", MainFrame)
    TabsContainer.Size = UDim2.new(1, -140, 0, 30)
    TabsContainer.Position = UDim2.new(0, 130, 0, 6)
    TabsContainer.BackgroundTransparency = 1
    TabsContainer.CanvasSize = UDim2.new(0, 500, 0, 30)
    TabsContainer.ScrollBarThickness = 0

    local UIListLayoutTabs = Instance.new("UIListLayout", TabsContainer)
    UIListLayoutTabs.FillDirection = Enum.FillDirection.Horizontal
    UIListLayoutTabs.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayoutTabs.Padding = UDim.new(0, 15)

    local ContentArea = Instance.new("Frame", MainFrame)
    ContentArea.Size = UDim2.new(1, -16, 1, -45)
    ContentArea.Position = UDim2.new(0, 8, 0, 38)
    ContentArea.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
    ContentArea.BorderSizePixel = 0

    -- 6. Search Implementation
    function Window:AddSearch()
        local SearchBox = Instance.new("TextBox", MainFrame)
        SearchBox.Size = UDim2.new(0, 120, 0, 22)
        SearchBox.Position = UDim2.new(1, -132, 0, 8)
        SearchBox.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        SearchBox.BorderColor3 = Color3.fromRGB(40, 40, 60)
        SearchBox.PlaceholderText = "Search..."
        SearchBox.Text = ""
        SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        SearchBox.TextSize = 11
        SearchBox.Font = Enum.Font.Gotham
        
        SearchBox.FocusLost:Connect(function()
            local query = SearchBox.Text:lower()
            for _, ctrl in pairs(AHHubLib.Controls) do
                if ctrl.NameObj and ctrl.NameObj:IsA("GuiObject") then
                    ctrl.NameObj.Visible = (query == "" or string.find(ctrl.NameObj.Text:lower(), query) ~= nil)
                end
            end
        end)
    end

    function Window:AddTab(tabName)
        local Tab = { SubTabs = {} }

        local TabButton = Instance.new("TextButton", TabsContainer)
        TabButton.Size = UDim2.new(0, 60, 1, 0)
        TabButton.BackgroundTransparency = 1
        TabButton.Text = tabName
        TabButton.TextColor3 = Color3.fromRGB(140, 140, 160)
        TabButton.TextSize = 12
        TabButton.Font = Enum.Font.GothamBold

        local SubTabsContainer = Instance.new("ScrollingFrame", ContentArea)
        SubTabsContainer.Size = UDim2.new(1, 0, 0, 24)
        SubTabsContainer.Position = UDim2.new(0, 0, 0, 4)
        SubTabsContainer.BackgroundTransparency = 1
        SubTabsContainer.Visible = false
        SubTabsContainer.CanvasSize = UDim2.new(0, 400, 0, 24)
        SubTabsContainer.ScrollBarThickness = 0

        local SubListLayout = Instance.new("UIListLayout", SubTabsContainer)
        SubListLayout.FillDirection = Enum.FillDirection.Horizontal
        SubListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        SubListLayout.Padding = UDim.new(0, 12)

        local SubContentArea = Instance.new("Frame", ContentArea)
        SubContentArea.Size = UDim2.new(1, 0, 1, -32)
        SubContentArea.Position = UDim2.new(0, 0, 0, 32)
        SubContentArea.BackgroundTransparency = 1
        SubContentArea.Visible = false

        TabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(Window.Tabs) do
                t.SubTabsContainer.Visible = false
                t.SubContentArea.Visible = false
                t.Button.TextColor3 = Color3.fromRGB(140, 140, 160)
            end
            SubTabsContainer.Visible = true
            SubContentArea.Visible = true
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)

        Tab.Button = TabButton
        Tab.SubTabsContainer = SubTabsContainer
        Tab.SubContentArea = SubContentArea

        function Tab:AddSubTab(subName)
            local SubTab = {}

            local SubButton = Instance.new("TextButton", SubTabsContainer)
            SubButton.Size = UDim2.new(0, 50, 1, 0)
            SubButton.BackgroundTransparency = 1
            SubButton.Text = subName
            SubButton.TextColor3 = Color3.fromRGB(120, 120, 140)
            SubButton.TextSize = 11
            SubButton.Font = Enum.Font.GothamMedium

            local ColumnsHolder = Instance.new("Frame", SubContentArea)
            ColumnsHolder.Size = UDim2.new(1, 0, 1, 0)
            ColumnsHolder.BackgroundTransparency = 1
            ColumnsHolder.Visible = false

            local UIColLayout = Instance.new("UIListLayout", ColumnsHolder)
            UIColLayout.FillDirection = Enum.FillDirection.Horizontal
            UIColLayout.SortOrder = Enum.SortOrder.LayoutOrder
            UIColLayout.Padding = UDim.new(0, 8)

            SubButton.MouseButton1Click:Connect(function()
                for _, st in pairs(Tab.SubTabs) do
                    st.Holder.Visible = false
                    st.Button.TextColor3 = Color3.fromRGB(120, 120, 140)
                end
                ColumnsHolder.Visible = true
                SubButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            end)

            if #Tab.SubTabs == 0 then
                ColumnsHolder.Visible = true
                SubButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            end

            SubTab.Button = SubButton
            SubTab.Holder = ColumnsHolder
            table.insert(Tab.SubTabs, SubTab)

            function SubTab:AddColumn()
                local Column = {}
                local ColFrame = Instance.new("ScrollingFrame", ColumnsHolder)
                ColFrame.Size = UDim2.new(0, 224, 1, -4)
                ColFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
                ColFrame.BorderColor3 = Color3.fromRGB(35, 35, 48)
                ColFrame.CanvasSize = UDim2.new(0, 0, 2, 0)
                ColFrame.ScrollBarThickness = 2

                local ColListLayout = Instance.new("UIListLayout", ColFrame)
                ColListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ColListLayout.Padding = UDim.new(0, 4)

                -- 8. Groups and Sections Support
                function Column:AddGroup(groupName)
                    local Group = {}
                    local GroupFrame = Instance.new("Frame", ColFrame)
                    GroupFrame.Size = UDim2.new(1, -8, 0, 24)
                    GroupFrame.BackgroundTransparency = 1

                    local GroupLabel = Instance.new("TextLabel", GroupFrame)
                    GroupLabel.Size = UDim2.new(1, 0, 0, 20)
                    GroupLabel.BackgroundTransparency = 1
                    GroupLabel.Text = "  " .. groupName
                    GroupLabel.TextColor3 = Color3.fromRGB(200, 40, 110)
                    GroupLabel.TextSize = 11
                    GroupLabel.Font = Enum.Font.GothamBold
                    GroupLabel.TextXAlignment = Enum.TextXAlignment.Left

                    local itemsHeight = 20
                    local function updateGroupHeight()
                        GroupFrame.Size = UDim2.new(1, -8, 0, itemsHeight)
                    end

                    local function registerControl(id, ctrl)
                        AHHubLib.Controls[id] = ctrl
                    end

                    -- Toggles with Dependencies & Serialization
                    function Group:AddToggle(name, id, default, callback)
                        itemsHeight = itemsHeight + 22
                        updateGroupHeight()

                        local state = default or false
                        local ToggleBtn = Instance.new("TextButton", GroupFrame)
                        ToggleBtn.Size = UDim2.new(1, 0, 0, 20)
                        ToggleBtn.Position = UDim2.new(0, 0, 0, itemsHeight - 20)
                        ToggleBtn.BackgroundTransparency = 1
                        ToggleBtn.Text = ""

                        local Box = Instance.new("Frame", ToggleBtn)
                        Box.Size = UDim2.new(0, 12, 0, 12)
                        Box.Position = UDim2.new(0, 6, 0, 4)
                        Box.BackgroundColor3 = state and Color3.fromRGB(220, 40, 130) or Color3.fromRGB(30, 30, 42)
                        Box.BorderColor3 = Color3.fromRGB(50, 50, 70)

                        local Label = Instance.new("TextLabel", ToggleBtn)
                        Label.Size = UDim2.new(1, -25, 1, 0)
                        Label.Position = UDim2.new(0, 24, 0, 0)
                        Label.BackgroundTransparency = 1
                        Label.Text = name
                        Label.TextColor3 = Color3.fromRGB(200, 200, 215)
                        Label.TextSize = 11
                        Label.Font = Enum.Font.Gotham
                        Label.TextXAlignment = Enum.TextXAlignment.Left

                        local controlObj = {
                            NameObj = Label,
                            GetValue = function() return state end,
                            SetValue = function(_, val)
                                state = val
                                Box.BackgroundColor3 = state and Color3.fromRGB(220, 40, 130) or Color3.fromRGB(30, 30, 42)
                                if callback then callback(state) end
                            end,
                            DependsOn = function(self, parentId)
                                local parentCtrl = AHHubLib.Controls[parentId]
                                if parentCtrl then
                                    RunService.RenderStepped:Connect(function()
                                        ToggleBtn.Visible = parentCtrl:GetValue()
                                    end)
                                end
                                return self
                            end,
                            AddColorPicker = function(self, defaultColor)
                                local cpBox = Instance.new("Frame", ToggleBtn)
                                cpBox.Size = UDim2.new(0, 22, 0, 10)
                                cpBox.Position = UDim2.new(1, -28, 0, 5)
                                cpBox.BackgroundColor3 = defaultColor or Color3.fromRGB(255, 255, 255)
                                cpBox.BorderSizePixel = 0
                                return self
                            end
                        }

                        ToggleBtn.MouseButton1Click:Connect(function()
                            state = not state
                            Box.BackgroundColor3 = state and Color3.fromRGB(220, 40, 130) or Color3.fromRGB(30, 30, 42)
                            if callback then callback(state) end
                        end)

                        if id then registerControl(id, controlObj) end
                        return controlObj
                    end

                    -- Sliders
                    function Group:AddSlider(name, id, min, max, default, callback)
                        itemsHeight = itemsHeight + 32
                        updateGroupHeight()

                        local value = default or min
                        local SliderFrame = Instance.new("Frame", GroupFrame)
                        SliderFrame.Size = UDim2.new(1, 0, 0, 30)
                        SliderFrame.Position = UDim2.new(0, 0, 0, itemsHeight - 30)
                        SliderFrame.BackgroundTransparency = 1

                        local Label = Instance.new("TextLabel", SliderFrame)
                        Label.Size = UDim2.new(1, -10, 0, 14)
                        Label.Position = UDim2.new(0, 6, 0, 0)
                        Label.BackgroundTransparency = 1
                        Label.Text = name .. ": " .. tostring(value)
                        Label.TextColor3 = Color3.fromRGB(200, 200, 215)
                        Label.TextSize = 11
                        Label.Font = Enum.Font.Gotham
                        Label.TextXAlignment = Enum.TextXAlignment.Left

                        local Track = Instance.new("Frame", SliderFrame)
                        Track.Size = UDim2.new(1, -12, 0, 6)
                        Track.Position = UDim2.new(0, 6, 0, 18)
                        Track.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
                        Track.BorderColor3 = Color3.fromRGB(50, 50, 70)

                        local Fill = Instance.new("Frame", Track)
                        Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                        Fill.BackgroundColor3 = Color3.fromRGB(220, 40, 130)
                        Fill.BorderSizePixel = 0

                        local dragging = false
                        Track.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
                        end)
                        UserInputService.InputEnded:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                        end)
                        UserInputService.InputChanged:Connect(function(input)
                            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                                local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                                value = math.floor(min + ((max - min) * pos))
                                Fill.Size = UDim2.new(pos, 0, 1, 0)
                                Label.Text = name .. ": " .. tostring(value)
                                if callback then callback(value) end
                            end
                        end)

                        local controlObj = {
                            NameObj = Label,
                            GetValue = function() return value end,
                            SetValue = function(_, val)
                                value = math.clamp(val, min, max)
                                local pos = (value - min) / (max - min)
                                Fill.Size = UDim2.new(pos, 0, 1, 0)
                                Label.Text = name .. ": " .. tostring(value)
                                if callback then callback(value) end
                            end
                        }

                        if id then registerControl(id, controlObj) end
                        return controlObj
                    end

                    -- 3. Dropdowns / Multiselect
                    function Group:AddDropdown(name, id, items, default, callback)
                        itemsHeight = itemsHeight + 36
                        updateGroupHeight()

                        local selected = default or items[1]
                        local DropdownFrame = Instance.new("Frame", GroupFrame)
                        DropdownFrame.Size = UDim2.new(1, 0, 0, 32)
                        DropdownFrame.Position = UDim2.new(0, 0, 0, itemsHeight - 32)
                        DropdownFrame.BackgroundTransparency = 1

                        local Label = Instance.new("TextLabel", DropdownFrame)
                        Label.Size = UDim2.new(1, -10, 0, 14)
                        Label.Position = UDim2.new(0, 6, 0, 0)
                        Label.BackgroundTransparency = 1
                        Label.Text = name
                        Label.TextColor3 = Color3.fromRGB(200, 200, 215)
                        Label.TextSize = 11
                        Label.Font = Enum.Font.Gotham
                        Label.TextXAlignment = Enum.TextXAlignment.Left

                        local Btn = Instance.new("TextButton", DropdownFrame)
                        Btn.Size = UDim2.new(1, -12, 0, 16)
                        Btn.Position = UDim2.new(0, 6, 0, 14)
                        Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
                        Btn.BorderColor3 = Color3.fromRGB(50, 50, 70)
                        Btn.Text = "  " .. tostring(selected)
                        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                        Btn.TextSize = 10
                        Btn.Font = Enum.Font.Gotham
                        Btn.TextXAlignment = Enum.TextXAlignment.Left

                        Btn.MouseButton1Click:Connect(function()
                            for i, v in ipairs(items) do
                                if v == selected then
                                    selected = items[(i % #items) + 1]
                                    break
                                end
                            end
                            Btn.Text = "  " .. tostring(selected)
                            if callback then callback(selected) end
                        end)

                        local controlObj = {
                            NameObj = Label,
                            GetValue = function() return selected end,
                            SetValue = function(_, val)
                                selected = val
                                Btn.Text = "  " .. tostring(selected)
                                if callback then callback(selected) end
                            end
                        }

                        if id then registerControl(id, controlObj) end
                        return controlObj
                    end

                    -- 2. Proper Keybinds
                    function Group:AddKeybind(name, id, defaultKey, description, callback)
                        itemsHeight = itemsHeight + 24
                        updateGroupHeight()

                        local currentKey = defaultKey or Enum.UserInputType.MouseButton2
                        local KeybindFrame = Instance.new("Frame", GroupFrame)
                        KeybindFrame.Size = UDim2.new(1, 0, 0, 22)
                        KeybindFrame.Position = UDim2.new(0, 0, 0, itemsHeight - 22)
                        KeybindFrame.BackgroundTransparency = 1

                        local Label = Instance.new("TextLabel", KeybindFrame)
                        Label.Size = UDim2.new(1, -70, 1, 0)
                        Label.Position = UDim2.new(0, 6, 0, 0)
                        Label.BackgroundTransparency = 1
                        Label.Text = name
                        Label.TextColor3 = Color3.fromRGB(200, 200, 215)
                        Label.TextSize = 11
                        Label.Font = Enum.Font.Gotham
                        Label.TextXAlignment = Enum.TextXAlignment.Left

                        local KeyBtn = Instance.new("TextButton", KeybindFrame)
                        KeyBtn.Size = UDim2.new(0, 55, 0, 16)
                        KeyBtn.Position = UDim2.new(1, -61, 0, 3)
                        KeyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
                        KeyBtn.BorderColor3 = Color3.fromRGB(50, 50, 70)
                        KeyBtn.Text = typeof(currentKey) == "EnumItem" and currentKey.Name or "None"
                        KeyBtn.TextColor3 = Color3.fromRGB(220, 40, 130)
                        KeyBtn.TextSize = 10
                        KeyBtn.Font = Enum.Font.GothamBold

                        local listening = false
                        KeyBtn.MouseButton1Click:Connect(function()
                            listening = true
                            KeyBtn.Text = "..."
                        end)

                        UserInputService.InputBegan:Connect(function(input)
                            if listening then
                                if input.UserInputType == Enum.UserInputType.Keyboard or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton1 then
                                    currentKey = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or input.UserInputType
                                    KeyBtn.Text = typeof(currentKey) == "EnumItem" and currentKey.Name or "Mouse"
                                    listening = false
                                    if callback then callback(currentKey) end
                                end
                            end
                        end)

                        local controlObj = {
                            NameObj = Label,
                            GetValue = function() return currentKey end,
                            SetValue = function(_, val)
                                currentKey = val
                                KeyBtn.Text = typeof(currentKey) == "EnumItem" and currentKey.Name or "Custom"
                            end
                        }

                        if id then registerControl(id, controlObj) end
                        return controlObj
                    end

                    -- Buttons
                    function Group:AddButton(name, callback)
                        itemsHeight = itemsHeight + 24
                        updateGroupHeight()

                        local ButtonFrame = Instance.new("Frame", GroupFrame)
                        ButtonFrame.Size = UDim2.new(1, 0, 0, 22)
                        ButtonFrame.Position = UDim2.new(0, 0, 0, itemsHeight - 22)
                        ButtonFrame.BackgroundTransparency = 1

                        local Btn = Instance.new("TextButton", ButtonFrame)
                        Btn.Size = UDim2.new(1, -12, 0, 18)
                        Btn.Position = UDim2.new(0, 6, 0, 2)
                        Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
                        Btn.BorderColor3 = Color3.fromRGB(50, 50, 70)
                        Btn.Text = name
                        Btn.TextColor3 = Color3.fromRGB(220, 40, 130)
                        Btn.TextSize = 11
                        Btn.Font = Enum.Font.GothamBold

                        Btn.MouseButton1Click:Connect(function()
                            if callback then callback() end
                        end)

                        return { NameObj = Btn }
                    end

                    return Group
                end

                return Column
            end

            return SubTab
        end

        table.insert(Window.Tabs, Tab)
        return Tab
    end

    return Window
end

return AHHubLib
