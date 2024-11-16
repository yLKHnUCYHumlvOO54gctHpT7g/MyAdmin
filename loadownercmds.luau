local function nameMatches(player, partialName)
    local nameLower = player.Name:lower()
    local displayNameLower = player.DisplayName:lower()
    partialName = partialName:lower()
    return nameLower == partialName or displayNameLower == partialName
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
local function nameMatches(player, partialName)
    local nameLower = player.Name:lower()
    local displayNameLower = player.DisplayName:lower()
    partialName = partialName:lower()
    return nameLower == partialName or displayNameLower == partialName
end

local function setupAdminCommands(admin)
    admin.Chatted:Connect(function(msg)
        msg = msg:lower()
        local command, targetPartialName = msg:match("^(%S+)%s*(.*)$")
        if not command then return end -- If the message doesn't contain a command, do nothing

        -- Admin Commands
        if command == ".ownercmds" then
            createCommandGui(admin)
        elseif command == ".rejoin" then
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, admin)
        elseif command == ".fast" then
            admin.Character.Humanoid.WalkSpeed = 50
        elseif command == ".normal" then
            admin.Character.Humanoid.WalkSpeed = 16
        elseif command == ".slow" then
            admin.Character.Humanoid.WalkSpeed = 5
        elseif command == ".unfloat" then
            admin.Character.HumanoidRootPart.Anchored = false
        elseif command == ".float" then
            admin.Character.HumanoidRootPart.CFrame = admin.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
            wait(0.3)
            admin.Character.HumanoidRootPart.Anchored = true
        elseif command == ".void" then
            admin.Character.HumanoidRootPart.CFrame = CFrame.new(1000000, 1000000, 1000000)
        elseif command == ".jump" then
            admin.Character.Humanoid.Jump = true
        elseif command == ".trip" then
            admin.Character.HumanoidRootPart.CFrame = admin.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
            admin.Character.Humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
        elseif command == ".sit" then
            admin.Character.Humanoid.Sit = true
        elseif command == ".freeze" then
            admin.Character.HumanoidRootPart.Anchored = true
            frozenPlayers[admin.UserId] = true
        elseif command == ".unfreeze" then
            for userId in pairs(frozenPlayers) do
                local frozenPlayer = game.Players:GetPlayerByUserId(userId)
                if frozenPlayer and frozenPlayer.Character then
                    frozenPlayer.Character.HumanoidRootPart.Anchored = false
                end
            end
            frozenPlayers = {}
        elseif command == ".kick" then
            admin:Kick("Kicked")
        elseif command == ".kill" then
            admin.Character.Humanoid.Health = 0
        elseif command == ".bring" then
            admin.Character.HumanoidRootPart.CFrame = admin.Character.HumanoidRootPart.CFrame
        elseif command == ".js" then
            local jumpscareGui = Instance.new("ScreenGui", admin:WaitForChild("PlayerGui"))
            local img = Instance.new("ImageLabel", jumpscareGui)
            img.Size, img.Image = UDim2.new(1, 0, 1, 0), "http://www.roblox.com/asset/?id=10798732430"
            local sound = Instance.new("Sound", game:GetService("SoundService"))
            sound.SoundId, sound.Volume = "rbxassetid://7076365030", 10
            sound:Play()
            wait(1.674)
            jumpscareGui:Destroy()
            sound:Destroy()
        elseif command == ".js2" then
            local jumpscareGui = Instance.new("ScreenGui", admin:WaitForChild("PlayerGui"))
            local img = Instance.new("ImageLabel", jumpscareGui)
            img.Size, img.Image = UDim2.new(1, 0, 1, 0), "http://www.roblox.com/asset/?id=75431648694596"
            local sound = Instance.new("Sound", game:GetService("SoundService"))
            sound.SoundId, sound.Volume = "rbxassetid://5567523008", 10
            sound:Play()
            wait(3.599)
            jumpscareGui:Destroy()
            sound:Destroy()
        elseif command == ".invert" then
            if not controlInversionActive[admin.UserId] then
                controlInversionActive[admin.UserId] = true
                local char = admin.Character
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    local inversionConnection = humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
                        humanoid:Move(Vector3.new(-humanoid.MoveDirection.X, 0, -humanoid.MoveDirection.Z), true)
                    end)
                    wait(10) -- Invert for 10 seconds
                    inversionConnection:Disconnect()
                    controlInversionActive[admin.UserId] = nil
                end
            end
        elseif command == ".uninvert" then
            if controlInversionActive[admin.UserId] then
                controlInversionActive[admin.UserId] = nil
            end
        elseif command == ".spin" then
            if not spinActive[admin.UserId] then
                spinActive[admin.UserId] = true
                local char = admin.Character
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
            if spinActive[admin.UserId] then
                spinActive[admin.UserId] = nil
            end
        elseif command == ".disablejump" then
            if not jumpDisabled[admin.UserId] then
                jumpDisabled[admin.UserId] = true
                local humanoid = admin.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.JumpPower = 0
                    wait(5)
                    humanoid.JumpPower = 50 -- Reset jump power (default can vary)
                    jumpDisabled[admin.UserId] = nil
                end
            end
        elseif command == ".unenablejump" then
            if jumpDisabled[admin.UserId] then
                local humanoid = admin.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.JumpPower = 50 -- Reset jump power
                end
                jumpDisabled[admin.UserId] = nil
            end
        elseif command == ".squeak" then
            local sound = Instance.new("Sound", admin.Character)
            sound.SoundId = "rbxassetid://507771019"
            sound:Play()
            wait(1) -- Wait for the sound to finish
            sound:Destroy()
        elseif command == ".bighead" then
            local head = admin.Character:FindFirstChild("Head")
            if head then
                head.Size = head.Size * 2
            end
        elseif command == ".tiny" then
            local char = admin.Character
            if char then
                char:FindFirstChild("Humanoid").RootPart.Size = Vector3.new(0.5, 0.5, 0.5)
            end
        elseif command == ".big" then
            local char = admin.Character
            if char then
                char:FindFirstChild("Humanoid").RootPart.Size = Vector3.new(2, 2, 2)
            end
        elseif command == ".sillyhat" then
            local hat = Instance.new("Accessory")
            local mesh = Instance.new("SpecialMesh")
            mesh.MeshId = "rbxassetid://507771019" -- Change this to a funny hat asset ID
            mesh.Parent = hat
            hat.Parent = admin.Character
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
