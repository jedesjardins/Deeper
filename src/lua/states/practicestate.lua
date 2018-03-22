local state = STATE.new()



local systems = require(LUA_FOLDER .. 'engine.systems')
local entities = require(LUA_FOLDER .. 'engine.entities')
local hitboxes = require(LUA_FOLDER .. 'engine.hitboxes')

function state:enter()

	state.ecs = ECS:new()

	state.ecs:addBeginSystem(systems.controlEntity)

	state.ecs:addSystem(systems.updatePosition)
	state.ecs:addSystem(systems.updateLockPosition)
	--state.ecs:addSystem(systems.updateDriftPosition)
	--state.ecs:addSystem(systems.createHitbox)
	state.ecs:addSystem(systems.updateAttack)
	state.ecs:addSystem(systems.updateInteractCollisions)
	state.ecs:addSystem(systems.updateMovementCollisions)
	state.ecs:addSystem(systems.updateItemCollisions)
	state.ecs:addSystem(systems.updateHitboxCollisions)

	state.ecs:addSystem(systems.updateHealth)

	state.ecs:addSystem(systems.updateLifetime)

	state.ecs:addEndSystem(systems.updateSprite)

	state.ecs:addDrawSystem(systems.drawSprite)
	state.ecs:addDrawSystem(systems.drawHitboxes)

	state.ecs:addPresets(entities)
	state.ecs:addPresets(hitboxes)

	state.ecs:addEntity("man", {0, 0})
	state.ecs:addEntity("sword", {-2, -1})
	state.ecs:addEntity("bow", {-2, -2})
	state.ecs:addEntity("wand", {-2, -3})

	local id2 = state.ecs:addEntity("man", {2, 2})
	state.ecs.components.control[id2] = nil


	self.viewport = {
		dim = Rect.new()
	}

	self.viewport.dim.x = 0
	self.viewport.dim.y = 0
	self.viewport.dim.w = 10
	self.viewport.dim.h = 7.5
end

function state:exit()
	state.ecs = nil
	state.viewport = nil
end

function state:update(dt, input)
	-- exit game
	if input:getKeyState("Escape") == KS.PRESSED then
		return {{"pop", 1}}
	end

	--[[
	-- pause
	if input:getKeyState("P") == KS.PRESSED then
		return {{"push", "pausestate"}}
	end
	]]

	return self.ecs:update(dt, input) or {}
end

function state:draw(drawcontainer)
	drawcontainer.dim = self.viewport.dim
	self.ecs:draw(drawcontainer)
end

return state