local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local Container = require(script:WaitForChild("Components"):WaitForChild("Container"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local CrosshairInterface = Knit.CreateController({
    Name = script.Name
})

function CrosshairInterface:render()
    return Roact.createElement(Container)
end

function CrosshairInterface:openInterface()
    self.roactHandle = Roact.mount(Roact.createElement("ScreenGui", {
        ResetOnSpawn = false,
        IgnoreGuiInset = true
    }, {
        container = self:render()
    }), playerGui, script.Name)
end

function CrosshairInterface:closeInterface()
    if self.roactHandle then
        Roact.unmount(self.roactHandle)
        self.roactHandle = nil
    end
end

function CrosshairInterface:KnitStart()
    -- self:openInterface()
end

function CrosshairInterface:KnitInit()

end

return CrosshairInterface