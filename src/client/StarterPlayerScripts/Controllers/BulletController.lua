local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local BulletController = Knit.CreateController({
    Name = script.Name
})

function BulletController:KnitStart()

end

function BulletController:KnitInit()
end

return BulletController