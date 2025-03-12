local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create UI window with Rayfield
local Window = Rayfield:CreateWindow({
    Name = "Aimbot Training Tool",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "Initializing...",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "AimbotTraining",
        FileName = "settings"
    }
})

-- Create a section for settings
local MainTab = Window:CreateTab("Main", 4483362458) -- Change the ID to your tab ID

-- Aimbot settings
local aimbotEnabled = false
local targetPart = "Head"  -- We will target the head of other players
local fovRadius = 100  -- Initial FOV radius (adjustable via UI)
local fovCircle = nil

-- Function to perform wall/visibility check
local function isVisible(target)
    local ray = workspace.CurrentCamera:WorldToScreenPoint(target.HumanoidRootPart.Position)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {game.Players.LocalPlayer.Character}
    
    local result = workspace:Raycast(workspace.CurrentCamera.CFrame.Position, target.HumanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position, raycastParams)
    return result == nil
end

-- Function to perform health check
local function isTargetAlive(target)
    return target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0
end

-- Function to aim at the target
local function aimAt(target)
    if target and target:FindFirstChild("Humanoid") then
        -- Only aim if the target is alive and visible
        if isVisible(target) and isTargetAlive(target) then
            local head = target:FindFirstChild("Head")
            if head then
                local camera = workspace.CurrentCamera
                local targetPos = head.Position
                local cameraPos = camera.CFrame.Position
                local direction = (targetPos - cameraPos).unit
                
                -- Smooth the aiming
                local cameraLookAt = CFrame.new(cameraPos, cameraPos + direction)
                camera.CFrame = cameraLookAt
            end
        end
    end
end

-- Function to check if the target is within the FOV circle
local function isInFOV(target)
    local mousePosition = game:GetService("Players").LocalPlayer:GetMouse().Position
    local screenPos = workspace.CurrentCamera:WorldToScreenPoint(target.HumanoidRootPart.Position)
    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePosition).Magnitude
    return distance <= fovRadius
end

-- Function to create and update the FOV circle
local function updateFOVCircle()
    if fovCircle then
        fovCircle:Remove()  -- Remove old circle to avoid duplicates
    end
    
    local screenCenter = game:GetService("Players").LocalPlayer:GetMouse().Position
    fovCircle = Instance.new("Frame")
    fovCircle.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
    fovCircle.Position = UDim2.new(0, screenCenter.X - fovRadius, 0, screenCenter.Y - fovRadius)
    fovCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    fovCircle.BackgroundTransparency = 0.5
    fovCircle.BorderSizePixel = 0
    fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    fovCircle.Parent = game:GetService("Players").LocalPlayer.PlayerGui
end

-- Function to toggle aimbot on/off
local aimbotToggle = MainTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = aimbotEnabled,
    Flag = "aimbotEnabled",
    Callback = function(value)
        aimbotEnabled = value
    end
})

-- FOV slider
local fovSlider = MainTab:CreateSlider({
    Name = "FOV Radius",
    Min = 50,
    Max = 200,
    Default = fovRadius,
    Increment = 10,
    Callback = function(value)
        fovRadius = value
        updateFOVCircle()
    end
})

-- Update loop to constantly check and aim at the target
game:GetService("RunService").RenderStepped:Connect(function()
    updateFOVCircle()  -- Update the FOV circle display

    if aimbotEnabled then
        -- Get the closest player to the local player
        local closestPlayer = nil
        local shortestDistance = math.huge
        
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                if isInFOV(player.Character) then
                    local distance = (player.Character.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if distance < shortestDistance then
                        closestPlayer = player
                        shortestDistance = distance
                    end
                end
            end
        end

        if closestPlayer then
            aimAt(closestPlayer.Character)
        end
    end
end)
