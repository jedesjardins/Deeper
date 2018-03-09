local state = STATE.new()


state.ecs = ECS:new()
local systems = require(LUA_FOLDER .. 'engine.systems')
local entities = require(LUA_FOLDER .. 'engine.entities')
local hitboxes = require(LUA_FOLDER .. 'engine.hitboxes')


state.ecs:addBeginSystem(systems.controlEntity)

state.ecs:addSystem(systems.updatePosition)
state.ecs:addSystem(systems.updateLockPosition)
--state.ecs:addSystem(systems.createHitbox)
state.ecs:addSystem(systems.updateAttack)
state.ecs:addSystem(systems.updateMovementCollisions)
state.ecs:addSystem(systems.updateItemCollisions)
state.ecs:addSystem(systems.updateHitboxCollisions)
state.ecs:addSystem(systems.updateLifetime)

state.ecs:addEndSystem(systems.updateSprite)

state.ecs:addDrawSystem(systems.drawSprite)
state.ecs:addDrawSystem(systems.drawHitboxes)

state.ecs:addPresets(entities)
state.ecs:addPresets(hitboxes)

state.ecs:addEntity("man", {0, 0})
state.ecs:addEntity("sword", {-2, 2})
state.ecs:addEntity("block", {-2, -2})
state.ecs:addEntity("testhitbox", {-2, 0, 1, 1})


local id2 = state.ecs:addEntity("man", {2, 2})
state.ecs.components.control[id2] = nil

local viewport = {
	dim = Rect.new()
}

viewport.dim.x = 0
viewport.dim.y = 0
viewport.dim.w = 10
viewport.dim.h = 7.5

function state:update(dt, input)
	--TODO: ecs.update() should also return bool
	self.ecs:update(dt, input)

	return true
end

function state:draw(drawcontainer)
	drawcontainer.dim = viewport.dim
	self.ecs:draw(drawcontainer)
end

return state