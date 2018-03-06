local state = STATE.new()


state.ecs = ECS:new()
local systems = require(LUA_FOLDER .. 'engine.systems')

state.ecs:addBeginSystem("controls", systems.controlMovement)
state.ecs:addSystem("position", systems.updatePosition)
state.ecs:addSystem("collide", systems.collisions)
state.ecs:addEndSystem("animate", systems.updateAnimations)
state.ecs:addDrawSystem("draw", systems.draw)

state.ecs:addEntity({
		control = {},
		position = {x = 0, y = 0},
		movement = {
			dx = 0,
			dy = 0,
			direction = "down",
			is_moving = false,
			changed = false
		},
		collision = {
			offx = 0,
			offy = -0.1875,
			w = .75,
			h = 1
		},
		size = {w = 1, h = 1},
		animate = {
			img_name = "man_",
			img = "man_down.png",
			frame = 1,
			frames = 4,
			animate = true,
			looptime = .8,
			defaulttime = .8
		}
	})

state.ecs:addEntity({
		position = {x = -1, y = 0},
		movement = {
			dx = 0,
			dy = 0,
			direction = "down",
			is_moving = false,
			changed = false
		},
		collision = {
			offx = 0,
			offy = -0.1875,
			w = .75,
			h = 1
		},
		size = {w = 1, h = 1},
		animate = {
			img_name = "man_",
			img = "man_down.png",
			frame = 1,
			frames = 4,
			animate = true,
			looptime = .8,
			defaulttime = .8
		}
	})


for i=1, 3 do
	state.ecs:addEntity({
			position = {x = 2, y = i},
			size = {w = 1, h = 1},
			collision = {
				offx = 0,
				offy = 0,
				w = 1,
				h = 1
			},
			animate = {
				img_name = "guy_",
				img = "guy_down.png",
				frame = 1,
				frames = 4,
				animate = false,
				looptime = 1,
				defaulttime = 1
			}
		})
end

for i=1, 3 do
	state.ecs:addEntity({
			position = {x = i, y = -3},
			size = {w = 1, h = 1},
			collision = {
				offx = 0,
				offy = 0,
				w = 1,
				h = 1
			},
			animate = {
				img_name = "guy_",
				img = "guy_down.png",
				frame = 1,
				frames = 4,
				animate = false,
				looptime = 1,
				defaulttime = 1
			}
		})
end



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