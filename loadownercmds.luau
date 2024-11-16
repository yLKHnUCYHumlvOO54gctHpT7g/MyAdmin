local function nameMatches(player, partialName)
    local nameLower = player.Name:lower()
    local displayNameLower = player.DisplayName:lower()
    partialName = partialName:lower()
    return nameLower:find(partialName) or displayNameLower:find(partialName)
end

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

local function createCommandGui(player)
    -- Create a ScreenGui
    local gui = Instance.new("ScreenGui", player.PlayerGui)
    gui.Name = "CommandGui"

    -- Create a Frame
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0.5, 0, 0.5, 0)
    frame.Position = UDim2.new(0.25, 0, 0.25, 0)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 0

    -- Create a TextLabel for the title
    local titleLabel = Instance.new("TextLabel", frame)
    titleLabel.Size = UDim2.new(1, 0, 0.1, 0)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.Text = "Owner Commands"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 24

    -- Create a scrolling frame for commands
    local scrollFrame = Instance.new("ScrollingFrame", frame)
    scrollFrame.Size = UDim2.new(1, 0, 0.9, 0)
    scrollFrame.Position = UDim2.new(0, 0, 0.1, 0)
    scrollFrame.BackgroundColor3 = Color3.new(1, 1, 1)
    scrollFrame.ScrollBarThickness = 10

    -- Create a UIListLayout for the commands
    local layout = Instance.new("UIListLayout", scrollFrame)
    layout.Padding = UDim.new(0, 5)

    -- Populate the scrolling frame with command labels
    for _, command in ipairs(commandsList) do
        local commandLabel = Instance.new("TextLabel", scrollFrame)
        commandLabel.Size = UDim2.new(1, 0, 0, 30)
        commandLabel.Text = command
        commandLabel.TextColor3 = Color3.new(0, 0, 0)
        commandLabel.BackgroundTransparency = 1
        commandLabel.Font = Enum.Font.SourceSans
        commandLabel.TextSize = 20
    end

    -- Close button
    local closeButton = Instance.new("TextButton", frame)
    closeButton.Size = UDim2.new(0.2, 0, 0.1, 0)
    closeButton.Position = UDim2.new(0.4, 0, 0.9, 0)
    closeButton.Text = "Close"
    closeButton.BackgroundColor3 = Color3.new(1, 0, 0)
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.Font = Enum.Font.SourceSans
    closeButton.TextSize = 20

    -- Close the GUI when the button is clicked
    closeButton.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
end

-- Function to setup command listeners for each admin
local function setupAdminCommands(admin)
    admin.Chatted:Connect(function(msg)
        msg = msg:lower()
        local command, targetPartialName = msg:match("^(%S+)%s+(.*)$")
        if not command or not targetPartialName then
            command = msg -- If no target name is specified, just check the command
        end

        local player = game.Players.LocalPlayer
        local target = nil

        -- Find the target player by name match
        for _, p in pairs(game.Players:GetPlayers()) do
            if nameMatches(p, targetPartialName) and p.UserId ~= player.UserId then
                target = p
                break
            end
        end

        -- Ensure there is a valid target
        if not target then
            Chat("Player not found!")
            return
        end

        if command then
            -- Admin Commands
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
                target.Character.HumanoidRootPart.Anchored = true
                frozenPlayers[target.UserId] = true
            elseif command == ".unfreeze" then
                for userId in pairs(frozenPlayers) do
                    local frozenPlayer = game.Players:GetPlayerByUserId(userId)
                    if frozenPlayer and frozenPlayer.Character then
                        frozenPlayer.Character.HumanoidRootPart.Anchored = false
                    end
                end
                frozenPlayers = {}
            elseif command == ".kick" then
                target:Kick("You have been kicked by an admin.")
            elseif command == ".kill" then
                target.Character.Humanoid.Health = 0
            elseif command == ".bring" then
                player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
            elseif command == ".js" then
                local jumpscareGui = Instance.new("ScreenGui", target:WaitForChild("PlayerGui"))
                local img = Instance.new("ImageLabel", jumpscareGui)
                img.Size, img.Image = UDim2.new(1, 0, 1, 0), "http://www.roblox.com/asset/?id=10798732430"
                local sound = Instance.new("Sound", game:GetService("SoundService"))
                sound.SoundId, sound.Volume = "rbxassetid://7076365030", 10
                sound:Play()
                wait(1.674)
                jumpscareGui:Destroy()
                sound:Destroy()
            elseif command == ".js2" then
                local jumpscareGui = Instance.new("ScreenGui", target:WaitForChild("PlayerGui"))
                local img = Instance.new("ImageLabel", jumpscareGui)
                img.Size, img.Image = UDim2.new(1, 0, 1, 0), "http://www.roblox.com/asset/?id=10807042621"
                local sound = Instance.new("Sound", game:GetService("SoundService"))
                sound.SoundId, sound.Volume = "rbxassetid://7076365030", 10
                sound:Play()
                wait(1.674)
                jumpscareGui:Destroy()
                sound:Destroy()
            elseif command == ".invert" then
                controlInversionActive[target.UserId] = true
                target.Character.Humanoid.PlatformStand = true
            elseif command == ".uninvert" then
                controlInversionActive[target.UserId] = nil
                target.Character.Humanoid.PlatformStand = false
            elseif command == ".spin" then
                spinActive[target.UserId] = true
                while spinActive[target.UserId] do
                    target.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(10), 0)
                    wait(0.1)
                end
            elseif command == ".unspin" then
                spinActive[target.UserId] = nil
            elseif command == ".disablejump" then
                jumpDisabled[target.UserId] = true
            elseif command == ".unenablejump" then
                jumpDisabled[target.UserId] = nil
            elseif command == ".squeak" then
                local squeakSound = Instance.new("Sound", target.Character)
                squeakSound.SoundId = "rbxassetid://6435229136"
                squeakSound:Play()
            elseif command == ".bighead" then
                target.Character.Head.Size = Vector3.new(10, 10, 10)
            elseif command == ".tiny" then
                target.Character.HumanoidRootPart.Size = Vector3.new(1, 1, 1)
            elseif command == ".big" then
                target.Character.HumanoidRootPart.Size = Vector3.new(10, 10, 10)
            elseif command == ".sillyhat" then
                local hat = Instance.new("Hat", target.Character)
                hat.Name = "Silly Hat"
                local mesh = Instance.new("SpecialMesh", hat)
                mesh.MeshId = "rbxassetid://10807042621"
            end
        end
    end)
end

game.Players.PlayerAdded:Connect(function(player)
    for _, adminName in ipairs(adminCmd) do
        if player.Name == adminName then
            setupAdminCommands(player)
        end
    end
end)
