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
    return Roact.createElement("ImageLabel", {
        Size = UDim2.fromScale(1, 1),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://13952608372"
    }, {
        uiAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
            AspectRatio = 1
        }),

        LeftFrame = Roact.createElement("Frame", {
            BackgroundColor3 = Color3.new(0),
            Size = UDim2.fromScale(100, 1),
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.fromScale(0, 0),
            BorderSizePixel = 0
        }),

        RightFrame = Roact.createElement("Frame", {
            BackgroundColor3 = Color3.new(0),
            Size = UDim2.fromScale(100, 1),
            AnchorPoint = Vector2.new(0, 0),
            Position = UDim2.fromScale(1, 0),
            BorderSizePixel = 0
        }),
    })
end

return Container