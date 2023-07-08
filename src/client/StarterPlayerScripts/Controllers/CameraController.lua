local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Janitor = require(ReplicatedStorage.Packages.Janitor)

local player = Players.LocalPlayer
local playerMouse = player:GetMouse()

local transformedValue = nil

local CameraController = Knit.CreateController({
    Name = script.Name,

    _janitor = Janitor.new(),

    camera = workspace.CurrentCamera :: Camera
})

function CameraController:enableOTS(state: boolean)
    self._janitor:Cleanup()

    if state then

        self._janitor:Add(RunService.Stepped:Connect(function()
            local character = player.Character

            local humanoid = character.Humanoid
    
            humanoid.CameraOffset = Vector3.new(2.1, 0, 0)

            local humanoidRootPart = character.HumanoidRootPart
    
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
            humanoid.AutoRotate = false
    
            local lookVector = self.camera.CFrame.LookVector
    
            local rootPos = humanoidRootPart.Position
            local distance = 900
        
            humanoidRootPart.CFrame = CFrame.new(rootPos, lookVector * Vector3.new(1, 0, 1) * distance)
            self:_motor6dMovements()
    
        end))
    else
        local character = player.Character

        local humanoid = character.Humanoid

        humanoid.CameraOffset = Vector3.new(0,0,0)
        humanoid.AutoRotate = true
    end
end


function CameraController:enableScope(state : boolean)
    self._janitor:Cleanup()
    local character = player.Character
    local humanoidRootPart = character.HumanoidRootPart
    local humanoid = character.Humanoid
    if state then
        humanoid.CameraOffset = Vector3.new(2.1, 0, 0)

        self._janitor:Add(RunService.Stepped:Connect(function()

            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

            local rootPos = humanoidRootPart.Position
            local distance = 900

            local lookVector = self.camera.CFrame.LookVector
        
            humanoidRootPart.CFrame = CFrame.new(rootPos, lookVector * Vector3.new(1, 0, 1) * distance)

            self:_motor6dMovements()
        end))

    end
end

function CameraController:_getTargetPosition()
	-- local location = UIS:GetMouseLocation()
	local location = Vector2.new(self.camera.ViewportSize.X/2, self.camera.ViewportSize.Y/2)
	local cameraRay = self.camera:ViewportPointToRay(location.X, location.Y)
	local rayFilter = RaycastParams.new()
	rayFilter.FilterDescendantsInstances = {player.Character}
	rayFilter.FilterType = Enum.RaycastFilterType.Exclude
	
	local rayMagnitude = 9999999
	local ray = workspace:Raycast(cameraRay.Origin, cameraRay.Direction  * rayMagnitude, rayFilter)
	local targetPosition
	if ray then
		targetPosition = ray.Position
	else
		targetPosition = cameraRay.Origin + (cameraRay.Direction * rayMagnitude)
	end

	return targetPosition
end

function CameraController:_motor6dMovements()
    local character = player.Character

    local head = character.Head
    local upperTorso = character.UpperTorso
    local waist = upperTorso.Waist

    if character:FindFirstChild("UpperTorso") and character:FindFirstChild("Head") then
        if self.camera.CameraSubject:IsDescendantOf(character) or self.camera.CameraSubject:IsDescendantOf(player) then

            local point = self:_getTargetPosition()

            local hypotenuse = (head.CFrame.Position - point).magnitude

            local opposite = head.CFrame.Y - point.Y


            local localizedCFrame = (CFrame.new(waist.C0.Position) * CFrame.Angles((math.asin(opposite / hypotenuse)),0,0)):ToObjectSpace(waist.Transform)
            transformedValue = localizedCFrame
            waist.Transform =  CFrame.new(waist.C0.Position) * transformedValue
            -- if tick() - tickUpdate >= 0.1 then
            -- 	tickUpdate = tick()
            -- 	-- game.ReplicatedStorage.Remotes.Server.ReplicateTransform:FireServer()
            -- end
            local YMovement = UserInputService:GetMouseDelta().Y
            if YMovement ~= 0 then
                -- task.wait(0.05)
                -- game.ReplicatedStorage.Remotes.Server.ReplicateTransform:FireServer(math.asin(opposite/hypotenuse))
            end
        end
    end	
end

function CameraController:KnitStart()

end

function CameraController:KnitInit()

end

return CameraController