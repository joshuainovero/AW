local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Janitor = require(ReplicatedStorage.Packages.Janitor)

local vehicleSettings = require(ReplicatedStorage.Data.VehiclesData)

local vehicles = ReplicatedStorage.Assets.Vehicles

local VehicleService
local VehicleController = Knit.CreateController({
    Name = script.Name,

    currentVehicle = nil :: Model,
    currentGear = 1,
    maxAngularSpeed = 0,
    _janitor = Janitor.new()
})

function VehicleController:shiftGear(gear: number)
    if not self.currentVehicle then
        return
    end

    local seat: VehicleSeat = self.currentVehicle.VehicleSeat

    local settings = vehicleSettings[self.currentVehicle.Name]
    seat.MaxSpeed = settings["Gear"..tostring(gear)].MaxSpeed

    self.currentVehicle.Front.LeftWheel.AngularVelocity.MaxTorque = settings["Gear"..tostring(gear)].MaxTorque - (settings["Gear"..tostring(gear)].MaxTorque * 0.3)
    self.currentVehicle.Front.RightWheel.AngularVelocity.MaxTorque = settings["Gear"..tostring(gear)].MaxTorque - (settings["Gear"..tostring(gear)].MaxTorque * 0.3)

    self.currentVehicle.Back.LeftWheel.AngularVelocity.MaxTorque = settings["Gear"..tostring(gear)].MaxTorque - (settings["Gear"..tostring(gear)].MaxTorque * 0.3)
    self.currentVehicle.Back.RightWheel.AngularVelocity.MaxTorque = settings["Gear"..tostring(gear)].MaxTorque - (settings["Gear"..tostring(gear)].MaxTorque * 0.3)

    self.maxAngularSpeed = settings["Gear"..tostring(gear)].MaxSpeed / (self.currentVehicle.Front.LeftWheel.Size.Y / 2)
    self.currentVehicle.Front.LeftWheel.AngularVelocity.AngularVelocity = Vector3.new(self.maxAngularSpeed * -seat.Throttle, 0, 0)
    self.currentVehicle.Front.RightWheel.AngularVelocity.AngularVelocity = Vector3.new(self.maxAngularSpeed * seat.Throttle, 0, 0)

    self.currentVehicle.Back.LeftWheel.AngularVelocity.AngularVelocity = Vector3.new(self.maxAngularSpeed * -seat.Throttle, 0, 0)
    self.currentVehicle.Back.RightWheel.AngularVelocity.AngularVelocity = Vector3.new(self.maxAngularSpeed * seat.Throttle, 0, 0)

    self.currentGear = gear
end

function VehicleController:KnitStart()
    VehicleService.initiateDriver:Connect(function(vehicle: Model)
        self.currentVehicle = vehicle
        local seat: VehicleSeat = self.currentVehicle.VehicleSeat

        self:shiftGear(self.currentGear)

        self._janitor:Add(seat.Changed:Connect(function(property)
            if property == "Occupant" then
                if seat.Occupant == nil then
                    self._janitor:Cleanup()
                    self.currentGear = 1
                end
            end
        end))

        self._janitor:Add(seat:GetPropertyChangedSignal("Throttle"):Connect(function()
            self.currentVehicle.Front.LeftWheel.AngularVelocity.AngularVelocity = Vector3.new(self.maxAngularSpeed * -seat.Throttle, 0, 0)
            self.currentVehicle.Front.RightWheel.AngularVelocity.AngularVelocity = Vector3.new(self.maxAngularSpeed * seat.Throttle, 0, 0)
        
            self.currentVehicle.Back.LeftWheel.AngularVelocity.AngularVelocity = Vector3.new(self.maxAngularSpeed * -seat.Throttle, 0, 0)
            self.currentVehicle.Back.RightWheel.AngularVelocity.AngularVelocity = Vector3.new(self.maxAngularSpeed * seat.Throttle, 0, 0)
        end))

        self._janitor:Add(seat:GetPropertyChangedSignal("Steer"):Connect(function()
            self.currentVehicle.Front.LeftSteer.CylindricalConstraint.TargetAngle = 30 * seat.Steer
            self.currentVehicle.Front.RightSteer.CylindricalConstraint.TargetAngle = 30 * seat.Steer
        end))
    end)


    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then
            return
        end

        if input.KeyCode == Enum.KeyCode.E then
            self:shiftGear(math.clamp(self.currentGear + 1, 1, 6))
            print(self.currentGear)
        elseif input.KeyCode == Enum.KeyCode.Q then
            self:shiftGear(math.clamp(self.currentGear - 1, 1, 6))
            print(self.currentGear)
        elseif input.KeyCode == Enum.KeyCode.R then
            self.currentVehicle.Back.LeftWheel.HingeConstraint.ActuatorType = Enum.ActuatorType.Motor
            self.currentVehicle.Back.RightWheel.HingeConstraint.ActuatorType = Enum.ActuatorType.Motor
            
            self.currentVehicle.Back.LeftWheel.HingeConstraint.MotorMaxTorque = 50000
            self.currentVehicle.Back.RightWheel.HingeConstraint.MotorMaxTorque = 50000
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then
            return
        end

        if input.KeyCode == Enum.KeyCode.R then
            self.currentVehicle.Back.LeftWheel.HingeConstraint.ActuatorType = Enum.ActuatorType.None
            self.currentVehicle.Back.RightWheel.HingeConstraint.ActuatorType = Enum.ActuatorType.None
        end
        
    end)
end

function VehicleController:KnitInit()
    VehicleService = Knit.GetService("VehicleService")
end

return VehicleController