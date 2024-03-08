local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Signal = require(ReplicatedStorage.Packages.Signal)

local vehicleSettings = require(ReplicatedStorage.Data.VehiclesData)

local vehicles = ReplicatedStorage.Assets.Vehicles

local STEER_MULTIPLIER = 30

local VehicleService
local SpeedometerInterface
local VehicleController = Knit.CreateController({
    Name = script.Name,

    currentVehicle = nil :: Model,
    currentGear = 1,
    maxAngularSpeed = 0,
    _janitor = Janitor.new(),

    speedChanged = Signal.new(),
    gearChanged = Signal.new(),
    rpmPercentageChanged = Signal.new()
})

function VehicleController:shiftGear(gear: number)
    if not self.currentVehicle then
        return
    end

    local seat: VehicleSeat = self.currentVehicle.VehicleSeat

    local settings = vehicleSettings[self.currentVehicle.Name]
    seat.MaxSpeed = settings["Gear"..tostring(gear)].MaxSpeed

    self.currentVehicle.Front.LeftWheel.AngularVelocity.MaxTorque = settings["Gear"..tostring(gear)].MaxTorque
    self.currentVehicle.Front.RightWheel.AngularVelocity.MaxTorque = settings["Gear"..tostring(gear)].MaxTorque

    self.currentVehicle.Back.LeftWheel.AngularVelocity.MaxTorque = settings["Gear"..tostring(gear)].MaxTorque
    self.currentVehicle.Back.RightWheel.AngularVelocity.MaxTorque = settings["Gear"..tostring(gear)].MaxTorque

    self.maxAngularSpeed = settings["Gear"..tostring(gear)].MaxSpeed / (self.currentVehicle.Front.LeftWheel.Size.Y / 2)
    self.currentVehicle.Front.LeftWheel.AngularVelocity.AngularVelocity = Vector3.new(self.maxAngularSpeed * -seat.Throttle, 0, 0)
    self.currentVehicle.Front.RightWheel.AngularVelocity.AngularVelocity = Vector3.new(self.maxAngularSpeed * seat.Throttle, 0, 0)

    self.currentVehicle.Back.LeftWheel.AngularVelocity.AngularVelocity = Vector3.new(self.maxAngularSpeed * -seat.Throttle, 0, 0)
    self.currentVehicle.Back.RightWheel.AngularVelocity.AngularVelocity = Vector3.new(self.maxAngularSpeed * seat.Throttle, 0, 0)

    self.currentGear = gear

    self.gearChanged:Fire(gear)
end

function VehicleController:KnitStart()
    VehicleService.initiateDriver:Connect(function(vehicle: Model)
        self.currentVehicle = vehicle
        local seat: VehicleSeat = self.currentVehicle.VehicleSeat

        seat.HeadsUpDisplay = false

        self:shiftGear(self.currentGear)

        self._janitor:Add(seat.Changed:Connect(function(property)
            print(property)
            if property == "Occupant" then
                if seat.Occupant == nil then
                    self._janitor:Cleanup()
                    self.currentGear = 1
                    SpeedometerInterface:closeInterface()
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
            self.currentVehicle.Front.LeftSteer.CylindricalConstraint.TargetAngle = STEER_MULTIPLIER * seat.Steer
            self.currentVehicle.Front.RightSteer.CylindricalConstraint.TargetAngle = STEER_MULTIPLIER * seat.Steer
        end))

        self._janitor:Add(RunService.RenderStepped:Connect(function()
            local settings = vehicleSettings[self.currentVehicle.Name]
            local currentSpeed = math.floor(seat.AssemblyLinearVelocity.Magnitude)

            local CONSTANT_BOOST = 50000 * 0.0477

            local inclination = math.clamp(self.vehicle.PrimaryPart.CFrame.LookVector:Dot(Vector3.new(0, 1, 0), 0, 1))
            local torque = self.currentGear + (inclination * CONSTANT_BOOST)

            local rpmPercentage = currentSpeed / settings["Gear"..tostring(self.currentGear)].MaxSpeed

            self.rpmPercentageChanged:Fire(rpmPercentage)

            self.speedChanged:Fire(math.floor(currentSpeed))
        end))

        SpeedometerInterface:openInterface()
    end)


    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then
            return
        end

        if not self.currentVehicle then
            warn("No vehicle")
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
            
            self.currentVehicle.Back.LeftWheel.HingeConstraint.MotorMaxTorque = vehicleSettings[self.currentVehicle.Name] or 50000
            self.currentVehicle.Back.RightWheel.HingeConstraint.MotorMaxTorque = vehicleSettings[self.currentVehicle.Name] or 50000
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then
            return
        end

        if input.KeyCode == Enum.KeyCode.R then
            self.currentVehicle.Back.LeftWheel.HingeConstraint.ActuatorType = Enum.ActuatorType.None
            self.currentVehicle.Back.RightWheel.HingeConstraint.ActuatorType = Enum.ActuatorType.None

        else 

            self.currentVehicle.Back.LeftWheel.HingeConstraint.ActuatorType = Enum.ActuatorType.Motor
            self.currentVehicle.Back.RightWheel.HingeConstraint..ActuatorType = Enum.ActuatorType.Motor
        end
        
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then
            return
        end
    
        if input.KeyCode == Enum.KeyCode.R then
            self.currentVehicle.Back.RightWheel.HingeConstraint.ActuatorType = Enum.ActuatorType.Nonea
        end
    end)
end

function VehicleController:KnitInit()
    VehicleService = Knit.GetService("VehicleService")
    SpeedometerInterface = Knit.GetController("SpeedometerInterface")
end

return VehicleController