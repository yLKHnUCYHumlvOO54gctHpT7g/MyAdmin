-- Ensure this script runs in a LocalScript

-- Load the Clone Illusion animation
local Anim = Instance.new("Animation")
Anim.AnimationId = "rbxassetid://215384594"  -- Animation ID for Clone Illusion

-- Define the humanoid and animation track outside the function to reuse
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local track = humanoid:LoadAnimation(Anim)

-- Function to start the animation
local function startCloneIllusion()
    print("Starting Clone Illusion")  -- Debug print
    track:Play(.5, 1, 1e7)  -- Play the animation in a loop
end

-- Function to stop the animation
local function stopCloneIllusion()
    print("Stopping Clone Illusion")  -- Debug print
    track:Stop()  -- Stop the animation
end

-- Function to handle the chat command
local function onChatted(message)
    -- Check if the message is a command
    if message:sub(1, 1) == "!" then
        local command = message:lower()
        if command == "!unclone" then
            stopCloneIllusion()
        end
    end
end

-- Start the animation as soon as the script runs
startCloneIllusion()

-- Connect the onChatted function to the player's Chatted event
player.Chatted:Connect(onChatted)

-- Handling character respawn to reinitialize the humanoid and track
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = character:WaitForChild("Humanoid")
    track = humanoid:LoadAnimation(Anim)
    startCloneIllusion()  -- Restart the animation upon character respawn
end)
