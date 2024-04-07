local http = game:GetService("HttpService")
local tp = game:GetService("TeleportService")
local uis = game:GetService("UserInputService")
local p = game:GetService("Players").LocalPlayer -- Player
local char = p.Character -- Character
local hrp = char:WaitForChild("HumanoidRootPart")

local function ServerHop()
    local function RandomServer()
        local ts = {}
        local stt = http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        for i,v in pairs(stt.data) do
            if v.playing ~= v.maxPlayers then
                table.insert(ts,v)
            end
        end
        return ts[math.random(1,#ts)]
    end
    tp:TeleportToPlaceInstance(game.PlaceId, RandomServer().id)
end

local function attackTarget(trackpart)
    game:GetService("ReplicatedStorage").Knit.Services.NodeService.RE.NodeClicked:FireServer(game:GetService("Workspace").Nodes[trackpart], true, false)
end

local function getClosest(trackpart)
    local distance = math.huge
    local tg
    for i, v in pairs(game:GetService("Workspace").Nodes:GetChildren()) do
        thing = string.split(v.Name, "_")
        for i2, v2 in pairs(thing) do
            if v2 == trackpart or trackpart == nil then
                local mag = (hrp.Position - v.Position).Magnitude
                if mag < distance then
                    distance = mag
                    tg = v
                end
            end
        end
    end
    print("Final Target: " .. tg.Name .. ", at Magniutde: " .. distance)
    tg.Name = "closest"
    return tg
end

local function getClosestsInRange(trackpart, range)
    local tgs = {}
    ind = 1
    for i, v in pairs(game:GetService("Workspace").Nodes:GetChildren()) do
        thing = string.split(v.Name, "_")
        for i2, v2 in pairs(thing) do
            if v2 == trackpart or trackpart == nil then
				local mag = (hrp.Position - v.Position).Magnitude
				if mag < range then
	    			v.Name = "closest" .. i
					print("added: " .. v.Name)
					table.insert(tgs, v.Name)
				end
            end
        end
    end
    return tgs
end

running = false
local function attackAllNearby(trackpart)
    while #trackpart > 0 and _G.enemyAutofarmActive == true do
		running = true
		if game:GetService("Workspace").Nodes:FindFirstChild(trackpart[1]) then
	        attackTarget(trackpart[1])
			placeholderPosition = (game:GetService("Workspace").Nodes:FindFirstChild(trackpart[1]).Position + Vector3.new(0, 10, 0))
       	end
		 repeat wait() until game:GetService("Workspace").Nodes:FindFirstChild(trackpart[1]) == nil
		hrp.Position = placeholderPosition
        table.remove(trackpart, 1)
    end
    running = false
end

spawn(function()
	 while _G.eggOpenActive == true do
		print("rizz")
		for i, v in pairs(_G.eggs) do
			game:GetService("ReplicatedStorage").Knit.Services.VendorService.RF.Purchase:InvokeServer(_G.eggs[i], _G.amountToOpen)
			wait()
		end
    end
end)

spawn(function()
    while _G.scriptActive == true do
		wait()
		if _G.enemyAutofarmActive == true and running == false then
	    	attackAllNearby(getClosestsInRange(_G.target, _G.range))
		end
    end
end)
