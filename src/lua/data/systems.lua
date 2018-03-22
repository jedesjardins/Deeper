local systems = {}

function systems.control(ecs, dt, input)
	local entities = ecs:requireAll("control", "position")

	for _, id in ipairs(entities) do
		local control = ecs.components.control[id]
		local movement = ecs.components.movement[id]
		local state = ecs.components.state[id]

		--[[
			Rotation
		]]
		local position = ecs.components.position[id]
		if input:getKeyState("Q") == KS.PRESSED 
			or input:getKeyState("Q") == KS.HELD then
			position.r = position.r + 2
		end
		if input:getKeyState("E") == KS.PRESSED 
			or input:getKeyState("E") == KS.HELD then
			position.r = position.r - 2
		end

		--[[
			Movement
		]]
		local new_directions = {}
		local was_moving = movement.dx ~= 0 or movement.dy ~= 0
		local is_moving = false
		local direction_changed = true

		movement.dx, movement.dy = 0, 0

		if input:getKeyState(control.up) >= KS.PRESSED then
			movement.dy = movement.dy + 4*dt/1000
			is_moving = true
			table.insert(new_directions, "up")

			if state.direction == "up" then
				direction_changed = false
			end
		end
		if input:getKeyState(control.down) >= KS.PRESSED then
			movement.dy = movement.dy - 4*dt/1000
			is_moving = true
			table.insert(new_directions, "down")

			if state.direction == "down" then
				direction_changed = false
			end
		end
		if input:getKeyState(control.left) >= KS.PRESSED then
			movement.dx = movement.dx - 4*dt/1000
			is_moving = true
			table.insert(new_directions, "left")

			if state.direction == "left" then
				direction_changed = false
			end
		end
		if input:getKeyState(control.right) >= KS.PRESSED then
			movement.dx = movement.dx + 4*dt/1000

			is_moving = true
			table.insert(new_directions, "right")

			if state.direction == "right" then
				direction_changed = false
			end
		end
		if input:getKeyState(control.lockdirection) >= KS.PRESSED then
			table.insert(new_directions, state.direction)

			direction_changed = false
		end

		--[[
			State
		]]
		if direction_changed and #new_directions > 0 then
			state.direction = new_directions[1]
		end

		state.action_queue = {}
		if is_moving then
			movement.is_moving = true
			table.insert(state.action_queue, "walk")
		else
			movement.is_moving = false
			table.insert(state.action_queue, "stand")
		end

		if input:getKeyState(control.attack) == KS.PRESSED then
			table.insert(state.action_queue, "stab")
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
		local mov = ecs.components.movement[id]
		local group = ecs.components.group[id]
		
		local p1 = collision.getPointsAround(
			{x = pos.x+col.offx, y = pos.y+col.offy, w = col.w, h = col.h, r = pos.r}, 
			{x = pos.x, y = pos.y}
		)

		if group ~= "item" then 
			for _, id2 in ipairs(entities) do
				if id ~= id2 then
					local pos2 = ecs.components.position[id2]
					local col2 = ecs.components.collision[id2]
					local mov2 = ecs.components.movement[id2]
					local group2 = ecs.components.group[id2]

					local p2 = collision.getPointsAround(
							{x = pos2.x+col2.offx, y = pos2.y+col2.offy, w = col2.w, h = col2.h, r = pos2.r}, 
							{x = pos2.x, y = pos2.y}
						)

					local does_collide, correction_vect = collision.collide(p1, p2)

					if does_collide then
						local mov2 = ecs.components.movement[id2]

						-- if theres hitboxes, apply the damage back and forth


						if group2 == "item" then
							-- try to pickup item

							if mov2 then
								-- projectiles are pushed around, should they lock on?
								pos2.x = pos2.x - (correction_vect.x)
								pos2.y = pos2.y - (correction_vect.y)

								-- to lock on add lock on component, calculate offset from pos2
								-- remove collision component to stop it from moving around
							end
						else if mov and mov2 and mov.is_moving and mov2.is_moving then
							-- move both

							pos.x = pos.x + (correction_vect.x)/2
							pos.y = pos.y + (correction_vect.y)/2

							pos2.x = pos2.x - (correction_vect.x)/2
							pos2.y = pos2.y - (correction_vect.y)/2
						else if mov and mov.is_moving then
							-- move id

							pos.x = pos.x + (correction_vect.x)
							pos.y = pos.y + (correction_vect.y)

						else if mov2 and mov2.is_moving then
							-- move id2

							pos2.x = pos2.x - (correction_vect.x)
							pos2.y = pos2.y - (correction_vect.y)
						else
							-- move id

							pos.x = pos.x + (correction_vect.x)/2
							pos.y = pos.y + (correction_vect.y)/2

							pos2.x = pos2.x - (correction_vect.x)/2
							pos2.y = pos2.y - (correction_vect.y)/2
						end end end end

						-- reset new points after moved
						p1 = collision.getPointsAround(
							{x = pos.x+col.offx, y = pos.y+col.offy, w = col.w, h = col.h, r = pos.r}, 
							{x = pos.x, y = pos.y}
						)
					end
				end
			end
		end
	end
end

function systems.updateState(ecs, dt, input)
	local entities = ecs:requireAll("state")

	for _, id in ipairs(entities) do
		local state = ecs.components.state[id]

		if not state.action then
			state.action_name = "stand"
			state.action = state.actions[state.action_name]
		end

		state.time = state.time + dt/1000
		-- end action
		if state.time > state.action.duration then
			state.action_name = state.action.next_action or state.action.stop
			state.action.next_action = nil
			state.action = state.actions[state.action_name]
			state.time = 0
		end

		--set new actions
		for _, action_name in ipairs(state.action_queue) do
			if state.action.combos then
				state.action.next_action = state.action.combos[action_name] or state.action.next_action
			end

			if state.action.interruptable and state.action_name ~= action_name then
				state.action_name = action_name
				state.action = state.actions[action_name]
				state.time = 0
			end
		end
	end
end

function systems.updateAnimation(ecs, dt, input)
	local entities = ecs:requireAll("sprite", "state")

	for _, id in ipairs(entities) do
		local sprite = ecs.components.sprite[id]
		local state = ecs.components.state[id]

		local duration = state.action.duration
		local percent = (state.time%duration)/duration
		local frameindex = math.floor(percent * #state.action.frames) + 1

		sprite.img = sprite.img_base.."_"..state.action.img..".png"

		sprite.framex = state.action.frames[frameindex]

		sprite.framey = state.direction_to_y[state.direction]

		sprite.totalframesx = state.action.framesw
		sprite.totalframesy = 4
	end
end

function systems.draw(ecs, drawcontainer)
	local entities = ecs:requireAll("position", "sprite")
	local drawItems = {}

	for _, id in ipairs(entities) do
		local position = ecs.components.position[id]
		local sprite = ecs.components.sprite[id]

		local di = DrawItem:new(2)
		local itemsprite = di.data.sprite
		itemsprite.texturename = sprite.img
		itemsprite.framex = sprite.framex
		itemsprite.framey = sprite.framey
		itemsprite.totalframesx = sprite.totalframesx
		itemsprite.totalframesy = sprite.totalframesy

		itemsprite.rotation = position.r

		itemsprite.dest = Rect.new()
		itemsprite.dest.x = position.x
		itemsprite.dest.y = position.y
		itemsprite.dest.w = position.w
		itemsprite.dest.h = position.h

		--drawcontainer:add(di)

		table.insert(drawItems, {position.y - position.h/2, di})
	end

	local sortfunc = function (a, b) return a[1] > b[1] end
	
	table.sort(drawItems, sortfunc)

	for i, v in ipairs(drawItems) do
		drawcontainer:add(v[2])
	end
end

function systems.drawHitbox(ecs, drawcontainer)
	local entities = ecs:requireAll("position", "collision")
	local drawItems = {}

	for _, id in ipairs(entities) do
		local position = ecs.components.position[id]
		local collision = ecs.components.collision[id]

		local di = DrawItem:new(2)
		local itemsprite = di.data.sprite
		itemsprite.texturename = "hitbox.png"
		itemsprite.framex = 1
		itemsprite.framey = 1
		itemsprite.totalframesx = 1
		itemsprite.totalframesy = 1

		itemsprite.rotation = position.r

		local px = collision.offx
		local py = collision.offy
		local r = position.r

		itemsprite.dest = Rect.new()
		itemsprite.dest.x = px*cos(r) - py*sin(r) + position.x
		itemsprite.dest.y = px*sin(r) + py*cos(r) + position.y
		itemsprite.dest.w = collision.w 
		itemsprite.dest.h = collision.h

		drawcontainer:add(di)
	end
end

return systems