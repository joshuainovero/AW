local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local BulletService = Knit.CreateService({
    Name = script.Name
})

function BulletService:KnitStart()
    
end

function BulletService:KnitInit()

end

return BulletService