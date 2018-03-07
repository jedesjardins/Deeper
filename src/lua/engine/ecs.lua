local ECS = {}
ECS.__index = ECS

local comp_mt = {
	__index = function(comp, key)
		local t = {}
		rawset(comp, key, t)
		return  t
	end
}

local function deepcopy(val)
	if type(val) == "table" then
		local t = {}
		for k, v in pairs(val) do
			t[k] = deepcopy(v)
		end
		return t
	else
		return val
	end
end

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

function ECS:requireAll(...)
	local argc = select("#", ...)

	if argc < 1 then return {} end

	for i = 1, argc do
		local comp = select(i, ...)
		if #comp < 1 then return {} end
	end

	local entities = {}
	local first_require = self.components[select(1, ...)]

	for uid, _ in pairs(first_require) do
		local is_present = true

		for i = 2, argc do
			if not self.components[select(i, ...)][uid] then
				is_present = false
				break
			end
		end

		if is_present then table.insert(entities, uid) end
	end
	
	return entities
end

function ECS:requireAny(...)

end

function ECS:addEntity(entity)
	-- get a unique uid
	local uid = 0
	if(#self.openUids ~= 0) then
		uid = self.openUids[#self.openUids]
		self.openUids[#self.openUids] = nil
	else
		uid = self.currUid
		self.currUid = self.currUid + 1
	end

	-- for each component in entity, store it
	for comp, values in pairs(entity) do
		local components = self.components[comp]
		components[uid] = deepcopy(values)
	end

	return uid
end

function ECS:addComponent(id, name, comp)
	self.components[name][id] = deepcopy(comp)
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
	table.insert(self.beginsystems, func)
end

function ECS:addSystem(name, func)
	table.insert(self.systems, func)
end

function ECS:addEndSystem(name, func)
	table.insert(self.endsystems, func)
end

function ECS:addSystems(systems)
	for name, func in pairs(systems) do
		self:addSystem(name, func)
	end
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
	for index, func in ipairs(self.beginsystems) do
		func(self, dt, input)
	end

	for index, func in ipairs(self.systems) do
		func(self, dt, input)
	end

	for index, func in ipairs(self.endsystems) do
		func(self, dt, input)
	end
end

function ECS:draw(drawcontainer)
	for name, func in pairs(self.drawsystems) do
		func(self, drawcontainer)
	end
end

return ECS

