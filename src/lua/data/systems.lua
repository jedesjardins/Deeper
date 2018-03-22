local systems = {}

function systems.control(ecs, dt, input)
	local entities = ecs:requireAll("control", "position")

	for _, id in ipairs(entities) do
		local control = ecs.components.control[id]
		local position = ecs.components.position[id]
		local movement = ecs.components.movement[id]

		--[[
			Rotation
		]]
		if input:getKeyState("Q") == KS.PRESSED 
			or input:getKeyState("Q") == KS.HELD then
			position.r = position.r + 1
		end
		if input:getKeyState("E") == KS.PRESSED 
			or input:getKeyState("E") == KS.HELD then
			position.r = position.r - 1
		end

		--[[
			Movement
		]]
		movement.dx, movement.dy = 0, 0
		local directions = {}
		local was_moving = movement.is_moving

		if input:getKeyState(control.up) >= KS.PRESSED then
			movement.dy = movement.dy + 4*dt/1000
			table.insert(directions, "up")
		end
		if input:getKeyState(control.down) >= KS.PRESSED then
			movement.dy = movement.dy - 4*dt/1000
			table.insert(directions, "down")
		end
		if input:getKeyState(control.left) >= KS.PRESSED then
			movement.dx = movement.dx - 4*dt/1000
			table.insert(directions, "left")
		end
		if input:getKeyState(control.right) >= KS.PRESSED then
			movement.dx = movement.dx + 4*dt/1000
			table.insert(directions, "right")
		end
		if input:getKeyState(control.lockdirection) >= KS.PRESSED then
			table.insert(directions, movement.direction)
		end

		-- check if moving
		if movement.dy ~= 0 or movement.dx ~= 0 then
			movement.is_moving = true
		else
			movement.is_moving = false
		end

		movement.changed = true
		for _, direction in ipairs(directions) do
			if direction == movement.direction then
				movement.changed = false
				break
			end
		end

		if movement.changed and movement.is_moving then
			movement.direction = directions[1]
		end

		if movement.is_moving then
			--[[ start animation
			anim.animate = true
			if not was_moving then anim.start = true end
			]]
		else
			--[[ stop animation
			anim.animate = false
			anim.time = 0
			]]
		end
	end
end

function systems.updatePosition(ecs, dt, input)
	local entities = ecs:requireAll("movement", "position")

	for _, id in ipairs(entities) do
		local pos = ecs.components.position[id]
		local movement = ecs.components.movement[id]
		pos.x = pos.x + movement.dx
		pos.y = pos.y + movement.dy
	end	
end

function systems.updateCollision(ecs, dt, input)
	local entities = ecs:requireAll("position", "collision")

	for _, id in ipairs(entities) do
		local pos = ecs.components.position[id]
		local col = ecs.components.collision[id]
		local p1 = collision.getPointsAround(
				{x = pos.x+col.offx, y = pos.y+col.offy, w = col.w, h = col.h, r = pos.r}, 
				{x = pos.x, y = pos.y}
			)

		for _, id2 in ipairs(entities) do
			if id ~= id2 then

				local pos2 = ecs.components.position[id2]
				local col2 = ecs.components.collision[id2]

				local p2 = collision.getPointsAround(
						{x = pos2.x+col2.offx, y = pos2.y+col2.offy, w = col2.w, h = col2.h, r = pos2.r}, 
						{x = pos2.x, y = pos2.y}
					)

				local does_collide, correction_vect = collision.collide(p1, p2)

				if does_collide then
					
					pos.x = pos.x + (correction_vect.x)
					pos.y = pos.y + (correction_vect.y)

					p1 = collision.getPointsAround(
						{x = pos.x+col.offx, y = pos.y+col.offy, w = col.w, h = col.h, r = pos.r}, 
						{x = pos.x, y = pos.y}
					)
				end
			end
		end
	end
end

function systems.draw(ecs, drawcontainer)
	local entities = ecs:requireAll("position")

	for _, id in ipairs(entities) do
		local position = ecs.components.position[id]
		local collision = ecs.components.collision[id]

		local di = DrawItem:new(2)
		local sprite = di.data.sprite
		sprite.texturename = "block.png"
		sprite.framex = 1
		sprite.framey = 1
		sprite.totalframesx = 1
		sprite.totalframesy = 1

		sprite.rotation = position.r

		sprite.dest = Rect.new()
		sprite.dest.x = position.x
		sprite.dest.y = position.y
		sprite.dest.w = position.w
		sprite.dest.h = position.h

		drawcontainer:add(di)
	end
end

return systems