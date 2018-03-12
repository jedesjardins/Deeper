
local systems = {
	controlEntity = function(ecs, dt, input)
		local entities = ecs:requireAll("control", "movement", "sprite", "state")

		for _, id in pairs(entities) do
			local control = ecs.components.control[id]

			-- use can_control for rigs/cut scenes/ etc
			if control.can_control then
				local state = ecs.components.state[id]
				local movement = ecs.components.movement[id]
				local anim = ecs.components.sprite[id]


				if input:getKeyState(control.interact) == KS.PRESSED then
					print("interact")
					--Debug:writeln("Input", "Interact")
				end

				if input:getKeyState(control.attack) == KS.PRESSED then
					--Debug:writeln("Input", "Attack")
					if state.action ~= "attack" then
						state.action = "attack"
						state.time = 0

						-- create damage hitbox
						local item_id = ecs.components.hand[id].held_id -- held item id
						local hit_id = 0

						if item_id and ecs.components.holdable[item_id].hitbox_name then
							local hitbox_name = ecs.components.holdable[item_id].hitbox_name

							hit_id = ecs:addEntity(hitbox_name, {id, state.actions[state.action].length})
						else
							hit_id = ecs:addEntity("punch_hitbox", {id, state.actions[state.action].length})
						end

						if ecs.components.projectile[hit_id] then
							local x, y = ecs.components.position[id].x, ecs.components.position[id].y
							local dx, dy = 0, 0 

							if movement.direction == "up" then dy = 3/16 
							else if movement.direction == "down" then dy = -3/16
							else if movement.direction == "right" then dx = 3/16
							else if movement.direction == "left" then dx = -3/16
							end end end end

							ecs.components.position[hit_id].x = x
							ecs.components.position[hit_id].y = y

							ecs.components.movement[hit_id].dx = dx
							ecs.components.movement[hit_id].dy = dy

							if ecs.components.sprite[hit_id] then
								local sprite = ecs.components.sprite[hit_id]

								if movement.direction == "up" then 
									ecs.components.position[hit_id].rotation = 90
								else if movement.direction == "down" then 
									ecs.components.position[hit_id].rotation = 270
								else if movement.direction == "right" then 
									ecs.components.position[hit_id].rotation = 0
								else if movement.direction == "left" then 
									ecs.components.position[hit_id].rotation = 180
								end end end end
							end
						end

						if movement.direction == "up" or movement.direction == "down" then
							local collision = ecs.components.collision[hit_id]

							local w, h = collision.w, collision.h
							collision.w, collision.h = h, w
						end
					end
				end

				if input:getKeyState(control.drop) == KS.PRESSED then
					local item_id = ecs.components.hand[id].held_id
					if item_id then 

						--ecs:removeEntity(item_id)
						ecs.components.hand[id].held_id = nil
						--ecs.components.p_position[id] = ecs.components.position[id]
						ecs.components.position[item_id] = ecs.components.p_position[item_id]
						ecs.components.p_position[item_id] = nil

						local targetposition = ecs.components.position[id]
						local targetcollision = ecs.components.collision[id]
						local position = ecs.components.position[item_id]
						local collision = ecs.components.collision[item_id]

						if movement.direction == "up" then
							position.x = targetposition.x + targetcollision.offx/2
							position.y = targetposition.y + targetcollision.offy/2 + targetcollision.h/2 + collision.h/2 + .1
						else if movement.direction == "left" then
							position.x = targetposition.x + targetcollision.offx/2 - targetcollision.w/2 - collision.w/2 - .1
							position.y = targetposition.y + targetcollision.offy/2
						else if movement.direction == "down" then
							position.x = targetposition.x + targetcollision.offx/2
							position.y = targetposition.y + targetcollision.offy/2 - targetcollision.h/2 - collision.h/2 - .1
						else if movement.direction == "right" then
							position.x = targetposition.x + targetcollision.offx/2 + targetcollision.w/2 + collision.w/2 + .1
							position.y = targetposition.y + targetcollision.offy/2
						end end end end
						position.rotation = 0
						ecs.components.lockon[item_id] = nil
					end

				end

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

				-- check if direction changed
				movement.changed = true
				for _, direction in ipairs(directions) do
					if direction == movement.direction then
						movement.changed = false
						break
					end
				end

				-- change direction
				if movement.changed and movement.is_moving and state.action ~= "attack" then
					movement.direction = directions[1]
				end

				if movement.is_moving then
					anim.animate = true
					if not was_moving then anim.start = true end
				else
					anim.animate = false
					anim.time = 0
				end
			end
		end
	end,

	updatePosition = function(ecs, dt, input)
		local entities = ecs:requireAll("movement", "position")

		for _, id in ipairs(entities) do
			local pos = ecs.components.position[id]
			local movement = ecs.components.movement[id]
			pos.x = pos.x + movement.dx
			pos.y = pos.y + movement.dy
		end	
	end,

	updateDriftPosition = function(ecs, dt, input)
		local entities = ecs:requireAll("control", "position")
		local items = ecs:requireAll("holdable", "position")

		for _, iid in ipairs(items) do
			local item_position = ecs.components.position[iid]

			for _, cid in ipairs(entities) do 
				local entity_position = ecs.components.position[cid]

				if (item_position.x - entity_position.x)*(item_position.x - entity_position.x)
					+ (item_position.y - entity_position.y)*(item_position.y - entity_position.y) < 
					3 * 3 
				then
				end
			end
		end
	end,

	updateLockPosition = function(ecs, dt, input)
		local entities = ecs:requireAll("lockon", "position")

		for _, id in ipairs(entities) do
			local position = ecs.components.position[id]
			local lockon = ecs.components.lockon[id]
			local lock_id = lockon.lock_id
			local targetposition = ecs.components.position[lock_id]
			local targetcollision = ecs.components.collision[lock_id]
			local targetmov = ecs.components.movement[lock_id]

			if targetmov.direction == "up" then
				position.rotation = 90
				position.x = targetposition.x + targetcollision.offx/2
				position.y = targetposition.y + targetcollision.offy/2 + targetcollision.h/2 + lockon.offx
			else if targetmov.direction == "left" then 
				position.rotation = 180
				position.x = targetposition.x + targetcollision.offx/2 - targetcollision.w/2 - lockon.offx
				position.y = targetposition.y + targetcollision.offy/2 + lockon.offy
			else if targetmov.direction == "down" then 
				position.rotation = 270
				position.x = targetposition.x + targetcollision.offx/2
				position.y = targetposition.y + targetcollision.offy/2 - targetcollision.h/2 - lockon.offx
			else if targetmov.direction == "right" then
				position.rotation = 0
				position.x = targetposition.x + targetcollision.offx/2 + targetcollision.w/2 + lockon.offx
				position.y = targetposition.y + targetcollision.offy/2 + lockon.offy
			end end end end

		end
	end,

	updateAttack = function(ecs, dt, input)
		entities = ecs:requireAll("state")

		for _, id in ipairs(entities) do
			local state = ecs.components.state[id]

			state.time = state.time + dt
			if state.time > state.actions[state.action].length * 1000 then

				state.action = state.actions[state.action].end_transition
				state.time = 0
			end
		end
	end,

	updateMovementCollisions = function(ecs, dt, input)
		-- handle colliding entities that aren't items or hitboxes
		local entities = ecs:requireAllBut({"position", "collision"}, {"holdable", "hitbox", "projectile"})

		-- initialize locals only once
		local r1, r2 = Rect.new(), Rect.new()
		local p1, p2 = Point.new(), Point.new()
		local pos_id, pos_id2 = 0, 0
		local col_id, col_id2 = 0, 0
		local mov_id, mov_id2 = 0, 0

		for i = 1, 4 do
		for _, id in ipairs(entities) do
			pos_id = ecs.components.position[id]
			col_id = ecs.components.collision[id]
			mov_id = ecs.components.movement[id]

			r1.x = pos_id.x	+ col_id.offx/2
			r1.y = pos_id.y + col_id.offy/2
			r1.w = col_id.w
			r1.h = col_id.h

			for _, id2 in ipairs(entities) do
				if id ~= id2 then
					pos_id2 = ecs.components.position[id2]
					col_id2 = ecs.components.collision[id2]
					mov_id2 = ecs.components.movement[id2]

					r2.x = pos_id2.x + col_id2.offx/2
					r2.y = pos_id2.y + col_id2.offy/2
					r2.w = col_id2.w
					r2.h = col_id2.h

					if r1:collide(r2) then
						print(id, "collides with", id2)

						-- if id and id2 moved
						if mov_id and mov_id2 and mov_id.is_moving and mov_id2.is_moving then
							r1:resolveBoth(r2, p1, p2)

							pos_id.x, pos_id.y = p1.x - col_id.offx/2, p1.y - col_id.offy/2
							pos_id2.x, pos_id2.y = p2.x - col_id2.offx/2, p2.y - col_id2.offy/2

						-- id moved
						else if mov_id and mov_id.is_moving then
							r1:resolve(r2, p1)

							pos_id.x, pos_id.y = p1.x - col_id.offx/2, p1.y - col_id.offy/2

						-- id2 moved
						else if mov_id2 and mov_id2.is_moving then
							r2:resolve(r1, p2)

							pos_id2.x, pos_id2.y = p2.x - col_id2.offx/2, p2.y - col_id2.offy/2
						else
							r1:resolveBoth(r2, p1, p2)

							pos_id.x, pos_id.y = p1.x - col_id.offx/2, p1.y - col_id.offy/2
							pos_id2.x, pos_id2.y = p2.x - col_id2.offx/2, p2.y - col_id2.offy/2
							
						end end end
					end
				end
			end
		end
		end	
	end,

	updateItemCollisions = function(ecs, dt, input)
		local items = ecs:requireAllBut({"holdable", "position", "collision"}, {"projectile"})
		-- Add some kind of inventory check to entities? Should hitboxes to damage to items?
		local entities = ecs:requireAllBut({"position", "collision"}, {"hitbox", "holdable", "projectile"}) 

		local r1, r2 = Rect.new(), Rect.new()
		local p1, p2 = Point.new(), Point.new()
		local pos_id, pos_id2 = 0, 0
		local col_id, col_id2 = 0, 0

		for _, id in ipairs(items) do
			pos_id = ecs.components.position[id]
			col_id = ecs.components.collision[id]

			r1.x = pos_id.x	+ col_id.offx/2
			r1.y = pos_id.y + col_id.offy/2
			r1.w = col_id.w
			r1.h = col_id.h

			for _, id2 in ipairs(entities) do
				if id ~= id2 then
					pos_id2 = ecs.components.position[id2]
					col_id2 = ecs.components.collision[id2]

					r2.x = pos_id2.x + col_id2.offx/2
					r2.y = pos_id2.y + col_id2.offy/2
					r2.w = col_id2.w
					r2.h = col_id2.h

					if r1:collide(r2) then

						if ecs.components.hand[id2] then
							if not ecs.components.hand[id2].held_id then
								ecs.components.p_position[id] = ecs.components.position[id]
								ecs.components.position[id] = nil
								ecs.components.hand[id2].held_id = id
								-- keep held item alive
								if ecs.components.lifetime[id] then 
									ecs.components.lifetime[id].time = inf

								end
								break
							end
						-- this never evaluates to true, items never collide
						else if  ecs.components.holdable[id2] then
							r1:resolveBoth(r2, p1, p2)

							pos_id.x, pos_id.y = p1.x - col_id.offx/2, p1.y - col_id.offy/2
							pos_id2.x, pos_id2.y = p2.x - col_id2.offx/2, p2.y - col_id2.offy/2

						-- items shouldn't overlap other things (that aren't items)
						else
							r1:resolve(r2, p1)

							pos_id.x, pos_id.y = p1.x - col_id.offx/2, p1.y - col_id.offy/2
						end end
					end
				end
			end
		end
	end,

	updateHitboxCollisions = function(ecs, dt, input)
		-- this includes projectiles as just moving hitboxes
		local hitboxes = ecs:requireAll("hitbox", "position", "collision")
		-- hitboxes can't hit other hitboxes
		local entities = ecs:requireAllBut({"position", "collision"}, {"hitbox", "holdable"})

		local r1, r2 = Rect.new(), Rect.new()
		local pos_id, pos_id2 = 0, 0
		local col_id, col_id2 = 0, 0

		for _, id in ipairs(hitboxes) do
			pos_id = ecs.components.position[id]
			col_id = ecs.components.collision[id]
			hit_id = ecs.components.hitbox[id]
			proj_id = ecs.components.projectile[id]

			r1.x = pos_id.x	+ col_id.offx/2
			r1.y = pos_id.y + col_id.offy/2
			r1.w = col_id.w
			r1.h = col_id.h

			for _, id2 in ipairs(entities) do
				if id ~= id2 and hit_id.ignore_id ~= id2 and not hit_id.ignore_hit_ids[id2] then
					pos_id2 = ecs.components.position[id2]
					col_id2 = ecs.components.collision[id2]
					eff_id2 = ecs.components.effects[id2]

					r2.x = pos_id2.x + col_id2.offx/2
					r2.y = pos_id2.y + col_id2.offy/2
					r2.w = col_id2.w
					r2.h = col_id2.h

					if r1:collide(r2) then
						print(id, "hit", id2)
						hit_id.ignore_hit_ids[id2] = true

						-- apply status effects
						if eff_id2 then
							for effect, info in pairs(hit_id.effects) do
								eff_id2[effect] = {info.duration, info.strength}
							end
						end

						-- apply damage
						for damagetype, amount in pairs(hit_id.damage) do 
							local comp = ecs.components[damagetype][id2]
							local class_modifier = ecs.components.modifier[id2].class[hit_id.class]
							local damage_modifier = ecs.components.modifier[id2].damage[damagetype]

							local modified_amount = amount + -1 * amount * ((class_modifier or 0) + (damage_modifier or 0))

							if comp then
								-- amounts are expressed in negatives for damage
								comp.amount = ((comp.amount + modified_amount) < 0 and 0) or 
											  ((comp.amount + modified_amount) > comp.max and comp.max) or 
											  (comp.amount + modified_amount)
							end
						end

						-- handle projectile collision
						if proj_id then
							if proj_id.delete_on_collision then
								ecs:removeEntity(id)
							else if proj_id.stop_on_collision then
								-- turn it into an item if it's holdable
								ecs.components.projectile[id] = nil
								ecs.components.movement[id] = nil 
								ecs.components.hitbox[id] = nil
								ecs.components.lifetime[id].time = 1
							end end
						end
						break

					end
				end
			end
		end
	end,

	updateHealth = function(ecs, dt, input)
		local entities = ecs:requireAll("health")

		for _, id in ipairs(entities) do
			local health = ecs.components.health[id]

			if health.amount <= 0 and health.amount ~= -1*inf then
				ecs.components.lifetime[id] = {time = -1*inf}
			end
		end
	end,

	updateLifetime = function(ecs, dt, input)
		local entities = ecs:requireAll("lifetime")

		for _, id in pairs(entities) do
			local lifetime = ecs.components.lifetime[id]

			lifetime.time = lifetime.time - dt/1000
			if lifetime.time <= 0 then
				ecs:removeEntity(id)
			end
		end
	end,

	updateSprite = function(ecs, dt, input)

		local entities = ecs:requireAll("sprite", "movement", "state")

		for _, id in ipairs(entities) do
			local anim = ecs.components.sprite[id]
			local move = ecs.components.movement[id]
			local state = ecs.components.state[id]

			-- animate
			if anim.animate then
				anim.time = (anim.time or 0) + dt

				local loopframes = anim.framesx / anim.actionToFrameX.max

				-- start of an animation, move forward a frame to be more snappy
				if anim.start then
					anim.time = anim.time + ((1000.0 * anim.looptime) / loopframes)
					anim.start = false
				end

				-- move to the next frame
				if anim.time > ((1000.0 * anim.looptime * ((anim.framex-1)%loopframes + 1)) / loopframes) then
					anim.framex = anim.framex + 1
					anim.time = anim.time % (1000.0 * anim.looptime)
				end

				-- set the frame
				local start_frame = math.floor(((anim.actionToFrameX[state.action] - 1) * loopframes) + 1)
				anim.framex = math.floor(start_frame + (anim.framex - 1) % loopframes)
				anim.framey = anim.directionToFrameY[move.direction]

			-- don't animate lol (so this code doesn't have to be in controls)
			else
				local loopframes = anim.framesx / anim.actionToFrameX.max

				anim.framex = math.floor(((anim.actionToFrameX[state.action] - 1) * loopframes) + 1)
				anim.framey = anim.directionToFrameY[move.direction]
			end
		end
	end,

	drawSprite = function(ecs, drawcontainer)
		local entities = ecs:requireAll("sprite", "position")
		local drawItems = {}

		for _, id in ipairs(entities) do
			local position = ecs.components.position[id]
			local sprite = ecs.components.sprite[id]

			local di = DrawItem.new(2)
			di.type = 2
			local dis = di.data.sprite

			dis.dest.x, dis.dest.y = position.x, position.y
			dis.dest.w, dis.dest.h = position.w, position.h

			dis.texturename = sprite.img
			dis.framex = sprite.framex
			dis.framey = sprite.framey
			dis.totalframesx = sprite.framesx
			dis.totalframesy = sprite.framesy
			dis.rotation = position.rotation or 0

			position.z = dis.dest.y - position.h/2

			table.insert(drawItems, {position.z, di})
		end

		local hentities = ecs:requireAll("hand", "sprite", "position", "movement")

		for _, id in ipairs(hentities) do
			local position = ecs.components.position[id]
			local movement = ecs.components.movement[id]
			local hand = ecs.components.hand[id]

			if hand.held_id then
				local sprite = ecs.components.sprite[hand.held_id]
				local p_pos = ecs.components.p_position[hand.held_id]
				local holdable = ecs.components.holdable[hand.held_id]

				local di = DrawItem.new(2)
				di.type = 2
				local dis = di.data.sprite
		
				local z = 0
				local hand_offx = hand.handloc[ecs.components.sprite[id].framey][ecs.components.sprite[id].framex][1]
				local hand_offy = hand.handloc[ecs.components.sprite[id].framey][ecs.components.sprite[id].framex][2]

				if movement.direction == "right" then
					dis.rotation = 0
					dis.dest.x = position.x + hand_offx - holdable.offx
					dis.dest.y = position.y + hand_offy - holdable.offy
					z = position.z - .1

				else if movement.direction == "up" then
					dis.rotation = 90
					dis.dest.x = position.x + hand_offx - holdable.offy
					dis.dest.y = position.y + hand_offy - holdable.offx
					z = position.z + .1

				else if movement.direction == "left" then
					dis.rotation = 180
					dis.dest.x = position.x + hand_offx + holdable.offx
					dis.dest.y = position.y + hand_offy - holdable.offy

					z = position.z + .1

				else if movement.direction == "down" then
					dis.rotation = 270
					dis.dest.x = position.x + hand_offx - holdable.offy
					dis.dest.y = position.y + hand_offy + holdable.offx

					z = position.z - .1

				end end end end

				
				dis.dest.w, dis.dest.h = p_pos.w, p_pos.h
				dis.framex = sprite.framex
				dis.framey = sprite.framey
				dis.texturename = sprite.img
				dis.totalframesx = sprite.framesx
				dis.totalframesy = sprite.framesy

				table.insert(drawItems, {z, di})

			end
		end

		local sortfunc = function (a, b) return a[1] > b[1] end
	
		table.sort(drawItems, sortfunc)

		for i, v in ipairs(drawItems) do
			drawcontainer:add(v[2])
		end
	end,

	drawHitboxes = function(ecs, drawcontainer)
		local entities = ecs:requireAll("collision", "position")

		for _, id in ipairs(entities) do
			local position = ecs.components.position[id]
			local collision = ecs.components.collision[id]

			local di = DrawItem.new(1)
			di.type = 1
			local dest = di.data.rect

			dest.x = position.x + collision.offx/2
			dest.y = position.y + collision.offy/2
			dest.w = collision.w
			dest.h = collision.h

			drawcontainer:add(di)
		end
	end
}

return systems