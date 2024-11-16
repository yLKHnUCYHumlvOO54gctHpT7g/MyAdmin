local DataStoreService = game:GetService("DataStoreService")
local adminDataStore = DataStoreService:GetDataStore("AdminDataStore")
local adminCmd = {
    "AK_ADMEN1", "Xeni_he07", "AK_ADMEN2", "goekaycool", "GYATT_DAMN1", 
    "BloxiAstra", "IIIlIIIllIlIllIII", "AliKhammas1234", 
    "dgthgcnfhhbsd", "AliKhammas", "YournothimbuddyXD"
}
local commandsList = {
    ".rejoin", ".fast", ".normal", ".slow", ".unfloat", ".float",
    ".void", ".jump", ".trip", ".sit", ".freeze", ".unfreeze",
    ".kick", ".kill", ".bring", ".js", ".js2", ".invert", 
    ".uninvert", ".spin", ".unspin", ".disablejump", ".unenablejump",
    ".squeak", ".bighead", ".tiny", ".big", ".sillyhat"
}
local frozenPlayers = {}
local controlInversionActive = {}
local spinActive = {}
local jumpDisabled = {}

local function Chat(msg)
    game.StarterGui:SetCore("ChatMakeSystemMessage", {
        Text = msg,
        Color = Color3.new(1, 0, 0),
        Font = Enum.Font.SourceSans,
        FontSize = Enum.FontSize.Size24,
    })
end

local function nameMatches(player, partialName)
    local nameLower = player.Name:lower()
    local displayNameLower = player.DisplayName:lower()
    partialName = partialName:lower()
    return nameLower:find(partialName) or displayNameLower:find(partialName)
end

local function createCommandGui(admin)
    -- Create a ScreenGui for the admin with a list of commands
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AdminCommandGUI"
    screenGui.Parent = admin.PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 400)
    frame.Position = UDim2.new(0, 10, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    frame.Parent = screenGui

    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Parent = frame
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uiListLayout.Padding = UDim.new(0, 10)

    for _, cmd in ipairs(commandsList) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, 30)
        button.Text = cmd
        button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.Font = Enum.Font.SourceSans
        button.FontSize = Enum.FontSize.Size18
        button.Parent = frame

        button.MouseButton1Click:Connect(function()
            admin:Chatted(cmd)
        end)
    end
end

local function executeCommand(admin, target, command)
    if admin.Name == target.Name then
        return -- Prevent executing on the admin themselves
    end

    if command == ".kill" then
        target.Character.Humanoid.Health = 0
    elseif command == ".bring" then
        target.Character.HumanoidRootPart.CFrame = admin.Character.HumanoidRootPart.CFrame
    end
end

local function setupAdminCommands(admin)
    admin.Chatted:Connect(function(msg)
        msg = msg:lower()
        local command, targetPartialName = msg:match("^(%S+)%s+(.*)$")
        if not command or not targetPartialName then
            command = msg -- If no target name is specified, just check the command
        end

        local target = nil
        -- Find the target player
        for _, player in ipairs(game.Players:GetPlayers()) do
            if nameMatches(player, targetPartialName) then
                target = player
                break
            end
        end

        -- If a target is found, execute the command
        if target then
            if command == ".ownercmds" then
                createCommandGui(player)
            elseif command == ".rejoin" then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
            elseif command == ".fast" then
                player.Character.Humanoid.WalkSpeed = 50
            elseif command == ".normal" then
                player.Character.Humanoid.WalkSpeed = 16
            elseif command == ".slow" then
                player.Character.Humanoid.WalkSpeed = 5
            elseif command == ".unfloat" then
                player.Character.HumanoidRootPart.Anchored = false
            elseif command == ".float" then
                player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
                wait(0.3)
                player.Character.HumanoidRootPart.Anchored = true
            elseif command == ".void" then
                player.Character.HumanoidRootPart.CFrame = CFrame.new(1000000, 1000000, 1000000)
            elseif command == ".jump" then
                player.Character.Humanoid.Jump = true
            elseif command == ".trip" then
                player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
                player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
            elseif command == ".sit" then
                player.Character.Humanoid.Sit = true
            elseif command == ".freeze" then
                player.Character.HumanoidRootPart.Anchored = true
                frozenPlayers[player.UserId] = true
            elseif command == ".unfreeze" then
                for userId in pairs(frozenPlayers) do
                    local frozenPlayer = game.Players:GetPlayerByUserId(userId)
                    if frozenPlayer and frozenPlayer.Character then
                        frozenPlayer.Character.HumanoidRootPart.Anchored = false
                    end
                end
                frozenPlayers = {}
            elseif command == ".kick" then
                player:Kick("Kicked")
            elseif command == ".kill" then
                player.Character.Humanoid.Health = 0
            elseif command == ".bring" then
                player.Character.HumanoidRootPart.CFrame = admin.Character.HumanoidRootPart.CFrame
            elseif command == ".js" then
                local jumpscareGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
                local img = Instance.new("ImageLabel", jumpscareGui)
                img.Size, img.Image = UDim2.new(1, 0, 1, 0), "http://www.roblox.com/asset/?id=10798732430"
                local sound = Instance.new("Sound", game:GetService("SoundService"))
                sound.SoundId, sound.Volume = "rbxassetid://7076365030", 10
                sound:Play()
                wait(1.674)
                jumpscareGui:Destroy()
                sound:Destroy()
            elseif command == ".js2" then
                local jumpscareGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
                local img = Instance.new("ImageLabel", jumpscareGui)
                img.Size, img.Image = UDim2.new(1, 0, 1, 0), "http://www.roblox.com/asset/?id=75431648694596"
                local sound = Instance.new("Sound", game:GetService("SoundService"))
                sound.SoundId, sound.Volume = "rbxassetid://5567523008", 10
                sound:Play()
                wait(3.599)
                jumpscareGui:Destroy()
                sound:Destroy()
            elseif command == ".invert" then
                if not controlInversionActive[player.UserId] then
                    controlInversionActive[player.UserId] = true
                    local char = player.Character
                    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        local inversionConnection = humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
                            humanoid:Move(Vector3.new(-humanoid.MoveDirection.X, 0, -humanoid.MoveDirection.Z), true)
                        end)
                        wait(10) -- Invert for 10 seconds
                        inversionConnection:Disconnect()
                        controlInversionActive[player.UserId] = nil
                    end
                end
            elseif command == ".uninvert" then
                if controlInversionActive[player.UserId] then
                    controlInversionActive[player.UserId] = nil
                end
            elseif command == ".spin" then
                if not spinActive[player.UserId] then
                    spinActive[player.UserId] = true
                    local char = player.Character
                    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        local initialRotation = char.HumanoidRootPart.CFrame
                        for i = 1, 12 do
                            wait(0.1)
                            char.HumanoidRootPart.CFrame = initialRotation * CFrame.Angles(0, math.rad(30 * i), 0)
                        end
                    end
                end
            elseif command == ".unspin" then
                if spinActive[player.UserId] then
                    spinActive[player.UserId] = nil
                end
            elseif command == ".disablejump" then
                if not jumpDisabled[player.UserId] then
                    jumpDisabled[player.UserId] = true
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.JumpPower = 0
                        wait(5)
                        humanoid.JumpPower = 50 -- Reset jump power (default can vary)
                        jumpDisabled[player.UserId] = nil
                    end
                end
            elseif command == ".unenablejump" then
                if jumpDisabled[player.UserId] then
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.JumpPower = 50 -- Reset jump power
                    end
                    jumpDisabled[player.UserId] = nil
                end
            elseif command == ".squeak" then
                local sound = Instance.new("Sound", player.Character)
                sound.SoundId = "rbxassetid://507771019"
                sound:Play()
                wait(1) -- Wait for the sound to finish
                sound:Destroy()
            elseif command == ".bighead" then
                local head = player.Character:FindFirstChild("Head")
                if head then
                    head.Size = head.Size * 2
                end
            elseif command == ".tiny" then
                local char = player.Character
                if char then
                    char:FindFirstChild("Humanoid").RootPart.Size = Vector3.new(0.5, 0.5, 0.5)
                end
            elseif command == ".big" then
                local char = player.Character
                if char then
                    char:FindFirstChild("Humanoid").RootPart.Size = Vector3.new(2, 2, 2)
                end
            elseif command == ".sillyhat" then
                local hat = Instance.new("Accessory")
                local mesh = Instance.new("SpecialMesh")
                mesh.MeshId = "rbxassetid://507771019" -- Change this to a funny hat asset ID
                mesh.Parent = hat
                hat.Parent = player.Character
            end
        end
    end)
end

-- Function to add player to admin list
local function addAdminToDataStore(player)
    local success, errorMessage = pcall(function()
        adminDataStore:SetAsync(player.UserId, true)
    end)
    if not success then
        Chat("Failed to save admin data for " .. player.Name .. ": " .. errorMessage)
    end
end

-- Load the admin list from data store
local function loadAdmins()
    for _, player in ipairs(game.Players:GetPlayers()) do
        local success, isAdmin = pcall(function()
            return adminDataStore:GetAsync(player.UserId)
        end)
        if success and isAdmin then
            table.insert(adminCmd, player.Name)
        end
    end
end

-- Apply commands for admins
game.Players.PlayerAdded:Connect(function(player)
    -- Check if the player is already an admin
    local success, isAdmin = pcall(function()
        return adminDataStore:GetAsync(player.UserId)
    end)
    
    if success and isAdmin then
        table.insert(adminCmd, player.Name)
        setupAdminCommands(player)
        addAdminToDataStore(player)
    end
end)

game.Players.PlayerAdded:Connect(function(player)
    loadAdmins()
end)
