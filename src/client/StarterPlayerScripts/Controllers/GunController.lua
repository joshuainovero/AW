local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Janitor = require(ReplicatedStorage.Packages.Janitor)

local gunPresets = require(ReplicatedStorage.Data.GunPresets)

local BulletService
local InventoryService
local DataService
local BulletController
local CameraController
local CrosshairInterface
local ScopeInterface
local AmmoHUDInterface
local GunController = Knit.CreateController({
    Name = script.Name,

    gunAnimations = {
        idle = {},
        recoil = {},
        reload = {}
    },
    
    _janitor = Janitor.new(),

    ammo = 0,

    gunSettings = {} :: table,

    currentTool = nil :: Tool,

    currentIdleTrack = nil :: AnimationTrack,
    currentRecoilTrack = nil :: AnimationTrack,
    currentReloadTrack = nil :: AnimationTrack,

    recoilRecoverConnection = nil :: RBXScriptConnection,
    zoomInConnection = nil :: RBXScriptConnection,
    zoomOutConnection = nil :: RBXScriptConnection,

    _fireTick = tick() :: number,

    _onTrigger = false :: boolean,

    fired = Signal.new(),

    zoomedIn = Signal.new(),

    ammoUpdated = Signal.new()
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
    self.gunSettings.CrosshairEnabled = settings.CrosshairEnabled
    self.gunSettings.ScopeUI = settings.ScopeUI
end

function GunController:_getTargetPosition()
    local location = UserInputService:GetMouseLocation()
    local cameraRay = CameraController.camera:ViewportPointToRay(location.X, location.Y)
    local rayFilter = RaycastParams.new()
    rayFilter.FilterDescendantsInstances = {localPlayer.Character}
    rayFilter.FilterType = Enum.RaycastFilterType.Exclude

    local rayMagnitude = 9999999
    local ray = workspace:Raycast(cameraRay.Origin, cameraRay.Direction * rayMagnitude, rayFilter)
    local targetPosition

    if ray then
        targetPosition = ray.Position
    else
        targetPosition = cameraRay.Origin + (cameraRay.Direction * rayMagnitude)
    end

    return targetPosition
end

function GunController:_recoil()
    local camera = CameraController.camera

    CameraController.camera.CFrame = camera.CFrame * CFrame.Angles(math.rad(self.gunSettings.RecoilForce),0,0)

    local recoverAngle = 0

    if self.recoilRecoverConnection then
        self.recoilRecoverConnection:Disconnect()
    end

    self.recoilRecoverConnection = RunService.RenderStepped:Connect(function(dt)
        recoverAngle += (dt * self.gunSettings.RecoilRecoverSpeed)
        if recoverAngle <= self.gunSettings.RecoilForce then
            camera.CFrame = camera.CFrame * CFrame.Angles(math.rad(-(dt * self.gunSettings.RecoilRecoverSpeed)),0,0)
        else
            self.recoilRecoverConnection:Disconnect()
            self.recoilRecoverConnection = nil
        end
    end)
end

function GunController:_fire(character)
    if self.currentReloadTrack.IsPlaying then
        print("Reloading")
        return
    end

    local ammo = self.currentTool:GetAttribute("Ammo")

    if not ammo or ammo < 1 then
        print("No ammo")
        return
    end

    if tick() - self._fireTick < self.gunSettings.FireRate then
        return
    end
    
    self._fireTick = tick()

    local targetPosition = self:_getTargetPosition()
    local startPos = self.currentTool.Parts.main.Muzzle.WorldPosition

    local direction = (CFrame.new(startPos, targetPosition).LookVector) * self.gunSettings.Velocity

    self.currentRecoilTrack:Play()
    self.currentRecoilTrack:AdjustSpeed(self.gunSettings.RecoilAnimSpeed)

    self.fired:Fire()
    task.spawn(function()
        self:_recoil()
    end)

    task.spawn(function()
        BulletController:renderBullet(character, startPos, direction, self.gunSettings)
    end)
    BulletService.fireBullet:Fire(character, startPos, targetPosition)
end

function GunController:_reload()
    if self.currentReloadTrack.IsPlaying then
        print("Already reloading")
        return
    end

    local success, state = DataService:validateAmmoAvailabilityRequested(self.currentTool):await()

    state = success and state

    if not state then
        print("No ammo available. can't reload")
        return
    end

    self.currentReloadTrack:Play()

end

function GunController:loadAnimations()
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
            local success, inventory = InventoryService:getInventoryRequested():await()
            inventory = success and inventory
            if not inventory then
                print("Failed to get inventory")
                return
            end

            UserInputService.MouseIconEnabled = false
            localPlayer.CameraMinZoomDistance = 5.5
            localPlayer.CameraMaxZoomDistance = 5.5
            self:_setGunPresets(gunPresets[child.Name])
            self.currentIdleTrack = self.gunAnimations.idle[child.Name].AnimationTrack
            self.currentRecoilTrack = self.gunAnimations.recoil[child.Name].AnimationTrack
            self.currentReloadTrack = self.gunAnimations.reload[child.Name].AnimationTrack
            self.currentTool = child

            self._janitor:Add(self.currentReloadTrack.Stopped:Connect(function()
                local reloadRequestState, updatedAmmoAvailability = DataService:updateAmmoRequested(self.currentTool):await()

                updatedAmmoAvailability = reloadRequestState and updatedAmmoAvailability

                if updatedAmmoAvailability then
                    self.ammoUpdated:Fire(child:GetAttribute("Ammo") or 0, updatedAmmoAvailability)
                end
                
            end))
            
            self.currentIdleTrack:Play()

            AmmoHUDInterface:openInterface()

            if self.gunSettings.CrosshairEnabled then
                CrosshairInterface:openInterface()
            end

            if self.gunSettings.ScopeUI then
                CameraController:enableOTS(false)
                CameraController:enableScope(true)
            else
                CameraController:enableOTS(true)
            end

            local availableAmmo = inventory.Ammo[child.Name]

            self.ammoUpdated:Fire(child:GetAttribute("Ammo") or 0, availableAmmo)

        end
    end)

    character.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") then
            self._janitor:Cleanup()
            UserInputService.MouseIconEnabled = true
            self.currentIdleTrack:Stop()
            self.currentRecoilTrack:Stop()
            self.currentReloadTrack:Stop()
            self.currentTool = nil
            CameraController:enableOTS(false)
            CameraController:enableScope(false)
            CrosshairInterface:closeInterface()
            ScopeInterface:closeInterface()
            AmmoHUDInterface:closeInterface()
            localPlayer.CameraMaxZoomDistance = 8.5
            localPlayer.CameraMinZoomDistance = 8.5
            CameraController.camera.CameraSubject = character.Humanoid
            CameraController.camera.FieldOfView = 70
        end
    end)

end

function GunController:KnitStart()
    UserInputService.InputBegan:Connect(function(input, gp)
        if not self.currentTool then
            return
        end

        if gp then
            return
        end

        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self._onTrigger = true
            if self.gunSettings.Auto then
                RunService:BindToRenderStep("AutoGun", 2, function()
                    self:_fire(character)
                end)
            else
                self:_fire(character)
            end

        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            if not self.currentTool then
                return
            end

            if not self.zoomInConnection then
                if self.zoomOutConnection then
                    self.zoomOutConnection:Disconnect()
                    self.zoomOutConnection = nil
                end

                self.zoomedIn:Fire(true)

                if self.gunSettings.ScopeUI then
                    ScopeInterface:openInterface()
                    localPlayer.CameraMinZoomDistance = 0.5
                    localPlayer.CameraMaxZoomDistance = 0.5
                    CameraController.camera.CameraSubject = self.currentTool.Parts.AimPart
                    CameraController.camera.FieldOfView = 50
                    for _, basePart: BasePart in self.currentTool:GetDescendants() do
                        if basePart:IsA("BasePart") and (basePart.Name ~= 'Handle' and basePart.Name ~= 'AimPart') then
                            basePart.Transparency = 1
                        end
                    end
                else
                    self.zoomInConnection = RunService.RenderStepped:Connect(function(dt)
                        if localPlayer.CameraMinZoomDistance >= 2.2 then
                            localPlayer.CameraMinZoomDistance -= dt * 25
                            localPlayer.CameraMaxZoomDistance -= dt * 25
                        else
                            self.zoomInConnection:Disconnect()
                            self.zoomInConnection = nil
                        end
                    end)
                end

            end

        elseif input.KeyCode == Enum.KeyCode.R then
            self:_reload()
        end
        
    end)

    UserInputService.InputEnded:Connect(function(input, gp)
        local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if self._onTrigger then
                self._onTrigger = false
                RunService:UnbindFromRenderStep("AutoGun")
            end

        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            if not self.currentTool then
                return
            end

            if not self.zoomOutConnection then
                if self.zoomInConnection then
                    self.zoomInConnection:Disconnect()
                    self.zoomInConnection = nil
                end

                self.zoomedIn:Fire(false)

                if self.gunSettings.ScopeUI then
                    ScopeInterface:closeInterface()
                    character.Humanoid.CameraOffset = Vector3.new(2.1, 0, 0)
                    localPlayer.CameraMaxZoomDistance = 5.5
                    localPlayer.CameraMinZoomDistance = 5.5
                    CameraController.camera.CameraSubject = character.Humanoid
                    CameraController.camera.FieldOfView = 70
                    for _, basePart: BasePart in self.currentTool:GetDescendants() do
                        if basePart:IsA("BasePart") and (basePart.Name ~= 'Handle' and basePart.Name ~= 'AimPart') then
                            basePart.Transparency = 0
                        end
                    end
                else
                    self.zoomOutConnection = RunService.RenderStepped:Connect(function(dt)
                        if localPlayer.CameraMinZoomDistance < 5.5 then
                            localPlayer.CameraMinZoomDistance += dt * 25
                            localPlayer.CameraMaxZoomDistance += dt * 25
                        else
                            localPlayer.CameraMinZoomDistance = 5.5
                            localPlayer.CameraMaxZoomDistance = 5.5
                            self.zoomOutConnection:Disconnect()
                            self.zoomOutConnection = nil
                        end
                    end)
                end

            end
        end
    end)
end

function GunController:KnitInit()
    BulletService = Knit.GetService("BulletService")
    InventoryService = Knit.GetService("InventoryService")
    DataService = Knit.GetService("DataService")
    BulletController = Knit.GetController("BulletController")
    CameraController = Knit.GetController("CameraController")
    CrosshairInterface = Knit.GetController("CrosshairInterface")
    ScopeInterface = Knit.GetController("ScopeInterface")
    AmmoHUDInterface = Knit.GetController("AmmoHUD")
end

return GunController