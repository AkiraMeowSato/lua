if game.PlaceId == 16732694052 then


local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()


-- MAIN UI
local Window = Rayfield:CreateWindow({
    Name = "Average Hub",
    LoadingTitle = "Average Hub",
    LoadingSubtitle = "by zel and aki",
    Theme = "Bloom", -- Check https://docs.sirius.menu/rayfield/configuration/themes
 
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface
 
    ConfigurationSaving = {
       Enabled = true,
       FolderName = nil, -- Create a custom folder for your hub/game
       FileName = "Fisch"
    },
 
    Discord = {
       Enabled = true, -- Prompt the user to join your Discord server if their executor supports it
       Invite = "jMcAfH8BEN", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ABCD would be ABCD
       RememberJoins = true -- Set this to false to make them join the discord every time they load it up
    },
 
    KeySystem = false, -- Set this to true to use our key system
    KeySettings = {
       Title = "Untitled",
       Subtitle = "Key System",
       Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
       FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
       SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
       GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
       Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
    }
 })


-- TABS
local Tab = Window:CreateTab("Fishing", 11767069582) 
   local Section = Tab:CreateSection("Fishing")
   local Toggle = Tab:CreateToggle({
    Name = "Auto Catch Legit",
    CurrentValue = false,
    Flag = "AutoCatchLegit", 
    Callback = function(Value)
        local RunService = game:GetService("RunService")
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer
        local playerGui = player:WaitForChild("PlayerGui")
        local autoReelConnection
        local scriptParent = script.Parent
        local mrsigmas = scriptParent:FindFirstChild("mrsigmas")

        if not mrsigmas then
            mrsigmas = Instance.new("BoolValue")
            mrsigmas.Name = "mrsigmas"
            mrsigmas.Parent = scriptParent
        end

        mrsigmas.Value = Value

        local function autoReel()
            local reel = playerGui:FindFirstChild("reel")
            if not reel then return end

            local bar = reel:FindFirstChild("bar")
            local playerbar = bar and bar:FindFirstChild("playerbar")
            local fish = bar and bar:FindFirstChild("fish")

            if playerbar and fish then
                if playerbar.Position == fish.Position then
                    return
                end
                playerbar.Position = fish.Position
            end
        end

        local function noperfect()
            local reel = playerGui:FindFirstChild("reel")
            if not reel then return end

            local bar = reel:FindFirstChild("bar")
            local playerbar = bar and bar:FindFirstChild("playerbar")

            if playerbar then
                playerbar.Position = UDim2.new(math.random(25, 30), 0, math.random(-35, -20), 0)
                wait(0.69)
            end
        end

        local function startAutoReel()
            if autoReelConnection then return end
            noperfect()
            wait(0.69)
            autoReelConnection = RunService.RenderStepped:Connect(autoReel)
        end

        local function stopAutoReel()
            if autoReelConnection then
                autoReelConnection:Disconnect()
                autoReelConnection = nil
            end
        end

        if mrsigmas.Value then
            task.spawn(function()
                startAutoReel()
                while mrsigmas.Value do
                    wait(0.169420)
                end
                stopAutoReel()
            end)
        else
            stopAutoReel()
        end
    end
   })

     local Toggle = Tab:CreateToggle({
        Name = "Auto Catch OBVIOUS",
        CurrentValue = false,
        Flag = "AutoCatchOBV", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Value)
         local value = Value
         local ReplicatedStorage = game:GetService("ReplicatedStorage")
         local args = {100, true}
         local reelfinished = ReplicatedStorage:WaitForChild("events"):WaitForChild("reelfinished")
         local scriptParent = script.Parent
         local mrsigmas = scriptParent:FindFirstChild("mrsigmas")
         
         if not mrsigmas then
             mrsigmas = Instance.new("BoolValue")
             mrsigmas.Name = "mrsigmasnowman"
             mrsigmas.Parent = scriptParent
         end
         
         mrsigmas.Value = Value
         
         local function startLoop()
             while value and mrsigmas.Value do
                 reelfinished:FireServer(unpack(args))
                 wait(0.3369420)
             end
         end
         
         if value and mrsigmas.Value then
             startLoop()
         end
         
         
         local function imsosigma()
             if mrsigmas.Value then
                 startLoop()
             end
         end
         
         imsosigma()
        end,
     })
 
     local Divider = Tab:CreateDivider()

     local Button = Tab:CreateButton({
      Name = "Auto Shake",
      Callback = function()
         local Players = game:GetService("Players")
         local UserInputService = game:GetService("UserInputService")
         local GuiService = game:GetService("GuiService")
         local VirtualInputManager = game:GetService("VirtualInputManager")
         
         local player = Players.LocalPlayer
         local playerGui = player:WaitForChild("PlayerGui")
         
         local buttonClicked = false
         local firingCoroutine = nil
         
         local function checkButton()
             local shakeui = playerGui:FindFirstChild("shakeui")
             if shakeui then
                 local safezone = shakeui:FindFirstChild("safezone")
                 if safezone then
                     return safezone:FindFirstChild("button")
                 end
             end
             return nil
         end
         
         local function ensureUINavigation()
             if not UserInputService.ModalEnabled then
                 UserInputService.ModalEnabled = true
             end
         end
         
         local function simulateButtonPress()
             local button = checkButton()
             if button then
                 GuiService.SelectedObject = button
                 VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                 task.wait()
                 VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
             end
         end
         
         local function toggleButtonClicking()
             ensureUINavigation()
         
             buttonClicked = true
             firingCoroutine = task.spawn(function()
                 while buttonClicked do
                     local button = checkButton()
                     if button and button.Parent then
                         GuiService.SelectedObject = button
                         simulateButtonPress()
                     end
                     task.wait()
                 end
             end)
         end
         
         local function stopButtonClicking()
             if firingCoroutine then
                 task.cancel(firingCoroutine)
                 firingCoroutine = nil
             end
         end
         
         playerGui.ChildAdded:Connect(function(child)
             if child.Name == "shakeui" then
                 toggleButtonClicking()
             end
         end)
         
         playerGui.ChildRemoved:Connect(function(child)
             if child.Name == "shakeui" then
                 stopButtonClicking()
             end
         end)
         
         if playerGui:FindFirstChild("shakeui") then
             toggleButtonClicking()
         end
      end,
   })

   local Divider = Tab:CreateDivider()

     local Toggle = Tab:CreateToggle({
      Name = "Auto Cast",
      CurrentValue = false,
      Callback = function(Value)
          if Value then
              task.spawn(function()
                  while Value do
                      local args = {
                          [1] = math.random(30, 100),
                          [2] = 1
                      }
                      local tool = game:GetService("Players").LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
                      local shaky = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui") and game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("shakeui")
                      if tool and tool:FindFirstChild("events") and tool.events:FindFirstChild("cast") then
                          local casted = tool:FindFirstChild("values") and tool.values:FindFirstChild("casted")
                          local bobberzone = tool:FindFirstChild("values") and tool.values:FindFirstChild("bobberzone")
                          if (not casted or casted.Value == false) and (not bobberzone or bobberzone.Value == "" or bobberzone.Value == "nil" or bobberzone.Value == nil) and not shaky then
                              tool.events.cast:FireServer(unpack(args))
                          end
                      else
                          break
                      end
                      wait(0.169420)
                  end
              end)
          else
              local tool = game:GetService("Players").LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
              if tool then
                  tool.Parent = game:GetService("Players").LocalPlayer.Backpack
              end
          end
      end,
  })




     local Toggle = Tab:CreateToggle({
        Name = "Zone Auto Cast",
        CurrentValue = false,
        Flag = "ZoneAutoCast", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Value)
        end,
     })



     local Dropdown = Tab:CreateDropdown({
        Name = "Zone Cast",
        Options = {"Deep Ocean","Brine Pool","Desolate Deep","Roslit Bay"},
        CurrentOption = {"Choose One"},
        MultipleOptions = false,
        Flag = "ZoneCastDropdown", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Options)
        -- The function that takes place when the selected option is changed
        -- The variable (Options) is a table of strings for the current selected options
        end,
     })



     local Dropdown = Tab:CreateDropdown({
        Name = "Event Cast",
        Options = {"Isonade","Great White Shark","Great Hammerhead Shark","Whale Shark"},
        CurrentOption = {"Choose One"},
        MultipleOptions = false,
        Flag = "EventCastDropdown", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Options)
        -- The function that takes place when the selected option is changed
        -- The variable (Options) is a table of strings for the current selected options
        end,
     })

     local Divider = Tab:CreateDivider()

     local Toggle = Tab:CreateToggle({
        Name = "Freeze",
        CurrentValue = false,
        Callback = function(Value)
         local Players = game:GetService("Players")
         local player = Players.LocalPlayer
         local button = script.Parent
         local isTeleporting = false
         local originalPosition
         local originalOrientation
         local skibidissigmaPart
         local weld
         local scriptParent = script.Parent
         local mrsigmas = scriptParent:FindFirstChild("mrsigmas")
         
         if not mrsigmas then
             mrsigmas = Instance.new("BoolValue")
             mrsigmas.Name = "mrsigmas"
             mrsigmas.Parent = scriptParent
         end
         
         mrsigmas.Value = Value
         
         local function startTeleporting()
             local character = player.Character or player.CharacterAdded:Wait()
             local rootPart = character:WaitForChild("HumanoidRootPart")
         
             originalPosition = rootPart.Position
             originalOrientation = rootPart.Orientation
             while mrsigmas.Value do
                 if skibidissigmaPart then
                     skibidissigmaPart:Destroy()
                     skibidissigmaPart = nil
                     weld = nil
                 end
         
                 local randomnum = math.random(1, 2)
                 skibidissigmaPart = Instance.new("Part")
                 skibidissigmaPart.Size = Vector3.new(1, 1, 1)
                 skibidissigmaPart.Position = originalPosition
                 skibidissigmaPart.Orientation = originalOrientation
                 skibidissigmaPart.Transparency = 0.5
                 skibidissigmaPart.Anchored = true
                 skibidissigmaPart.Name = "Skibidisssigma"
                 skibidissigmaPart.Parent = workspace
         
                 weld = Instance.new("Weld")
                 weld.Name = "ligmaballz"
                 weld.Part0 = skibidissigmaPart
                 weld.Part1 = rootPart
                 weld.C0 = skibidissigmaPart.CFrame:inverse() * rootPart.CFrame
                 weld.C1 = skibidissigmaPart.CFrame:inverse() * rootPart.CFrame
                 weld.Parent = skibidissigmaPart
         
                 if randomnum == 2 then
                     weld:Destroy()
                     skibidissigmaPart:Destroy()
                     skibidissigmaPart = nil
                     weld = nil
                     task.wait(0.69420)
                 else
                     task.wait(0.169)
                 end
             end
         end
         
         local function stopTeleporting()
             wait(0.269)
             if skibidissigmaPart then
                 for _, part in pairs(workspace:GetChildren()) do
                     if part.Name == "Skibidisssigma" then
                         part:Destroy()
                     end
                 end
                 skibidissigmaPart = nil
                 weld = nil
             end
         end
         
         local function nobrainrotthistime()
             if mrsigmas.Value then
                     startTeleporting()
             else
                 stopTeleporting()
             end
         end
         
         nobrainrotthistime()
        end,
     })



     local Toggle = Tab:CreateToggle({
        Name = "Zone Freeze",
        CurrentValue = true,
        Flag = "ZoneFreezeTogg", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Value)
         local Players = game:GetService("Players")
         local player = Players.LocalPlayer
         local button = script.Parent
         local isTeleporting = false
         local originalPosition
         local originalOrientation
         local skibidissigmaPart
         local weld
         local scriptParent = script.Parent
         local mrsigmas = scriptParent:FindFirstChild("mrsigmas")
         
         if not mrsigmas then
             mrsigmas = Instance.new("BoolValue")
             mrsigmas.Name = "mrsigmas"
             mrsigmas.Parent = scriptParent
         end
         
         mrsigmas.Value = Value
         
         local function startTeleporting()
             local character = player.Character or player.CharacterAdded:Wait()
             local rootPart = character:WaitForChild("HumanoidRootPart")
         
             originalPosition = rootPart.Position
             originalOrientation = rootPart.Orientation
             while mrsigmas.Value do
                 if skibidissigmaPart then
                     skibidissigmaPart:Destroy()
                     skibidissigmaPart = nil
                     weld = nil
                 end
         
                 local randomnum = math.random(1, 3)
                 skibidissigmaPart = Instance.new("Part")
                 skibidissigmaPart.Size = Vector3.new(1, 1, 1)
                 skibidissigmaPart.Position = originalPosition
                 skibidissigmaPart.Orientation = originalOrientation
                 skibidissigmaPart.Transparency = 0.5
                 skibidissigmaPart.Anchored = true
                 skibidissigmaPart.Name = "Skibidisssigma"
                 skibidissigmaPart.Parent = workspace
         
                 weld = Instance.new("Weld")
                 weld.Name = "ligmaballz"
                 weld.Part0 = skibidissigmaPart
                 weld.Part1 = rootPart
                 weld.C0 = skibidissigmaPart.CFrame:inverse() * rootPart.CFrame
                 weld.C1 = skibidissigmaPart.CFrame:inverse() * rootPart.CFrame
                 weld.Parent = skibidissigmaPart
         
                 if randomnum == 3 then
                     weld:Destroy()
                     skibidissigmaPart:Destroy()
                     skibidissigmaPart = nil
                     weld = nil
                     task.wait(0.69420)
                 else
                     task.wait(0.169)
                 end
             end
         end
         
         local function stopTeleporting()
             wait(0.269)
             for _, part in pairs(workspace:GetChildren()) do
                 if part.Name == "Skibidisssigma" then
                     part:Destroy()
                 end
             end
             skibidissigmaPart = nil
             weld = nil
         end
         
         local function nobrainrotthistime()
             if mrsigmas.Value then
                     startTeleporting()
             else
                 stopTeleporting()
             end
         end
         
         nobrainrotthistime()
        end,
     })
 










local Tab = Window:CreateTab("Crab Cage", 11767069582) -- Title, Image
    local Section = Tab:CreateSection("Crab Cage")
    local Input = Tab:CreateInput({
        Name = "Buy Crab Cage",
        CurrentValue = "",
        PlaceholderText = "How many u want to buy",
        RemoveTextAfterFocusLost = false,
        Callback = function(Text)
        -- The function that takes place when the input is changed
        -- The variable (Text) is a string for the value in the text box
        end,
     })

     local Button = Tab:CreateButton({
        Name = "Place One Crab cage",
        Callback = function()
        -- The function that takes place when the button is pressed
        end,
     })


     local Toggle = Tab:CreateToggle({
        Name = "Place All Crab Cage",
        CurrentValue = false,
        Callback = function(Value)
        -- The function that takes place when the toggle is pressed
        -- The variable (Value) is a boolean on whether the toggle is true or false
        end,
     })


     local Toggle = Tab:CreateToggle({
        Name = "Claim crab cage (near)",
        CurrentValue = false,
        Callback = function(Value)
        -- The function that takes place when the toggle is pressed
        -- The variable (Value) is a boolean on whether the toggle is true or false
        end,
     })



     local Button = Tab:CreateButton({
        Name = "Hide Crab Cage",
        Callback = function()
        -- The function that takes place when the button is pressed
        end,
     })




local Tab = Window:CreateTab("TP", 11767069582) -- Title, Image
    local Section = Tab:CreateSection("Teleport")
    local Input = Tab:CreateInput({
    Name = "Tp TO",
    CurrentValue = "",
    PlaceholderText = "Type the username",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
    -- The function that takes place when the input is changed
    -- The variable (Text) is a string for the value in the text box
    end,
 })

   local Dropdown = Tab:CreateDropdown({
   Name = "Teleport Zone",
   Options = {"Moosewood", "Sunstone Island", "Terrapin Island", "Roslit Bay", "Arch", "Snowcap Island", "Mushgrove Swamp", "Statue Of Sovereignty", "Vertigo", "Keepers Altar", "Forsaken Shore", "Desolate Deep", "Harvesters Spike", "Birch Cay", "Earmark Island", "The Depths"},
   CurrentOption = {"Choose"},
   MultipleOptions = false,
   Callback = function(Options)
   local player = game.Players.LocalPlayer
       local character = player.Character
       local rootPart = character:WaitForChild("HumanoidRootPart")
       if Options[1] == "Moosewood" then
           rootPart.Position = Vector3.new(386.3420715332031, 134.50051879882812, 245.22225952148438)
       elseif Options[1] == "Sunstone Island" then
           rootPart.Position = Vector3.new(-928.51123046875, 131.37030029296875, -1113.084716796875)
       elseif Options[1] == "Terrapin Island" then
           rootPart.Position = Vector3.new(-194.75677490234375, 135.02825927734375, 1949.579833984375)
       elseif Options[1] == "Roslit Bay" then
           rootPart.Position = Vector3.new(-1497.358642578125, 133.00003051757812, 630.5381469726562)
       elseif Options[1] == "Arch" then
           rootPart.Position = Vector3.new(1002.1404418945312, 131.3202362060547, -1244.3638916015625)
       elseif Options[1] == "Snowcap Island" then
           rootPart.Position = Vector3.new(2608.3046875, 135.2838592529297, 2397.0341796875)
       elseif Options[1] == "Mushgrove Swamp" then
           rootPart.Position = Vector3.new(2453.543212890625, 130.65296936035156, -665.6732177734375)
       elseif Options[1] == "Statue Of Sovereignty" then
           rootPart.Position = Vector3.new(40.73866653442383, 133.2073211669922, -1011.77587890625)
       elseif Options[1] == "Vertigo" then
           rootPart.Position = Vector3.new(-120.59034729003906, -515.29931640625, 1143.71240234375)
       elseif Options[1] == "Keepers Altar" then
           rootPart.Position = Vector3.new(1297.457275390625, -805.2922973632812, -295.951171875)
       elseif Options[1] == "Forsaken Shore" then
           rootPart.Position = Vector3.new(-2495.73193359375, 133.25001525878906, 1559.684326171875)
       elseif Options[1] == "Desolate Deep" then
           rootPart.Position = Vector3.new(-1609.1846923828125, -231.07492065429688, -2896.917724609375)
       elseif Options[1] == "Harvesters Spike" then
           rootPart.Position = Vector3.new(-558.7638549804688, 166.93368530273438, -365.0516662597656)
       elseif Options[1] == "Birch Cay" then
           rootPart.Position = Vector3.new(1735.5574951171875, 143, -2434.491455078125)
       elseif Options[1] == "Earmark Island" then
           rootPart.Position = Vector3.new(1246.6859130859375, 147.10130310058594, 509.4786071777344)
       elseif Options[1] == "The Depths" then
           rootPart.Position = Vector3.new(568.153, -701.881, 1230.85)
       end
   end,
   })

   local Divider = Tab:CreateDivider()

   local Button = Tab:CreateButton({
      Name = "Map 'Fix'",
      Callback = function()
      -- The function that takes place when the button is pressed
      end,
   })

   local Button = Tab:CreateButton({
      Name = "Tp To chest",
      Callback = function()
      -- The function that takes place when the button is pressed
      end,
   })




local Tab = Window:CreateTab("Appraiser", 11767069582) -- Title, Image
    local Section = Tab:CreateSection("Appraiser")
    local Toggle = Tab:CreateToggle({
        Name = "off/on",
        CurrentValue = false,
        Callback = function(Value)
        -- The function that takes place when the toggle is pressed
        -- The variable (Value) is a boolean on whether the toggle is true or false
        end,
     })

     local Slider = Tab:CreateSlider({
        Name = "Delay",
        Range = {0.05, 1},
        Increment = 0.01,
        Suffix = "Delay",
        CurrentValue = 0.45,
        Flag = "Appraiser1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Value)
        -- The function that takes place when the slider changes
        -- The variable (Value) is a number which correlates to the value the slider is currently at
        end,
     })



     local Toggle = Tab:CreateToggle({
        Name = "Shiny",
        CurrentValue = false,
        Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Value)
        -- The function that takes place when the toggle is pressed
        -- The variable (Value) is a boolean on whether the toggle is true or false
        end,
     })


     local Toggle = Tab:CreateToggle({
        Name = "Sparkling",
        CurrentValue = false,
        Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
        Callback = function(Value)
        -- The function that takes place when the toggle is pressed
        -- The variable (Value) is a boolean on whether the toggle is true or false
        end,
     })



     local Dropdown = Tab:CreateDropdown({
        Name = "Mutation",
        Options = {"Translucent","Darkened","Frozen","Albino","Negative","Silver","Electric","Glossy","Midas","Mythical","Ghastly","Sinister","Mosaic","Aurora","Atlantean","Nuclear","Hexed","Sunken"},
        CurrentOption = {"Meow"},
        MultipleOptions = false,
        Callback = function(Options)
        -- The function that takes place when the selected option is changed
        -- The variable (Options) is a table of strings for the current selected options
        end,
     })





local Tab = Window:CreateTab("Credits", 11767069582) -- Title, Image
    local Divider = Tab:CreateDivider()
    local Paragraph = Tab:CreateParagraph({Title = "Meow!", Content = "Thank you for using our script! it means alot, The ui is made by 📞, the scripts and etc by zel!!"})
    local Divider = Tab:CreateDivider()
    local Section = Tab:CreateSection("Discord")
    local inviteLink = "discord.gg/jMcAfH8BEN"
    local Button = Tab:CreateButton({
        Name = "Discord to clipboard",
        Callback = function()
        -- The function that takes place when the button is pressed
        setclipboard(inviteLink)
        end,
     })

     local Button = Tab:CreateButton({
      Name = "Rejoin",
      Callback = function()
      -- The function that takes place when the button is pressed
      end,
   })

-- Themes Tab (do not delete)
    local TTab = Window:CreateTab("Theme", 11767069582)
    local OSection = TTab:CreateSection("Themes")

    local Button = TTab:CreateButton({
    Name = "Default Theme",
    Flag = "DefaultTheme", 
    Callback = function()
    Window.ModifyTheme('Default')
    end,
    })

    local Button = TTab:CreateButton({
    Name = "AmberGlow Theme",
    Flag = "AmberGlow", 
    Callback = function()
    Window.ModifyTheme('AmberGlow')
    end,
    })

    local Button = TTab:CreateButton({
    Name = "Amethyst Theme",
    Flag = "Amethyst", 
    Callback = function()
    Window.ModifyTheme('Amethyst')
    end,
    })

    local Button = TTab:CreateButton({
    Name = "Bloom Theme",
    Flag = "Bloom", 
    Callback = function()
    Window.ModifyTheme('Bloom')
    end,
    })

    local Button = TTab:CreateButton({
    Name = "DarkBlue Theme",
    Flag = "DarkBlue", 
    Callback = function()
    Window.ModifyTheme('DarkBlue')
    end,
    })

    local Button = TTab:CreateButton({
    Name = "Green Theme",
    Flag = "Green", 
    Callback = function()
    Window.ModifyTheme('Green')
    end,
    })

    local Button = TTab:CreateButton({
    Name = "Light Theme",
    Flag = "Light", 
    Callback = function()
    Window.ModifyTheme('Light')
    end,
    })

    local Button = TTab:CreateButton({
    Name = "Ocean Theme",
    Flag = "Ocean", 
    Callback = function()
    Window.ModifyTheme('Ocean')
    end,
    })
 

-- NOTIFICATION ON EXECUTE


 Rayfield:Notify({
    Title = "Notification!",
    Content = "Please join our discord in Credits, it helps us alot",
    Duration = 6.5,
    Image = 4483362458,
    Actions = { -- Notification Buttons
 
       Ignore = { -- Duplicate this table (or remove it) to add and remove buttons to the notification.
          Name = "Okay!",
          Callback = function()
             print("The user tapped Okay!")
          end
       },
       
 
 },
 })
Rayfield:LoadConfiguration()
end
