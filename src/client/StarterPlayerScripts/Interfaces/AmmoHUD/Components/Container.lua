local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Roact = require(ReplicatedStorage.Vendor.Roact)

local Container = Roact.Component:extend(script.Name)

local GunController

Knit.OnStart():andThen(function()
    GunController = Knit.GetController("GunController")
end):catch(warn)

function Container:init()
    self._janitor = Janitor.new()

    self.imageLabelRef = Roact.createRef()
end

function Container:didMount()
    self:setState({
        capacity = 0,
        available = 0
    })

    self._janitor:Add(GunController.ammoUpdated:Connect(function(capacity_, available_)
        self:setState({
            capacity = capacity_,
            available = available_
        })
    end))

    local imageLabel = self.imageLabelRef:getValue()

    TweenService:Create(imageLabel, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {Position = UDim2.fromScale(1, 1)}):Play()
end

function Container:willUnmount()
    self._janitor:Destroy()
end

function Container:render()
    return Roact.createElement("ImageLabel", {
        Size = UDim2.fromScale(0.2, 0.097),
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.fromScale(1.15, 1),
        BackgroundTransparency = 1,
        Image = "rbxassetid://14096011789",
        ImageColor3 = Color3.new(0),
        [Roact.Ref] = self.imageLabelRef
    }, {
        uiAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
            AspectRatio = 3.7
        }),

        uiGradient = Roact.createElement("UIGradient", {
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0,1),
                NumberSequenceKeypoint.new(0.468,0.494),
                NumberSequenceKeypoint.new(1, 0.144)
            })
        }),

        capacityText = Roact.createElement("TextLabel", {
            Name = "Capacity",
            TextScaled = true,
            Size = UDim2.fromScale(0.284, 0.928),
            Position = UDim2.fromScale(0.333, 0.5),
            AnchorPoint = Vector2.new(0, 0.5),
            TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.Sarpanch,
            Text = self.state.capacity,
            BackgroundTransparency = 1
        }),

        availableText = Roact.createElement("TextLabel", {
            Name = "Available",
            TextScaled = true,
            Size = UDim2.fromScale(0.239, 0.554),
            Position = UDim2.fromScale(0.642, 0.5),
            AnchorPoint = Vector2.new(0, 0.5),
            TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.Sarpanch,
            Text = "/ "..tostring(self.state.available),
            BackgroundTransparency = 1
        })
    })
end

return Container