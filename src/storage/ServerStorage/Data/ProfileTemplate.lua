local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Guns = require(ReplicatedStorage.Enums.Guns)

return {
    Ammo = {
        [Guns.AK47] = 0,
        [Guns.Glock17] = 0,
        [Guns.M16A4] = 0
    },

    Moderation = {
        Banned = false
    }
}