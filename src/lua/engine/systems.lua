local systems = {
	controlMovement = function(ecs, dt, input)
		entities = ecs:requireAll("control", "movement", "animate")

		for _, id in ipairs(entities) do
			local control = ecs.components.control[id]
			local movement = ecs.components.movement[id]
			local anim = ecs.components.animate[id]

			-- update movement and check directions
			movement.dx, movement.dy = 0, 0
			local directions = {}
			local was_moving = movement.is_moving

			if input:getKeyState("W") == KS.HELD
				or input:getKeyState("W") == KS.PRESSED then
				movement.dy = movement.dy + 4*dt/1000 --math.floor(4.0/(1000.0/dt))
				table.insert(directions, "up")
			end
			if input:getKeyState("S") == KS.HELD
				or input:getKeyState("S") == KS.PRESSED then
				movement.dy = movement.dy - 4*dt/1000
				table.insert(directions, "down")
			end
			if input:getKeyState("A") == KS.HELD
				or input:getKeyState("A") == KS.PRESSED then
				movement.dx = movement.dx - 4*dt/1000
				table.insert(directions, "left")
			end
			if input:getKeyState("D") == KS.HELD
				or input:getKeyState("D") == KS.PRESSED then
				movement.dx = movement.dx + 4*dt/1000
				table.insert(directions, "right")
			end

			if input:getKeyState("Space") == KS.PRESSED then
				print("Space")
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
			if movement.changed or movement.is_moving ~= was_moving then
				if movement.is_moving then
					-- start animation
					anim.img = anim.img_name..movement.direction..".png"
					anim.animate = true
					anim.frame = 2
					anim.time = ((1000.0 * anim.looptime) / anim.frames)
				else
					-- stop animation
					anim.animate = false
					anim.frame = 1
					anim.time = 0
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

	collisions = function(ecs, dt, input)
		entities = ecs:requireAll("position", "collision")

		local r1, r2 = Rect.new(), Rect.new()

		local collision_pairs = {}

		for _, id in ipairs(entities) do
			local pos_id = ecs.components.position[id]
			local col_id = ecs.components.collision[id]

			r1.x = pos_id.x	+ col_id.offx/2
			r1.y = pos_id.y + col_id.offy/2
			r1.w = col_id.w
			r1.h = col_id.h

			calculateCollisionOut(r1)

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
		
		for _, pair in ipairs(collision_pairs) do
			local pos1 = ecs.components.position[pair[1]]
			local pos2 = ecs.components.position[pair[2]]

			local col1 = ecs.components.collision[pair[1]]
			local col2 = ecs.components.collision[pair[2]]
			-- more
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

		local entities = ecs:requireAll("animate", "position", "size")
		local drawItems = {}

		for _, id in ipairs(entities) do
			local dest = Rect.new()
			local col = Rect.new()
			local di = DrawItem.new()

			dest.x, dest.y = ecs.components["position"][id]["x"], ecs.components["position"][id]["y"]
			dest.w, dest.h = ecs.components["size"][id]["w"], ecs.components["size"][id]["h"]
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