local state = STATE.new()

local systems = require(LUA_FOLDER .. 'data.systems')
local entities = require(LUA_FOLDER .. 'data.entities')

function state:enter()
	self.ecs = ECS:new()
	self.ecs:addPresets(entities)

	self.ecs:addBeginSystem(systems.control)
	self.ecs:addSystem(systems.updatePosition)
	--self.ecs:addSystem(systems.updateLock)
	self.ecs:addSystem(systems.updateState)
	self.ecs:addSystem(systems.updateHeldItem)
	self.ecs:addSystem(systems.updateCollision)
	self.ecs:addSystem(systems.updateAnimation)
	self.ecs:addDrawSystem(systems.draw)
	self.ecs:addDrawSystem(systems.drawHitbox)

	local id1 = self.ecs:addEntity("man", {0, 0, 0})
	local id2 = self.ecs:addEntity("sword", {1, 0, 0})
	local id3 = self.ecs:addEntity("block", {-2, 1, 0})
	local id4 = self.ecs:addEntity("block", {-2, 1.5, 0})

	local id5 = self.ecs:addEntity("man", {0, 0, 0})
	self.ecs.components.control[id5] = nil

	self.vp = Rect.new()
	self.vp.x = 0
	self.vp.y = 0
	self.vp.w = 5
	self.vp.h = 3.75

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
end

function state:draw(drawcontainer)
	drawcontainer.dim = self.vp
	self.ecs:draw(drawcontainer)
end



return state