local state = STATE.new()
state.ecs = ECS:new()

state.ecs:addSystems(require(LUA_FOLDER .. 'engine.systems'))
state.ecs:addEntity({
		position = {x = 0, y = 0},
		size = {w = 10, h = 10}
	})

function state:update(dt, input)

	print(dt)
	local is_running = input:update()

	--TODO: ecs.update() should also return bool
	self.ecs:update(dt, input)

	return is_running
end

function state:draw(drawcontainer)
	local r = Rect.new()

	r.x, r.y = self.ecs.components["position"][1]["x"], self.ecs.components["position"][1]["y"]
	r.w, r.h = self.ecs.components["size"][1]["w"], self.ecs.components["size"][1]["h"]
	drawcontainer:add(r)
end

return state