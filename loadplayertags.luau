local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local RankColors = {
    ["AK OWNER"] = {
        primary = Color3.fromRGB(20, 20, 20),     -- Dark gray
        accent = Color3.fromRGB(255, 215, 0)      -- Gold
    },
    ["AK SCRIPTER"] = {
        primary = Color3.fromRGB(20, 20, 20),
        accent = Color3.fromRGB(138, 43, 226)     -- Purple
    },
    ["AK SUPPORTER"] = {
        primary = Color3.fromRGB(20, 20, 20),
        accent = Color3.fromRGB(0, 191, 255)      -- Sky blue
    },
    ["AK STAFF"] = {
        primary = Color3.fromRGB(20, 20, 20),
        accent = Color3.fromRGB(50, 205, 50)      -- Lime
    },
    ["AK ADVERTISER"] = {
        primary = Color3.fromRGB(20, 20, 20),
        accent = Color3.fromRGB(255, 69, 0)       -- Orange-red
    },
    ["AK TRIAL"] = {
        primary = Color3.fromRGB(20, 20, 20),
        accent = Color3.fromRGB(169, 169, 169)    -- Gray
    },
    ["AK USER"] = {
        primary = Color3.fromRGB(20, 20, 20),
        accent = Color3.fromRGB(65, 105, 225)     -- Royal blue
    }
}

local function createTag(player, rankText)
    local function attachTagToHead(character)
        local head = character:WaitForChild("Head", 5)
        if not head then return end

        local existingTag = head:FindFirstChild("RankTag")
        if existingTag then existingTag:Destroy() end

        -- Main tag container
        local tag = Instance.new("BillboardGui")
        tag.Name = "RankTag"
        tag.Size = UDim2.new(0, 150, 0, 40) -- Default size
        tag.StudsOffset = Vector3.new(0, 3, 0)
        tag.AlwaysOnTop = true
        tag.MaxDistance = math.huge -- Always visible

        -- Background container (button)
        local container = Instance.new("TextButton")
        container.Size = UDim2.new(1, 0, 1, 0)
        container.BackgroundTransparency = 0.3
        container.BackgroundColor3 = RankColors[rankText].primary
        container.BorderSizePixel = 0
        container.Text = "" -- Empty text to make it act as a button
        container.Parent = tag

        -- Rounded corners
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0.1, 0)
        corner.Parent = container

        -- Accent line
        local accent = Instance.new("Frame")
        accent.Size = UDim2.new(1, 0, 0, 2)
        accent.Position = UDim2.new(0, 0, 0, 0)
        accent.BackgroundColor3 = RankColors[rankText].accent
        accent.BorderSizePixel = 0
        accent.Parent = container

        -- Rank text
        local rankLabel = Instance.new("TextLabel")
        rankLabel.Size = UDim2.new(1, 0, 0.6, 0)
        rankLabel.Position = UDim2.new(0, 0, 0.1, 0)
        rankLabel.BackgroundTransparency = 1
        rankLabel.Text = rankText
        rankLabel.TextColor3 = Color3.new(1, 1, 1)
        rankLabel.TextSize = 14
        rankLabel.Font = Enum.Font.GothamBold
        rankLabel.Parent = container

        -- Username text
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

        -- Distance-based scaling
        local connection = RunService.RenderStepped:Connect(function()
            if not (character and character:FindFirstChild("Head") and Players.LocalPlayer.Character) then return end

            local localCharacter = Players.LocalPlayer.Character
            local headPosition = character.Head.Position
            local localHeadPosition = localCharacter.Head.Position

            local distance = (headPosition - localHeadPosition).Magnitude
            local scale = math.clamp(1 - (distance / 300), 0.4, 1) -- Scale between 0.4 and 1 based on distance

            tag.Size = UDim2.new(0, 150 * scale, 0, 40 * scale)
            rankLabel.TextSize = math.max(14 * scale, 8)
            userLabel.TextSize = math.max(11 * scale, 6)
        end)

        -- Cleanup on tag removal
        tag.AncestryChanged:Connect(function(_, parent)
            if not parent then
                connection:Disconnect()
            end
        end)

        -- Teleport functionality on click
        container.MouseButton1Click:Connect(function()
            local localPlayer = Players.LocalPlayer
            if localPlayer.Character and character:FindFirstChild("HumanoidRootPart") then
                localPlayer.Character:MoveTo(character.HumanoidRootPart.Position)
            end
        end)
    end

    if player.Character then attachTagToHead(player.Character) end
    player.CharacterAdded:Connect(attachTagToHead)
end

-- Player groups
local Advertisers = {"Vlafz195", "6736_45", "goekaycool", "goekayball", "goekayball2"}
local FreeTrial = {}
local Scripters = {"GYATT_DAMN1", "328ml", "29Kyooo", "BloxiAstra", "ImOn_ValveIndex"}
local Owners = {"Xeni_he07", "AliKhammas1234", "AliKhammas", "I_LOVEYOU12210", "AK_ADMEN1", "YournothimbuddyXD", "AK_ADMEN2"}
local Supporter = {"Robloxian74630436"}
local AKStaff = {"goekaycool"}

-- Whitelist check
local function isWhitelisted(player)
    local success, result = pcall(function()
        local response = game:HttpGet("https://raw.githubusercontent.com/AKadminlol/AK-ADMIN/refs/heads/main/AK%20ADMIN.json")
        local data = HttpService:JSONDecode(response)
        return data and data.whitelisted and table.find(data.whitelisted, player.Name) ~= nil
    end)
    return success and result
end

-- Apply tags to players
local function applyPlayerTag(player)
    if table.find(Owners, player.Name) then
        createTag(player, "AK OWNER")
    elseif table.find(Scripters, player.Name) then
        createTag(player, "AK SCRIPTER")
    elseif table.find(Supporter, player.Name) then
        createTag(player, "AK SUPPORTER")
    elseif table.find(AKStaff, player.Name) then
        createTag(player, "AK STAFF")
    elseif table.find(Advertisers, player.Name) then
        createTag(player, "AK ADVERTISER")
    elseif table.find(FreeTrial, player.Name) then
        createTag(player, "AK TRIAL")
    elseif isWhitelisted(player) then
        createTag(player, "AK USER")
    end
end

-- Apply tags to existing players
for _, player in pairs(Players:GetPlayers()) do
    applyPlayerTag(player)
end

-- Apply tags to new players
Players.PlayerAdded:Connect(applyPlayerTag)
