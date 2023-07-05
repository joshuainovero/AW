local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Guns = require(ReplicatedStorage.Enums.Guns)
 
 return {
    [Guns.AK47] = {
        FireRate = 0.12,
        Range = 3000,
        Velocity = 1650,
        BaseDamage = 10,
        MagazineCapacity = 30,
        RecoilForce = 2,
        RecoilRecoverSpeed = 10,
        RecoilAnimSpeed = 1.3,
        Auto = true,
        AmmoType = "39mm",
        CrosshairEnabled = true
    },

    [Guns.M16A4] = {
        FireRate = 0.1,
        Range = 3000,
        Velocity = 1650,
        BaseDamage = 10,
        MagazineCapacity = 30,
        RecoilForce = 2,
        RecoilRecoverSpeed = 10,
        RecoilAnimSpeed = 1.3,
        Auto = true,
        AmmoType = "5.56x45mm",
        CrosshairEnabled = true
    },

    [Guns.Glock17] = {
        FireRate = 0.15,
        Range = 3000,
        Velocity = 1650,
        BaseDamage = 10,
        MagazineCapacity = 20,
        RecoilForce = 2,
        RecoilRecoverSpeed = 10,
        RecoilAnimSpeed = 1.5,
        Auto = false,
        AmmoType = "9mm",
        CrosshairEnabled = true
    },

    [Guns.M40A5] = {
        FireRate = 0.1,
        Range = 3000,
        Velocity = 1650,
        BaseDamage = 10,
        MagazineCapacity = 30,
        RecoilForce = 2,
        RecoilRecoverSpeed = 10,
        RecoilAnimSpeed = 1.3,
        Auto = true,
        AmmoType = "5.56x45mm",
        CrosshairEnabled = false
    }
}
