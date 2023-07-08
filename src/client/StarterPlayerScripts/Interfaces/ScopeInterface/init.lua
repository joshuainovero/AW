local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local Container = require(script:WaitForChild("Components"):WaitForChild("Container"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ScopeInterface = Knit.CreateController({
    Name = script.Name
})

function ScopeInterface:render()
    return Roact.createElement(Container)
end

function ScopeInterface:openInterface()
    self.roactHandle = Roact.mount(Roact.createElement("ScreenGui", {
        ResetOnSpawn = false,
        IgnoreGuiInset = true
    }, {
        container = self:render()
    }), playerGui, script.Name)
end

function ScopeInterface:closeInterface()
    Roact.unmount(self.roactHandle)
end

function ScopeInterface:KnitInit()

end

function ScopeInterface:KnitStart()
    
end

return ScopeInterface