local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local GunController = Knit.CreateController({
    Name = script.Name
})

function GunController:KnitStart()
    

end

function GunController:KnitInit()

end

return GunController