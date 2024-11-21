local StarterGui = game:GetService("StarterGui")
StarterGui:SetCore("SendNotification", {
    Title = "AK ADMIN",
    Text = "Welcome to AK ADMIN! Type !cmds to see the available commands.",
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
        -- Try to find a similar command
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
game.Players.LocalPlayer.Chatted:Connect(function(msg)
    -- Only process commands that start with !
    if msg:sub(1, 1) == "!" then
        -- Trim and clean up command input
        local fullCommand = msg:lower():gsub("^%s*", ""):gsub("%s*$", "")

        -- Check if command exists directly
        if _G.cmds[fullCommand] then
            executeCommand(fullCommand)
        else
            -- Try to find a suggestion
            local suggestion = suggestClosestCommand(fullCommand)
            if suggestion then
                if fullCommand == suggestion:lower() then
                    executeCommand(suggestion)
                else
                    -- Create buttons for the suggestion
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
                end
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
