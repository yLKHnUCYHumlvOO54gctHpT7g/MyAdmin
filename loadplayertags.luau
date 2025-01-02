local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local RankColors = {
    ["AK OWNER"] = {
        primary = Color3.fromRGB(20, 20, 20),
        accent = Color3.fromRGB(255, 215, 0)
    },
    ["AK SCRIPTER"] = {
        primary = Color3.fromRGB(20, 20, 20),
        accent = Color3.fromRGB(138, 43, 226)
    },
    ["AK SUPPORTER"] = {
        primary = Color3.fromRGB(20, 20, 20),
        accent = Color3.fromRGB(0, 191, 255)
    },
    ["AK STAFF"] = {
        primary = Color3.fromRGB(20, 20, 20),
        accent = Color3.fromRGB(50, 205, 50)
    },
    ["AK ADVERTISER"] = {
        primary = Color3.fromRGB(20, 20, 20),
        accent = Color3.fromRGB(255, 69, 0)
    },
    ["AK TRIAL"] = {
        primary = Color3.fromRGB(20, 20, 20),
        accent = Color3.fromRGB(169, 169, 169)
    },
    ["AK USER"] = {
        primary = Color3.fromRGB(20, 20, 20),
        accent = Color3.fromRGB(65, 105, 225)
    }
}

local function createNotificationUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "TagNotification"
    gui.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 150)
    frame.Position = UDim2.new(0.5, -150, 0.5, -75)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local blur = Instance.new("BlurEffect")
    blur.Size = 15
    blur.Parent = game:GetService("Lighting")

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.7
    stroke.Thickness = 2
    stroke.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 15)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 22
    title.Text = "Tag Visibility Settings"
    title.Parent = frame

    local message = Instance.new("TextLabel")
    message.Size = UDim2.new(0.9, 0, 0, 40)
    message.Position = UDim2.new(0.05, 0, 0.35, 0)
    message.BackgroundTransparency = 1
    message.Font = Enum.Font.Gotham
    message.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    message.TextSize = 16
    message.TextWrapped = true
    message.Text = "Would you like to display your rank tag above your character?"
    message.Parent = frame

    local function createButton(text, position, color)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(0.4, 0, 0, 35)
        button.Position = position
        button.BackgroundColor3 = color
        button.BorderSizePixel = 0
        button.Font = Enum.Font.GothamBold
        button.TextColor3 = Color3.new(1, 1, 1)
        button.TextSize = 14
        button.Text = text
        button.AutoButtonColor = true
        button.Parent = frame

        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = button

        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.3), {BackgroundTransparency = 0.2}):Play()
        end)

        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
        end)

        return button
    end

    local yesButton = createButton("Yes", UDim2.new(0.08, 0, 0.7, 0), Color3.fromRGB(46, 204, 113))
    local noButton = createButton("No", UDim2.new(0.52, 0, 0.7, 0), Color3.fromRGB(231, 76, 60))

    frame.BackgroundTransparency = 1
    title.TextTransparency = 1
    message.TextTransparency = 1
    yesButton.BackgroundTransparency = 1
    noButton.BackgroundTransparency = 1
    yesButton.TextTransparency = 1
    noButton.TextTransparency = 1

    TweenService:Create(frame, TweenInfo.new(0.5), {BackgroundTransparency = 0.1}):Play()
    TweenService:Create(title, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    TweenService:Create(message, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    TweenService:Create(yesButton, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
    TweenService:Create(noButton, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
    TweenService:Create(yesButton, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    TweenService:Create(noButton, TweenInfo.new(0.5), {TextTransparency = 0}):Play()

    return gui, yesButton, noButton, blur
end

local function handleTeleport(character, targetCharacter)
    local humanoid = character:FindFirstChild("Humanoid")
    local targetHRP = targetCharacter:FindFirstChild("HumanoidRootPart")
    
    if not (humanoid and targetHRP) then return end
    
    local targetCFrame = targetHRP.CFrame
    local teleportOffset = targetCFrame.lookVector * -3
    local teleportPosition = targetHRP.Position + teleportOffset
    
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {character, targetCharacter}
    
    local ray = workspace:Raycast(teleportPosition + Vector3.new(0, 3, 0), Vector3.new(0, -10, 0), params)
    if ray then
        teleportPosition = ray.Position
    end
    
    humanoid:MoveTo(teleportPosition)
    
    local effect = Instance.new("Part")
    effect.Size = Vector3.new(1, 1, 1)
    effect.CFrame = CFrame.new(teleportPosition)
    effect.Anchored = true
    effect.CanCollide = false
    effect.Transparency = 0.5
    effect.Shape = Enum.PartType.Ball
    effect.Material = Enum.Material.Neon
    effect.Color = Color3.fromRGB(255, 255, 255)
    effect.Parent = workspace
    
    TweenService:Create(effect, TweenInfo.new(0.5), {
        Size = Vector3.new(0, 0, 0),
        Transparency = 1
    }):Play()
    
    game:GetService("Debris"):AddItem(effect, 0.5)
end

local function attachTagToHead(character, player, rankText)
    local head = character:WaitForChild("Head", 5)
    if not head then return end
    
    local existingTag = head:FindFirstChild("RankTag")
    if existingTag then existingTag:Destroy() end
    
    local tag = Instance.new("BillboardGui")
    tag.Name = "RankTag"
    tag.Size = UDim2.new(0, 150, 0, 40)
    tag.StudsOffset = Vector3.new(0, 3, 0)
    tag.AlwaysOnTop = true
    tag.MaxDistance = math.huge
    
    local container = Instance.new("TextButton")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 0.3
    container.BackgroundColor3 = RankColors[rankText].primary
    container.BorderSizePixel = 0
    container.Text = ""
    container.Parent = tag
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.1, 0)
    corner.Parent = container
    
    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(1, 0, 0, 2)
    accent.Position = UDim2.new(0, 0, 0, 0)
    accent.BackgroundColor3 = RankColors[rankText].accent
    accent.BorderSizePixel = 0
    accent.Parent = container
    
    local rankLabel = Instance.new("TextLabel")
    rankLabel.Size = UDim2.new(1, 0, 0.6, 0)
    rankLabel.Position = UDim2.new(0, 0, 0.1, 0)
    rankLabel.BackgroundTransparency = 1
    rankLabel.Text = rankText
    rankLabel.TextColor3 = Color3.new(1, 1, 1)
    rankLabel.TextSize = 14
    rankLabel.Font = Enum.Font.GothamBold
    rankLabel.Parent = container
    
    local userLabel = Instance.new("TextLabel")
    userLabel.Size = UDim2.new(1, 0, 0.4, 0)
    userLabel.Position = UDim2.new(0, 0, 0.6, 0)
    userLabel.BackgroundTransparency = 1
    userLabel.Text = "@" .. player.Name
    userLabel.TextColor3 = RankColors[rankText].accent
    userLabel.TextSize = 11
    userLabel.Font = Enum.Font.Gotham
    userLabel.Parent = container
    
    tag.Parent = head
    
    local connection = RunService.RenderStepped:Connect(function()
        if not (character and character:FindFirstChild("Head") and Players.LocalPlayer.Character) then return end
        
        local localCharacter = Players.LocalPlayer.Character
        local headPosition = character.Head.Position
        local localHeadPosition = localCharacter:FindFirstChild("Head") and localCharacter.Head.Position
        
        if localHeadPosition then
            local distance = (headPosition - localHeadPosition).Magnitude
            local scale = math.clamp(1 - (distance / 300), 0.4, 1)
            
            tag.Size = UDim2.new(0, 150 * scale, 0, 40 * scale)
            rankLabel.TextSize = math.max(14 * scale, 8)
            userLabel.TextSize = math.max(11 * scale, 6)
        end
    end)
    
    tag.AncestryChanged:Connect(function(_, parent)
        if not parent then
            connection:Disconnect()
        end
    end)
    
    local function onTagActivated()
        local localPlayer = Players.LocalPlayer
        if localPlayer.Character and character then
            handleTeleport(localPlayer.Character, character)
        end
    end
    
    container.MouseButton1Click:Connect(onTagActivated)
    container.TouchTap:Connect(onTagActivated)
    
    container.MouseEnter:Connect(function()
        TweenService:Create(container, TweenInfo.new(0.3), {
            BackgroundTransparency = 0.1
        }):Play()
    end)
    
    container.MouseLeave:Connect(function()
        TweenService:Create(container, TweenInfo.new(0.3), {
            BackgroundTransparency = 0.3
        }):Play()
    end)
end

local function createTag(player, rankText, showPrompt)
    if showPrompt and player == Players.LocalPlayer then
        local gui, yesButton, noButton, blur = createNotificationUI()
        gui.Parent = player:WaitForChild("PlayerGui")
        
        local function cleanup()
            TweenService:Create(gui.Frame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
            blur:Destroy()
            task.wait(0.5)
            gui:Destroy()
        end
        
        yesButton.MouseButton1Click:Connect(function()
            cleanup()
            attachTagToHead(player.Character, player, rankText)
            player.CharacterAdded:Connect(function(character)
                attachTagToHead(character, player, rankText)
            end)
        end)
        
        noButton.MouseButton1Click:Connect(function()
            cleanup()
        end)
    else
        attachTagToHead(player.Character, player, rankText)
        player.CharacterAdded:Connect(function(character)
            attachTagToHead(character, player, rankText)
        end)
    end
end

local Advertisers = {"Vlafz195", "6736_45", "goekaycool", "goekayball", "goekayball2"}
local FreeTrial = {}
local Scripters = {"GYATT_DAMN1", "328ml", "29Kyooo", "BloxiAstra", "ImOn_ValveIndex"}
local Owners = {"Xeni_he07", "AliKhammas1234", "AliKhammas", "I_LOVEYOU12210", "AK_ADMEN1", "YournothimbuddyXD", "AK_ADMEN2"}
local Supporter = {"Robloxian74630436"}
local AKStaff = {"goekaycool"}

local function isWhitelisted(player)
    local success, result = pcall(function()
        local response = game:HttpGet("https://raw.githubusercontent.com/AKadminlol/AK-ADMIN/refs/heads/main/AK%20ADMIN.json")
        local data = HttpService:JSONDecode(response)
        return data and data.whitelisted and table.find(data.whitelisted, player.Name) ~= nil
    end)
    return success and result
end

local function applyPlayerTag(player)
    local showPrompt = player == Players.LocalPlayer
    
    if table.find(Owners, player.Name) then
        createTag(player, "AK OWNER", showPrompt)
    elseif table.find(Scripters, player.Name) then
        createTag(player, "AK SCRIPTER", showPrompt)
    elseif table.find(Supporter, player.Name) then
        createTag(player, "AK SUPPORTER", showPrompt)
    elseif table.find(AKStaff, player.Name) then
        createTag(player, "AK STAFF", showPrompt)
    elseif table.find(Advertisers, player.Name) then
        createTag(player, "AK ADVERTISER", showPrompt)
    elseif table.find(FreeTrial, player.Name) then
        createTag(player, "AK TRIAL", showPrompt)
    elseif isWhitelisted(player) then
        createTag(player, "AK USER", showPrompt)
    end
end

-- Apply tags to existing players
for _, player in pairs(Players:GetPlayers()) do
    applyPlayerTag(player)
end

-- Apply tags to new players
Players.PlayerAdded:Connect(applyPlayerTag)
