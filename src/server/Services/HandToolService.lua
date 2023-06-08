local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tools = ReplicatedStorage.Assets.Guns

local Knit = require(ReplicatedStorage.Packages.Knit)

local HandToolsService = Knit.CreateService({
    Name = script.Name,
    Client = {
        clientToolEquipped = Knit.CreateSignal(),
        clientToolUnequipped = Knit.CreateSignal()
    }
})

function HandToolsService.Client:equipToolRequested(player, toolType)
    self.Server:equipTool(player, toolType)
end

function HandToolsService.Client:giveToolRequested(player, toolType)
    self.Server:giveTool(player, toolType)
end

function HandToolsService.Client:unequipToolRequested(player)
    self.Server:unequipTools(player)
end

function HandToolsService:_getEquippedTool(player)
    local character = player.Character or player.CharacterAdded:Wait()
    return character:FindFirstChildOfClass("Tool")
end

function HandToolsService:equipTool(player: Player, toolType)
    -- local character = player.Character or player.CharacterAdded:Wait()
    -- local humanoid = character:waitForChild("Humanoid")

    -- local equippedTool = self:_getEquippedTool(player)
    -- if equippedTool then
    --     self:unequipTools(player)
    -- end

    -- local tool = tools:FindFirstChild(toolType)
    -- if not tool then
    --     warn(("%s tool not found in ReplicatedStorage.Assets.Tools!"):format(toolType))
    --     return
    -- end

    -- local clonedTool = tool:Clone()
    -- clonedTool.Parent = player.Backpack
    -- humanoid:EquipTool(clonedTool)
    -- self.Client.clientToolEquipped:Fire(player, toolType)

    -- local character = player.Character or player.CharacterAdded:Wait()
    -- local humanoid = character:waitForChild("Humanoid")

    -- -- local equippedTool = self:_getEquippedTool(player)
    -- -- if equippedTool then
    -- --     self:unequipTools(player)
    -- -- end

    -- local backpack = player.Backpack
    -- local tool = backpack:FindFirstChild(toolType)
    -- if not tool then
    --     warn(("%s tool not found in ReplicatedStorage.Assets.Tools!"):format(toolType))
    --     return
    -- end


end

function HandToolsService:unequipTools(player)
    local character = player.Character or player.CharacterAdded:Wait()
    for _, instance in character:GetChildren() do
        if instance:IsA("Tool") then
            instance:Destroy()
        end
    end

    self.Client.clientToolUnequipped:Fire(player)
end

function HandToolsService:giveTool(player: Player, toolType)

    local tool = tools:FindFirstChild(toolType)
    if not tool then
        warn(("%s tool not found in ReplicatedStorage.Assets.Tools!"):format(toolType))
        return
    end

    local clonedTool = tool:Clone()
    clonedTool.Parent = player.Backpack
end

return HandToolsService