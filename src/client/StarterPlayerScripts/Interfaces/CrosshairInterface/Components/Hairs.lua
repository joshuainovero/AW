local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local Hairs = Roact.Component:extend(script.Name)

local transparencySequence = NumberSequence.new({
    NumberSequenceKeypoint.new(0,0),
    NumberSequenceKeypoint.new(1,0.8),
})

function Hairs:init(props)

    self._janitor = Janitor.new()

    self.upFrameRef = Roact.createRef()
    self.downFrameRef = Roact.createRef()
    self.leftFrameRef = Roact.createRef()
    self.rightFrameRef = Roact.createRef()

    self:setState({
        hairWidth = props.hairWidth,
        hairHeight = props.hairHeight
    })
end

function Hairs:didMount()

end

function Hairs:willUnmount()
    self._janitor:Cleanup()
end

function Hairs:render()
    return Roact.createFragment({
        Up = Roact.createElement("Frame", {
            Size = UDim2.new(0, self.state.hairHeight, 0, self.state.hairWidth),
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.fromScale(0.5, 0),
            BackgroundColor3 = Color3.new(1,1,1),
            BorderSizePixel = 0,
            [Roact.Ref] = self.upFrameRef
        }, {
            uiGradient = Roact.createElement("UIGradient", {
                Transparency = transparencySequence,
                Rotation = 90
            })
        }),

        Down = Roact.createElement("Frame", {
            Size = UDim2.new(0, self.state.hairHeight, 0, self.state.hairWidth),
            AnchorPoint = Vector2.new(0.5, 1),
            Position = UDim2.fromScale(0.5, 1),
            BackgroundColor3 = Color3.new(1,1,1),
            BorderSizePixel = 0,
            [Roact.Ref] = self.downFrameRef
        }, {
            uiGradient = Roact.createElement("UIGradient", {
                Transparency = transparencySequence,
                Rotation = 270
            })
        }),

        Left = Roact.createElement("Frame", {
            Size = UDim2.new(0, self.state.hairWidth, 0, self.state.hairHeight),
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.fromScale(0, 0.5),
            BackgroundColor3 = Color3.new(1,1,1),
            BorderSizePixel = 0,
            [Roact.Ref] = self.leftFrameRef
        }, {
            uiGradient = Roact.createElement("UIGradient", {
                Transparency = transparencySequence
            })
        }),

        Right    = Roact.createElement("Frame", {
            Size = UDim2.new(0, self.state.hairWidth, 0, self.state.hairHeight),
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.fromScale(1, 0.5),
            BackgroundColor3 = Color3.new(1,1,1),
            BorderSizePixel = 0,
            [Roact.Ref] = self.rightFrameRef
        }, {
            uiGradient = Roact.createElement("UIGradient", {
                Transparency = transparencySequence,
                Rotation = 180
            })
        })
    })
end

return Hairs