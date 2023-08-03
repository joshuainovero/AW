local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Vendor.Roact)

local function vitalBar(props)
    return Roact.createElement("ImageLabel", {
        Size = props.size or UDim2.fromScale(0,0),
        Position = props.position or UDim2.fromScale(0,0),
        Image = props.image,
        BackgroundTransparency = 1,
        ImageColor3 = Color3.fromRGB(50,50,50),
        ZIndex = props.zIndex or 1
    }, {
        uiAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
            AspectRatio = props.aspectRatio
        }),

        bar = Roact.createElement("ImageLabel", {
            Size = UDim2.fromScale(1,1),
            Position = UDim2.fromScale(0,0),
            Image = props.image,
            BackgroundTransparency = 1,
            ImageColor3 = props.barColor,
            Rotation = props.rotation or 0,
            ZIndex = props.zIndex or 1
        }, {
            uiGradient = Roact.createElement("UIGradient", {
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0,0),

                    NumberSequenceKeypoint.new(math.clamp(props.barSize - 0.001, 0, props.barSize), 0),
                    NumberSequenceKeypoint.new(props.barSize, 1),

                    NumberSequenceKeypoint.new(1,1)
                })
            }),
        }),

        Roact.createFragment(props[Roact.Children])
    })
end

return vitalBar