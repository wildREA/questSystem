-- Services & External References
local QuestUpdateEvent = game.ReplicatedStorage.Remotes:WaitForChild("QuestUpdateEvent")  -- Wait for the RemoteEvent to be available since it's being programatically created in QuestHandler

-- Basic UI elements
local questFrame = game.Players.LocalPlayer.PlayerGui:WaitForChild("ScreenGui"):WaitForChild("QuestFrame")


-- Copy billboard GUI per step's block
local function PlaceBillboardGui(object, stepDescription)
	local BillboardGui = game.ReplicatedStorage:WaitForChild("BillboardGuis"):WaitForChild("QuestBillboard"):Clone()
	BillboardGui.Parent = object
	BillboardGui.TextLabel.Text = stepDescription
	BillboardGui.Enabled = 1
end


-- Remove previous billboard (if any) and replace with new one to correct block
local function ShowQuestBillboard(quest, stepNumber)
	-- Validate step number
	local currentStep = quest.steps[stepNumber]
	if not currentStep then
		warn("Invalid step number:", stepNumber, "Quest either doesn't exist or is finished")  -- Fallback for += 1 for last step
		return
	end

	-- Destroy existing billboard on *any* part that has one named "QuestBillboard"
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("BillboardGui") and v.Name == "QuestBillboard" then
			v:Destroy()
		end
	end

	-- Ensure step part exists
	local part = workspace:WaitForChild(currentStep.partName, 5)  -- 5s timeout
	if not part then
		warn("Part not found (even after waiting) for step:", stepNumber)
		return
	end
	
	-- Call function to place a new billboard for the correct step part
	PlaceBillboardGui(part, currentStep.description)
	
	-- Validates data to prevent future mistakes (unknown error fallback)
	if typeof(stepNumber) ~= "number" then
		warn("Expected stepNumber to be a number but got:", stepNumber)
		return
	end
end


-- Quest state tracking
local currentQuest

-- Quest update event listener
QuestUpdateEvent.OnClientEvent:Connect(function(action, data)
	if action == "Start" then
		currentQuest = data  -- Store the quest data
		print("Quest started:", data)
		questFrame.Title.Text = data.title
		questFrame.Desc.Text = data.description  -- Refers to the quest's own description (not steps descriptions)
		ShowQuestBillboard(currentQuest, 1)
		questFrame:WaitForChild("Counter").Text = "Start!"  -- probably needs to use waitForChild since it has things inside it, but also doesnt make sense since they are large items in size
	elseif action == "StepComplete" then
		ShowQuestBillboard(currentQuest, data)
		questFrame.Counter.Text = "Step " .. data .. " completed"  -- Refers to an integer as a number
	elseif action == "Complete" then
		questFrame.Counter.Text = "Quest complete!"
	end
end)
