local systems = {
	controlMovement = function(ecs, dt, input)
		entities = ecs:requireAll("control", "movement", "animate", "position", "state")

		for _, id in ipairs(entities) do
			local control = ecs.components.control[id]
			local position = ecs.components.position[id]
			local movement = ecs.components.movement[id]
			local anim = ecs.components.animate[id]
			local state = ecs.components.state[id]

			-- attack
			local pastaction = state.action
			if input:getKeyState(control.attack) == KS.PRESSED then
				state.action = "attack"
				state.start = true
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
			or movement.is_moving ~= was_moving 
			or state.action ~= pastaction then
				if movement.is_moving then
					-- start animation
					--TODO(James): add in state name to load asset
					anim.img = anim.img_name..movement.direction..state.action..".png"
					anim.animate = true
					anim.frame = 2
					anim.time = ((1000.0 * anim.looptime) / anim.frames)
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



				local hid = ecs:addEntity({
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
							sx = 1, sy = 1
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
					if not pos_id then print(eid) end
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

			local z = dest.y - dest.h/2;

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

		local entities = ecs:requireAll("animate", "position", "collision")
		local drawItems = {}

		for _, id in ipairs(entities) do
			local dest = Rect.new()
			local col = Rect.new()
			local di = DrawItem.new()

			dest.x, dest.y = ecs.components["position"][id]["x"], ecs.components["position"][id]["y"]
			dest.w, dest.h = ecs.components["position"][id]["sx"], ecs.components["position"][id]["sy"]
			col.x = ecs.components["position"][id]["x"] + ecs.components["collision"][id]["offx"]/2
			col.y = ecs.components["position"][id]["y"] + ecs.components["collision"][id]["offy"]/2
			col.w, col.h = ecs.components["collision"][id]["w"], ecs.components["collision"][id]["h"]

			di.texturename = ecs.components["animate"][id]["img"]
			di.frame = ecs.components["animate"][id]["frame"]
			di.frames = ecs.components["animate"][id]["frames"]
			di.destrect = dest
			di.colrect = col

			local z = dest.y - dest.h/2;

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

return systems