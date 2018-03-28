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
			Toss Item
		]]
		if input:getKeyState("R") == KS.PRESSED then
			local item_id = ecs.components.hand[id].item
			ecs.components.hand[id].item = nil

			if item_id then
				ecs.components.collision[item_id] = ecs.components.p_collision[item_id]	-- restore collision
				ecs.components.held[item_id] = nil

				local x, y = 0, 0

				if state.direction == "down" then
					y = -6
					ecs.components.position[item_id].y = ecs.components.position[item_id].y - 1
				else if state.direction == "up" then
					y = 6
					ecs.components.position[item_id].y = ecs.components.position[item_id].y + 1
				else if state.direction == "right" then
					x = 6
					ecs.components.position[item_id].x = ecs.components.position[item_id].x + 1
				else if state.direction == "left" then
					x = -6
					ecs.components.position[item_id].x = ecs.components.position[item_id].x - 1
				end end end end

				ecs.components.movement[item_id] = {
														dx = 0, dy = 0,	-- instantaneous movement controls in tiles/second
														mx = x, my = y,	-- momentum in tiles/second
														friction = 16, -- in tiles / second^2
														is_moving = false
													}
			end
		end

		--[[
			Add Momentum
		]]
		if input:getKeyState("T") == KS.PRESSED then
			if state.direction == "down" then movement.my = -10
			else if state.direction == "up" then movement.my = 10
			else if state.direction == "right" then movement.mx = 10
			else if state.direction == "left" then movement.mx = -10
			end end end end
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
			State stuff
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
			table.insert(state.action_queue, "attack")
		end
	end
end

function systems.updatePosition(ecs, dt, input)
	local entities = ecs:requireAll("movement", "position")

	for _, id in ipairs(entities) do
		--TODO: Remove this if to allow movement
		--if (ecs.components.hand[id] and ecs.components.hand[id].item == nil) or not ecs.components.hand[id] then
		local pos = ecs.components.position[id]
		local movement = ecs.components.movement[id]
		pos.x = pos.x + movement.dx + movement.mx*dt/1000
		pos.y = pos.y + movement.dy + movement.my*dt/1000
		pos.z = pos.y - pos.h/2

		local nx = math.abs(movement.mx)-(movement.friction*dt/1000)
		local ny = math.abs(movement.my)-(movement.friction*dt/1000)

		movement.mx = nx > 0 and nx*math.sign(movement.mx) or 0
		movement.my = ny > 0 and ny*math.sign(movement.my) or 0
		--end
	end	
end

function systems.updateLock(ecs, dt, input)
	local entities = ecs:requireAll("lock", "position")

	for _, id in ipairs(entities) do
		local lock = ecs.components.lock[id]
		local position = ecs.components.position[id]

		local target = ecs.components.position[lock.id]

		position.x = target.x
		position.y = target.y
	end
end

function systems.updateHeldItem(ecs, dt, input)
	local entities = ecs:requireAll("hand", "position", "state")

	for _, id in ipairs(entities) do
		hand = ecs.components.hand[id]
		if hand.item then
			local position = ecs.components.position[id]
			local state = ecs.components.state[id]
			local item_position = ecs.components.position[hand.item]
			local item_holdable = ecs.components.holdable[hand.item]

			local framey = false

			if not item_holdable then item_holdable = {offx = 0, offy = 0} end

			if state.direction == "down" then
				framey = 1
				item_position.r = 270
				item_position.z = position.z - 1/16
			else if state.direction == "up" then
				framey = 2
				item_position.r = 90
				item_position.z = position.z + 1/16
			else if state.direction == "right" then
				framey = 3
				item_position.r = 0
				item_position.z = position.z - 1/16
			else if state.direction == "left" then
				framey = 4
				item_position.r = 180
				item_position.z = position.z + 1/16
			end end end end

			-- rotate item
			local duration = state.action.duration
			local percent = (state.time%duration)/duration
			local frameindex = math.floor(percent * #state.action.frames) + 1

			item_position.r = item_position.r + state.action.angles[frameindex]

			-- rotate around hold point
			local offx, offy = item_holdable.offx, item_holdable.offy
			local r = item_position.r

			local rot_offx = (offx * cos(r) - offy * sin(r))
			local rot_offy = (offx * sin(r) + offy * cos(r))


			local framex = state.action.frames[frameindex]

			local hand_off_x = hand_positions["man"][framey][framex][1]
			local hand_off_y = hand_positions["man"][framey][framex][2]

			item_position.x = position.x + hand_off_x - rot_offx
			item_position.y = position.y + hand_off_y - rot_offy

			if state.action.hitboxs[frameindex] and item_holdable then
				ecs.components.collision[hand.item] = item_holdable.collision
			else
				ecs.components.collision[hand.item] = nil
			end
		end
	end
end

function systems.updateCollision(ecs, dt, input)
	local entities = ecs:requireAll("position", "collision")

	for _, id in ipairs(entities) do
		local pos = ecs.components.position[id]
		local col = ecs.components.collision[id]
		local mov = ecs.components.movement[id]
		local group = ecs.components.group[id]
		local hand = ecs.components.hand[id]
		
		if group ~= "item" and col ~= nil then 
			local p1 = collision.getPointsAround(
				{x = pos.x+col.offx, y = pos.y+col.offy, w = col.w, h = col.h, r = pos.r}, 
				{x = pos.x, y = pos.y}
			)

			for _, id2 in ipairs(entities) do
				if id ~= id2 and ecs.components.held[id2] ~= id then
					local pos2 = ecs.components.position[id2]
					local col2 = ecs.components.collision[id2]
					local mov2 = ecs.components.movement[id2]
					local group2 = ecs.components.group[id2]

					if col2 ~= nil then
						local p2 = collision.getPointsAround(
								{x = pos2.x+col2.offx, y = pos2.y+col2.offy, w = col2.w, h = col2.h, r = pos2.r}, 
								{x = pos2.x, y = pos2.y}
							)

						local does_collide, correction_vect = collision.collide(p1, p2)

						if does_collide then
							local mov2 = ecs.components.movement[id2]

							-- if theres hitboxes, apply the damage back and forth
							--TODO(JAMES): Do hitbox stuff here
							if ecs.components.hitbox[id] and not ecs.components.hitbox[id].hit_ids[id2] then
								ecs.components.hitbox[id].hit_ids[id2] = true
								print(id, "effects", id2)
							end

							if ecs.components.hitbox[id2] and not ecs.components.hitbox[id2].hit_ids[id] then
								ecs.components.hitbox[id2].hit_ids[id] = true
								print(id2, "effects", id)
							end

							if group2 == "item" then
								-- try to pickup item
								if hand and not ecs.components.held[id2] then
									ecs.components.p_collision[id2] = col2
									ecs.components.collision[id2] = nil
									ecs.components.held[id2] = id
									hand.item = id2

									if ecs.components.holdable[id2] then
										ecs.components.hitbox[id2] = ecs.components.holdable[id2].hitbox
									end
								end

								if mov2 then
									-- projectiles are pushed around, should they lock on?
									pos2.x = pos2.x - (correction_vect.x)
									pos2.y = pos2.y - (correction_vect.y)
									mov2.mx = 0
									mov2.my = 0

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
end

function systems.updateState(ecs, dt, input)
	local entities = ecs:requireAll("state")

	for _, id in ipairs(entities) do
		local state = ecs.components.state[id]

		-- set the starting state
		if not state.action then
			state.action_name = "stand"
			state.action = state.actions[state.action_name]
			state.action.duration = (hold and hold.actions[state.action_name] and hold.actions[state.action_name].duration) 
						or state.actions[state.action_name].base_duration
		end

		
		-- held item action info
		local hold = ecs.components.hand[id] 
					and ecs.components.hand[id].item
					and ecs.components.holdable[ecs.components.hand[id].item]

		state.time = state.time + dt/1000
		-- end action, start next
		if state.time > state.action.duration then
			state.action_name = state.action.next_action or state.action.stop
			state.action.next_action = nil
			state.action = state.actions[state.action_name]
			state.action.duration = (hold and hold.actions[state.action_name] and hold.actions[state.action_name].duration) 
						or state.actions[state.action_name].base_duration
			-- reset hitbox
			if hold then
				ecs.components.hitbox[ecs.components.hand[id].item].hit_ids = {}
			end

			state.time = 0
		end

		--set new actions
		for _, action_name in ipairs(state.action_queue) do
			if hold 
			   and hold.actions[state.action_name] 
			   and hold.actions[state.action_name].combos[action_name] then

				state.action.next_action = hold.actions[state.action_name].combos[action_name]
											   or state.action.next_action
											   or action_name

			-- no held item, combos
			else if state.action.combos then
				state.action.next_action = state.action.combos[action_name] or state.action.next_action
			end end

			if state.action.interruptable and state.action_name ~= action_name then
				state.action_name = action_name
				state.action = state.actions[action_name]
				state.action.duration = (hold and hold.actions[state.action_name] and hold.actions[state.action_name].duration) 
						or state.actions[state.action_name].base_duration

				-- reset hitbox
				if hold then
					ecs.components.hitbox[ecs.components.hand[id].item].hit_ids = {}
				end
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

		if not position.z then position.z = position.y - position.h/2 end

		table.insert(drawItems, {position.z, di})
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