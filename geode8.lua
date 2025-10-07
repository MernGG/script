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
		queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/MernGG/script/refs/heads/master/geode8.lua'))()")
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
-- local cap = player:WaitForChild("PlayerGui"):WaitForChild("BackpackGui"):WaitForChild("Backpack"):WaitForChild("Inventory"):WaitForChild("TopButtons"):WaitForChild("Unaffected"):WaitForChild("InventorySize").Text

local function getRandomPublicServer()
	local base = ("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=1&limit=100&excludeFullGames=true")
		:format(tostring(game.PlaceId))

	local valid = {}
	local cursor = nil
	local pagesFetched = 0

	while pagesFetched < 3 do
		pagesFetched += 1

		local url = base
		if cursor then
			url = url .. "&cursor=" .. HttpService:UrlEncode(cursor)
		end

		local success, response = pcall(function()
			return HttpService:JSONDecode(game:HttpGet(url))
		end)

		if not success then
			warn("Failed to get server list:", response)
			break
		end

		if not response or typeof(response) ~= "table" or typeof(response.data) ~= "table" then
			warn("Malformed server list response.")
			break
		end

		for _, server in ipairs(response.data) do
			if server.playing and server.maxPlayers and server.id
				and server.playing < server.maxPlayers
				and server.id ~= game.JobId
			then
				table.insert(valid, server.id)
			end
		end

		-- Prepare next page; stop if there's no next cursor.
		cursor = response.nextPageCursor
		if not cursor then
			break
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
	local retrying = false

	-- Attach a listener in case teleport fails
	TeleportService.TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
		if player == Players.LocalPlayer then
			warn("Teleport failed with result:", teleportResult.Name, errorMessage)
			if not retrying then
				retrying = true
				task.delay(5, function()
					doRtp()
				end)
			end
		end
	end)

	while true do
		local serverId = getRandomPublicServer()
		if serverId then
			print("Attempting to teleport to server:", serverId)
			local success, err = pcall(function()
				TeleportService:TeleportToPlaceInstance(game.PlaceId, serverId, Players.LocalPlayer)
			end)

			-- If Teleport call was accepted, break the loop
			if success then
				print("Teleport call accepted")
				break
			else
				warn("Teleport call failed:", err)
			end
		else
			warn("No available servers found.")
		end

		task.wait(5)
	end
end

local function doLoop()
    wait(10)
    teleportWaypoint("Fortune River")
    wait(10)
    pickupGeodes()
    teleportWaypoint("The Magma Furnace")
    wait(7)
    pickupGeodes()
    teleportWaypoint("Frozen Peak")
    wait(7)
    pickupGeodes()

    doRtp()
end 


doLoop()