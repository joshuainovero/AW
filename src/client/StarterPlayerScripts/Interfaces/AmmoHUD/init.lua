local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local Container = require(script:WaitForChild("Components"):WaitForChild("Container"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local AmmoHUDInterface = Knit.CreateController({
    Name = script.Name,

    _unmounting = false
})

function AmmoHUDInterface:render()
    return Roact.createElement(Container)
end

function AmmoHUDInterface:openInterface()
    if self.roactHandle then
        print("EXISTING")
        return
    end

    self.roactHandle = Roact.mount(Roact.createElement("ScreenGui", {
        ResetOnSpawn = false,
        IgnoreGuiInset = true
    }, {
        container = self:render()
    }), playerGui, script.Name)

end

function AmmoHUDInterface:closeInterface()
    if self.roactHandle then
        if self._unmounting then
            return
        end

        self._unmounting = true

        Roact.unmount(self.roactHandle)
        self.roactHandle = nil
        self._unmounting = false
    end
end

function AmmoHUDInterface:KnitStart()
end

function AmmoHUDInterface:KnitInit()

end

return AmmoHUDInterface