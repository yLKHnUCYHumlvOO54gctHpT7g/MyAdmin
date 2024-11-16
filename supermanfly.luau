-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ContextActionService = game:GetService("ContextActionService")

-- Variables
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local flying = false
local flySpeed = 50
local TOGGLE_KEY = Enum.KeyCode.X
local isSelectingKeybind = false
local minSpeed = 0
local maxSpeed = 500

-- Add Workspace Gravity reference
local workspace = game:GetService("Workspace")
local defaultGravity = workspace.Gravity

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Shadow = Instance.new("ImageLabel")
local Container = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ToggleButton = Instance.new("TextButton")
local SpeedSlider = Instance.new("TextButton")
local KeybindButton = Instance.new("TextButton")
local StatusIndicator = Instance.new("Frame")

-- GUI Styling
ScreenGui.Parent = player.PlayerGui
ScreenGui.ResetOnSpawn = false

-- Main Container with Gradient
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 200, 0, 190)
MainFrame.Position = UDim2.new(0.85, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Add Gradient
local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 30))
})
UIGradient.Rotation = 45
UIGradient.Parent = MainFrame

-- Shadow Effect
Shadow.Name = "Shadow"
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
Shadow.Size = UDim2.new(1, 40, 1, 40)
Shadow.Image = "rbxassetid://5554236805"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.4
Shadow.Parent = MainFrame

-- Container for Content
Container.Name = "Container"
Container.Size = UDim2.new(1, -20, 1, -20)
Container.Position = UDim2.new(0, 10, 0, 10)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

-- Title with Accent
Title.Size = UDim2.new(0.7, 0, 0, 30)
Title.Position = UDim2.new(0, 8, 0, 0)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "SUPERMAN FLY"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Container

-- Status Indicator
StatusIndicator.Size = UDim2.new(0, 8, 0, 8)
StatusIndicator.Position = UDim2.new(1, -15, 0, 11)
StatusIndicator.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
StatusIndicator.Parent = Container

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(1, 0)
statusCorner.Parent = StatusIndicator

-- Toggle Button
ToggleButton.Size = UDim2.new(1, 0, 0, 38)
ToggleButton.Position = UDim2.new(0, 0, 0, 40)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "FLY: OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14
ToggleButton.AutoButtonColor = false
ToggleButton.Parent = Container

-- Speed Slider
SpeedSlider.Size = UDim2.new(1, 0, 0, 38)
SpeedSlider.Position = UDim2.new(0, 0, 0, 88)
SpeedSlider.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
SpeedSlider.Font = Enum.Font.GothamSemibold
SpeedSlider.Text = "SPEED: " .. flySpeed
SpeedSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedSlider.TextSize = 14
SpeedSlider.AutoButtonColor = false
SpeedSlider.Parent = Container

-- Keybind Button
KeybindButton.Size = UDim2.new(1, 0, 0, 38)
KeybindButton.Position = UDim2.new(0, 0, 0, 136)
KeybindButton.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
KeybindButton.Font = Enum.Font.GothamSemibold
KeybindButton.Text = "KEYBIND: X"
KeybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
KeybindButton.TextSize = 14
KeybindButton.AutoButtonColor = false
KeybindButton.Parent = Container

-- Add corners and effects to all buttons
for _, button in pairs({MainFrame, ToggleButton, SpeedSlider, KeybindButton}) do
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button
    
    -- Add hover effect
    if button ~= MainFrame then
        local hover = false
        button.MouseEnter:Connect(function()
            hover = true
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = button.BackgroundColor3:Lerp(Color3.fromRGB(255, 255, 255), 0.1)
            }):Play()
        end)
        
        button.MouseLeave:Connect(function()
            hover = false
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = hover and button.BackgroundColor3:Lerp(Color3.fromRGB(255, 255, 255), 0.1) or 
                                  (button == ToggleButton and (flying and Color3.fromRGB(75, 255, 75) or Color3.fromRGB(255, 75, 75)) or 
                                  Color3.fromRGB(45, 45, 50))
            }):Play()
        end)
    end
end

-- Add click effect to buttons
for _, button in pairs({ToggleButton, SpeedSlider, KeybindButton}) do
    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            Size = UDim2.new(button.Size.X.Scale, button.Size.X.Offset, button.Size.Y.Scale, button.Size.Y.Offset - 2)
        }):Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            Size = UDim2.new(button.Size.X.Scale, button.Size.X.Offset, button.Size.Y.Scale, button.Size.Y.Offset + 2)
        }):Play()
    end)
end

-- Add to Variables section
local ctrl = {f = 0, b = 0, l = 0, r = 0}
local lastctrl = {f = 0, b = 0, l = 0, r = 0}
local keyConnections = {}

-- Add animation functions
local currentAnim = nil
local function PlayAnim(id, time, speed)
    pcall(function()
        if currentAnim then
            currentAnim:Stop(0.1)
        end
        
        player.Character.Animate.Disabled = true
        local hum = player.Character.Humanoid
        local animtrack = hum:GetPlayingAnimationTracks()
        for i, track in pairs(animtrack) do
            track:Stop()
        end
        
        local Anim = Instance.new("Animation")
        Anim.AnimationId = "rbxassetid://"..id
        local loadanim = hum:LoadAnimation(Anim)
        loadanim:Play()
        loadanim.TimePosition = time
        loadanim:AdjustSpeed(speed)
        
        currentAnim = loadanim
        
        loadanim.Stopped:Connect(function()
            player.Character.Animate.Disabled = false
            for i, track in pairs(animtrack) do
                track:Stop()
            end
        end)
    end)
end

local function StopAnim()
    player.Character.Animate.Disabled = false
    local animtrack = player.Character.Humanoid:GetPlayingAnimationTracks()
    for i, track in pairs(animtrack) do
        track:Stop()
    end
end

-- Add to Variables section
local lastDirection = "none"
local turnTilt = 0
local maxTilt = 45 -- Maximum tilt angle for turns

-- Update the updateFly function
local function updateFly()
    if not flying then return end
    
    local camera = workspace.CurrentCamera
    local speed = flySpeed
    
    -- Create BodyGyro and BodyVelocity if they don't exist
    if not rootPart:FindFirstChild("FlyGyro") then
        local bg = Instance.new("BodyGyro")
        bg.Name = "FlyGyro"
        bg.P = 9e4
        bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.CFrame = rootPart.CFrame
        bg.Parent = rootPart
        
        local bv = Instance.new("BodyVelocity")
        bv.Name = "FlyVelocity"
        bv.Velocity = Vector3.new(0, 0.1, 0)
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Parent = rootPart
    end
    
    local bg = rootPart.FlyGyro
    local bv = rootPart.FlyVelocity
    
    -- Calculate velocity
    if ctrl.f + ctrl.b + ctrl.l + ctrl.r > 0 then
        bv.Velocity = ((camera.CoordinateFrame.lookVector * (ctrl.f + ctrl.b)) + 
            ((camera.CoordinateFrame * CFrame.new(ctrl.l + ctrl.r, (ctrl.f + ctrl.b) * 0.2, 0).p) - 
            camera.CoordinateFrame.p)) * speed
        lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
    elseif ctrl.f + ctrl.b + ctrl.l + ctrl.r == 0 and speed ~= 0 then
        bv.Velocity = ((camera.CoordinateFrame.lookVector * (lastctrl.f + lastctrl.b)) + 
            ((camera.CoordinateFrame * CFrame.new(lastctrl.l + lastctrl.r, (lastctrl.f + lastctrl.b) * 0.2, 0).p) - 
            camera.CoordinateFrame.p)) * speed
    else
        bv.Velocity = Vector3.new(0, 0.1, 0)
    end
    
    -- Update gyro
    bg.CFrame = camera.CoordinateFrame * CFrame.Angles(-math.rad(ctrl.f * 90), 0, 0)
end

-- Update button colors (much brighter)
local function enhanceGUI()
    -- Add gradient background to MainFrame
    local UIGradient = Instance.new("UIGradient")
    UIGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 40))
    })
    UIGradient.Rotation = 45
    UIGradient.Parent = MainFrame

    -- Remove dark gradients from buttons
    for _, button in pairs({ToggleButton, SpeedSlider, KeybindButton}) do
        -- Set default colors without dark overlays
        if button == ToggleButton then
            button.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
        else
            button.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        end
    end
end

-- Add to Variables section
local isMobile = UserInputService.TouchEnabled
local TouchGui = nil
local TouchControls = nil
local TouchActive = false

-- Add after GUI creation but before button styling
if isMobile then
    -- Create Touch Controls
    TouchGui = Instance.new("ScreenGui")
    TouchGui.Name = "FlyTouchControls"
    TouchGui.ResetOnSpawn = false
    TouchGui.Parent = player.PlayerGui

    TouchControls = Instance.new("ImageButton")
    TouchControls.Size = UDim2.new(0, 150, 0, 150)
    TouchControls.Position = UDim2.new(0.1, 0, 0.5, 0)
    TouchControls.AnchorPoint = Vector2.new(0.5, 0.5)
    TouchControls.BackgroundTransparency = 0.5
    TouchControls.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    TouchControls.Image = "rbxassetid://8997446837" -- Joystick image
    TouchControls.ImageTransparency = 0.5
    TouchControls.Visible = false
    TouchControls.Parent = TouchGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = TouchControls
end

-- Add to Variables section
local PlayerModule = require(player.PlayerScripts:WaitForChild("PlayerModule"))
local Controls = PlayerModule:GetControls()

-- Update toggleFlight function
local function toggleFlight()
    flying = not flying
    ToggleButton.Text = flying and "FLY: ON" or "FLY: OFF"
    
    local targetColor = flying and Color3.fromRGB(75, 255, 75) or Color3.fromRGB(255, 75, 75)
    TweenService:Create(ToggleButton, TweenInfo.new(0.3), {
        BackgroundColor3 = targetColor
    }):Play()
    
    if flying then
        workspace.Gravity = 0
        humanoid.PlatformStand = true
        
        -- Play initial idle animation
        PlayAnim(10714347256, 4, 0)
        
        -- Handle movement and animations using ControlModule
        RunService:BindToRenderStep("FlyControls", Enum.RenderPriority.Input.Value, function()
            local moveVector = Controls:GetMoveVector()
            
            -- Update animations based on movement
            if moveVector.Magnitude > 0.1 then
                if moveVector.Z < 0 then  -- Moving forward
                    if moveVector.X < -0.1 then  -- Left
                        if lastDirection ~= "left" then
                            lastDirection = "left"
                            PlayAnim(10714177846, 4.65, 0)
                        end
                    elseif moveVector.X > 0.1 then  -- Right
                        if lastDirection ~= "right" then
                            lastDirection = "right"
                            PlayAnim(10714177846, 4.65, 0)
                        end
                    else
                        if lastDirection ~= "forward" then
                            lastDirection = "forward"
                            PlayAnim(10714177846, 4.65, 0)
                        end
                    end
                elseif moveVector.Z > 0 then  -- Moving backward
                    if lastDirection ~= "backward" then
                        lastDirection = "backward"
                        PlayAnim(10147823318, 4.11, 0)
                    end
                end
            else
                if lastDirection ~= "idle" then
                    lastDirection = "idle"
                    PlayAnim(10714347256, 4, 0)  -- Idle animation
                end
            end
        end)
        
        -- Create BodyGyro and BodyVelocity
        local bg = Instance.new("BodyGyro")
        bg.Name = "FlyGyro"
        bg.P = 9e4
        bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.CFrame = rootPart.CFrame
        bg.Parent = rootPart
        
        local bv = Instance.new("BodyVelocity")
        bv.Name = "FlyVelocity"
        bv.Velocity = Vector3.new(0, 0.1, 0)
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Parent = rootPart
        
        -- Bind the flying physics update
        RunService:BindToRenderStep("Fly", Enum.RenderPriority.Camera.Value, function()
            local camera = workspace.CurrentCamera
            local moveVector = Controls:GetMoveVector()
            
            -- Calculate velocity
            if moveVector.Magnitude > 0 then
                bv.Velocity = ((camera.CFrame.LookVector * -moveVector.Z) + 
                    (camera.CFrame.RightVector * moveVector.X)) * flySpeed
            else
                bv.Velocity = Vector3.new(0, 0.1, 0)
            end
            
            -- Calculate tilt angles
            local forwardTilt = moveVector.Z < 0 and -90 or (moveVector.Z * 50)  -- -90 for forward tilt
            local sideTilt = -moveVector.X * 45  -- Up to 45 degrees for side tilt
            
            -- Update orientation with both forward and side tilt
            bg.CFrame = camera.CFrame 
                * CFrame.Angles(math.rad(forwardTilt), 0, math.rad(sideTilt))
        end)
    else
        workspace.Gravity = defaultGravity
        humanoid.PlatformStand = false
        lastDirection = "none"
        
        StopAnim()
        
        if rootPart:FindFirstChild("FlyGyro") then
            rootPart.FlyGyro:Destroy()
        end
        if rootPart:FindFirstChild("FlyVelocity") then
            rootPart.FlyVelocity:Destroy()
        end
        
        RunService:UnbindFromRenderStep("FlyControls")
        RunService:UnbindFromRenderStep("Fly")
    end
end

-- Update Toggle Function with a separate function
ToggleButton.MouseButton1Click:Connect(toggleFlight)

-- Update Speed Slider
SpeedSlider.MouseButton1Down:Connect(function()
    local mouse = game:GetService("Players").LocalPlayer:GetMouse()
    local moveConnection
    local releaseConnection
    
    local function updateSpeed(mouseX)
        local relativeX = math.clamp((mouseX - SpeedSlider.AbsolutePosition.X) / SpeedSlider.AbsoluteSize.X, 0, 1)
        flySpeed = math.floor(minSpeed + (maxSpeed - minSpeed) * relativeX)
        if flySpeed < 10 then flySpeed = 10 end  -- Minimum speed threshold
        SpeedSlider.Text = "SPEED: " .. flySpeed
        
        -- Update slider color based on speed
        local speedColor = Color3.fromRGB(
            math.floor(255 - (relativeX * 180)),
            math.floor(75 + (relativeX * 180)),
            75
        )
        TweenService:Create(SpeedSlider, TweenInfo.new(0.1), {
            BackgroundColor3 = speedColor
        }):Play()
    end
    
    updateSpeed(mouse.X)
    moveConnection = mouse.Move:Connect(function()
        updateSpeed(mouse.X)
    end)
    
    releaseConnection = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if moveConnection then moveConnection:Disconnect() end
            if releaseConnection then releaseConnection:Disconnect() end
        end
    end)
end)

-- Update Keybind System
local function handleKeybind(input)
    if not isSelectingKeybind and input.KeyCode == TOGGLE_KEY then
        toggleFlight()
    end
end

-- Update Keybind Button
KeybindButton.MouseButton1Click:Connect(function()
    isSelectingKeybind = true
    KeybindButton.Text = "PRESS ANY KEY..."
    KeybindButton.BackgroundColor3 = Color3.fromRGB(75, 255, 75)
end)

-- Update Input Handler
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if isSelectingKeybind then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            local blacklistedKeys = {
                Enum.KeyCode.Unknown,
                Enum.KeyCode.LeftShift,
                Enum.KeyCode.RightShift,
                Enum.KeyCode.LeftControl,
                Enum.KeyCode.RightControl,
                Enum.KeyCode.LeftAlt,
                Enum.KeyCode.RightAlt,
                Enum.KeyCode.LeftSuper,
                Enum.KeyCode.RightSuper
            }
            
            -- Check if key is blacklisted
            for _, blockedKey in ipairs(blacklistedKeys) do
                if input.KeyCode == blockedKey then
                    return
                end
            end
            
            -- Set new keybind
            isSelectingKeybind = false
            TOGGLE_KEY = input.KeyCode
            KeybindButton.Text = "KEYBIND: " .. input.KeyCode.Name
            KeybindButton.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        end
    else
        handleKeybind(input)
    end
end)

-- Add Cancel Keybind Selection
UserInputService.InputBegan:Connect(function(input)
    if isSelectingKeybind and input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePosition = UserInputService:GetMouseLocation()
        local buttonPosition = KeybindButton.AbsolutePosition
        local buttonSize = KeybindButton.AbsoluteSize
        
        -- Check if click is outside the button
        if mousePosition.X < buttonPosition.X or 
           mousePosition.X > buttonPosition.X + buttonSize.X or 
           mousePosition.Y < buttonPosition.Y or 
           mousePosition.Y > buttonPosition.Y + buttonSize.Y then
            
            isSelectingKeybind = false
            KeybindButton.Text = "KEYBIND: " .. TOGGLE_KEY.Name
            KeybindButton.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        end
    end
end)

-- Character Added Handler
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    
    if flying then
        workspace.Gravity = defaultGravity
        toggleFlight()
    end
end)

-- Update the draggable functionality to support both touch and mouse
local function enableDragging(frame)
    local dragging = false
    local dragTouch = nil
    local dragStart = nil
    local startPos = nil
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and not dragging then
            dragging = true
            dragTouch = input.Touch.TouchId
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and 
           dragging and 
           input.Touch.TouchId == dragTouch then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.TouchEnded:Connect(function(input)
        if input.Touch.TouchId == dragTouch then
            dragging = false
            dragTouch = nil
        end
    end)
end

-- Update the speed slider functionality
local function updateSpeedSlider()
    local sliding = false
    local touchId = nil
    
    local function updateSpeed(inputPosition)
        -- Check if input is within MainFrame bounds
        local mainFramePos = MainFrame.AbsolutePosition
        local mainFrameSize = MainFrame.AbsoluteSize
        
        -- Stop sliding if outside MainFrame
        if inputPosition.X < mainFramePos.X or 
           inputPosition.X > mainFramePos.X + mainFrameSize.X or
           inputPosition.Y < mainFramePos.Y or 
           inputPosition.Y > mainFramePos.Y + mainFrameSize.Y then
            sliding = false
            touchId = nil
            return
        end
        
        -- Calculate relative X position and clamp it
        local relativeX = math.clamp(
            (inputPosition.X - SpeedSlider.AbsolutePosition.X) / SpeedSlider.AbsoluteSize.X,
            0, 1
        )
        
        -- Update speed value
        flySpeed = math.floor(minSpeed + (maxSpeed - minSpeed) * relativeX)
        if flySpeed < 10 then flySpeed = 10 end
        SpeedSlider.Text = "SPEED: " .. flySpeed
        
        -- Update slider color based on speed
        local speedColor = Color3.fromRGB(
            math.floor(255 - (relativeX * 180)),
            math.floor(75 + (relativeX * 180)),
            75
        )
        SpeedSlider.BackgroundColor3 = speedColor
    end
    
    -- Handle touch start
    SpeedSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            touchId = input.Touch.TouchId
            updateSpeed(input.Position)
        end
    end)
    
    -- Handle touch movement
    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.Touch and input.Touch.TouchId == touchId then
            updateSpeed(input.Position)
        end
    end)
    
    -- Handle touch end
    UserInputService.TouchEnded:Connect(function(input)
        if input.Touch.TouchId == touchId then
            sliding = false
            touchId = nil
        end
    end)
    
    -- Additional safety cleanup
    game:GetService("RunService").RenderStepped:Connect(function()
        if sliding then
            local touches = UserInputService:GetTouches()
            local touchFound = false
            
            for _, touch in ipairs(touches) do
                if touch.TouchId == touchId then
                    touchFound = true
                    updateSpeed(touch.Position)
                    break
                end
            end
            
            if not touchFound then
                sliding = false
                touchId = nil
            end
        end
    end)
end

-- Initialize the speed slider
updateSpeedSlider()

-- Apply the dragging functionality to the MainFrame
enableDragging(MainFrame)

-- Call the enhance function after creating the GUI
enhanceGUI()

-- Add smooth transitions for button clicks
for _, button in pairs({ToggleButton, SpeedSlider, KeybindButton}) do
    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            Size = UDim2.new(button.Size.X.Scale, button.Size.X.Offset, button.Size.Y.Scale, button.Size.Y.Offset - 2)
        }):Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {
            Size = UDim2.new(button.Size.X.Scale, button.Size.X.Offset, button.Size.Y.Scale, button.Size.Y.Offset + 2)
        }):Play()
    end)
end

-- Update GUI elements
local function updateGUI()
    -- Remove old speed slider
    if SpeedSlider then SpeedSlider:Destroy() end
    
    -- Add speed control container
    local SpeedControl = Instance.new("Frame")
    SpeedControl.Name = "SpeedControl"
    SpeedControl.Size = UDim2.new(1, 0, 0, 38)
    SpeedControl.Position = UDim2.new(0, 0, 0, 88)
    SpeedControl.BackgroundTransparency = 1
    SpeedControl.Parent = Container
    
    -- Minus Button
    local MinusButton = Instance.new("TextButton")
    MinusButton.Size = UDim2.new(0.2, 0, 1, 0)
    MinusButton.Position = UDim2.new(0, 0, 0, 0)
    MinusButton.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    MinusButton.Text = "-"
    MinusButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinusButton.TextSize = 24
    MinusButton.Font = Enum.Font.GothamBold
    MinusButton.Parent = SpeedControl
    
    -- Speed Display
    local SpeedDisplay = Instance.new("TextLabel")
    SpeedDisplay.Size = UDim2.new(0.6, 0, 1, 0)
    SpeedDisplay.Position = UDim2.new(0.2, 0, 0, 0)
    SpeedDisplay.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    SpeedDisplay.Text = "SPEED: " .. flySpeed
    SpeedDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedDisplay.TextSize = 14
    SpeedDisplay.Font = Enum.Font.GothamSemibold
    SpeedDisplay.Parent = SpeedControl
    
    -- Plus Button
    local PlusButton = Instance.new("TextButton")
    PlusButton.Size = UDim2.new(0.2, 0, 1, 0)
    PlusButton.Position = UDim2.new(0.8, 0, 0, 0)
    PlusButton.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    PlusButton.Text = "+"
    PlusButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    PlusButton.TextSize = 24
    PlusButton.Font = Enum.Font.GothamBold
    PlusButton.Parent = SpeedControl
    
    -- Close Button (moved further right)
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 25, 0, 25)
    CloseButton.Position = UDim2.new(1, -8, 0, 3)  -- Moved further right
    CloseButton.AnchorPoint = Vector2.new(1, 0)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 20
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = Container
    
    -- Minimize Button
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
    MinimizeButton.Position = UDim2.new(1, -38, 0, 3)  -- Positioned to the left of close button
    MinimizeButton.AnchorPoint = Vector2.new(1, 0)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    MinimizeButton.Text = "-"
    MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeButton.TextSize = 20
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.Parent = Container
    
    -- Add corners to all buttons
    for _, button in pairs({MinusButton, SpeedDisplay, PlusButton, CloseButton, MinimizeButton}) do
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = button
    end
    
    -- Add hover effects
    for _, button in pairs({MinusButton, PlusButton, CloseButton, MinimizeButton}) do
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = button.BackgroundColor3:Lerp(Color3.fromRGB(255, 255, 255), 0.1)
            }):Play()
        end)
        
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.2), {
                BackgroundColor3 = button == CloseButton and Color3.fromRGB(255, 75, 75) or Color3.fromRGB(45, 45, 50)
            }):Play()
        end)
    end
    
    -- Button functionality
    local function updateSpeedDisplay()
        SpeedDisplay.Text = "SPEED: " .. flySpeed
        
        -- Update color based on speed
        local relativeSpeed = (flySpeed - minSpeed) / (maxSpeed - minSpeed)
        local speedColor = Color3.fromRGB(
            math.floor(255 - (relativeSpeed * 180)),
            math.floor(75 + (relativeSpeed * 180)),
            75
        )
        TweenService:Create(SpeedDisplay, TweenInfo.new(0.1), {
            BackgroundColor3 = speedColor
        }):Play()
    end
    
    MinusButton.MouseButton1Click:Connect(function()
        flySpeed = math.max(10, flySpeed - 10)
        updateSpeedDisplay()
    end)
    
    PlusButton.MouseButton1Click:Connect(function()
        flySpeed = math.min(maxSpeed, flySpeed + 10)
        updateSpeedDisplay()
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        -- First fade out all content
        for _, child in pairs(Container:GetChildren()) do
            TweenService:Create(child, TweenInfo.new(0.2), {
                BackgroundTransparency = 1
            }):Play()
            
            if child:IsA("TextButton") or child:IsA("TextLabel") then
                TweenService:Create(child, TweenInfo.new(0.2), {
                    TextTransparency = 1
                }):Play()
            end
        end
        
        -- Wait for fade out
        wait(0.2)
        
        -- Then animate the frame closing
        TweenService:Create(MainFrame, TweenInfo.new(
            0.3,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ), {
            Size = UDim2.new(0, MainFrame.Size.X.Offset, 0, 0),
            Position = UDim2.new(
                MainFrame.Position.X.Scale,
                MainFrame.Position.X.Offset,
                MainFrame.Position.Y.Scale,
                MainFrame.Position.Y.Offset + MainFrame.Size.Y.Offset/2
            )
        }):Play()
        
        -- Turn off flying if it's on
        if flying then
            toggleFlight()
        end
        
        -- Destroy after animations complete
        wait(0.3)
        ScreenGui:Destroy()
    end)
    
    -- Add minimize functionality
    local minimized = false
    MinimizeButton.MouseButton1Click:Connect(function()
        if minimized then
            -- Expanding
            -- First tween the frame size
            TweenService:Create(MainFrame, TweenInfo.new(
                0.3,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ), {
                Size = MainFrame:GetAttribute("OriginalSize")
            }):Play()
            
            -- Wait a bit before showing content
            wait(0.1)
            
            -- Fade in all content
            for _, child in pairs(Container:GetChildren()) do
                if child ~= Title and child ~= CloseButton and child ~= MinimizeButton then
                    child.Visible = true
                    
                    -- Special handling for SpeedControl frame
                    if child.Name == "SpeedControl" then
                        -- Set the frame itself to transparent
                        child.BackgroundTransparency = 1
                        
                        -- Handle the children of SpeedControl
                        for _, speedChild in pairs(child:GetChildren()) do
                            TweenService:Create(speedChild, TweenInfo.new(0.2), {
                                BackgroundTransparency = 0,
                                TextTransparency = 0
                            }):Play()
                        end
                    else
                        -- Handle other elements normally
                        TweenService:Create(child, TweenInfo.new(0.2), {
                            BackgroundTransparency = 0
                        }):Play()
                        
                        if child:IsA("TextButton") or child:IsA("TextLabel") then
                            TweenService:Create(child, TweenInfo.new(0.2), {
                                TextTransparency = 0
                            }):Play()
                        end
                    end
                end
            end
            
            MinimizeButton.Text = "-"
        else
            -- Store original size first time
            if not MainFrame:GetAttribute("OriginalSize") then
                MainFrame:SetAttribute("OriginalSize", MainFrame.Size)
            end
            
            -- Minimizing
            -- First fade out content
            for _, child in pairs(Container:GetChildren()) do
                if child ~= Title and child ~= CloseButton and child ~= MinimizeButton then
                    TweenService:Create(child, TweenInfo.new(0.2), {
                        BackgroundTransparency = 1
                    }):Play()
                    
                    -- If the child has text, fade that out too
                    if child:IsA("TextButton") or child:IsA("TextLabel") then
                        TweenService:Create(child, TweenInfo.new(0.2), {
                            TextTransparency = 1
                        }):Play()
                    end
                    
                    -- Hide after fade
                    delay(0.2, function()
                        child.Visible = false
                    end)
                end
            end
            
            -- Wait for fade out to complete
            wait(0.2)
            
            -- Then tween the frame size
            TweenService:Create(MainFrame, TweenInfo.new(
                0.3,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            ), {
                Size = UDim2.new(0, 200, 0, 40)
            }):Play()
            
            MinimizeButton.Text = "+"
        end
        
        minimized = not minimized
    end)
    
    -- Make entire GUI draggable
    local function enableDragging(frame)
        local dragging = false
        local dragInput
        local dragStart
        local startPos
        
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or 
               input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        
        frame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or
               input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
    end
    
    -- Apply dragging to MainFrame
    enableDragging(MainFrame)
end

-- Call the update function
updateGUI()
