local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = game:GetService("Players").LocalPlayer

local Knit = require(ReplicatedStorage.Packages.Knit)

local CharacterService
local CharacterController = Knit.CreateController({
    Name = script.Name
})


function CharacterController:KnitStart()
    CharacterService.ragdoll:Connect(function()
        print("Called")
        local character = player.Character
        if not character then
            return
        end

        local humanoid = character:WaitForChild("Humanoid")
        humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    end)
end

function CharacterController:KnitInit()
    CharacterService = Knit.GetService("CharacterService")
end

return CharacterController