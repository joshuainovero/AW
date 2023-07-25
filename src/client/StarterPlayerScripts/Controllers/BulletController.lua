local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Janitor = require(ReplicatedStorage.Packages.Janitor)

local gunAssetsData = require(ReplicatedStorage.Data.GunAssets)

local effects = ReplicatedStorage.Assets.Effects

local bulletStorage = Instance.new('Folder')
bulletStorage.Name = 'BulletStorage'
bulletStorage.Parent = workspace

local BulletService
local ScopeInterface

local BulletController = Knit.CreateController({
    Name = script.Name,

	_janitor = Janitor.new()
})

function BulletController:renderBullet(character, startPos, direction, gunSettings, charException)
	local player = game:GetService('Players').LocalPlayer
	local playerCharacter = player.Character

	if playerCharacter == charException then
        return
    end

	print('Rendering bullet')
	local lastPos = startPos
	local startTime = tick()

	local bullet = Instance.new('Part')
	bullet.Size = Vector3.new(0.0,0.05,0.2)
	bullet.Anchored = true
	bullet.CanCollide = false
	bullet.BrickColor = BrickColor.new('Gold')
	bullet.Material = Enum.Material.Neon
	bullet.Position = startPos
	bullet.Parent = bulletStorage

	local rayFilter = RaycastParams.new()
	rayFilter.FilterDescendantsInstances = {character, bulletStorage}
	rayFilter.FilterType = Enum.RaycastFilterType.Exclude

	local currentTool = character:FindFirstChildOfClass("Tool")

	local sound = game.ReplicatedStorage.Assets.Sounds.GunFire[currentTool.Name]:Clone()
	sound.Parent = currentTool.Handle
	sound.Volume = 0.2
	sound:Play()
	sound.Ended:Connect(function()
		sound:Destroy()
	end)

	task.spawn(function()
		if not currentTool then return end
		local muzzleEffect = currentTool.Parts.main.Muzzle.MuzzleEffect

		if not ScopeInterface.roactHandle then
			muzzleEffect:Emit(1)
		end
	end)

	local currentRange = gunSettings.Range

	while currentRange > 0  do
		local timePassed = tick() - startTime
		local currentPos = startPos + (direction * timePassed)
		local distance = (lastPos - currentPos).Magnitude
		currentRange -= distance

		local ray = workspace:Raycast(lastPos, currentPos - lastPos, rayFilter)
		if not ray then
			ray = workspace:Raycast(currentPos, lastPos - currentPos, rayFilter)
		end

		if ray then
			local hit = ray.Instance
			currentPos = ray.Position
			local bloodHitEffectClone = effects.BloodHitEffect:Clone()
			local bloodEffect = bloodHitEffectClone.Attachment.Blood
			bloodEffect.Enabled = true

			bloodHitEffectClone.Position = currentPos
			bloodHitEffectClone.Parent = workspace
			
			bloodEffect:Emit(100)
			Debris:AddItem(bloodHitEffectClone, 1)
		end

		if ScopeInterface.roactHandle then
			bullet.Transparency = 1
		else
			bullet.Transparency = 0
		end

		local bulletOffset = CFrame.new(0,0, -(lastPos-currentPos).Magnitude/2)
		bullet.CFrame = CFrame.new(currentPos,lastPos) * bulletOffset
		bullet.Size = Vector3.new(0,0.05,(lastPos - currentPos).Magnitude)

		if ray then
			break
		end

		lastPos = currentPos
		local t = tick()
		repeat
			task.wait()
		until tick() - t >= 1/60
	end	

	local t = tick()
	repeat
		task.wait()
	until tick() - t >= 1/60
	bullet:Destroy()
end

function BulletController:KnitStart()
	self._janitor:Add(BulletService.renderClientBullet:Connect(function(character, startPos, direction, gunSettings, bulletOwner)
		self:renderBullet(character, startPos, direction, gunSettings, bulletOwner)
	end))
end

function BulletController:KnitInit()
	BulletService = Knit.GetService("BulletService")
	ScopeInterface = Knit.GetController("ScopeInterface")
end

return BulletController