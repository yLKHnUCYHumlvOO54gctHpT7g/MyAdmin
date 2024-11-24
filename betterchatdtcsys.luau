local ChatInputTextBox = game:GetService("CoreGui").ExperienceChat.appLayout.chatInputBar.Background.Container.TextContainer.TextBoxContainer.TextBox

-- Function to close the GUI
local function closeGui()
    local originalPosition = BarFrame.Position.Y.Scale
    for i = 0, 1, 0.05 do
        BarFrame.Position = UDim2.new(0.5, 0, originalPosition + (0.2 * i), 0)
        wait(0.01)
    end
    AkaScreenGui:Destroy()
end

loadstring(game:HttpGet("https://raw.githubusercontent.com/Alikhammass/MyAdmin/refs/heads/main/allcmds.luau"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Alikhammass/MyAdmin/refs/heads/main/loadcmds.luau"))()

-- Close GUI when the button is clicked
local function chat(txt)
    if game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents") then
        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(txt, "All")
    else
        game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(txt)
    end
end

-- Command handler for the ExperienceChat TextBox
ChatInputTextBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local command = ChatInputTextBox.Text:lower()
        local normalchatmsgs = ChatInputTextBox.Text
        ChatInputTextBox.Text = "" -- Clear the input box
        for cmdname, link in pairs(_G.cmds) do
            if command == cmdname then
                ChatInputTextBox.Text = "" -- Clear the input box after command execution
                loadstring(game:HttpGet(link))()
            end
        end
        chat(normalchatmsgs)
        -- Handle specific commands
        if command:sub(1, 6) == "!copy " then
            local target = command:sub(7)
            for _, v in pairs(game.Players:GetChildren()) do
                if v.Name:lower():find(target:lower()) or v.DisplayName:lower():find(target:lower()) then
                    game:GetService("ReplicatedStorage").ModifyUserEvent:FireServer(v.Name)
                end
            end
        elseif command == "!copynearest" then
            local closestPlayer
            local closestDistance = math.huge

            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (player.Character.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end

            if closestPlayer then
                game:GetService("ReplicatedStorage").ModifyUserEvent:FireServer(closestPlayer.Name)
            end
        elseif command == "!copy all" then
            for _, player in pairs(game.Players:GetPlayers()) do
                game:GetService("ReplicatedStorage").ModifyUserEvent:FireServer(player.Name)
            end
        elseif command == "!uncopy" then
            warn("Stopped copying.")
        end
    end
end)
