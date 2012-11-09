local def = 
{
	run = 500,
	walk = 250,
	step = 18,
	jump = 200,
	
	view = Vector(0,0,64),
	viewducked = Vector(0,0,28),	
	mass = 85,
	
	min = Vector(-16, -16, 0),
	max = Vector(16, 16, 72),
	maxduck = Vector(16, 16, 36),
}

function pac.SetPlayerSize(ply, f)
	local TICKRATE = SERVER and 1/FrameTime() or 0
	
	ply:SetModelScale(f, 0)
	
	ply:SetViewOffset(def.view * f)
	ply:SetViewOffsetDucked(def.viewducked * f)
	
	ply:SetRunSpeed(math.max(def.run * f, TICKRATE/2))
	ply:SetWalkSpeed(math.max(def.walk * f, TICKRATE/4))
	
	ply:SetStepSize(def.step * f)
	
	ply:SetHull(def.min * scale, def.max * f)
	ply:SetHullDuck(def.min * scale, def.maxduck * f)
			
	local phys = ply:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMass(def.mass * f)	
	end
	
	hook.Add("UpdateAnimation", "scale", function(ply, vel, max)
		if ply.pac_player_size and ply.pac_player_size ~= 1 then
			ply:SetPlaybackRate(1 / ply.pac_player_size)
			return true
		end
	end)
	 
	ply.pac_player_size = f
end