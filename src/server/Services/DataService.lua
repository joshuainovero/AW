local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)
local ProfileService = require(ReplicatedStorage.Vendor.ProfileService)

local Guns = require(ReplicatedStorage.Enums.Guns)

local ProfileTemplate = require(ServerStorage.Data.ProfileTemplate)
local GunMaxCapacity = require(ReplicatedStorage.Data.GunMaxCapacity)

local InventoryService

local DataService = Knit.CreateService {
    Name = script.Name,
    Client = {
        getData = Knit.CreateSignal()
    },

	CURRENT_STORE_KEY = "TEST-BUILD",

	profileLoaded = Signal.new(),

    profiles = {}
}

local profileStore = ProfileService.GetProfileStore("PlayerData", ProfileTemplate)

function DataService:getPlayerProfile(player)
	local found = self.profiles[player]

	return found
end

function DataService.Client:updateAmmoRequested(player: Player, tool: Tool)
	return self.Server:updateAmmo(player, tool)
end

function DataService.Client:validateAmmoAvailabilityRequested(player: Player, tool: Tool)
	return self.Server:validateAmmoAvailability(player, tool)
end

function DataService:updateAmmo(player: Player, tool: Tool)
	local inventory = InventoryService:getInventory(player)

	if not inventory then
		return false
	end

	local maxCapacity = GunMaxCapacity[tool.Name]

	local pendingAmmo = math.clamp(maxCapacity, 0, inventory.Ammo[tool.Name])

	inventory.Ammo[tool.Name] = math.clamp(inventory.Ammo[tool.Name] - pendingAmmo , 0, math.huge)

	if not tool:GetAttribute("Ammo") then
		tool:SetAttribute("Ammo", 0)
	end

	tool:SetAttribute("Ammo", tool:GetAttribute("Ammo") + (pendingAmmo - tool:GetAttribute("Ammo")))

	return inventory.Ammo[tool.Name]

end

function DataService:validateAmmoAvailability(player: Player, tool: Tool)
	local inventory = InventoryService:getInventory(player)

	if not inventory then
		return
	end

	if not tool:GetAttribute("Ammo") then
		tool:SetAttribute("Ammo", 0)
	end

	local availableAmmo = inventory.Ammo[tool.Name]

	local maxCapacity = GunMaxCapacity[tool.Name]

	return availableAmmo > 0 and tool:GetAttribute("Ammo") < maxCapacity
end

function DataService:_retrievePlayerProfile(player)
	local profile
	local retrieveCounter = 0

	repeat
		task.wait()

		profile = profileStore:LoadProfileAsync(self.CURRENT_STORE_KEY.."-"..player.UserId)
		retrieveCounter += 1

	until retrieveCounter > 3 or profile ~= nil

	return profile
end

function DataService:_releaseProfile(profile)
	profile:Release()
end

function DataService:_playerAdded(player)
	local profile = DataService:_retrievePlayerProfile(player)

	if not profile then
		player:Kick("Failed to load your data, please rejoin.")
	end

	if profile.Data.Moderation.Banned then
		-- Banned.
		player:Kick("You have been banned from this experience.")
		return
	end

	profile:AddUserId(player.UserId) -- GDPR compliance
	profile:Reconcile() -- Fill in missing variables from ProfileTemplate

	profile:ListenToRelease(function()
		self.profiles[player] = nil
		player:Kick("Someone has joined another server using your account.")
	end)

	if player:IsDescendantOf(game.Players) then
		self.profiles[player] = profile
		self.profileLoaded:Fire(player)
		return
	end

	DataService:_releaseProfile(profile)
end

function DataService:_playerLeft(player)
	local profile = self.profiles[player]

	if profile ~= nil then
		profile:Release()
	end
end

function DataService:KnitInit()

	InventoryService = Knit.GetService("InventoryService")

    Players.PlayerAdded:Connect(function(player)
        self:_playerAdded(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        self:_playerLeft(player)
    end)

	for _, player in Players:GetPlayers() do
		self:_playerAdded(player)
	end
end

return DataService