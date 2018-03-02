local state = STATE.new()


state.ecs = ECS:new()
state.ecs:addSystems(require(LUA_FOLDER .. 'engine.systems'))
state.ecs:addDrawSystem("draw", function(self, drawcontainer)
		local dest = Rect.new()
		local di = DrawItem.new()

		dest.x, dest.y = self.components["position"][1]["x"], self.components["position"][1]["y"]
		dest.w, dest.h = self.components["size"][1]["w"], self.components["size"][1]["h"]

		di.texturename = self.components["animate"][1]["img"]
		di.frame = self.components["animate"][1]["frame"]
		di.frames = self.components["animate"][1]["frames"]
		di.destrect = dest
		drawcontainer:add(di)
	end)


state.ecs:addEntity({
		control = {},
		position = {x = 0, y = 0},
		size = {w = 1, h = 1},
		animate = {
			img = "spr_down.png",
			-- palette = "",
			frame = 1,
			frames = 4,
			animate = true,
			looptime = 1
		}
	})

local world = {
	dim = Rect.new()
}

world.dim.x = 0
world.dim.y = 0
world.dim.w = 640
world.dim.h = 480

function state:update(dt, input)
	local is_running = input:update()

	--TODO: ecs.update() should also return bool
	self.ecs:update(dt, input)

	return is_running
end

function state:draw(drawcontainer)
	drawcontainer.dim = world.dim
	self.ecs:draw(drawcontainer)
end

return state