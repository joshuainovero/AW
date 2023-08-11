local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)

local vehicles = ReplicatedStorage.Assets.Vehicles

local VehicleService = Knit.CreateService({
    Name = script.Name,
    Client = {
        initiateDriver = Knit.CreateSignal()
    }
})

local function setBasePartsNetworkOwner(parent: Instance, networkOwner)
    print("Setting network owner to: ", networkOwner)
    for _, instance: BasePart in parent:GetDescendants() do
        if not instance:IsA("BasePart") then
            continue
        end

        instance:SetNetworkOwner(networkOwner)
    end
end

function VehicleService:spawnVehicle(vehicleName: string, position: Vector3)
    local vehicle = vehicles:FindFirstChild(vehicleName)

    if not vehicle then
        return
    end

    local vehicleClone: Model = vehicle:Clone()

    vehicleClone:PivotTo(CFrame.new(position))

    vehicleClone.Parent = workspace

    local seat: VehicleSeat = vehicleClone.VehicleSeat

    seat.Changed:Connect(function(property)
        if property == "Occupant" then
            if seat.Occupant and seat.Occupant:IsA("Humanoid") then
                local player =  Players:GetPlayerFromCharacter(seat.Occupant.Parent)
                setBasePartsNetworkOwner(vehicleClone, player)
                self.Client.initiateDriver:Fire(player, vehicleClone)
            else
                setBasePartsNetworkOwner(vehicleClone, nil)
            end
        end
    end)
end

function VehicleService:destroyVehicle(vehicle: Model)
    if vehicle then
        vehicle:Destroy()
    end
end

function VehicleService:KnitStart()
    self:spawnVehicle("Chassis", Vector3.new(30, 2, 30))
end

function VehicleService:KnitInit()

end

return VehicleService