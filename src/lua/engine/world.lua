local world = {}

function world.new(ecs)
	local self = setmetatable({}, ECS)

	self.ecs = ecs
	self.x = 0
	self.y = 0
	-- needs array of 
	self.tile = {
		{
			{0},{0},{0},{0}
		},
		{
			{0},{1},{1},{0}
		},
		{
			{0},{1},{1},{0}
		},
		{
			{0},{0},{0},{0}
		},
	}

	return self
end

function world:update()
	
end

function world:collide(ecs, id, r)

end

function world:draw(viewport)
	
end

return world