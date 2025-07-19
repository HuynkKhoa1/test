local Fluent = loadstring(Game:HttpGet("https://raw.githubusercontent.com/discoart/FluentPlus/refs/heads/main/Beta.lua", true))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "ASTD ",
    SubTitle = "By Khoa",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "swords" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

local AutoCheck = Tabs.Main:AddToggle("AutoCheck", {
    Title = "Auto Check",
    Description = "Auto Check if you are in Infinite Mode",
    Default = false,
    Callback = function(value)
    end
})

local AccountOption = Tabs.Main:AddSection("Option [ Account ]")

local Carry = Tabs.Main:AddToggle("Carry", {
    Title = "Carry",
    Description = "This acc will be carry account",
    Default = false,
    Callback = function(value)
    end
})

local InfRoom = Tabs.Main:AddDropdown("InfRoom", {
    Title = "Inf Room",
    Description = "Select the Infinite Room",
    Values = {"1", "2", "3", "4", "5", "6", "7", "8"},
    Multi = false,
    Default = 1,
    Callback = function(Value)
        local roomPaths = {
            ["1"] = workspace.Map.Buildings.InfinitePods:GetChildren()[8].room,
            ["2"] = workspace.Map.Buildings.InfinitePods.StoryPod.room,
            ["3"] = workspace.Map.Buildings.InfinitePods:GetChildren()[4].room,
            ["4"] = workspace.Map.Buildings.InfinitePods:GetChildren()[2].room,
            ["5"] = workspace.Map.Buildings.InfinitePods:GetChildren()[6].room,
            ["6"] = workspace.Map.Buildings.InfinitePods:GetChildren()[5].room,
            ["7"] = workspace.Map.Buildings.InfinitePods:GetChildren()[7].room,
            ["8"] = workspace.Map.Buildings.InfinitePods:GetChildren()[3].room,
        }
        print("Inf Room selected:", Value, "Path:", roomPaths[Value])
    end
})

local Normal = Tabs.Main:AddToggle("Normal", {
    Title = "Normal",
    Description = "This acc will be will get carry by Carry account",
    Default = false,
    Callback = function(value)
    end
})

local Section = Tabs.Main:AddSection("Loop Check")

local AutoJoinInfinite = Tabs.Main:AddToggle("AutoJoinInfinite", {
    Title = "Auto Join Infinite",
    Description = "Auto Join Infinite Mode",
    Default = false,
    Callback = function(value)
        if value then
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer
            local targetUsernames = {}
            local stopTeleport = false
            local scanRadius = 10 -- Studs to scan for players
            local VirtualInputManager = game:GetService("VirtualInputManager")

            -- Check if either Carry or Normal is selected
            if not Options.Carry.Value and not Options.Normal.Value then
                Fluent:Notify({
                    Title = "Error",
                    Content = "Please select either Carry or Normal mode first!",
                    Duration = 5
                })
                Options.AutoJoinInfinite:SetValue(false)
                return
            end

            -- Validate required inputs based on mode
            if Options.Carry.Value then
                if Options.Username1.Value == "" or Options.Username2.Value == "" or (Options.Username3 and Options.Username3.Value == "") then
                    Fluent:Notify({
                        Title = "Error",
                        Content = "Please fill Username 1, Username 2, and Username 3!",
                        Duration = 5
                    })
                    Options.AutoJoinInfinite:SetValue(false)
                    return
                end
                table.insert(targetUsernames, Options.Username1.Value)
                table.insert(targetUsernames, Options.Username2.Value)
                table.insert(targetUsernames, Options.Username3.Value)
            elseif Options.Normal.Value then
                if Options.CarryUsername.Value == "" or Options.Username1.Value == "" or Options.Username2.Value == "" then
                    Fluent:Notify({
                        Title = "Error",
                        Content = "Please fill Carry Username, Username 1, and Username 2!",
                        Duration = 5
                    })
                    Options.AutoJoinInfinite:SetValue(false)
                    return
                end
                table.insert(targetUsernames, Options.CarryUsername.Value)
                table.insert(targetUsernames, Options.Username1.Value)
                table.insert(targetUsernames, Options.Username2.Value)
            end

            -- Room paths with exact floor parts
            local roomPaths = {
                ["1"] = workspace.Map.Buildings.InfinitePods:GetChildren()[8].room.room.floor,
                ["2"] = workspace.Map.Buildings.InfinitePods.StoryPod.room.room.floor,
                ["3"] = workspace.Map.Buildings.InfinitePods:GetChildren()[4].room.room.floor,
                ["4"] = workspace.Map.Buildings.InfinitePods:GetChildren()[2].room.room.floor,
                ["5"] = workspace.Map.Buildings.InfinitePods:GetChildren()[6].room.room.floor,
                ["6"] = workspace.Map.Buildings.InfinitePods:GetChildren()[5].room.room.floor,
                ["7"] = workspace.Map.Buildings.InfinitePods:GetChildren()[7].room.room.floor,
                ["8"] = workspace.Map.Buildings.InfinitePods:GetChildren()[3].room.room.floor,
            }

            -- Function to check for players in radius
            local function checkPlayersInRadius()
                local character = LocalPlayer.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then
                    return false
                end

                local rootPos = character.HumanoidRootPart.Position
                local playersFound = 0

                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and table.find(targetUsernames, player.Name) then
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local distance = (player.Character.HumanoidRootPart.Position - rootPos).Magnitude
                            if distance <= scanRadius then
                                playersFound = playersFound + 1
                            end
                        end
                    end
                end

                return playersFound >= #targetUsernames
            end

            -- Function to spam E key
            local function spamEKey()
                for i = 1, 5 do -- Spam E key 5 times
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    wait(0.1)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                end
            end

            -- Function to check CarryUsername in Dex
            local function checkDexForCarry()
                local success, dex = pcall(function()
                    return game:GetService("Dex") or game.Workspace:FindFirstChild("Dex") -- Adjust Dex location if needed
                end)
                if success and dex then
                    for _, playerData in pairs(dex:GetPlayers() or {}) do -- Adjust GetPlayers() based on Dex structure
                        if playerData.Name == Options.CarryUsername.Value and playerData.ProfileID then -- Adjust field names
                            return true
                        end
                    end
                end
                return false
            end

            -- Main teleport and scan loop
            spawn(function()
                while Options.AutoJoinInfinite.Value and not stopTeleport do
                    -- First check if we already have the team
                    if checkPlayersInRadius() then
                        Fluent:Notify({
                            Title = "Team Status",
                            Content = "Found Team",
                            Duration = 5
                        })
                        stopTeleport = true

                        -- Logic for Carry account
                        if Options.Carry.Value then
                            spamEKey() -- Spam E key
                        end

                        -- Logic for Normal account
                        if Options.Normal.Value then
                            while not checkDexForCarry() and Options.AutoJoinInfinite.Value do
                                wait(1) -- Check every 1 second
                            end
                            if checkDexForCarry() then
                                spamEKey() -- Spam E key when CarryUsername appears in Dex
                            end
                        end
                        break
                    end

                    -- Teleport to selected room
                    local selectedRoom = Options.InfRoom.Value
                    local floorPart = roomPaths[selectedRoom]
                    
                    if floorPart and floorPart:IsA("BasePart") then
                        -- Teleport to the room
                        LocalPlayer.Character.HumanoidRootPart.CFrame = floorPart.CFrame + Vector3.new(0, 5, 0)
                        Fluent:Notify({
                            Title = "Teleporting",
                            Content = "Teleporting to Infinite Room "..selectedRoom,
                            Duration = 2
                        })

                        -- Scan for players after teleporting
                        for i = 1, 5 do -- Scan for 10 seconds (5 iterations * 2 seconds)
                            if not Options.AutoJoinInfinite.Value then break end
                            
                            if checkPlayersInRadius() then
                                Fluent:Notify({
                                    Title = "Team Status",
                                    Content = "Found Team",
                                    Duration = 5
                                })
                                stopTeleport = true

                                -- Logic for Carry account
                                if Options.Carry.Value then
                                    spamEKey() -- Spam E key
                                end

                                -- Logic for Normal account
                                if Options.Normal.Value then
                                    while not checkDexForCarry() and Options.AutoJoinInfinite.Value do
                                        wait(1) -- Check every 1 second
                                    end
                                    if checkDexForCarry() then
                                        spamEKey() -- Spam E key when CarryUsername appears in Dex
                                    end
                                end
                                break
                            end
                            wait(2) -- Wait 2 seconds between scans
                        end
                    else
                        Fluent:Notify({
                            Title = "Error",
                            Content = "Invalid room selection",
                            Duration = 3
                        })
                        wait(2)
                    end
                end
            end)
        else
            stopTeleport = true
        end
    end
})

local CarryUsername = Tabs.Main:AddInput("CarryUsername", {
    Title = "Carry Username",
    Description = "Enter your Carry Username",
    Default = "",
    Placeholder = "Enter Carry Username",
    Numeric = false,
    Finished = false,
    Callback = function(value)
    end
})

local Username1 = Tabs.Main:AddInput("Username1", {
    Title = "Username 1",
    Description = "Enter your Username 1",
    Default = "",
    Placeholder = "Enter Username 1",
    Numeric = false,
    Finished = false,
    Callback = function(value)
    end
})

local Username2 = Tabs.Main:AddInput("Username2", {
    Title = "Username 2",
    Description = "Enter your Username 2",
    Default = "",
    Placeholder = "Enter Username 2",
    Numeric = false,
    Finished = false,
    Callback = function(value)
    end
})

local Username3 = Tabs.Main:AddInput("Username3", {
    Title = "Username 3",
    Description = "Enter your Username 3",
    Default = "",
    Placeholder = "Enter Username 3",
    Numeric = false,
    Finished = false,
    Callback = function(value)
    end
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

SaveManager:LoadAutoloadConfig()
