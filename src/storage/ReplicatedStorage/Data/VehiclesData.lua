local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Vehicles = require(ReplicatedStorage.Enums.Vehicles)

return {
    [Vehicles.Chassis] = {
        Gear1 = {
            MaxSpeed = 60,
            MaxTorque = 20000
        },

        Gear2 = {
            MaxSpeed = 120,
            MaxTorque = 16000
        },

        Gear3 = {
            MaxSpeed = 180,
            MaxTorque = 12000
        },

        Gear4 = {
            MaxSpeed = 240,
            MaxTorque = 8000
        },

        Gear5 = {
            MaxSpeed = 300,
            MaxTorque = 6000
        },

        Gear6 = {
            MaxSpeed = 340,
            MaxTorque = 4000
        }
    }
}