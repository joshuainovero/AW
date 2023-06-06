local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

Knit.OnStart():andThen(function()
    local GunController = Knit.GetController("GunController")
    GunController:loadAnimations()
end):catch(warn)
