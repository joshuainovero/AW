local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local Container = require(script:WaitForChild("Components"):WaitForChild("Container"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local SpeedometerInterface = Knit.CreateController({
    Name = script.Name
})

function SpeedometerInterface:render()
    return Roact.createElement(Container)
end

function SpeedometerInterface:openInterface()
    self.roactHandle = Roact.mount(Roact.createElement("ScreenGui", {
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, {
        container = self:render()
    }), playerGui, script.Name)
end

function SpeedometerInterface:closeInterface()
    if self.roactHandle then
        Roact.unmount(self.roactHandle)
        self.roactHandle = nil
    end
end

function SpeedometerInterface:KnitInit()

end

function SpeedometerInterface:KnitStart()
   
end

return SpeedometerInterface