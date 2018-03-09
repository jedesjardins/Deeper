local state = STATE.new()


state.ecs = ECS:new()
local systems = require(LUA_FOLDER .. 'engine.systems')
local entities = require(LUA_FOLDER .. 'engine.entities')


state.ecs:addBeginSystem(systems.controlEntity)
state.ecs:addSystem(systems.updatePosition)
state.ecs:addSystem(systems.createHitbox)
state.ecs:addSystem(systems.updateCollisions)
state.ecs:addEndSystem(systems.updateSprite)
state.ecs:addDrawSystem(systems.drawSprite)
state.ecs:addDrawSystem(systems.drawHitboxes)

state.ecs:addEntity(entities.man, {0, 0})
state.ecs:addEntity(entities.sword, {1, 0})

local id2 = state.ecs:addEntity(entities.man, {2, 2})
state.ecs.components.control[id2] = nil

--[[
state.ecs:addBeginSystem("controls", systems.controls)
state.ecs:addSystem("position", systems.updatePosition)
state.ecs:addSystem("lockto", systems.lockto)
state.ecs:addSystem("collide", systems.collisions)
state.ecs:addSystem("attack", systems.attack)
state.ecs:addSystem("hitbox", systems.hitbox)
state.ecs:addEndSystem("animate", systems.updateAnimations)
state.ecs:addDrawSystem("draw", systems.drawWithCollisions)

local id1 = state.ecs:addEntity(entities.player)
state.ecs:addComponent(id1, "control", {up = "W", down = "S", left = "A", right = "D",
										attack = "Space",
										lockdirection = "Left Shift", interact = "Return",
										freeze_controls = "P", can_control = true})

local id2 = state.ecs:addEntity(entities.player)
state.ecs:addComponent(id2, "control", {up = "I", down = "K", left = "J", right = "L",
										attack = "U",
										lockdirection = "Right Shift", interact = "Return",
										freeze_controls = "P", can_control = true})
state.ecs.components.position[id2].x = 2

local id3 = state.ecs:addEntity(entities.sword)
--state.ecs:addEntity(entities.block)

local id4 = state.ecs:addEntity(entities.block)
]]

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