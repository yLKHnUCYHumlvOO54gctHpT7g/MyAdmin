local StarterGui = game:GetService("StarterGui")
StarterGui:SetCore("SendNotification", {
    Title = "AK ADMIN",
    Text = "Welcome to AK ADMIN! Type /cmds to see the available commands.",
    Duration = 5
})

-- Function to find the closest matching command
local function suggestClosestCommand(input)
    if not input then return nil end
    
    local closestCommand = nil
    local shortestDistance = math.huge
    
    -- Simple distance calculation
    for cmd in pairs(_G.cmds) do
        local distance = 0
        local maxLen = math.max(#input, #cmd)
        
        -- Compare characters
        for i = 1, maxLen do
            local c1 = input:sub(i, i):lower()
            local c2 = cmd:sub(i, i):lower()
            if c1 ~= c2 then
                distance = distance + 1
            end
        end
        
        -- Update closest command if this one is closer
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
                Text = "Error executing command",
                Duration = 5
            })
        end
    else
        -- Suggestion handling (will only occur when there is no exact match)
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

-- Connect chat event to command execution
game.Players.LocalPlayer.Chatted:Connect(function(msg)
    -- Define the prefix
    local prefix = "/"
    
    -- Only proceed if the message starts with the prefix
    if msg:sub(1, #prefix) == prefix then
        -- Remove prefix and any leading/trailing whitespace, convert to lowercase for comparison
        local command = msg:sub(#prefix + 1):lower():match("^%s*(.-)%s*$")
        
        -- Check if the command exists and execute it
        if _G.cmds[command] then
            executeCommand(command)
        else
            -- Only suggest a command if no exact match was found
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
end)
