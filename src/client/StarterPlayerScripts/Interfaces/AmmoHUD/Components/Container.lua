local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Vendor.Roact)

local Container = Roact.Component:extend(script.Name)

function Container:init()

end

function Container:didMount()

end

function Container:willUnmount()

end

function Container:render()
    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(0.5, 0.5)
    }, {
        uiAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
            AspectRatio = 1
        })
    })
end

return Container