local state = STATE.new()
state.ecs = ECS:new()

state.ecs:addSystems(require(LUA_FOLDER .. 'engine.systems'))
state.ecs:addDrawSystem("draw", function(self, drawcontainer)
		local r = Rect.new()
		local di = DrawItem.new()

		r.x, r.y = self.components["position"][1]["x"], self.components["position"][1]["y"]
		r.w, r.h = self.components["size"][1]["w"], self.components["size"][1]["h"]

		di.texturename = "guy.png"
		di.rect = r
		drawcontainer:add(di)
	end)


state.ecs:addEntity({
		control = {},
		position = {x = 0, y = 0},
		size = {w = 10, h = 10}
	})

function state:update(dt, input)
	local is_running = input:update()

	--TODO: ecs.update() should also return bool
	self.ecs:update(dt, input)

	return is_running
end

function state:draw(drawcontainer)
	self.ecs:draw(drawcontainer)
end

return state