local GEODES_FOLDER = Workspace:WaitForChild("Geode") -- Workspace/Geodes
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local gui = player:WaitForChild("PlayerGui"):WaitForChild("MainUI")
local list = gui:WaitForChild("FastTravel"):WaitForChild("Content"):WaitForChild("List")

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")


print('Starting...')
local TeleportCheck = false

Players.LocalPlayer.OnTeleport:Connect(function(State)
	if (not TeleportCheck) and queue_on_teleport then
		TeleportCheck = true
		queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/MernGG/script/refs/heads/master/geode.lua'))()")
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
end


local function teleportWaypoint(wp)
-- Loop through all entries in the list
    for _, entry in ipairs(list:GetChildren()) do
        if entry:IsA("TextButton") or entry:IsA("ImageButton") then
            if entry.Name == wp then
                print('here')
                firesignal(entry.MouseButton1Click)
            end
        end
    end
end


-- local sellall = player:WaitForChild("PlayerGui"):WaitForChild("BackpackGui"):WaitForChild("Backpack"):WaitForChild("Inventory"):WaitForChild("TopButtons"):WaitForChild("SellAll")
-- firesignal(sellall.MouseButton1Click)


local function getRandomPublicServer()
    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
    local success, response = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)

    if not success then
        warn("Failed to get server list:", response)
        return nil
    end

    local servers = response.data
    local valid = {}

    for _, server in pairs(servers) do
        if server.playing < server.maxPlayers and server.id ~= game.JobId then
            table.insert(valid, server.id)
        end
    end

    if #valid > 0 then
        return valid[math.random(1, #valid)]
    else
        warn("No valid servers found.")
        return nil
    end
end

-- local cmd = "loadstring(game:HttpGet('https://raw.githubusercontent.com/TokyoYoo/gga2/refs/heads/main/Trst.lua'))()"
-- queue_on_teleport(cmd)


local function doRtp()
    local serverId = getRandomPublicServer()
    if serverId then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, serverId, Players.LocalPlayer)
    else
        wait(15)
        doRtp()
    end
end

local function doLoop()
    if (not TeleportCheck) then
        queue_on_teleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/MernGG/script/refs/heads/master/geode.lua'))()")
    end
    

    wait(10)
    local fastTravelMenu = player.PlayerGui.MainUI.FastTravel
    fastTravelMenu.Visible = true
    task.wait(0.1)
    fastTravelMenu.Visible = false
    wait(1)
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

