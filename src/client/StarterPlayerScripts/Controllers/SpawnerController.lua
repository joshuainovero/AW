local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local spawners = workspace:WaitForChild("Spawners")

local AMPLITUDE = 0.0125
local FREQUENCY = 1
local ROTATION_SPEED = 60

local HandToolService
local SpawnerController = Knit.CreateController({
    Name = script.Name,

    gunSpawners = {}
})


function SpawnerController:KnitStart()
    for _, spawner: BasePart in spawners:GetChildren() do
        spawner.Transparency = 1
        local proximityPrompt = Instance.new("ProximityPrompt")
        proximityPrompt.RequiresLineOfSight = false
        proximityPrompt.MaxActivationDistance = 5
        proximityPrompt.ActionText = "Grab"
        proximityPrompt.ObjectText = spawner.Name
        proximityPrompt.Parent = spawner

        proximityPrompt.TriggerEnded:Connect(function()
            HandToolService:giveToolRequested(spawner.Name)
        end)

        local gun: Tool = ReplicatedStorage.Assets.Guns:FindFirstChild(spawner.Name)
        if gun then
            local gunClone: Tool = gun:Clone()
            print("Cloning")
            for _, v in gunClone:GetDescendants() do
                if v:IsA("BasePart") then
                   v.Anchored = true
                end
            end
            gunClone:PivotTo(CFrame.new(spawner.Position))
            gunClone.Parent = workspace
            self.gunSpawners[spawner] = gunClone
        end
    end

    local at = 0

    RunService.RenderStepped:Connect(function(dt)
        at += dt
        for spawner: BasePart, gunTool: Tool in self.gunSpawners do
            local verticalOffset = math.sin(at + FREQUENCY) * AMPLITUDE
            local rotAngle = at * ROTATION_SPEED

            local newPos = gunTool:GetPivot().Position + Vector3.new(0,verticalOffset, 0)

            gunTool:PivotTo(CFrame.new(newPos) * CFrame.Angles(0, math.rad(rotAngle), 0))
            spawner:PivotTo(gunTool:GetPivot())
        end
    end)
end

function SpawnerController:KnitInit()
    HandToolService = Knit.GetService("HandToolService")
end

return SpawnerController