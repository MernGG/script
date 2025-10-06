local GEODES_FOLDER = Workspace:WaitForChild("Geode") -- Workspace/Geodes
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FastTravel = ReplicatedStorage.Remotes.Misc.FastTravel
local GetFastTravelData = ReplicatedStorage.Remotes.Misc.GetFastTravelData

-- Request unlock data on startup

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")


print('Starting')
local TeleportCheck = false

Players.LocalPlayer.OnTeleport:Connect(function(State)
	if (not TeleportCheck) and queue_on_teleport then
		TeleportCheck = true
        GetFastTravelData:FireServer()
		queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/MernGG/script/refs/heads/master/geode4.lua'))()")
	end
end)




local function pickupGeodes()
    for _, geode in ipairs(GEODES_FOLDER:GetChildren()) do
        -- assume each geode is a Model with PrimaryPart set, or a Part
        local part = geode.PrimaryPart or geode:FindFirstChildWhichIsA("BasePart")
        if part then
            firetouchinterest(hrp, part, 0) -- simulate touch begin
            firetouchinterest(hrp, part, 1) -- simulate touch end
            wait(0.05)
        end
    end
    wait(1)
end



-- 🧭 Function to teleport to a specific waypoint
function teleportWaypoint(name)
	-- Find current waypoint (closest within 10 studs)
	local currentWaypoint = workspace.Map.Waypoints:FindFirstChild("Museum")

	-- Get the target waypoint model
	local target = workspace.Map.Waypoints:FindFirstChild(name)
	if not target then
		warn("Target waypoint", name, "not found in workspace.")
		return
	end

	print("Teleporting from", currentWaypoint.Name, "to", name)
	FastTravel:FireServer(currentWaypoint, target)
end


-- local sellall = player:WaitForChild("PlayerGui"):WaitForChild("BackpackGui"):WaitForChild("Backpack"):WaitForChild("Inventory"):WaitForChild("TopButtons"):WaitForChild("SellAll")
-- firesignal(sellall.MouseButton1Click)


-- Get a random public server
local function getRandomPublicServer()
	local servers = HttpService:JSONDecode(game:HttpGet(
		"https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
	)).data

	local valid = {}
	for _, server in ipairs(servers) do
		if server.playing < server.maxPlayers and server.id ~= game.JobId then
			table.insert(valid, server.id)
		end
	end

	if #valid > 0 then
		return valid[math.random(1, #valid)]
	else
		return nil
	end
end

-- Keep retrying until teleport succeeds
local function doRtp()
	while true do
		local serverId = getRandomPublicServer()
		if serverId then
			print("Trying server:", serverId)
			local success, err = pcall(function()
				TeleportService:TeleportToPlaceInstance(game.PlaceId, serverId, Players.LocalPlayer)
			end)

			if success then
				print("Teleport initiated.")
				break
			else
				warn("Teleport failed:", err)
			end
		else
			warn("No valid server found.")
		end

		-- Wait and retry
		task.wait(5)
	end
end

local function doLoop()
    if (not TeleportCheck) then
        queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/MernGG/script/refs/heads/master/geode4.lua'))()")
    end


    wait(10)
    teleportWaypoint("Fortune River")
    wait(10)
    pickupGeodes()
    teleportWaypoint("The Magma Furnace")
    wait(10)
    pickupGeodes()
    teleportWaypoint("Frozen Peak")
    wait(10)
    pickupGeodes()

    doRtp()
end 






doLoop()

