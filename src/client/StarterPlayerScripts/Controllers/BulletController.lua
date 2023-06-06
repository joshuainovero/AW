local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)

local gunAssetsData = require(ReplicatedStorage.Data.GunAssets)

local bulletStorage = Instance.new('Folder')
bulletStorage.Name = 'BulletStorage'
bulletStorage.Parent = workspace

local BulletController = Knit.CreateController({
    Name = script.Name,
})

function BulletController:renderBullet(character, startPos, direction, gunSettings, charException)
	local player = game:GetService('Players').LocalPlayer
	local playerCharacter = player.Character
	if playerCharacter == charException then  
        return 
    end
	-- print('Rendering bullet')
	local lastPos = startPos
	local startTime = tick()

	local bullet = Instance.new('Part')
	bullet.Size = Vector3.new(0.0,0.1,0.4)
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
	sound.SoundId = gunAssetsData[currentTool.Name].FireSound
	sound.Volume = 0.2
	sound:Play()
	sound.Ended:Connect(function()
		sound:Destroy()
	end)

	task.spawn(function()
		if not currentTool then return end
		currentTool.Parts.main.Muzzle.PointLight.Enabled = true
		currentTool.Parts.main.Muzzle.MuzzleEffect.Enabled = true
		task.wait(0.05)
		if not currentTool then return end
		currentTool.Parts.main.Muzzle.PointLight.Enabled = false
		currentTool.Parts.main.Muzzle.MuzzleEffect.Enabled = false
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
		end

		local bulletOffset = CFrame.new(0,0, -(lastPos-currentPos).Magnitude/2)
		bullet.CFrame = CFrame.new(currentPos,lastPos) * bulletOffset
		bullet.Size = Vector3.new(.1,.1,(lastPos - currentPos).Magnitude)

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
	print(gunSettings.Range)
end

function BulletController:KnitStart()

end

function BulletController:KnitInit()

end

return BulletController