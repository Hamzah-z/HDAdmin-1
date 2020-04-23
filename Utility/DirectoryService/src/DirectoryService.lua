local module = {}



-- SERVICES
local players = game:GetService("Players")
local starterGui = game:GetService("StarterGui")
local replicatedStorage = game:GetService("ReplicatedStorage")



-- LOCAL FUNCTIONS
local function createFolder(folderName, folderParent)
	local folder = folderParent:FindFirstChild(folderName)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = folderName
		folder.Parent = folderParent
	end
	return folder
end

local function getPathwayTable(pathway)
	return pathway:split(".")
end

local function setupDirectory(pathwayTable, startParent, finalFunction)
	local currentParent = startParent
	local total = #pathwayTable
	for i = 1, total do
		local folderName = pathwayTable[i]
		local folder = createFolder(folderName, currentParent)
		if i == total and finalFunction then
			return(finalFunction(folder))
		end
		currentParent = folder
	end
end



-- FUNCTIONS
function module:getLocationDetails(location)
	local realLocations = {
		["ServerStorage"] = {
			realLocation = game:GetService("ServerStorage"),
		},
		["ReplicatedStorage"] = {
			realLocation = game:GetService("ReplicatedStorage"),
		},
		["StarterGui"] = {
			realLocation = game:GetService("StarterGui"),
			playerPathway = "PlayerGui.HDAdmin",
		},
		["StarterPlayerScripts"] = {
			realLocation = game:GetService("StarterPlayer").StarterPlayerScripts,
			playerPathway = "PlayerScripts",
		},
		["StarterCharacterScripts"] = {
			realLocation = game:GetService("StarterPlayer").StarterCharacterScripts,
			playerPathway = "Character",
		},
	}
	return realLocations[location]
end

function module:createDirectory(pathway, contents)
	local pathwayTable = getPathwayTable(pathway)
	local location = table.remove(pathwayTable, 1)
	local locationDetails = self:getLocationDetails(location)
	local currentParent = locationDetails.realLocation
	local finalFunction = function(finalFolder)
		local playerPathway = locationDetails.playerPathway
		if playerPathway then
			local playerPathwayTable = getPathwayTable(playerPathway)
			local playerFinalFunction = function(finalFolder)
				for _, object in pairs(contents) do
					object:Clone().Parent = finalFolder
				end
			end
			for _, plr in pairs(players:GetPlayers()) do
				setupDirectory(playerPathwayTable, plr, playerFinalFunction)
			end
		end
		for _, object in pairs(contents) do
			object.Parent = finalFolder
		end
		return finalFolder
	end
	if #pathwayTable == 0 then
		return(finalFunction(currentParent))
	end
	return(setupDirectory(pathwayTable, currentParent, finalFunction))
end



return module