  local player = game.Players.LocalPlayer;
		local tag = Instance.new("BillboardGui");
		tag.Name = "PlayerTag";
		tag.AlwaysOnTop = true;
		tag.Size = UDim2.new(0, 200, 0, 50);
		tag.StudsOffset = Vector3.new(0, 3, 0);
		local label = Instance.new("TextLabel");
		label.Name = "TagLabel";
		label.Size = UDim2.new(1, 0, 1, 0);
		label.BackgroundTransparency = 1;
		label.Text = "AK OWNER";
		label.TextColor3 = Color3.new(1, 1, 1);
		label.TextStrokeTransparency = 0.5;
		label.TextStrokeColor3 = Color3.new(0, 0, 0);
		label.Font = Enum.Font.Bangers;
		label.FontSize = Enum.FontSize.Size32;
		local Advertisers = {"Vlafz195","6736_45","goekaycool","goekayhack","goekayball","goekayball2"};
		local FreeTrial = {};
		local Scripters = {"GYATT_DAMN1","328ml",""};
		local Owners = {"IIIlIIIllIlIllIII","AliKhammas1234","AliKhammas","dgthgcnfhhbsd","AK_ADMEN1","YournothimbuddyXD","AK_ADMEN2"};
		local GMS = {"victorwielki"};
		local AKStaff = {"goekaycool"} -- New staff table

		-- Create tags for different ranks
		local function createTag(player, text)
			-- Check if player already has a tag
			if player.Character then
				local existingTag = player.Character.Head:FindFirstChild("RankTag")
				if existingTag then
					return -- Exit if tag already exists
				end
			end

			local tag = Instance.new("BillboardGui")
			tag.Name = "RankTag"
			tag.Size = UDim2.new(0, 200, 0, 50)
			tag.StudsOffset = Vector3.new(0, 2.5, 0)
			tag.AlwaysOnTop = true
			tag.MaxDistance = math.huge
			
			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, 0, 1, 0)
			label.BackgroundTransparency = 1
			label.Text = text
			label.TextColor3 = Color3.new(1, 1, 1)
			label.TextStrokeTransparency = 1
			label.Font = Enum.Font.SourceSansBold
			label.TextSize = 20
			label.Parent = tag

			-- Update transparency based on distance
			game:GetService("RunService").RenderStepped:Connect(function()
				if player.Character and player.Character:FindFirstChild("Head") and game.Players.LocalPlayer.Character then
					local distance = (player.Character.Head.Position - game.Players.LocalPlayer.Character.Head.Position).Magnitude
					if distance > 49 then
						local transparency = math.min((distance - 25) / 25, 0.5)
						label.TextTransparency = transparency
					else
						label.TextTransparency = 0
					end
				end
			end)
			
			-- Attach tag to player character
			if player.Character and player.Character:FindFirstChild("Head") then
				tag.Parent = player.Character.Head
			end
			
			-- Handle character respawning
			player.CharacterAdded:Connect(function(char)
				local head = char:WaitForChild("Head")
				-- Check for existing tag before creating new one
				if not head:FindFirstChild("RankTag") then
					tag.Parent = head
				end
			end)
		end

		-- Function to check player rank and apply appropriate tag
		local function applyPlayerTag(player)
			-- Wait for character to load
			if not player.Character then
				player.CharacterAdded:Wait()
			end
			
			if table.find(Owners, player.Name) then
				createTag(player, "AK OWNER")
			elseif table.find(Scripters, player.Name) then
				createTag(player, "AK SCRIPTER")
			elseif table.find(GMS, player.Name) then
				createTag(player, "AK GM")
			elseif table.find(AKStaff, player.Name) then
				createTag(player, "AK STAFF")
			elseif table.find(Advertisers, player.Name) then
				createTag(player, "AK ADVERTISER")
			elseif table.find(FreeTrial, player.Name) then
				createTag(player, "AK TRIAL")
			elseif table.find(getgenv().premiumUsers, player.Name) then
				createTag(player, "AK USER")
			end
		end

		-- Apply tags to existing players
		for _, player in pairs(game.Players:GetPlayers()) do
			applyPlayerTag(player)
		end

		-- Apply tags to new players who join
		game.Players.PlayerAdded:Connect(applyPlayerTag)
