local StarterGui = game:GetService("StarterGui")

StarterGui:SetCore("SendNotification", {
    Title = "AK ADMIN",
    Text = "Welcome to AK ADMIN! Type /cmds to see the available commands.",
    Duration = 5
})

local recentSuggestion = nil -- Track the last suggestion

-- Calculate the Levenshtein Distance between two strings
local function levenshteinDistance(s1, s2)
    local len1, len2 = #s1, #s2
    local matrix = {}
    for i = 0, len1 do
        matrix[i] = {[0] = i}
    end
    for j = 0, len2 do
        matrix[0][j] = j
    end
    for i = 1, len1 do
        for j = 1, len2 do
            if s1:sub(i, i) == s2:sub(j, j) then
                matrix[i][j] = matrix[i-1][j-1]
            else
                matrix[i][j] = math.min(matrix[i-1][j] + 1, matrix[i][j-1] + 1, matrix[i-1][j-1] + 1)
            end
        end
    end
    return matrix[len1][len2]
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
    
    if closestCommand ~= recentSuggestion then
        recentSuggestion = closestCommand
        return closestCommand
    end
    
    return nil -- Avoid repeating the same suggestion
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
                Text = "Error executing command",
                Duration = 5
            })
        end
    else
        -- Try to find a similar command
        local suggestion = suggestClosestCommand(command)
        if suggestion then
            StarterGui:SetCore("SendNotification", {
                Title = "Command Suggestion 💡",
                Text = "Did you mean: " .. suggestion .. "?",
                Duration = 5
            })
        end
    end
end

-- Connect chat event to command execution
game.Players.LocalPlayer.Chatted:Connect(function(msg)
    local command = msg:lower():match("^%s*(.-)%s*$")
    
    if command and _G.cmds[command] then
        executeCommand(command)
    else
        local suggestion = suggestClosestCommand(command)
        if suggestion then
            StarterGui:SetCore("SendNotification", {
                Title = "Command Suggestion 💡",
                Text = "Did you mean: " .. suggestion .. "?",
                Duration = 5
            })
        end
    end
end)
