local systems = {
	updatePosition = function(ecs, dt, input)
		local poscomps = ecs.components["position"]

		for i, pos in pairs(ecs.components["position"]) do
			if input:getKeyState("W") == KS.HELD
				or input:getKeyState("W") == KS.PRESSED then
				pos.y = pos.y - math.floor(dt/2)
			end
			if input:getKeyState("S") == KS.HELD
				or input:getKeyState("S") == KS.PRESSED then
				pos.y = pos.y + math.floor(dt/2)
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

		for i, size in pairs(ecs.components["size"]) do
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
	end
}

return systems