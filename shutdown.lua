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
    local fadeConn = RunService.Heartbeat:Connect(function()
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
    local dotConn = RunService.Heartbeat:Connect(function()
        local now = os.clock()
        if now - lastDotTime >= dotInterval then
            lastDotTime = now
            dotCount = (dotCount + 1) % 4
            dots.Text = "Please wait"..string.rep(".", dotCount)
        end
    end)

    -- Pulsing title effect
    local pulseConn = RunService.Heartbeat:Connect(function()
        local pulse = math.sin(os.clock() * 1.5) * 0.05 + 1
        title.TextSize = 32 * pulse
    end)

    return gui, function()
        fadeConn:Disconnect()
        dotConn:Disconnect()
        pulseConn:Disconnect()
    end
