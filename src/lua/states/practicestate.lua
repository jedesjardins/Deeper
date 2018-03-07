local state = STATE.new()


state.ecs = ECS:new()
local systems = require(LUA_FOLDER .. 'engine.systems')
local entities = require(LUA_FOLDER .. 'engine.entities')

state.ecs:addBeginSystem("controls", systems.controlMovement)
state.ecs:addSystem("position", systems.updatePosition)
state.ecs:addSystem("collide", systems.collisions)
state.ecs:addSystem("hitbox", systems.hitbox)
state.ecs:addEndSystem("animate", systems.updateAnimations)
state.ecs:addDrawSystem("draw", systems.draw)

local id1 = state.ecs:addEntity(entities.player)
state.ecs:addComponent(id1, "control", {up = "W", down = "S", left = "A", right = "D",
										attack = "Space",
										lockdirection = "Left Shift"})
local id2 = state.ecs:addEntity(entities.player)
state.ecs.components.position[id2].x = 2
--state.ecs:addEntity(entities.block)

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