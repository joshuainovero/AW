local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local Hairs = Roact.Component:extend(script.Name)

local GunController

local transparencySequence = NumberSequence.new({
    NumberSequenceKeypoint.new(0,0),
    NumberSequenceKeypoint.new(1,0.887),
})

function Hairs:init(props)
    GunController = Knit.GetController("GunController")

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
    local a = 8
    self._janitor:Add(GunController.fired:Connect(function()
        self.upFrameRef:getValue().Position = self.upFrameRef:getValue().Position + UDim2.new(0,0,0,-a)
        self.downFrameRef:getValue().Position = self.downFrameRef:getValue().Position + UDim2.new(0,0,0,a)
        self.leftFrameRef:getValue().Position = self.leftFrameRef:getValue().Position + UDim2.new(0,-a,0,0)
        self.rightFrameRef:getValue().Position = self.rightFrameRef:getValue().Position + UDim2.new(0,a,0,0)

        local info = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
        TweenService:Create(self.upFrameRef:getValue(), info, {Position = UDim2.fromScale(0.5, 0)}):Play()
        TweenService:Create(self.downFrameRef:getValue(), info, {Position = UDim2.fromScale(0.5, 1)}):Play()
        TweenService:Create(self.leftFrameRef:getValue(), info, {Position = UDim2.fromScale(0, 0.5)}):Play()
        TweenService:Create(self.rightFrameRef:getValue(), info, {Position = UDim2.fromScale(1, 0.5)}):Play()
    end))
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