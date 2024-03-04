local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerService = game:GetService("PlayerService")

local Knit = require(ReplicatedStorage.Packages.Knit)

local LocalPlayer = PlayerService.LocalPlayer

local Animations = require(ReplicatedStorage.Enums.Aniamtions)
local AniamtionsData = require(ReplicatedStorage.Packages.Animationns)

local AnimationService
local AnimationController = Knit.CreateController({
    Name = script.Name,

    CachedAnimations = {}
})

function AnimationController:PlayAnimation(Animation: Animations.Animations)
    local Humanoid: Humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")

    if not Humanoid then
        return
    end

    local AnimationId = AniamtionsData[Animation]
    if not AniamtionId then
        warn("Animation data not found!")
    end

    local Animator: Animator = Humanoid:FindFirstChild("Animator")
    if not Animator then
        Instance.new("Animator").Parent = Humanoid
    end

    local CachedAnimation = self.CachedAnimations[Animation]
    if CachedAnimation then
        CachedAnimation:Play()
    else    
        local AnimationObject: Animation = Instance.new("Animation")
        AnimationObject.AnimationId = AnimationId
        self.CachedAnimation[Animation] = AnimationObject
        Animator:LoadAnimation(AnimationObject)

        self.CachedAnimation[Animation]:Play()
    end

end

function AnimationController:KnitStart()
    PlayerService.PlayerAdded:Connect(function(Player: Player)
        if Player ~= LocalPlayer then
            return
        end
    

        Player.CharacterAdded:Connect(function(Character: Model)
            for _, CachedAnimation in self.CachedAnimations do
                CachedAnimation:Destroy()
            end

            self.CachedAnimations = {}
        end)
    end)

    AnimationService.PlayAnimation:Connect(function(Animation: Animations.Animations)
        self:PlayAnimation(Animation)
    end)
end

function AnimationController:KnitInit()
    AnimationService = Knit.GetService("AnimationService")
end


return AnimationController