local ECS = {}
ECS.__index = ECS

local comp_mt = {
	__index = function(comp, key)
		local t = {}
		rawset(comp, key, t)
		return  t
	end
}

function ECS.new()
	local self = setmetatable({}, ECS)

	self.currUid = 1
	self.openUids = {}
	self.components = {}
	self.beginsystems = {}
	self.systems = {}
	self.endsystems = {}
	self.drawsystems = {}

	setmetatable(self.components, comp_mt)
	return self
end

function ECS:addEntity(entity)
	-- get a unique uid
	local uid = 0
	if(#self.openUids ~= 0) then
		uid = self.openUids[#self.openUids]
	else
		uid = self.currUid
		self.currUid = self.currUid + 1
	end

	-- for each component in entity, store it
	for comp, values in pairs(entity) do
		local components = self.components[comp]
		components[uid] = values
	end
end

function ECS:addEntities(...)
	local argc = select("#", ...)

	for i = 1, argc do
		local entity = select(i, ...)
		self:addEntity(entity)
	end
end

function ECS:removeEntity(uid)
	self.openUids[#self.openUids+1] = uid

	for name, components in pairs(self.components) do
		components[uid] = nil
	end
end

function ECS:clearEntities()
	for name, component in pairs(self.components) do
		for uid, v in pairs(component) do
			component[uid] = nil
		end
	end

	self.currUid = 1
	self.openUids = {}
end

function ECS:addBeginSystem(name, func)
	self.systems[name] = func
end

function ECS:addSystem(name, func)
	self.systems[name] = func
end

function ECS:addSystems(systems)
	for name, func in pairs(systems) do
		self:addSystem(name, func)
	end
end

function ECS:addEndSystem(name, func)
	self.systems[name] = func
end

function ECS:addDrawSystem(name, func)
	self.drawsystems[name] = func
end

function ECS:removeSystem(name)
	self.systems[name] = nil
end

function ECS:clearSystems()
	for name, func in pairs(self.systems) do
		self.systems[name] = nil
	end
end

function ECS:update(dt, input)
	for name, func in pairs(self.beginsystems) do
		func(self, dt, input)
	end

	for name, func in pairs(self.systems) do
		func(self, dt, input)
	end

	for name, func in pairs(self.endsystems) do
		func(self, dt, input)
	end
end

function ECS:draw(drawcontainer)
	for name, func in pairs(self.drawsystems) do
		func(self, drawcontainer)
	end
end

return ECS

