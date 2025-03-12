-- Assuming you have already included the Rayfield UI library in your game
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

-- Load the updated Rayfield UI library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Customization Settings
local rainbowSpeed = 2    -- Speed of the rainbow effect (higher = faster)
local healthBarWidth = 6  -- Width of the health bar
local showHealthBar = true -- Toggle visibility of the health bar
local ESP_ENABLED = true  -- Toggle ESP

-- Function to generate a smoothly changing rainbow color
local function getRainbowColor(timeOffset)
    local time = tick() * rainbowSpeed + timeOffset
    local r = math.sin(time) * 127 + 128
    local g = math.sin(time + 2) * 127 + 128
    local b = math.sin(time + 4) * 127 + 128
    return Color3.fromRGB(r, g, b)
end

-- Create the Rayfield window with a Dark Blue theme
local Window = Rayfield:CreateWindow({
    Name = "ESP Customization",
    LoadingTitle = "Loading ESP Customization...",
    LoadingSubtitle = "Please wait",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,  -- Saves config in Roblox settings
        FileName = "ESP_Settings"
    },
    Discord = {
        Enabled = true,
        Invite = "https://discord.com/invite/YourInvite",  -- Replace with your own invite link
        UseLink = true
    },
    KeySystem = false, -- Disable key system for now
    Key = "",  -- Optional: Key for system
    Theme = Color3.fromRGB(0, 0, 128), -- Dark blue theme for the Rayfield window
})

-- Add a section for ESP Settings
local ESPSection = Window:CreateSection("ESP Settings", {name = "Settings"})

-- Create ESP Settings Sliders and Toggles using Rayfield

-- Rainbow Speed Slider
local rainbowSpeedSlider = ESPSection:CreateSlider({
    Name = "Rainbow Speed",
    Min = 1,
    Max = 10,
    Default = rainbowSpeed,
    Color = Color3.fromRGB(255, 255, 0),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(value)
        rainbowSpeed = value
    end,
})

-- Health Bar Width Slider
local healthBarWidthSlider = ESPSection:CreateSlider({
    Name = "Health Bar Width",
    Min = 2,
    Max = 10,
    Default = healthBarWidth,
    Color = Color3.fromRGB(255, 0, 0),
    Increment = 1,
    ValueName = "Width",
    Callback = function(value)
        healthBarWidth = value
    end,
})

-- Show Health Bar Toggle
local showHealthBarToggle = ESPSection:CreateToggle({
    Name = "Show Health Bar",
    Default = showHealthBar,
    Callback = function(state)
        showHealthBar = state
    end
})

-- ESP Toggle (Enable/Disable ESP)
local ESPToggleButton = ESPSection:CreateToggle({
    Name = "Enable ESP",
    Default = ESP_ENABLED,
    Callback = function(state)
        ESP_ENABLED = state
    end,
})

-- Menu Toggle Key (M)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.M then
        Window:Toggle()  -- Toggle Rayfield menu when 'M' is pressed
    end
end)

-- Function to update ESP settings based on Rayfield values
local function updateSettings()
    rainbowSpeed = rainbowSpeedSlider:GetValue()
    healthBarWidth = healthBarWidthSlider:GetValue()
end

-- Create ESP function (same as before, now using customizable settings)
local function createESP(player)
    if player == LocalPlayer then return end

    local espBox = Drawing.new("Square")
    espBox.Visible = false
    espBox.Thickness = 2
    espBox.Filled = false

    local nameTag = Drawing.new("Text")
    nameTag.Visible = false
    nameTag.Size = 16
    nameTag.Center = true
    nameTag.Outline = true
    nameTag.Font = 2 -- Bold font

    local healthBarBackground = Drawing.new("Square") -- Health bar background
    healthBarBackground.Visible = false
    healthBarBackground.Thickness = 1
    healthBarBackground.Filled = true
    healthBarBackground.Color = Color3.fromRGB(50, 50, 50) -- Dark gray

    local healthBar = Drawing.new("Square") -- Health bar (shrinks with health)
    healthBar.Visible = false
    healthBar.Thickness = 0
    healthBar.Filled = true

    -- Function to determine if the player is a friend of the LocalPlayer
    local function isPlayerFriend()
        return player:IsFriendsWith(LocalPlayer.UserId)
    end

    local function updateESP()
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not player.Character:FindFirstChild("Humanoid") then
            espBox.Visible = false
            nameTag.Visible = false
            healthBar.Visible = false
            healthBarBackground.Visible = false
            return
        end

        local character = player.Character
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")

        local screenPosition, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
        
        if onScreen and ESP_ENABLED then
            local head = character:FindFirstChild("Head")
            local headPosition = head.Position + Vector3.new(0, 1, 0)
            local bottomPosition = humanoidRootPart.Position - Vector3.new(0, 3, 0)
            
            local topScreenPosition = Camera:WorldToViewportPoint(headPosition)
            local bottomScreenPosition = Camera:WorldToViewportPoint(bottomPosition)

            local boxHeight = math.abs(topScreenPosition.Y - bottomScreenPosition.Y)
            local boxWidth = boxHeight / 2

            -- Determine the color based on friendship status
            local boxColor
            local textColor
            if isPlayerFriend() then
                boxColor = Color3.fromRGB(255, 255, 0)  -- Yellow for friends
                textColor = Color3.fromRGB(255, 255, 0)  -- Yellow for friends
            else
                boxColor = getRainbowColor(player.UserId)  -- Rainbow effect for non-friends
                textColor = getRainbowColor(player.UserId)  -- Rainbow effect for non-friends
            end

            -- Apply the color to the box
            espBox.Color = boxColor
            espBox.Size = Vector2.new(boxWidth, boxHeight)
            espBox.Position = Vector2.new(screenPosition.X - boxWidth / 2, screenPosition.Y - boxHeight / 2)
            espBox.Visible = true

            -- Apply the color to the name tag
            nameTag.Position = Vector2.new(screenPosition.X, screenPosition.Y - boxHeight / 2 - 15)
            nameTag.Text = player.Name .. " [" .. math.floor(humanoid.Health) .. "]"
            nameTag.Color = textColor
            nameTag.Visible = true

            -- Health bar calculations
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            local barHeight = boxHeight * healthPercent -- Health bar shrinks with health

            -- Health bar background size
            healthBarBackground.Size = Vector2.new(healthBarWidth, boxHeight) -- Full height background
            healthBarBackground.Position = Vector2.new(espBox.Position.X - healthBarWidth - 4, espBox.Position.Y)
            healthBarBackground.Visible = true

            if showHealthBar then
                -- Health bar size and position
                healthBar.Size = Vector2.new(healthBarWidth, barHeight)
                healthBar.Position = Vector2.new(espBox.Position.X - healthBarWidth - 4, espBox.Position.Y + (boxHeight - barHeight)) -- Shrinks from the bottom
                healthBar.Color = Color3.fromRGB(255 - (healthPercent * 255), healthPercent * 255, 0) -- Red to Green gradient
                healthBar.Visible = true
            else
                healthBar.Visible = false
            end
        else
            espBox.Visible = false
            nameTag.Visible = false
            healthBar.Visible = false
            healthBarBackground.Visible = false
        end
    end

    RunService.RenderStepped:Connect(updateESP)
end

-- Handle players joining and creating ESP for them
local function onPlayerAdded(player)
    player.CharacterAdded:Connect(function()
        wait(1) -- Allow character to load
        createESP(player)
    end)
end

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        onPlayerAdded(player)
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)
