-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

-- Settings
local ESP_ENABLED = true
local aimbotEnabled = false
local flyingEnabled = false
local targetPart = "Head"
local fovRadius = 100
local flySpeed = 50
local walkSpeed = 16
local jumpPower = 50
local rightClickHeld = false

-- Rayfield UI Window
local Window = Rayfield:CreateWindow({
    Name = "V0xelHub",
    LoadingTitle = "Loading Features...",
    LoadingSubtitle = "Please wait",
    Theme = "DarkBlue"
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "V0xelSettings",
        FileName = "config"
    }
    -- Key
    KeySystem = true
    KeySettings = {
        Title = "Cheese dreamer detected"
        Subtitle = "Provide a valid key"
        Note = "Only way to get a key is to get it from V0xel noob >:D"
        SaveKey = true
        Key = {"ohminty","fart","pinus","criminality","myheadhurtsfromcoding","v0xelballs"}

})

local MainTab = Window:CreateTab("Cheats", "box")

-- ESP Toggle with Callback
local ESPToggleButton = MainTab:CreateToggle({
    Name = "Enable ESP",
    Default = ESP_ENABLED,
    Callback = function(state)
        ESP_ENABLED = state
        if ESP_ENABLED then
            enableESP()
        else
            disableESP()
        end
    end,
})

-- Aimbot Toggle
local aimbotToggle = MainTab:CreateToggle({
    Name = "Enable Aimbot",
    Default = aimbotEnabled,
    Callback = function(state)
        aimbotEnabled = state
    end
})

-- Fly Toggle
local flyToggle = MainTab:CreateToggle({
    Name = "Enable Fly",
    Default = flyingEnabled,
    Callback = function(state)
        flyingEnabled = state
        if flyingEnabled then
            enableFly()
        else
            disableFly()
        end
    end
})

-- Fly Speed Slider
local flySpeedSlider = MainTab:CreateSlider({
    Name = "Fly Speed",
    Min = 10,
    Max = 200,
    Default = flySpeed,
    Increment = 5,
    Callback = function(value)
        flySpeed = value
    end
})

-- Walk Speed Slider
local walkSpeedSlider = MainTab:CreateSlider({
    Name = "Walk Speed",
    Min = 0,
    Max = 100,
    Default = walkSpeed,
    Increment = 1,
    Callback = function(value)
        walkSpeed = value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = walkSpeed
        end
    end
})

-- Jump Power Slider
local jumpPowerSlider = MainTab:CreateSlider({
    Name = "Jump Power",
    Min = 0,
    Max = 200,
    Default = jumpPower,
    Increment = 5,
    Callback = function(value)
        jumpPower = value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = jumpPower
        end
    end
})

-- FOV Slider
local fovSlider = MainTab:CreateSlider({
    Name = "FOV Radius",
    Min = 50,
    Max = 200,
    Default = fovRadius,
    Increment = 10,
    Callback = function(value)
        fovRadius = value
    end
})

-- Aimbot Function
local function aimAt(target)
    if target and target:FindFirstChild(targetPart) then
        local targetPosition = target[targetPart].Position
        local newCFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
        
        -- Smoothly move towards the target
        Camera.CFrame = Camera.CFrame:Lerp(newCFrame, 0.2)
    end
end

RunService.RenderStepped:Connect(function()
    if aimbotEnabled and rightClickHeld then
        local closestTarget = nil
        local shortestDistance = math.huge
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (player.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if distance < shortestDistance and distance <= fovRadius then
                    closestTarget = player.Character
                    shortestDistance = distance
                end
            end
        end
        if closestTarget then
            aimAt(closestTarget)
        end
    end
end)

-- Detect Right Click Pressed
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and aimbotEnabled then
        rightClickHeld = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        rightClickHeld = false
    end
end)

-- Fly Function
local flying = false
local bodyVelocity

function enableFly()
    if flying then return end
    flying = true
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, flySpeed, 0)
        bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bodyVelocity.Parent = hrp
    end
end

function disableFly()
    flying = false
    if bodyVelocity then
        bodyVelocity:Destroy()
    end
end

local function createESP(player)
    if player == LocalPlayer then return end

    local highlight = Instance.new("Highlight")
    highlight.Parent = player.Character
    highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Red highlight for enemies
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- White outline
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if ESP_ENABLED then
            createESP(player)
        end
    end)
end)
