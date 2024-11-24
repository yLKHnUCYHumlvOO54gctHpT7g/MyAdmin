local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

StarterGui:SetCore("SendNotification", {
    Title = "AK ADMIN",
    Text = "Welcome to AK ADMIN! Type !cmds to see the available commands.",
    Duration = 8
})

-- Function to calculate Levenshtein Distance for better suggestions
local function levenshteinDistance(s, t)
    local d = {}
    local sLen, tLen = #s, #t
    for i = 0, sLen do d[i] = {[0] = i} end
    for j = 0, tLen do d[0][j] = j end
    for i = 1, sLen do
        for j = 1, tLen do
            d[i][j] = math.min(d[i-1][j] + 1, d[i][j-1] + 1, d[i-1][j-1] + (s:byte(i) == t:byte(j) and 0 or 1))
        end
    end
    return d[sLen][tLen]
end

-- Function to find the closest matching command
local function suggestClosestCommand(input)
    if not input then return nil end

    local closestCommand = nil
    local shortestDistance = math.huge

    for cmd in pairs(_G.cmds) do
        local distance = levenshteinDistance(input:lower(), cmd:lower())
        if distance < shortestDistance and distance <= 3 then
            shortestDistance = distance
            closestCommand = cmd
        end
    end

    return closestCommand
end

-- Function to execute a command
local function executeCommand(command)
    if _G.cmds[command] then
        local success, errorMessage = pcall(function()
            loadstring(game:HttpGet(_G.cmds[command]))()
        end)

        if success then
            StarterGui:SetCore("SendNotification", {
                Title = "Command Executed ✅",
                Text = "Executed: " .. command,
                Duration = 3
            })
        else
            StarterGui:SetCore("SendNotification", {
                Title = "Execution Error ❌",
                Text = "Error executing command: " .. errorMessage,
                Duration = 5
            })
        end
    else
        local suggestion = suggestClosestCommand(command)
        if suggestion then
            StarterGui:SetCore("SendNotification", {
                Title = "Command Suggestion 💡",
                Text = "Did you mean: " .. suggestion .. "?",
                Duration = 5
            })
        else
            StarterGui:SetCore("SendNotification", {
                Title = "Unknown Command ❌",
                Text = "Command not found",
                Duration = 3
            })
        end
    end
end

-- Connect chat event to command execution for the local player
LocalPlayer.Chatted:Connect(function(msg)
    if msg:sub(1, 1) == "!" then
        local fullCommand = msg:lower():gsub("^%s*", ""):gsub("%s*$", "")

        if _G.cmds[fullCommand] then
            executeCommand(fullCommand)
        else
            local suggestion = suggestClosestCommand(fullCommand)
            if suggestion then
                local bindable = Instance.new("BindableFunction")

                function bindable.OnInvoke(response)
                    if response == "Yes" then
                        executeCommand(suggestion)
                    end
                end

                StarterGui:SetCore("SendNotification", {
                    Title = "Command Suggestion 💡",
                    Text = "Did you mean: " .. suggestion .. "?",
                    Duration = 10,
                    Button1 = "Yes",
                    Button2 = "No",
                    Callback = bindable
                })
            else
                StarterGui:SetCore("SendNotification", {
                    Title = "Unknown Command ❌",
                    Text = "Command not found",
                    Duration = 3
                })
            end
        end
    end
end)

-- Handles real-time typing detection
StarterGui.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Slash then
        local textBox = game.Players.LocalPlayer.PlayerGui:WaitForChild("Chat"):WaitForChild("Frame"):WaitForChild("ChatBar"):WaitForChild("Frame"):WaitForChild("BoxFrame"):WaitForChild("ChatBar")
        textBox:GetPropertyChangedSignal("Text"):Connect(function()
            detectTyping(textBox.Text)
        end)
    end
end)
