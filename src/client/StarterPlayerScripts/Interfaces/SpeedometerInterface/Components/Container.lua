local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Roact = require(ReplicatedStorage.Vendor.Roact)
local Janitor = require(ReplicatedStorage.Packages.Janitor)

local Container = Roact.PureComponent:extend(script.Name)

local VehicleController

local MIN_ANGLE = 47
local MAX_ANGLE = 313

function Container:init()
    VehicleController = Knit.GetController("VehicleController")

    self:setState({
        speed = 0,
        gear = 1
    })

    self._janitor = Janitor.new()

    self.leftFrameRef = Roact.createRef()
    self.rightFrameRef = Roact.createRef()
end

function Container:didMount()
    self._janitor:Add(VehicleController.speedChanged:Connect(function(speed_)
        self:setState({
            speed = speed_
        })
    end))

    self._janitor:Add(VehicleController.gearChanged:Connect(function(gear_)
        self:setState({
            gear = gear_
        })
    end))

    self._janitor:Add(VehicleController.rpmPercentageChanged:Connect(function(rpmPercentage_)
        local leftFrame = self.leftFrameRef:getValue()
        local rightFrame = self.rightFrameRef:getValue()

        local mappedAngle = MIN_ANGLE + (rpmPercentage_ * (MAX_ANGLE - MIN_ANGLE))

        local leftRot = math.clamp(mappedAngle - 180, -180, 0)

        leftFrame.Rotation = leftRot
    
    
        if mappedAngle > 180 then
    
    
            local rightRot = math.clamp(mappedAngle - 360, -180, 0)
    
            rightFrame.Rotation = rightRot
            rightFrame.Visible = true
        else
            rightFrame.Visible = false
        end
    end))
end

function Container:willUnmount()
    self._janitor:Destroy()
end

function Container:render()
    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(0.162, 0.342),
        Position = UDim2.fromScale(0.5, 0.66),
        AnchorPoint = Vector2.new(0.5,0),
        BackgroundTransparency = 1
    }, {
        uiAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
            AspectRatio = 1
        }),

        speed = Roact.createElement("TextLabel", {
            TextScaled = true,
            Size = UDim2.fromScale(0.571, 0.272),
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.498, 0.618),
            TextColor3 = Color3.new(1,1,1),
            FontFace = Font.new("rbxasset://fonts/families/Michroma.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            Text = self.state.speed
        }),

        unit = Roact.createElement("TextLabel", {
            TextScaled = true,
            Size = UDim2.fromScale(0.355, 0.068),
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.834),
            TextColor3 = Color3.new(1,1,1),
            FontFace = Font.new("rbxasset://fonts/families/Michroma.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            Text = "KM/H"
        }),

        gear = Roact.createElement("TextLabel", {
            TextScaled = true,
            Size = UDim2.fromScale(0.142, 0.096),
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.437),
            TextColor3 = Color3.new(1,1,1),
            FontFace = Font.new("rbxasset://fonts/families/Michroma.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            Text = "D"..tostring(self.state.gear)
        }),

        canvasGroup = Roact.createElement("CanvasGroup", {
            Size = UDim2.fromScale(1,1),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1
        }, {
            frame = Roact.createElement("Frame", {
                Size = UDim2.fromScale(1,1),
                Position = UDim2.fromScale(0.5, 0.7),
                BackgroundTransparency = 1,
                AnchorPoint = Vector2.new(0.5,0.5)
            }, {
                uiAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
                    AspectRatio = 1
                }),

                outerBG = Roact.createElement("ImageLabel", {
                    Size = UDim2.fromScale(1,1),
                    Position = UDim2.fromScale(0,0),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://14430154321"
                }),

                rpmBG = Roact.createElement("ImageLabel", {
                    Size = UDim2.fromScale(1,1),
                    Position = UDim2.fromScale(0,0),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://14430154527",
                    ImageColor3 = Color3.fromRGB(65, 73, 82),
                    ZIndex = 0
                }),

                leftCanvas = Roact.createElement("CanvasGroup", {
                    Size = UDim2.fromScale(0.5, 1),
                    Position = UDim2.fromScale(0,0),
                    BackgroundTransparency = 1
                }, {
                    leftFrame = Roact.createElement("Frame", {
                        Size = UDim2.fromScale(2, 1),
                        Position = UDim2.fromScale(0.005, 0),
                        BackgroundTransparency = 1,
                        Rotation = -180,
                        [Roact.Ref] = self.leftFrameRef
                    }, {
                        leftImage = Roact.createElement("ImageLabel", {
                            Size = UDim2.fromScale(0.5, 1),
                            Position = UDim2.fromScale(0,0),
                            BackgroundTransparency = 1,
                            ImageRectOffset = Vector2.new(-500, 0),
                            ImageRectSize = Vector2.new(1024, 1024),
                            Image = "rbxassetid://14430166513",
                            ImageColor3 = Color3.fromRGB(60, 112, 244)
                        })
                    })
                }),

                rightCanvas = Roact.createElement("CanvasGroup", {
                    Size = UDim2.fromScale(0.5, 1),
                    Position = UDim2.fromScale(0.5,0),
                    BackgroundTransparency = 1
                }, {
                    rightFrame = Roact.createElement("Frame", {
                        Size = UDim2.fromScale(2, 1),
                        Position = UDim2.fromScale(-1, 0),
                        BackgroundTransparency = 1,
                        Rotation = -180,
                        [Roact.Ref] = self.rightFrameRef
                    }, {
                        rightImage = Roact.createElement("ImageLabel", {
                            Size = UDim2.fromScale(0.5, 1),
                            Position = UDim2.fromScale(0.5,0),
                            BackgroundTransparency = 1,
                            ImageRectOffset = Vector2.new(500, 0),
                            ImageRectSize = Vector2.new(1024, 1024),
                            Image = "rbxassetid://14430166513",
                            ImageColor3 = Color3.fromRGB(60, 112, 244)
                        })
                    })
                })
            })
        })
    })
end

return Container