local systems = {
	updatePosition = function(ecs, dt, input)
		local poscomps = ecs.components["position"]

		for i, pos in pairs(poscomps) do
			if input:getKeyState("W") == KS.HELD
				or input:getKeyState("W") == KS.PRESSED then
				pos.y = pos.y + math.floor(dt/2)
			end
			if input:getKeyState("S") == KS.HELD
				or input:getKeyState("S") == KS.PRESSED then
				pos.y = pos.y - math.floor(dt/2)
			end
			if input:getKeyState("A") == KS.HELD
				or input:getKeyState("A") == KS.PRESSED then
				pos.x = pos.x - math.floor(dt/2)
			end
			if input:getKeyState("D") == KS.HELD
				or input:getKeyState("D") == KS.PRESSED then
				pos.x = pos.x + math.floor(dt/2)
			end
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
	end
}

return systems