local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Welcome notification
StarterGui:SetCore("SendNotification", {
    Title = "AK ADMIN",
    Text = "Welcome to AK ADMIN! Type !cmds to see the available commands.",
    Duration = 5
})

-- Function to calculate Levenshtein distance
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
            local cost = (s1:sub(i, i) == s2:sub(j, j)) and 0 or 1
            matrix[i][j] = math.min(
                matrix[i - 1][j] + 1,     -- Deletion
                matrix[i][j - 1] + 1,     -- Insertion
                matrix[i - 1][j - 1] + cost -- Substitution
            )
        end
    end

    return matrix[len1][len2]
end

-- Function to suggest the closest command
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
                Text = errorMessage or "Error executing command",
                Duration = 5
            })
        end
    else
        -- Try to find a suggestion
        local suggestion = suggestClosestCommand(command)
        if suggestion then
            -- Create a BindableFunction for the suggestion buttons
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

-- Chat command listener
LocalPlayer.Chatted:Connect(function(msg)
    -- Only process commands that start with '!'
    if msg:sub(1, 1) == "!" then
        local command = msg:sub(2):lower():gsub("^%s*", ""):gsub("%s*$", "") -- Clean up the input
        executeCommand(command)
    end
end)
