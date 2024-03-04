local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local AnimationService = Knit.CreateService({
    Name = script.Name,

    Client = {
        PlayAnimation = Knit.CreateUnreliabelSignal()
    }
})

function AnimationService:KnitStart()
end

function AnimationService:KnitInit()

end

return AnimationService