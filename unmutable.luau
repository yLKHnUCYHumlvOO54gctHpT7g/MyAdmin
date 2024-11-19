local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local ToggleButton = Instance.new("TextButton")
local UICorner_2 = Instance.new("UICorner")
local UIPadding = Instance.new("UIPadding")
local CloseButton = Instance.new("TextButton")
local UICorner_3 = Instance.new("UICorner")

-- Properties
ScreenGui.Name = "UnmutableGUI"
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -50)
MainFrame.Size = UDim2.new(0, 200, 0, 100)
MainFrame.Active = true
MainFrame.Draggable = true

UICorner.Parent = MainFrame
UICorner.CornerRadius = UDim.new(0, 8)

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(-0.09, 0, 0, 0)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "UNMUTABLE (MIC UP)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16

ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = MainFrame
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 59, 59)
ToggleButton.Position = UDim2.new(0.5, -70, 0.5, 0)
ToggleButton.Size = UDim2.new(0, 140, 0, 35)
ToggleButton.Font = Enum.Font.GothamSemibold
ToggleButton.Text = "OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14

UICorner_2.Parent = ToggleButton
UICorner_2.CornerRadius = UDim.new(0, 6)

UIPadding.Parent = MainFrame
UIPadding.PaddingBottom = UDim.new(0, 10)
UIPadding.PaddingLeft = UDim.new(0, 10)
UIPadding.PaddingRight = UDim.new(0, 10)
UIPadding.PaddingTop = UDim.new(0, 10)

CloseButton.Name = "CloseButton"
CloseButton.Parent = MainFrame
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 59, 59)
CloseButton.Position = UDim2.new(1, -25, 0, 5)
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 14

UICorner_3.Parent = CloseButton
UICorner_3.CornerRadius = UDim.new(0, 4)
getgenv().cantmutemehaha = false
local plr = game.Players.LocalPlayer
local char = plr.Character
local hrp = char.HumanoidRootPart
-- Toggle functionality
local enabled = false
ToggleButton.MouseButton1Click:Connect(function()
    enabled = not enabled
    ToggleButton.Text = enabled and "ON" or "OFF"
    ToggleButton.BackgroundColor3 = enabled and Color3.fromRGB(59, 255, 59) or Color3.fromRGB(255, 59, 59)
    
    if enabled then
        getgenv().originpos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
        getgenv().cantmutemehaha = true
        spawn(function()
            while getgenv().cantmutemehaha do
                task.wait()
                if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
                    hrp.CFrame = CFrame.new(
                        math.random(getgenv().originpos.X - 7, getgenv().originpos.X + 7),
                        getgenv().originpos.Y,
                        math.random(getgenv().originpos.Z - 7, getgenv().originpos.Z + 7)
                    )
                end
            end
        end)
    else
        getgenv().cantmutemehaha = false
        wait(0.03)
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = getgenv().originpos
        end
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)
