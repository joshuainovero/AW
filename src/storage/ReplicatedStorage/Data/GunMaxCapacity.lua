local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Guns = require(ReplicatedStorage.Enums.Guns)

return {
    [Guns.AK47] = 30,
    [Guns.Glock17] = 15,
    [Guns.M16A4] = 20,
    [Guns.M40A5] = 5
}