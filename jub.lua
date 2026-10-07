local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "ESP Script",
   LoadingTitle = "ESP Rayfield",
   LoadingSubtitle = "Fixed Boxes",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false
})

local Tab = Window:CreateTab("ESP Settings", 4483362458)

local ESP = {
    Boxes = false,
    Tracers = false,
    Names = false,
    BoxColor = Color3.fromRGB(0, 255, 136),
    TracerColor = Color3.fromRGB(255, 255, 255),
    NameColor = Color3.fromRGB(255, 255, 255)
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local function createESP(player)
    if player == LocalPlayer then return end

    local box = Drawing.new("Square")
    box.Visible = false
    box.Thickness = 1.5
    box.Filled = false

    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Thickness = 1

    local name = Drawing.new("Text")
    name.Visible = false
    name.Size = 14
    name.Center = true
    name.Outline = true

    local connection
    connection = RunService.RenderStepped:Connect(function()
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChildOfClass("Humanoid") and character.Humanoid.Health > 0 then
            
            -- Точный расчет границ персонажа по CFrame и Size
            local cframe, size = character:GetBoundingBox()
            local hrpPos, onScreen = Camera:WorldToViewportPoint(cframe.Position)

            if onScreen then
                -- Верхняя и нижняя точки персонажа
                local topPos = Camera:WorldToViewportPoint((cframe * CFrame.new(0, size.Y / 2, 0)).Position)
                local bottomPos = Camera:WorldToViewportPoint((cframe * CFrame.new(0, -size.Y / 2, 0)).Position)

                local height = math.abs(topPos.Y - bottomPos.Y)
                local width = height * 0.65 -- Пропорциональная ширина под модель персонажа

                -- 1. Box ESP
                if ESP.Boxes then
                    box.Size = Vector2.new(width, height)
                    box.Position = Vector2.new(hrpPos.X - width / 2, topPos.Y)
                    box.Color = ESP.BoxColor
                    box.Visible = true
                else
                    box.Visible = false
                end

                -- 2. Tracer ESP
                if ESP.Tracers then
                    tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    tracer.To = Vector2.new(hrpPos.X, bottomPos.Y)
                    tracer.Color = ESP.TracerColor
                    tracer.Visible = true
                else
                    tracer.Visible = false
                end

                -- 3. Name ESP
                if ESP.Names then
                    name.Position = Vector2.new(hrpPos.X, topPos.Y - 16)
                    name.Text = player.DisplayName or player.Name
                    name.Color = ESP.NameColor
                    name.Visible = true
                else
                    name.Visible = false
                end
            else
                box.Visible = false
                tracer.Visible = false
                name.Visible = false
            end
        else
            box.Visible = false
            tracer.Visible = false
            name.Visible = false

            if not Players:FindFirstChild(player.Name) then
                box:Remove()
                tracer:Remove()
                name:Remove()
                connection:Disconnect()
            end
        end
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    createESP(player)
end
Players.PlayerAdded:Connect(createESP)

-- Элементы управления Rayfield
Tab:CreateToggle({
   Name = "Enable Boxes (Обводка)",
   CurrentValue = false,
   Callback = function(Value) ESP.Boxes = Value end,
})

Tab:CreateToggle({
   Name = "Enable Tracers (Линии)",
   CurrentValue = false,
   Callback = function(Value) ESP.Tracers = Value end,
})

Tab:CreateToggle({
   Name = "Enable Names (Ники)",
   CurrentValue = false,
   Callback = function(Value) ESP.Names = Value end,
})

Tab:CreateColorPicker({
    Name = "Box Color",
    Color = ESP.BoxColor,
    Callback = function(Value) ESP.BoxColor = Value end
})

Tab:CreateColorPicker({
    Name = "Tracer Color",
    Color = ESP.TracerColor,
    Callback = function(Value) ESP.TracerColor = Value end
})
