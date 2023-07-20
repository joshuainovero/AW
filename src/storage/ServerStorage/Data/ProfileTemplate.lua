local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Guns = require(ReplicatedStorage.Enums.Guns)

return {

    Inventory = {
        Ammo = {
            [Guns.AK47] = 80,
            [Guns.Glock17] = 40,
            [Guns.M16A4] = 60,
            [Guns.M40A5] = 30
        }
    },

    Moderation = {
        Banned = false
    }
}