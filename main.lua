local module = {}

local TweenService = game:GetService("TweenService")

local CurrentCamera = workspace.CurrentCamera

local FlyingPlayers = {}

function module.ToggleFly( tbl : {} )

	local player = tbl["Player"]
	local fly = tbl["Fly"]
	local speed = tbl["Speed"]
	local turntime = tbl["TurnTime"] or 0.15
	local movetime = tbl["MoveTime"] or 0.1

	if not player or fly == nil or not speed then return end

	local FlyingFind = FlyingPlayers[player.UserId] or nil

	if FlyingFind == not fly then
		FlyingPlayers[player.UserId] = fly
	elseif FlyingFind == nil then
		FlyingPlayers[player.UserId] = fly
	end

	local Character = player.Character or player.CharacterAdded:Wait()
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
	
	--Character.Animate.Disabled = fly

	if FlyingPlayers[player.UserId] == false then
		local OldFF = HumanoidRootPart:FindFirstChildOfClass("BodyVelocity")
		local OldFG = HumanoidRootPart:FindFirstChildOfClass("BodyGyro")

		if OldFF then OldFF:Destroy() end
		if OldFG then OldFG:Destroy() end

		return
	end
	
	local ControlModule = require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"):WaitForChild("ControlModule"))

	local FlightForce = Instance.new("BodyVelocity")
	FlightForce.MaxForce = Vector3.new(1, 1, 1) * 10^6
	FlightForce.P = 10^6

	local FlightGryo = Instance.new("BodyGyro")
	FlightGryo.MaxTorque = Vector3.new(1, 1, 1) * 10^6
	FlightGryo.P = 10^6

	FlightGryo.Parent = FlyingPlayers[player.UserId] and HumanoidRootPart or nil
	FlightForce.Parent = FlyingPlayers[player.UserId] and HumanoidRootPart or nil

	FlightGryo.CFrame = HumanoidRootPart.CFrame
	FlightForce.Velocity = Vector3.new()

	if FlyingPlayers[player.UserId] == true then
		while FlyingPlayers[player.UserId] == true do
			local MoveVector = ControlModule:GetMoveVector()
			local Direction = CurrentCamera.CFrame.RightVector * (MoveVector.X) + CurrentCamera.CFrame.LookVector * (MoveVector.Z * -1)

			if Direction:Dot(Direction) > 0 then
				Direction = Direction.Unit
			end

			TweenService:Create(FlightGryo, TweenInfo.new(turntime,Enum.EasingStyle.Sine),{CFrame = CurrentCamera.CFrame}):Play()
			TweenService:Create(FlightForce, TweenInfo.new(movetime,Enum.EasingStyle.Sine),{Velocity = Direction * speed}):Play()
			task.wait()
		end
	end
end

return module
