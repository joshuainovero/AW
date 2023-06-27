local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Janitor = require(ReplicatedStorage.Packages.Janitor)

local Roact = require(ReplicatedStorage.Vendor.Roact)

local HairsComponent = require(script.Parent:WaitForChild("Hairs"))

local Container = Roact.Component:extend(script.Name)

local GunController

function Container:init()

    GunController = Knit.GetController("GunController")

    self._janitor = Janitor.new()

    self.frameRef = Roact.createRef()

    self:setState({
        radius = 45
    })
end

function Container:didMount()
    local frame: Frame = self.frameRef:getValue()
    local frameRadius = self.state.radius

    self._janitor:Add(GunController.fired:Connect(function()

        frame.Size = UDim2.fromOffset(frame.Size.X.Offset + 8, frame.Size.Y.Offset + 8)
        local info = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
        TweenService:Create(frame, info, {Size = UDim2.fromOffset(self.state.radius, self.state.radius)}):Play()
    end))

    self._janitor:Add(GunController.zoomedIn:Connect(function(state)
        print("Hey")
        local info = TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
        if state then
            self.state.radius = 35
        else
            self.state.radius = 45
        end
        TweenService:Create(frame, info, {Size = UDim2.fromOffset(self.state.radius, self.state.radius)}):Play()
    end))
end

function Container:willUnmount()
end

function Container:render()
    return Roact.createElement("Frame", {
        Size = UDim2.fromOffset(self.state.radius, self.state.radius),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        BackgroundColor3 = Color3.new(0),
        BackgroundTransparency = 1,
        [Roact.Ref] = self.frameRef
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