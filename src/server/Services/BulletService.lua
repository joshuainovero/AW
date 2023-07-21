local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Janitor = require(ReplicatedStorage.Packages.Janitor)

local gunPresets = require(ReplicatedStorage.Data.GunPresets)

local BulletService = Knit.CreateService({
    Name = script.Name,

    Client = {
        fireBullet = Knit.CreateSignal(),
        renderClientBullet = Knit.CreateSignal()
    }
})

function BulletService:fireBullet(player : Player, bulletOwner, startPosition: Vector3,  targetPosition : Vector3)
    local character = player.Character
	local tool = character:FindFirstChildOfClass('Tool')
	-- if not tool then warn('No tool is equipped') return end

	local ownerHumanoid = tool.Parent:FindFirstChildOfClass('Humanoid')
	if not ownerHumanoid or ownerHumanoid.Health <= 0 then
		print('Dead')
		return
	end

	local handle = character:FindFirstChildOfClass('Tool').Handle

	local gunSettings = gunPresets[handle.Parent.Name]

	-- if handle.Parent:GetAttribute("Magazine") <= 0 then
	-- 	return
	-- end

	-- handle.Parent:SetAttribute("Magazine", handle.Parent:GetAttribute("Magazine") - 1)
	-- clientEvents.UpdateAmmoUI:FireClient(player, handle.Parent:GetAttribute("Magazine"))
	local startPos = startPosition
	local velocity = gunSettings.Velocity
	local direction = (CFrame.new(startPos, targetPosition).LookVector) * velocity

	local range = gunSettings.Range

	-- clientEvents.RenderBullet:FireAllClients(character, startPos, direction, gunSettings, bulletOwner)

    self.Client.renderClientBullet:FireAll(character, startPos, direction, gunSettings, bulletOwner)

	local blacklist = {character, handle}
	local rayFilter = RaycastParams.new()
	rayFilter.FilterDescendantsInstances = blacklist
	rayFilter.FilterType = Enum.RaycastFilterType.Exclude


	local startTime = tick()
	local lastPos = startPos

	-- local bullet
	-- if debugServerBullet then
	-- 	bullet = Instance.new('Part')
	-- 	bullet.Size = Vector3.new(0.0,0.1,0.4)
	-- 	bullet.Anchored = true
	-- 	bullet.CanCollide = false
	-- 	bullet.Color = Color3.fromRGB(1,0,0)
	-- 	bullet.Material = Enum.Material.Neon
	-- 	bullet.Position = startPos
	-- 	bullet.Parent = folder
	-- end
    
	tool:SetAttribute("Ammo", math.clamp(tool:GetAttribute("Ammo") - 1, 0, math.huge))

	while range > 0 do
		local timePassed = tick() - startTime

		local currentPos = startPos + (direction * timePassed)
		local distance = (lastPos - currentPos).Magnitude
		range -= distance

		local ray = workspace:Raycast(lastPos, currentPos - lastPos, rayFilter)
		if ray == nil then
			ray = workspace:Raycast(currentPos, lastPos - currentPos, rayFilter)
		end

		-- if debugServerBullet then
		-- 	local bulletOffset = CFrame.new(0,0, -(lastPos-currentPos).Magnitude/2)
		-- 	bullet.CFrame = CFrame.new(currentPos,lastPos) * bulletOffset
		-- 	bullet.Size = Vector3.new(.1,.1,(lastPos - currentPos).Magnitude)
		-- end

		if ray then
			--print(ray.Instance)
			local hit = ray.Instance
			currentPos = ray.Position
			
			local model = hit:FindFirstAncestorOfClass('Model')
			if model then
				local humanoid = model:FindFirstChildWhichIsA('Humanoid') or nil
				if humanoid then
					humanoid:TakeDamage(gunSettings.BaseDamage)
				end
			end
			break
		end
		
		lastPos = currentPos
		task.wait()
	end
end

function BulletService:KnitStart()
    self.Client.fireBullet:Connect(function(player : Player, bulletOwner, startPosition: Vector3,  targetPosition : Vector3)
        self:fireBullet(player, bulletOwner, startPosition,  targetPosition)
    end)
end

function BulletService:KnitInit()

end

return BulletService