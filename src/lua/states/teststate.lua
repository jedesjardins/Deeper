local state = STATE.new()

local systems = require(LUA_FOLDER .. 'data.systems')
local entities = require(LUA_FOLDER .. 'data.entities')

function state:enter()
	self.ecs = ECS:new()
	self.ecs:addPresets(entities)

	self.ecs:addBeginSystem(systems.control)
	self.ecs:addSystem(systems.updatePosition)
	self.ecs:addSystem(systems.updateCollision)
	self.ecs:addDrawSystem(systems.draw)

	local id1 = self.ecs:addEntity("man", {0, 0, 0})
	local id2 = self.ecs:addEntity("man", {2, 1, 0})
	local id3 = self.ecs:addEntity("man", {2, 2, 0})
	local id4 = self.ecs:addEntity("man", {3, 1, 0})
	
	self.ecs.components.collision[id1].offx = 0
	self.ecs.components.control[id2] = nil
	self.ecs.components.control[id3] = nil
	self.ecs.components.control[id4] = nil

	self.vp = Rect.new()
	self.vp.x = 0
	self.vp.y = 0
	self.vp.w = 10
	self.vp.h = 7.5

	self.rotation = 0

	self.r1 = Rect.new()
	self.r1.x, self.r1.y, self.r1.w, self.r1.h = 0, 0, 1, 1
	self.r2 = Rect.new()
	self.r2.x, self.r2.y, self.r2.w, self.r2.h = 1, 0, 1, 1
end

function state:exit()

end

function state:update(dt, input)
	if input:getKeyState("Escape") == KS.PRESSED then
		return {{"pop", 1}}
	end

	return self.ecs:update(dt, input) or {}


	--[[

	if input:getKeyState("W") == KS.PRESSED 
		or input:getKeyState("W") == KS.HELD then
		self.r1.y = self.r1.y + .01
	end
	if input:getKeyState("A") == KS.PRESSED 
		or input:getKeyState("A") == KS.HELD then
		self.r1.x = self.r1.x - .01
	end
	if input:getKeyState("S") == KS.PRESSED 
		or input:getKeyState("S") == KS.HELD then
		self.r1.y = self.r1.y - .01
	end
	if input:getKeyState("D") == KS.PRESSED 
		or input:getKeyState("D") == KS.HELD then
		self.r1.x = self.r1.x + .01
	end

	if input:getKeyState("Q") == KS.PRESSED 
		or input:getKeyState("Q") == KS.HELD then
		self.rotation = self.rotation + 1
	end

	if input:getKeyState("E") == KS.PRESSED 
		or input:getKeyState("E") == KS.HELD then
		self.rotation = self.rotation - 1
	end

	local rr1 = {
		x = self.r1.x,
		y = self.r1.y,
		w = self.r1.w,
		h = self.r1.h,
		r = self.rotation
	}
	local rr2 = {
		x = self.r2.x,
		y = self.r2.y,
		w = self.r2.w,
		h = self.r2.h,
		r = 0
	}

	local does_collide, correction_vect = collide(rr1, rr2)

	if does_collide then
		

		self.r1.x = self.r1.x + correction_vect.x
		self.r1.y = self.r1.y + correction_vect.y
	end

	return {}
	]]
end

function state:draw(drawcontainer)
	drawcontainer.dim = self.vp
	self.ecs:draw(drawcontainer)

	--[[
	drawcontainer.dim = self.vp

	local di = DrawItem:new(2)
	local sprite = di.data.sprite
	sprite.texturename = "block.png"
	sprite.framex = 1
	sprite.framey = 1
	sprite.totalframesx = 1
	sprite.totalframesy = 1
	sprite.rotation = self.rotation
	sprite.dest = self.r1

	drawcontainer:add(di)

	di = DrawItem:new(2)
	sprite = di.data.sprite
	sprite.texturename = "block.png"
	sprite.framex = 1
	sprite.framey = 1
	sprite.totalframesx = 1
	sprite.totalframesy = 1
	sprite.rotation = 0
	sprite.dest = self.r2

	drawcontainer:add(di)
	]]
end

--[[

	COLLISION STUFF

]]



return state