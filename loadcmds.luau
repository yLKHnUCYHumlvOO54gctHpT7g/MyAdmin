local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Initialize command list if it doesn't exist
if not _G.cmds then
    _G.cmds = {}
end

-- Get PlayerGui and destroy existing notification UI if it exists
local existingGui = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("AKAdminNotifications")
if existingGui then
    existingGui:Destroy()
end

-- Create the ScreenGui for notifications
local NotificationGui = Instance.new("ScreenGui")
NotificationGui.Name = "AKAdminNotifications"
NotificationGui.ResetOnSpawn = false
NotificationGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Function to create and display a notification
local function createNotification(title, text, duration, suggestion, suggestionCallback)
    -- Destroy any existing notifications
    for _, child in pairs(NotificationGui:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    -- Create the notification frame
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 300, 0, 110)
    notification.Position = UDim2.new(1, 50, 0.80, 0)  -- Positioned off-screen to the right
    notification.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    notification.BackgroundTransparency = 0
    notification.BorderSizePixel = 0
    notification.Parent = NotificationGui

    -- Add a UI corner for rounded edges
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notification

    -- Add a gradient background
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 45)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 35))
    })
    gradient.Rotation = 45
    gradient.Parent = notification

    -- Add an accent bar on the left
    local titleAccent = Instance.new("Frame")
    titleAccent.Size = UDim2.new(0, 3, 0, 20)
    titleAccent.Position = UDim2.new(0, 10, 0, 13)
    titleAccent.BackgroundColor3 = Color3.fromRGB(65, 165, 255)
    titleAccent.BorderSizePixel = 0
    titleAccent.Parent = notification

    -- Add a UI corner to the accent bar
    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 2)
    accentCorner.Parent = titleAccent

    -- Create the title label
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -40, 0, 20)
    titleLabel.Position = UDim2.new(0, 20, 0, 13)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = title
    titleLabel.Parent = notification

    -- Create the message label
    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -20, 0, 40)
    messageLabel.Position = UDim2.new(0, 10, 0, 38)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Font = Enum.Font.Gotham
    messageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    messageLabel.TextSize = 13
    messageLabel.TextWrapped = true
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.Text = text
    messageLabel.Parent = notification

    -- Add a button container for suggestion prompts if suggestion is true
    if suggestion then
        local buttonContainer = Instance.new("Frame")
        buttonContainer.Size = UDim2.new(1, -20, 0, 28)
        buttonContainer.Position = UDim2.new(0, 10, 1, -38)
        buttonContainer.BackgroundTransparency = 1
        buttonContainer.Parent = notification

        -- Create the "Yes" button
        local yesButton = Instance.new("TextButton")
        yesButton.Size = UDim2.new(0.48, 0, 1, 0)
        yesButton.Position = UDim2.new(0, 0, 0, 0)
        yesButton.BackgroundColor3 = Color3.fromRGB(65, 165, 255)
        yesButton.Text = "Yes"
        yesButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        yesButton.Font = Enum.Font.GothamBold
        yesButton.TextSize = 13
        yesButton.AutoButtonColor = false
        yesButton.Parent = buttonContainer

        -- Apply corner to yes button
        local yesCorner = Instance.new("UICorner")
        yesCorner.CornerRadius = UDim.new(0, 6)
        yesCorner.Parent = yesButton

        -- Create the "No" button
        local noButton = Instance.new("TextButton")
        noButton.Size = UDim2.new(0.48, 0, 1, 0)
        noButton.Position = UDim2.new(0.52, 0, 0, 0)
        noButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        noButton.Text = "No"
        noButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        noButton.Font = Enum.Font.GothamBold
        noButton.TextSize = 13
        noButton.AutoButtonColor = false
        noButton.Parent = buttonContainer

        -- Apply corner to no button
        local noCorner = Instance.new("UICorner")
        noCorner.CornerRadius = UDim.new(0, 6)
        noCorner.Parent = noButton

        -- Helper function for creating hover effects on buttons
        local function createHoverEffect(button, defaultColor, hoverColor)
            button.MouseEnter:Connect(function()
                TweenService:Create(button,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad),
                    {BackgroundColor3 = hoverColor}
                ):Play()
            end)

            button.MouseLeave:Connect(function()
                TweenService:Create(button,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad),
                    {BackgroundColor3 = defaultColor}
                ):Play()
            end)
        end

        -- Set up hover effects for Yes and No buttons
        createHoverEffect(yesButton,
            Color3.fromRGB(65, 165, 255),
            Color3.fromRGB(85, 175, 255)
        )
        createHoverEffect(noButton,
            Color3.fromRGB(45, 45, 55),
            Color3.fromRGB(55, 55, 65)
        )

        -- Set up button click logic for yes button
        yesButton.MouseButton1Click:Connect(function()
            if suggestionCallback then
                suggestionCallback(true)
            end
            notification:Destroy()
        end)

        -- Set up button click logic for no button
        noButton.MouseButton1Click:Connect(function()
            if suggestionCallback then
                suggestionCallback(false)
            end
            notification:Destroy()
        end)
    end

    -- Create progress bar for notification timer
    local progressBar = Instance.new("Frame")
    progressBar.Name = "ProgressBar"
    progressBar.Size = UDim2.new(1, 0, 0, 2)
    progressBar.Position = UDim2.new(0, 0, 1, -2)
    progressBar.BackgroundColor3 = Color3.fromRGB(65, 165, 255)
    progressBar.BorderSizePixel = 0
    progressBar.Parent = notification

    -- Animate notification in from the right
    local slideTween = TweenService:Create(notification,
        TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Position = UDim2.new(1, -320, 0.80, 0)}
    )
    slideTween:Play()

    -- Animate progress bar
    local progressTween = TweenService:Create(progressBar,
        TweenInfo.new(duration, Enum.EasingStyle.Linear),
        {Size = UDim2.new(0, 0, 0, 2)}
    )
    progressTween:Play()

    -- Timer to slide out and destroy the notification
    task.delay(duration, function()
        local slideOutTween = TweenService:Create(notification,
            TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            {Position = UDim2.new(1, 50, 0.80, 0)}
        )
        slideOutTween:Play()

        slideOutTween.Completed:Wait()
        notification:Destroy()
    end)
end

-- Function to suggest closest command
local function suggestClosestCommand(input)
    if not input then return nil end
    local closestCommand = nil
    local highestScore = -math.huge
    
    if _G.cmds[input] then
        return input
    end
    
    for cmd in pairs(_G.cmds) do
        local score = 0
        local inputLower = input:lower()
        local cmdLower = cmd:lower()
        local inputLen = #inputLower
        local cmdLen = #cmdLower
        
        if inputLower == cmdLower then
            return cmd
        end
        
        if cmdLower:sub(1, inputLen) == inputLower then
            score = score + 25
        end

        local function levenshteinDistance(s1, s2)
            local len1 = #s1
            local len2 = #s2
            local d = {}
            
            for i = 0, len1 do d[i] = {[0] = i} end
            for j = 0, len2 do d[0][j] = j end
            
            for j = 1, len2 do
                for i = 1, len1 do
                    local cost = (s1:sub(i,i) == s2:sub(j,j)) and 0 or 1
                    d[i][j] = math.min(
                        d[i-1][j] + 1,
                        d[i][j-1] + 1,
                        d[i-1][j-1] + cost
                    )
                end
            end
            
            return d[len1][len2]
        end
        
        local distance = levenshteinDistance(inputLower, cmdLower)
        score = score - (distance * 5)
        
        local lengthDiff = math.abs(inputLen - cmdLen)
        score = score - (lengthDiff * 2)

        local lastFoundIndex = 0
        local consecutiveMatches = 0
        for i = 1, inputLen do
            local char = inputLower:sub(i,i)
            local found = cmdLower:find(char, lastFoundIndex+1)
            if found then
                score = score + (2 - (found - i) * 0.5)
                if found == lastFoundIndex + 1 then
                    consecutiveMatches = consecutiveMatches + 1
                    score = score + (consecutiveMatches * 2)
                else
                    consecutiveMatches = 0
                end
                lastFoundIndex = found
            end
        end

        local commonPrefix = 0
        for i = 1, math.min(inputLen, cmdLen) do
            if inputLower:sub(i, i) == cmdLower:sub(i,i) then
                commonPrefix = commonPrefix + 1
            else
                break
            end
        end
        score = score + (commonPrefix * 4)

        if score > highestScore then
            highestScore = score
            closestCommand = cmd
        end
    end
    
    return highestScore > 10 and closestCommand or nil
end

-- Function to show notification when a command is "executed"
local function executeCommandNotification(command)
    if _G.cmds[command] then
        createNotification(
            "Success",
            "Executed command: " .. command,
            3,
            false
        )
    else
        local suggestion = suggestClosestCommand(command)
        if suggestion then
            createNotification(
                "Command Suggestion",
                "Did you mean: " .. suggestion .. "?",
                10,
                true,
                function(accepted)
                    if accepted then
                        if _G.cmds[suggestion] then
                            createNotification(
                                "Success",
                                "Executed command: " .. suggestion,
                                3,
                                false
                            )
                        end
                    end
                end
            )
        end
    end
end

-- Initial welcome notification
task.wait(1)
createNotification(
    "AK ADMIN",
    "Welcome to AK ADMIN! Type !cmds to see the available commands.",
    8,
    false
)

local lastInput = ""

-- Handle player chat messages
LocalPlayer.Chatted:Connect(function(msg)
    if msg:sub(1, 1) == "!" then
        local command = msg:sub(2):lower():gsub("^%s*", ""):gsub("%s*$", "")
        -- Show notification as if the command was executed, but don't run the command
        executeCommandNotification("!"..command)
        lastInput = command
        return
    end
end)

-- Function to update suggestions while typing in the chatbox
local function updateSuggestion(input)
    if input == "" then return end
    local suggestion = suggestClosestCommand("!" .. input)
    if suggestion then
        for _, child in pairs(NotificationGui:GetChildren()) do
            if child:IsA("Frame") and child.Name ~= "ProgressBar" then
                child:Destroy()
            end
        end
        
        createNotification(
            "Command Suggestion",
            "Did you mean: " .. suggestion .. "?",
            10,
            true,
            function(accepted)
                if accepted then
                   if _G.cmds[suggestion] then
                        createNotification(
                            "Success",
                            "Executed command: " .. suggestion,
                            3,
                            false
                        )
                    end
                end
            end
        )
    else
        for _, child in pairs(NotificationGui:GetChildren()) do
            if child:IsA("Frame") and child.Name ~= "ProgressBar" then
                child:Destroy()
            end
        end
    end
end

local lastChatInput = ""
local connection

-- Function to set up the chat input monitoring
local function handleChatUpdate(chatbox)
    if connection then
        connection:Disconnect()
        connection = nil
    end

    if chatbox then
        connection = chatbox.TextBox.FocusLost:Connect(function(enterPressed)
           if not enterPressed and lastChatInput ~= "" then
                updateSuggestion(lastChatInput)
            end
            lastChatInput = ""
        end)

        chatbox.TextBox.Changed:Connect(function()
            local currentText = chatbox.TextBox.Text
            if currentText:sub(1,1) == "!" then
                local input = currentText:sub(2):lower():gsub("^%s*", ""):gsub("%s*$", "")
                lastChatInput = input
            else
                lastChatInput = ""
            end
        end)
    end
end

-- Function to hook chat service events
local function hookChatService()
    local chatService = game:GetService("Chat")
    chatService.OnChatWindowLoaded:Connect(handleChatUpdate)
    if chatService.ChatWindowLoaded then
        handleChatUpdate(chatService.ChatWindow)
    end
end

hookChatService()
