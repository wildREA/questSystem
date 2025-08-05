-- Services & Requires
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local QuestUpdateEvent = RemotesFolder:WaitForChild("QuestUpdateEvent")
local QuestDefinitions = require(ReplicatedStorage.Quests:WaitForChild("Quests"))

-- Add leaderstats
local function AddLeaderstats(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
end

-- Quest storage
local ActiveQuests = {}

-- Define an action to start the question (in this case simply when player is added)
Players.PlayerAdded:Connect(function(player)
	AddLeaderstats(player)
	
	-- Add XP IntValue to leaderstats
	local xp = Instance.new("IntValue")
	xp.Name = "XP"
	xp.Value = 0
	xp.Parent = player:WaitForChild("leaderstats")
	
	ActiveQuests[player.UserId] = {}  -- Player-specific quest data w/ '[player.UserId]'

	local quest = QuestDefinitions[1]  -- index realtive to ModuleScript: 'Quests'
	ActiveQuests[player.UserId][quest.id] = {step = 1}  -- Quest id reference from ModuleScript: 'Quests'
	QuestUpdateEvent:FireClient(player, "Start", quest)  -- Args: 'Start', QuestData
	-- 'player' is not a valid argument because it's the server sending the event)
end)


-- Checks progress with modular operations, AKA using ModuleScript: 'Quests' for references
-- Call later with heartbeat
local function CheckQuestProgress(player)
	local playerQuests = ActiveQuests[player.UserId]  -- 'player.UserId' is the player's unique identifier for quest data
	for questId, data in pairs(playerQuests) do  -- 'questId' is the id from ModuleScript: 'Quests', referenced by 'ActiveQuests'
		local quest = QuestDefinitions[questId]  -- defines the quest by id
		local currentStep = quest.steps[data.step]  -- 'quest.steps' is a table of steps for the quest, 'data.step' is the current step

		if currentStep and currentStep.condition(player) then  -- If the current step is valid and the condition is met, then the step is complete
			data.step += 1
			QuestUpdateEvent:FireClient(player, "StepComplete", data.step)  -- Previously unmentioned: 'StepComplete' is a client-side event because the client needs to know when a step is complete

			if data.step > #quest.steps then  -- If the current step is greater than the number of steps in the quest, then the quest is complete
				if quest.reward then
					quest.reward(player)
				end
				-- Notify client of completion (event updates UI)
				QuestUpdateEvent:FireClient(player, "Complete", quest)
			end
		end
	end
end


-- Tracks quest progress for all players
-- Call CheckQuestProgress periodically with heartbeat
local lastCheck = 0
game:GetService("RunService").Stepped:Connect(function(dt)
	lastCheck += dt
	if lastCheck >= 0.25 then
		lastCheck = 0
		for _, player in pairs(Players:GetPlayers()) do
			CheckQuestProgress(player)
		end
	end
end)
