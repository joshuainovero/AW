local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Vendor.Roact)

local VitalBar = require(script.Parent:WaitForChild("VitalBar"))

local Container = Roact.Component:extend(script.Name)

function Container:init()
    local player = game.Players.LocalPlayer

    local char = player.Character or player.CharacterAdded:Wait()

    local hum = char:WaitForChild("Humanoid")

    self:setState({
        health = 1
    })

    hum.HealthChanged:Connect(function(health)
        self:setState({
            health = health/100
        })
    end)
end

function Container:didMount()

end

function Container:willUnmount()

end

function Container:render()
    return Roact.createElement("Frame", {
        Size = UDim2.fromScale(0.242, 0.199),
        Position = UDim2.fromScale(0.02, 0.79),
        BackgroundTransparency = 1
    }, {
        uiAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint", {
            AspectRatio = 2.385
        }),

        healthBar = Roact.createElement(VitalBar, {
            size = UDim2.fromScale(0.734, 0.221),
            position = UDim2.fromScale(0.208, 0.349),
            image = "rbxassetid://14154907637",
            aspectRatio = 7.938,
            barColor = Color3.fromRGB(171,13,2),
            barSize = self.state.health
        }),

        shieldBar = Roact.createElement(VitalBar, {
            size = UDim2.fromScale(0.46, 0.138),
            position = UDim2.fromScale(0.206, 0.582),
            image = "rbxassetid://14154907637",
            aspectRatio = 7.938,
            barColor = Color3.fromRGB(0, 170, 255),
            barSize = 0.4
        }),

        levelBar = Roact.createElement(VitalBar, {
            size = UDim2.fromScale(0.334, 0.797),
            position = UDim2.fromScale(0.002, 0.093),
            image = "rbxassetid://14155671791",
            aspectRatio = 1,
            barColor = Color3.fromRGB(138, 158, 51),
            zIndex = 2,
            rotation = 270,
            barSize = 0.1
        }, {
            text = Roact.createElement("TextLabel", {
                TextScaled = true,
                Size = UDim2.fromScale(0.4, 0.4),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                BackgroundTransparency = 1,
                TextColor3 = Color3.new(1,1,1),
                FontFace = Font.new("rbxasset://fonts/families/Michroma.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                Text = "LV. 1",
                ZIndex = 3
            })
        }),
    })
end

return Container