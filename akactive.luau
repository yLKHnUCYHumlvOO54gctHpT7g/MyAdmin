-- Cache services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Create the ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdminActiveGUI"
screenGui.Parent = game:WaitForChild("CoreGui")

-- Create main container
local mainContainer = Instance.new("Frame")
mainContainer.Name = "MainContainer"
mainContainer.Size = UDim2.new(0, 140, 0, 45)
mainContainer.Position = UDim2.new(1, -145, 0, -55)
mainContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainContainer.BackgroundTransparency = 0.2
mainContainer.BorderSizePixel = 0
mainContainer.Parent = screenGui

-- Add styling to container
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 6)
uiCorner.Parent = mainContainer

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 35)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25, 25, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 25))
}
gradient.Rotation = 45
gradient.Parent = mainContainer

-- Create the green dot with enhanced visuals
local dot = Instance.new("Frame")
dot.Name = "HeartbeatDot"
dot.Size = UDim2.new(0, 8, 0, 8)  -- Smaller initial size
dot.Position = UDim2.new(0, 15, 0, 18)  -- Closer to text
dot.BackgroundColor3 = Color3.fromRGB(80, 240, 120)  -- Enhanced green color
dot.BorderSizePixel = 0
dot.AnchorPoint = Vector2.new(0.5, 0.5)
dot.Parent = mainContainer

-- Add rounded corners to the green dot
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(1, 0)
uiCorner.Parent = dot

-- Add glow effect to dot
local dotGlow = Instance.new("UIGradient")
dotGlow.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 240, 120)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 180, 80))
}
dotGlow.Parent = dot

-- Create text labels
local adminLabel = Instance.new("TextLabel")
adminLabel.Name = "AdminStatus"
adminLabel.Size = UDim2.new(0, 100, 0, 20)
adminLabel.Position = UDim2.new(0, 30, 0, 5)
adminLabel.Font = Enum.Font.GothamBold
adminLabel.Text = "AK Admin Active"
adminLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
adminLabel.TextSize = 13
adminLabel.TextXAlignment = Enum.TextXAlignment.Left
adminLabel.BackgroundTransparency = 1
adminLabel.Parent = mainContainer

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Name = "FPSCounter"
fpsLabel.Size = UDim2.new(0, 100, 0, 20)
fpsLabel.Position = UDim2.new(0, 30, 0, 22)
fpsLabel.Font = Enum.Font.Gotham
fpsLabel.Text = "FPS: --"
fpsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
fpsLabel.TextSize = 12
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel.BackgroundTransparency = 1
fpsLabel.Parent = mainContainer

-- Enhanced smooth animation
local heartbeatInfo = TweenInfo.new(
    0.8,  -- Faster, smoother pulse
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.InOut,
    -1,
    true
)

-- Create enhanced tweens
local heartbeatTween = TweenService:Create(dot, heartbeatInfo, {
    Size = UDim2.new(0, 12, 0, 12),  -- More subtle size change
    BackgroundTransparency = 0.2,
    BackgroundColor3 = Color3.fromRGB(100, 255, 140)  -- Color shift during pulse
})

-- Create rotation animation for the gradient
local rotationInfo = TweenInfo.new(
    2,
    Enum.EasingStyle.Linear,
    Enum.EasingDirection.InOut,
    -1
)

local gradientRotation = TweenService:Create(dotGlow, rotationInfo, {
    Rotation = 360
})

-- Play the animations
heartbeatTween:Play()
gradientRotation:Play()

-- FPS Counter logic
local frameCount = 0
local timeElapsed = 0

RunService.RenderStepped:Connect(function(delta)
    frameCount = frameCount + 1
    timeElapsed = timeElapsed + delta
    
    if timeElapsed >= 1 then
        local fps = math.floor(frameCount / timeElapsed)
        fpsLabel.Text = "FPS: " .. tostring(fps)
        
        frameCount = 0
        timeElapsed = 0
    end
end)
