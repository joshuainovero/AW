local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local Knit = require(ReplicatedStorage.Packages.Knit)

local gunPresets = require(ReplicatedStorage.Data.GunPresets)

local BulletController
local GunController = Knit.CreateController({
    Name = script.Name,

    gunAnimations = {
        idle = {},
        recoil = {},
        reload = {}
    },

    gunSettings = {},

    currentTool = nil,

    currentIdleTrack = nil, 
    currentRecoilTrack = nil,
    currentReloadTrack = nil
    
})

function GunController:_setGunPresets(settings)
    self.gunSettings.FireRate = settings.FireRate
    self.gunSettings.Range = settings.Range
    self.gunSettings.Velocity = settings.Velocity
    self.gunSettings.RecoilForce = settings.RecoilForce
    self.gunSettings.RecoilRecoverSpeed = settings.RecoilRecoverSpeed
    self.gunSettings.AmmoType = settings.AmmoType
    self.gunSettings.Auto = settings.Auto
    self.gunSettings.RecoilAnimSpeed = settings.RecoilAnimSpeed
    self.gunSettings.MagazineCapacity = settings.MagazineCapacity

    print(self.gunSettings)
end

function GunController:_getTargetPosition()
    local camera = workspace.CurrentCamera
    local location = UserInputService:GetMouseLocation()
    local cameraRay = camera:ViewportPointToRay(location.X, location.Y)
    local rayFilter = RaycastParams.new()
    rayFilter.FilterDescendantsInstances = {localPlayer.Character}
    rayFilter.FilterType = Enum.RaycastFilterType.Exclude

    local rayMagnitude = 1000000
    local ray = workspace:Raycast(cameraRay.Origin, cameraRay.Direction * rayMagnitude, rayFilter)
    local targetPosition

    if ray then
        targetPosition = ray.Position
    else
        targetPosition = cameraRay.Origin + (cameraRay.Direction * rayMagnitude)
    end

    return targetPosition
end

function GunController:_fire(character)

    local targetPosition = self:_getTargetPosition()
    local startPos = self.currentTool.Parts.main.Muzzle.WorldPosition

    local direction = (CFrame.new(startPos, targetPosition).LookVector) * self.gunSettings.Velocity

    BulletController:renderBullet(character, startPos, direction, self.gunSettings)
end

function GunController:loadAnimations()
    print("Loaded")
    local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")

    for name, data in require(ReplicatedStorage.Data.GunAssets) do
        self.gunAnimations.idle[name] = {}
        self.gunAnimations.idle[name].AnimationObject = Instance.new("Animation")
        self.gunAnimations.idle[name].AnimationObject.AnimationId = data.IdleAnimation
        self.gunAnimations.idle[name].AnimationTrack = humanoid:LoadAnimation(self.gunAnimations.idle[name].AnimationObject)
    
        self.gunAnimations.recoil[name] = {}
        self.gunAnimations.recoil[name].AnimationObject = Instance.new("Animation")
        self.gunAnimations.recoil[name].AnimationObject.AnimationId = data.RecoilAnimation
        self.gunAnimations.recoil[name].AnimationTrack = humanoid:LoadAnimation(self.gunAnimations.recoil[name].AnimationObject)
    
        self.gunAnimations.reload[name] = {}
        self.gunAnimations.reload[name].AnimationObject = Instance.new("Animation")
        self.gunAnimations.reload[name].AnimationObject.AnimationId = data.ReloadAnimation
        self.gunAnimations.reload[name].AnimationTrack = humanoid:LoadAnimation(self.gunAnimations.reload[name].AnimationObject)
    end

    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            print(child)
            self:_setGunPresets(gunPresets[child.Name])
            self.currentIdleTrack = self.gunAnimations.idle[child.Name].AnimationTrack
            self.currentRecoilTrack = self.gunAnimations.recoil[child.Name].AnimationTrack
            self.currentReloadTrack = self.gunAnimations.reload[child.Name].AnimationTrack
            self.currentTool = child
            self.currentIdleTrack:Play()
        end
    end)

    character.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") then
            if self.currentIdleTrack then
                self.currentIdleTrack:Stop()
                self.currentRecoilTrack:Stop()
                self.currentReloadTrack:Stop()
                self.currentTool = nil
            end
        end
    end)

end

function GunController:KnitStart()
    UserInputService.InputBegan:Connect(function(input, gp)
        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:_fire(character)
        end
    end)

end

function GunController:KnitInit()
    BulletController = Knit.GetController("BulletController")
end

return GunController