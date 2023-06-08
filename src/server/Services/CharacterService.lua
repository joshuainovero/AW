local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local CharacterService = Knit.CreateService({
    Name = script.Name
})

function CharacterService:_rigInit(character: Model)
    local player: Player = Players:GetPlayerFromCharacter(character)
    local newHumanoidDesc = Instance.new("HumanoidDescription")

    local playerHumanoidDesc = Players:GetHumanoidDescriptionFromUserId(player.UserId)
    newHumanoidDesc.HeadColor = playerHumanoidDesc.HeadColor
    newHumanoidDesc.LeftArmColor = playerHumanoidDesc.LeftArmColor
    newHumanoidDesc.LeftLegColor = playerHumanoidDesc.LeftLegColor
    newHumanoidDesc.RightArmColor = playerHumanoidDesc.RightArmColor
    newHumanoidDesc.RightLegColor = playerHumanoidDesc.RightLegColor
    newHumanoidDesc.TorsoColor = playerHumanoidDesc.TorsoColor

    -- Body clothes
    newHumanoidDesc.GraphicTShirt = playerHumanoidDesc.GraphicTShirt
    newHumanoidDesc.Shirt = playerHumanoidDesc.Shirt
    newHumanoidDesc.Pants = playerHumanoidDesc.Pants

    newHumanoidDesc.BodyTypeScale = 0.3

    local humanoid = character:WaitForChild("Humanoid")

    newHumanoidDesc.Face = 86487700
    newHumanoidDesc.Head = 86498048
    newHumanoidDesc.LeftArm = 86500054
    newHumanoidDesc.LeftLeg = 86500064
    newHumanoidDesc.RightArm = 86500036
    newHumanoidDesc.RightLeg = 86500078
    newHumanoidDesc.Torso = 86500008

    humanoid:ApplyDescription(newHumanoidDesc)
end

function CharacterService:KnitStart()

end

function CharacterService:KnitInit()
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function(character)
            player.CameraMaxZoomDistance = 5.5
            player.CameraMinZoomDistance = 5.5
            self:_rigInit(character)
        end)
    end)
end

return CharacterService