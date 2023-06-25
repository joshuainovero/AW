local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Vendor.Roact)

local HairsComponent = require(script.Parent:WaitForChild("Hairs"))

local Container = Roact.Component:extend(script.Name)



function Container:init()
    self:setState({
        radius = 50
    })
end

function Container:didMount()

end

function Container:willUnmount()
end

function Container:render()
    return Roact.createElement("Frame", {
        Size = UDim2.fromOffset(self.state.radius, self.state.radius),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        BackgroundColor3 = Color3.new(0),
        BackgroundTransparency = 1
    }, {
        uiCorner = Roact.createElement("UICorner", {
            CornerRadius = UDim.new(1,0)
        }),

        hairs = Roact.createElement(HairsComponent, {
            hairWidth = 15,
            hairHeight = 4
        })
    })
end

return Container