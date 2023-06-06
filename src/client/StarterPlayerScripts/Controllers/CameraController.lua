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

    _OTSJanitor = Janitor.new(),

    camera = workspace.CurrentCamera
})

function CameraController:enableOTS()
    
end

function CameraController:_getTargetPosition()
	-- local location = UIS:GetMouseLocation()
	local location = Vector2.new(self.camera.ViewportSize.X/2, self.camera.ViewportSize.Y/2)
	local cameraRay = self.camera:ViewportPointToRay(location.X, location.Y)
	local rayFilter = RaycastParams.new()
	rayFilter.FilterDescendantsInstances = {player.Character}
	rayFilter.FilterType = Enum.RaycastFilterType.Exclude
	
	local rayMagnitude = 10
	local ray = workspace:Raycast(cameraRay.Origin, cameraRay.Direction  * rayMagnitude, rayFilter)
	local targetPosition
	if ray then
		targetPosition = ray.Position
	else
		targetPosition = cameraRay.Origin + (cameraRay.Direction * rayMagnitude)
	end

	return targetPosition
end

function CameraController:KnitStart()
    self._OTSJanitor:Add(RunService.Stepped:Connect(function()
        local character = player.Character or player.CharacterAdded:Wait()
        if not character:FindFirstChild("HumanoidRootPart") and not character:FindFirstChild("Head") and not character:FindFirstChild("Neck") and not character:FindFirstChild("Waist") and not character:FindFirstChild("Humanoid") then
            
            print("Returning")
            return
        end
        
        local humanoid = character.Humanoid
        local humanoidRootPart = character.HumanoidRootPart
        local head = character.Head
        local upperTorso = character.UpperTorso
        local waist = upperTorso:FindFirstChild("Waist")

        if not waist then
            return
        end

        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        humanoid.AutoRotate = false
        humanoid.CameraOffset = Vector3.new(2.1,0,0)

        local lookVector = self.camera.CFrame.LookVector

        local rootPos = humanoidRootPart.Position
        local distance = 900
    
        humanoidRootPart.CFrame = CFrame.new(rootPos, lookVector * Vector3.new(1, 0, 1) * distance)
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

    end))


end

function CameraController:KnitInit()

end

return CameraController