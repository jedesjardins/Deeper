local systems = {
	
	controlMovement = function(ecs, dt, input)
		entities = ecs:requireAll("control", "movement")

		for _, id in ipairs(entities) do
			local control = ecs.components.control[id]
			local movement = ecs.components.movement[id]

			local pdx, pdy = movement.dx, movement.dy
			movement.dx, movement.dy = 0, 0

			if input:getKeyState("W") == KS.HELD
				or input:getKeyState("W") == KS.PRESSED then
				movement.dy = movement.dy + math.floor(dt/6)
			end
			if input:getKeyState("S") == KS.HELD
				or input:getKeyState("S") == KS.PRESSED then
				movement.dy = movement.dy - math.floor(dt/6)
			end
			if input:getKeyState("A") == KS.HELD
				or input:getKeyState("A") == KS.PRESSED then
				movement.dx = movement.dx - math.floor(dt/6)
			end
			if input:getKeyState("D") == KS.HELD
				or input:getKeyState("D") == KS.PRESSED then
				movement.dx = movement.dx + math.floor(dt/6)
			end

			movement.changed = false

			-- no movement
			if movement.dx == 0 and movement.dy == 0 then
				if movement.direction.x or movement.direction.y then
					movement.changed = true
				end

				movement.direction.x = nil
				movement.direction.y = nil

			-- if there was no previous motion
			else if movement.direction.x == nil and movement.direction.y == nil then
				if movement.dx ~= 0 then
					movement.direction.x = movement.dx
					movement.changed = true
				else if movement.dy ~= 0 then
					movement.direction.y = movement.dy
					movement.changed = true
				end end

			-- if there was previous motion
			-- check if there is still motion
			else if movement.direction.x then 
				if math.sign(movement.direction.x) == math.sign(movement.dx) then
					movement.changed = false
				else
					movement.changed = true
					movement.direction.x = nil

					if movement.dy ~= 0 then
						movement.direction.y = movement.dy
					end
				end

			else if movement.direction.y then 
				if math.sign(movement.direction.y) == math.sign(movement.dy) then
					movement.changed = false
				else
					movement.changed = true
					movement.direction.y = nil

					if movement.dx ~= 0 then
						movement.direction.x = movement.dx
					end
				end
			end end end end
		end
	end,

	updatePosition = function(ecs, dt, input)
		entities = ecs:requireAll("control", "movement")

		for _, id in ipairs(entities) do
			local pos = ecs.components.position[id]
			local movement = ecs.components.movement[id]

			pos.x = pos.x + movement.dx
			pos.y = pos.y + movement.dy
		end	
	end,

	updateSize = function(ecs, dt, input)
		local sizecomps = ecs.components["size"]

		for i, size in pairs(sizecomps) do
			if input:getKeyState("Up") == KS.HELD
				or input:getKeyState("Up") == KS.PRESSED then
				size.w = size.w + math.floor(dt/4)
				size.h = size.h + math.floor(dt/4)
			end
			if input:getKeyState("Down") == KS.HELD
				or input:getKeyState("Down") == KS.PRESSED then
				size.w = size.w - math.floor(dt/4)
				size.h = size.h - math.floor(dt/4)
			end
		end
	end,

	updateAnimations = function(ecs, dt, input)
		local animcomps = ecs.components["animate"]

		for i, anim in pairs(animcomps) do
			--[[
			if input:getKeyState("P") == KS.PRESSED then
				anim.frame = 1
				anim.animate = not anim.animate
				anim.time = 0
			end

			if input:getKeyState("Right") == KS.PRESSED then
				anim.looptime = anim.looptime + .1
			end

			if input:getKeyState("Left") == KS.PRESSED then
				anim.looptime = anim.looptime - .1
			end
			]]

			if anim.animate then
				anim.time = (anim.time or 0) + dt
				if anim.time > ((1000.0 * anim.looptime * anim.frame) / anim.frames) then
					-- increment and bound frames
					anim.frame = anim.frame + 1
					anim.frame = ((anim.frame - 1) % anim.frames) + 1

					anim.time = anim.time % (1000.0 * anim.looptime)
				end
			end
		end
	end,

	draw = function(ecs, drawcontainer)

		local entities = ecs:requireAll("animate", "position", "size")

		for _, id in ipairs(entities) do
			local dest = Rect.new()
			local di = DrawItem.new()

			dest.x, dest.y = ecs.components["position"][id]["x"], ecs.components["position"][id]["y"]
			dest.w, dest.h = ecs.components["size"][id]["w"], ecs.components["size"][id]["h"]

			di.texturename = ecs.components["animate"][id]["img"]
			di.frame = ecs.components["animate"][id]["frame"]
			di.frames = ecs.components["animate"][id]["frames"]
			di.destrect = dest
			drawcontainer:add(di)
		end
	end
}

return systems