local state = STATE.new()


state.ecs = ECS:new()
local systems = require(LUA_FOLDER .. 'engine.systems')

state.ecs:addBeginSystem("controls", systems.controlMovement)
state.ecs:addBeginSystem("position", systems.updatePosition)
state.ecs:addSystem("size", systems.updateSize)
state.ecs:addSystem("animate", systems.updateAnimations)
state.ecs:addDrawSystem("draw", systems.draw)


state.ecs:addEntity({
		control = {},
		position = {x = 0, y = 0},
		movement = {
			dx = 0,
			dy = 0,
			changed = false,
			direction = {x, y}
		},
		size = {w = 2, h = 2},
		animate = {
			img = "spr_down.png",	-- image file
			-- palette = "",
			frame = 1,				-- starting frame
			frames = 4,				-- frames in the image
			animate = true,			-- bool animate
			looptime = 1,			-- in seconds
			defaulttime = 1
		}
	})

state.ecs:addEntity({
		position = {x = 0, y = 0},
		size = {w = 2, h = 2},
		animate = {
			img = "spr_down.png",	-- image file
			-- palette = "",
			frame = 1,				-- starting frame
			frames = 4,				-- frames in the image
			animate = true,			-- bool animate
			looptime = 1 			-- in seconds
		}
	})

local viewport = {
	dim = Rect.new()
}

viewport.dim.x = 0
viewport.dim.y = 0
viewport.dim.w = 640
viewport.dim.h = 480

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