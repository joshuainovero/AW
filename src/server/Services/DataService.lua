local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)
local ProfileService = require(ReplicatedStorage.Vendor.ProfileService)

-- local ProfileTemplate = require(ReplicatedStorage.Core.Shared.Data.ProfileTemplate)

local CurrencyService
local DataService = Knit.CreateService {
    Name = "DataService",
    Client = {
        GetData = Knit.CreateSignal()
    },

	CURRENT_STORE_KEY = "RELEASE-BUILD-6",

	ProfileLoaded = Signal.new(),

    Profiles = {}
}

-- local ProfileStore = ProfileService.GetProfileStore("PlayerData", ProfileTemplate)

-- function DataService.Client:getItemStatusRequested(player)
-- 	local profile = self.Server:GetPlayerProfile(player)
-- 	if not profile then
-- 		warn("Cannot get items status - player profile is nil.")
-- 		return nil
-- 	end

-- 	local profileData = profile.Data
-- 	return profileData.Backpack[BackpackCategory.HiddenItems]
-- end

-- function DataService:RetrievePlayerProfile(player)
-- 	local profile
-- 	local retrieveCounter = 0

-- 	repeat
-- 		task.wait()

-- 		profile = ProfileStore:LoadProfileAsync(self.CURRENT_STORE_KEY.."-"..player.UserId)
-- 		retrieveCounter += 1

-- 	until retrieveCounter > 3 or profile ~= nil

-- 	return profile
-- end

-- function DataService:GetPlayerProfile(player)
-- 	local found = self.Profiles[player]

-- 	return found
-- end

-- function DataService:ReleaseProfile(profile)
-- 	profile:Release()
-- end

-- function DataService:PlayerAdded(player)
-- 	local profile = DataService:RetrievePlayerProfile(player)

-- 	if not profile then
-- 		player:Kick("Failed to load your data, please rejoin.")
-- 	end

-- 	if profile.Data.Banned then
-- 		-- Banned.
-- 		player:Kick("You have been banned from this experience.")
-- 		return
-- 	end

-- 	profile:AddUserId(player.UserId) -- GDPR compliance
-- 	profile:Reconcile() -- Fill in missing variables from ProfileTemplate

-- 	profile:ListenToRelease(function()
-- 		self.Profiles[player] = nil
-- 		player:Kick("Someone has joined another server using your account.")
-- 	end)

-- 	if player:IsDescendantOf(game.Players) then
-- 		self.Profiles[player] = profile
-- 		self.ProfileLoaded:Fire(player)
-- 		local data = profile.Data
-- 		local playerGems = data.Currency[CurrencyTypes.Gems]
-- 		local playerGold = data.Currency[CurrencyTypes.Gold]

-- 		CurrencyService.Client.onUpdatedCurrency:Fire(player, CurrencyTypes.Gems, playerGems, false)
-- 		CurrencyService.Client.onUpdatedCurrency:Fire(player, CurrencyTypes.Gold, playerGold, false)

-- 		return
-- 	end

-- 	DataService:ReleaseProfile(profile)
-- end

-- function DataService:PlayerLeft(player)
-- 	local profile = self.Profiles[player]

-- 	if profile ~= nil then
-- 		profile:Release()
-- 	end
-- end

-- function DataService:KnitInit()
-- 	CurrencyService = Knit.GetService("CurrencyService")

--     Players.PlayerAdded:Connect(function(player)
--         self:PlayerAdded(player)
--     end)

--     Players.PlayerRemoving:Connect(function(player)
--         self:PlayerLeft(player)
--     end)

-- 	for _, player in Players:GetPlayers() do
-- 		self:PlayerAdded(player)
-- 	end
-- end

return DataService