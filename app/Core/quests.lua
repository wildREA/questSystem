local QuestDefinitions = {}

-- QuestDefinitions contain a quest object and properties within the object. They can be modified as needed to either modify, add, or remove a quest, or vice-versa for the properties of an object
QuestDefinitions[1] = {
	id = 1,
	title = "The Holy Trinity",
	description = "Step onto three blocks",
	steps = {
		{
			id = 1,  -- Step 1 stars upon PlayerAdded
			description = "Step onto the first block",
			partName = "Step1Part",
			condition = function(player, part)
				local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				local part = workspace:FindFirstChild("Step1Part")
				return hrp and (hrp.Position - part.Position).Magnitude < 5
			end,
		},
		{
			id = 2,  -- Next steps are followed by touching the blocks
			description = "Step onto the next block",
			partName = "Step2Part",
			condition = function(player, part)
				local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				local part = workspace:FindFirstChild("Step2Part")
				return hrp and (hrp.Position - part.Position).Magnitude < 5
			end
		},
		{
			id = 3,
			description = "Step onto the other block",
			partName = "Step3Part",
			condition = function(player, part)
				local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				local part = workspace:FindFirstChild("Step3Part")
				return hrp and (hrp.Position - part.Position).Magnitude < 5
			end
		}
	},
	-- Reward function(s)
	-- If a quest needs a different reward, a reward functions names can be specified, or just changing the reward itself is possible
	reward = function(player)
		local stats = player:FindFirstChild("leaderstats")
		if stats and stats:FindFirstChild("XP") then
			stats.XP.Value += 100
		end
	end
}

return QuestDefinitions
