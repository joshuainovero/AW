local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local DataService

local InventoryService = Knit.CreateService({
    Name = script.Name,

    Client = {
        inventoryUpdated = Knit.CreateSignal(),
        itemAdded = Knit.CreateSignal()
    }
})

function InventoryService.Client:getInventoryRequested(player: Player)
    return self.Server:getInventory(player)
end

function InventoryService:getInventory(player: Player)
    local profile = DataService:getPlayerProfile(player)
    local profileData = profile and profile.Data

    if not profileData then
        return
    end

    return profileData.Inventory
end

function InventoryService:KnitStart()

end

function InventoryService:KnitInit()
    DataService = Knit.GetService("DataService")
end

return InventoryService