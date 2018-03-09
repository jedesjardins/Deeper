local oldsystems = {

	-- CONTOLLERS --
	-- Players, AI, rigs

	ai = function(ecs, dt, input)
	end,

	controls = function(ecs, dt, input)
		entities = ecs:requireAll("control", "movement", "animate", "position", "state")

		for _, id in ipairs(entities) do
			local control = ecs.components.control[id]



			if input:getKeyState(control.freeze_controls) == KS.PRESSED then
				control.can_control = not control.can_control
			end

			-- use freeze controls for rigs/cut scenes/ etc
			if control.can_control then
				local position = ecs.components.position[id]
				local movement = ecs.components.movement[id]
				local anim = ecs.components.animate[id]
				local state = ecs.components.state[id]

				-- attack
				if input:getKeyState(control.attack) == KS.PRESSED then
					state.action = "attack"
				end

				-- interact
				if input:getKeyState(control.interact) == KS.PRESSED then
					print("interact")
				end

				-- update movement and check directions
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
				if movement.changed and movement.is_moving then
					movement.direction = directions[1]
				end

				-- if the direction changed or you start moving again
				if movement.changed 
				or movement.is_moving ~= was_moving then
					if movement.is_moving then
						-- start animation
						--TODO(James): add in state name to load asset
						anim.animate = true
						anim.time = ((1000.0 * anim.looptime) / anim.framesx)
					else if state.action ~= pastaction then
						anim.img = anim.img_name..movement.direction..state.action..".png"
					else
						-- stop animation
						anim.animate = false
						anim.frame = 1
						anim.time = 0
					end end 
				end
			end
		end
	end,

	lockto = function(ecs, dt, input)
		local entities = ecs:requireAll("lockto", "position")

		for _, id in ipairs(entities) do
			local position = ecs.components.position[id]
			local lockto = ecs.components.lockto[id]

			-- lock position
			local targetpos = ecs.components.position[lockto.id]
			if targetpos then
				position.x = targetpos.x
				position.y = targetpos.y
			end

			-- calulate rotation
			local targetmov = ecs.components.movement[lockto.id]
			local targetstate = ecs.components.state[lockto.id]
			if targetmov then
				if targetmov.direction == "up" then
					position.rotation = 90
					position.y = position.y + lockto.offx
				else if targetmov.direction == "left" then 
					position.rotation = 180
					position.x = position.x - lockto.offx
				else if targetmov.direction == "down" then 
					position.rotation = 270
					position.y = position.y - lockto.offx
				else 
					position.rotation = 0
					position.x = position.x + lockto.offx
				end end end

				-- calculate hand pos
				local targetanim = ecs.components.animate[lockto.id]
				local targethand = ecs.components.handloc[lockto.id]
				if targetanim then
					local frame = targetanim.frame
					position.x = position.x + targethand[targetmov.direction..targetstate.action][frame][1]
					position.y = position.y + targethand[targetmov.direction..targetstate.action][frame][2]
				end
			end
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

	attack = function(ecs, dt, input)
		entities = ecs:requireAll("position", "state", "movement")
		
		for _, id in ipairs(entities) do
			local state = ecs.components.state[id]
			if state.action == "attack" and state.start then
				local position = ecs.components.position[id]
				local movement = ecs.components.movement[id]
				local collision = ecs.components.collision[id] or {offx = 0, offy = 0, w = 1, h = 1}

				local hitx, hity, hitw, hith = 0, 0, 1, 1

				if movement.direction == "up" then
					hitx = position.x
					hity = position.y + hith/2 + collision.h/2 + collision.offy/2
				else if movement.direction == "down" then
					hitx = position.x
					hity = position.y - hith/2 - collision.h/2 + collision.offy/2
				else if movement.direction == "left" then
					hitx = position.x - hitw/2 - collision.w/2 + collision.offx/2
					hity = position.y
				else if movement.direction == "right" then
					hitx = position.x + hitw/2 + collision.w/2 + collision.offx/2
					hity = position.y
				end end end end



				local hid = ecs:addEntityFromTable({
						hitbox = {
							parent = id,
							x = hitx,
							y = hity,
							w = 1,
							h = 1,
							lifetime = 1000
						},
						animate = {
							img_name = "guy_",
							img = "guy_down.png",
							frame = 1,
							frames = 4,
							animate = false,
							looptime = 1,
							defaulttime = 1
						},
						position = {
							x = hitx, y = hity,
							sx = 1, sy = 1,
							rotation = 0
						},
						collision = {
							offx = 0,
							offy = 0,
							w = 1,
							h = 1
						}	
					})
			end
			state.start = false
		end
	end,

	hitbox = function(ecs, dt, input)
		local hitboxs = ecs:requireAll("hitbox")
		local entities = ecs:requireAll("position", "collision")
		local delete = {}

		for _, hid in ipairs(hitboxs) do
			local hitbox = ecs.components.hitbox[hid]
			local hrect = Rect.new()
			hrect.x = hitbox.x
			hrect.y = hitbox.y
			hrect.w = hitbox.w
			hrect.h = hitbox.h

			for _, eid in ipairs(entities) do
				if eid ~= hitbox.parent and eid ~= hid then

					local pos_id = ecs.components.position[eid]
					local col_id = ecs.components.collision[eid]
					local crect = Rect.new()

					crect.x = pos_id.x	+ col_id.offx/2
					crect.y = pos_id.y + col_id.offy/2
					crect.w = col_id.w
					crect.h = col_id.h

					if hrect:collide(crect) then
						print(hid, "collides with", eid)
					end
				end
			end

			hitbox.lifetime = hitbox.lifetime - dt
			if hitbox.lifetime < 0 then
				table.insert(delete, hid)
			end
		end

		for _, id in pairs(delete) do
			ecs:removeEntity(id)
		end
	end,

	collisions = function(ecs, dt, input)
		local entities = ecs:requireAll("position", "collision")

		local r1, r2 = Rect.new(), Rect.new()

		local collision_pairs = {}

		for i = 1, 4 do
		for _, id in ipairs(entities) do
			local pos_id = ecs.components.position[id]
			local col_id = ecs.components.collision[id]

			r1.x = pos_id.x	+ col_id.offx/2
			r1.y = pos_id.y + col_id.offy/2
			r1.w = col_id.w
			r1.h = col_id.h

			for _, id2 in ipairs(entities) do
				if id ~= id2 then
					local pos_id2 = ecs.components.position[id2]
					local col_id2 = ecs.components.collision[id2]

					r2.x = pos_id2.x + col_id2.offx/2
					r2.y = pos_id2.y + col_id2.offy/2
					r2.w = col_id2.w
					r2.h = col_id2.h

					if r1:collide(r2) then

						local mov_id = ecs.components.movement[id]
						local mov_id2 = ecs.components.movement[id2]

						local p1, p2 = Point.new(), Point.new()

						-- if id and id2 moved
						if mov_id and mov_id2 and mov_id.is_moving and mov_id2.is_moving then
							r1:resolveBoth(r2, p1, p2)

							pos_id.x, pos_id.y = p1.x - col_id.offx/2, p1.y - col_id.offy/2
							pos_id2.x, pos_id2.y = p2.x - col_id2.offx/2, p2.y - col_id2.offy/2

						-- id moved
						else if mov_id and mov_id.is_moving then
							r1:resolve(r2, p1)

							-- pos_id.x, pos_id.y = p1.x, p1.y
							pos_id.x, pos_id.y = p1.x - col_id.offx/2, p1.y - col_id.offy/2

						-- id2 moved
						else if mov_id2 and mov_id2.is_moving then
							r2:resolve(r1, p2)

							-- pos_id2.x, pos_id2.y = p2.x, p2.y
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

	updateAnimations = function(ecs, dt, input)
		local animcomps = ecs.components["animate"]

		for i, anim in pairs(animcomps) do
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

		local entities = ecs:requireAll("animate", "position")
		local drawItems = {}

		for _, id in ipairs(entities) do
			local dest = Rect.new()
			local di = DrawItem.new()

			dest.x, dest.y = ecs.components["position"][id]["x"], ecs.components["position"][id]["y"]
			dest.w, dest.h = ecs.components["position"][id]["sx"], ecs.components["position"][id]["sy"]

			di.texturename = ecs.components["animate"][id]["img"]
			di.frame = ecs.components["animate"][id]["frame"]
			di.frames = ecs.components["animate"][id]["frames"]
			di.destrect = dest

			local z = 0
			if ecs.components.position[id].rotation % 180 == 0 then
				z = dest.y - dest.w/2;
			else
				z = dest.y - dest.h/2;
			end

			table.insert(drawItems, {z, di})
			--drawcontainer:add(di)
		end

		local sortfunc = function (a, b) return a[1] > b[1] end
	
		table.sort(drawItems, sortfunc)

		for i, v in ipairs(drawItems) do
			drawcontainer:add(v[2])
		end
	end,

	drawWithCollisions = function(ecs, drawcontainer)

		local entities = ecs:requireAll("animate", "position")
		local drawItems = {}

		for _, id in ipairs(entities) do
			local dest = Rect.new()
			local col = Rect.new()
			local di = DrawItem.new()

			dest.x, dest.y = ecs.components.position[id].x, ecs.components.position[id].y
			dest.w, dest.h = ecs.components.position[id].sx, ecs.components.position[id].sy
			if ecs.components.collision[id] then
				col.x = ecs.components.position[id].x + ecs.components.collision[id].offx/2
				col.y = ecs.components.position[id].y + ecs.components.collision[id].offy/2
				col.w, col.h = ecs.components.collision[id].w, ecs.components.collision[id].h
			end

			di.texturename = ecs.components.animate[id].img
			di.frame = ecs.components.animate[id].frame
			di.frames = ecs.components.animate[id].frames
			di.destrect = dest
			di.colrect = col

			di.rotation = ecs.components.position[id].rotation or 0

			local z = 0
			if ecs.components.position[id].rotation % 180 == 0 and ecs.components.lockto[id] then
				z = dest.y - dest.w/2 + ecs.components.lockto[id].offx - 2/16;
			else
				z = dest.y - dest.h/2;
			end

			table.insert(drawItems, {z, di})
			--drawcontainer:add(di)
		end

		local sortfunc = function (a, b) return a[1] > b[1] end
	
		table.sort(drawItems, sortfunc)

		for i, v in ipairs(drawItems) do
			drawcontainer:add(v[2])
		end
	end

}

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
						local name = ecs.components.name[item_id]

						local hit_id = 0
						if name then
							hit_id = ecs:addEntity(name.."_hitbox", {id, state.actions[state.action].length})
						else
							hit_id = ecs:addEntity("punch_hitbox", {id, state.actions[state.action].length})
						end

						if movement.direction == "up" or movement.direction == "down" then
							local collision = ecs.components.collision[hit_id]

							local w, h = collision.w, collision.h
							collision.w, collision.h = h, w
						end
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
		entities = ecs:requireAll("position", "movement")

		for _, id in ipairs(entities) do
			local pos = ecs.components.position[id]
			local movement = ecs.components.movement[id]
			pos.x = pos.x + movement.dx
			pos.y = pos.y + movement.dy
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
		local entities = ecs:requireAllBut({"position", "collision"}, {"holdable", "hitbox"})

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
		local items = ecs:requireAll("holdable", "position", "collision")
		-- Add some kind of inventory check to entities? Should hitboxes to damage to items?
		local entities = ecs:requireAllBut({"position", "collision"}, {"hitbox"}) 

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
							ecs.components.p_position[id] = ecs.components.position[id]
							ecs.components.position[id] = nil
							ecs.components.hand[id2].held_id = id
						else if  ecs.components.holdable[id2] then
							r1:resolveBoth(r2, p1, p2)

							pos_id.x, pos_id.y = p1.x - col_id.offx/2, p1.y - col_id.offy/2
							pos_id2.x, pos_id2.y = p2.x - col_id2.offx/2, p2.y - col_id2.offy/2
						else
							r1:resolve(r2, p1)

							pos_id.x, pos_id.y = p1.x - col_id.offx/2, p1.y - col_id.offy/2
						end end
						

						break
					end
				end
			end
		end
	end,

	updateHitboxCollisions = function(ecs, dt, input)
		local hitboxes = ecs:requireAll("hitbox", "position", "collision")
		-- hitboxes can't hit other hitboxes
		local entities = ecs:requireAllBut({"position", "collision"}, {"hitbox"})

		local r1, r2 = Rect.new(), Rect.new()
		local pos_id, pos_id2 = 0, 0
		local col_id, col_id2 = 0, 0

		for _, id in ipairs(hitboxes) do
			pos_id = ecs.components.position[id]
			col_id = ecs.components.collision[id]
			hit_id = ecs.components.hitbox[id]

			r1.x = pos_id.x	+ col_id.offx/2
			r1.y = pos_id.y + col_id.offy/2
			r1.w = col_id.w
			r1.h = col_id.h

			for _, id2 in ipairs(entities) do
				if id ~= id2 and hit_id.ignore_id ~= id2 then
					pos_id2 = ecs.components.position[id2]
					col_id2 = ecs.components.collision[id2]
					mov_id2 = ecs.components.movement[id2]
					eff_id2 = ecs.components.effects[id2]

					r2.x = pos_id2.x + col_id2.offx/2
					r2.y = pos_id2.y + col_id2.offy/2
					r2.w = col_id2.w
					r2.h = col_id2.h

					if r1:collide(r2) then
						print(id, "hit", id2)

						-- apply status effects
						if eff_id2 then
							for effect, info in pairs(hit_id.effects) do
								eff_id2[effect] = {info.duration, info.strength}
							end
						end

						for damagetype, amount in pairs(hit_id.damage) do 
							local comp = ecs.components[damagetype]
							if comp then
								comp.amount = comp.amount - amount
							end
						end

					end
				end
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

			local di = DrawItem.new()
			di.type = 2
			local dis = di.data.sprite

			dis.dest.x, dis.dest.y = position.x, position.y
			dis.dest.w, dis.dest.h = position.w, position.h

			dis.texturename = sprite.img
			dis.framex = sprite.framex
			dis.framey = sprite.framey
			dis.totalframesx = sprite.framesx
			dis.totalframesy = sprite.framesy
			dis.rotation = 0

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

				local di = DrawItem.new()
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

			local di = DrawItem.new()
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