local ECS = {}
ECS.__index = ECS

local comp_mt = {
	__index = function(comp, key)
		local t = {}
		rawset(comp, key, t)
		return  t
	end
}

local function deepcopy(val, scratch)
	if type(val) == "table" then
		local t = {}
		for k, v in pairs(val) do
			t[k] = deepcopy(v, scratch)
		end
		return t
	else if type(val) == "string" then
		if #val > 1 and string.sub(val, 1, 1) == "$" then
			local index = tonumber(string.sub(val, 2))
			if not scratch[index] then 
				print("Entity requires at least "..tostring(index).. " arguments to create.")
			end
			return scratch[index]
		else
			return val
		end
	else
		return val
	end end
end

function ECS.new()
	local self = setmetatable({}, ECS)

	self.currUid = 1
	self.openUids = {}
	self.deleteUids = {}
	self.presets = {}
	self.components = {}
	self.beginsystems = {}
	self.systems = {}
	self.endsystems = {}
	self.drawsystems = {}

	setmetatable(self.components, comp_mt)
	return self
end

function ECS:requireAllBut(all, but)
	if #all == 0 then return {} end
	
	but = but or {}

	local entities = {}
	local first_require = self.components[all[1]]

	for uid, _ in pairs(first_require) do
		local include = true

		-- check components to have
		for i = 2, #all do
			if not self.components[all[i]][uid] then
				include = false
				break
			end
		end

		if include then
			-- check components not to have
			for i = 1, #but do 
				if self.components[but[i]][uid] then
					include = false
					break
				end
			end

			if include then table.insert(entities, uid) end
		end
	end

	return entities
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

function ECS:addPresets(entities)
	for name, components in pairs(entities) do
		self.presets[name] = components
		self.presets[name].name = name
	end
end

function ECS:addEntity(name, scratch)
	local entity = self.presets[name]
	if not entity then
		Debug:writeln("ECS","No entity", name)
		return nil
	end

	return self:addEntityFromTable(entity, scratch)
end

function ECS:addEntityFromTable(entity, scratch)
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
		components[uid] = deepcopy(values, scratch or {})
	end

	return uid
end

function ECS:addComponent(id, name, comp, scratch)
	self.components[name][id] = deepcopy(comp, scratch or {})
end

function ECS:removeEntity(uid)
	-- delete is done at the end of update
	table.insert(self.deleteUids, uid)
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

function ECS:addBeginSystem(func)
	table.insert(self.beginsystems, func)
end

function ECS:addSystem(func)
	table.insert(self.systems, func)
end

function ECS:addEndSystem(func)
	table.insert(self.endsystems, func)
end

function ECS:addDrawSystem(func)
	table.insert(self.drawsystems, func)
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
		local ret = func(self, dt, input)
		if ret then
			return ret
		end
	end

	for index, func in ipairs(self.systems) do
		func(self, dt, input)
	end

	for index, func in ipairs(self.endsystems) do
		func(self, dt, input)
	end

	for _, uid in ipairs(self.deleteUids) do
		self.openUids[#self.openUids+1] = uid

		for name, components in pairs(self.components) do
			components[uid] = nil
		end
	end

	self.deleteUids = {}

	return ret
end

function ECS:draw(drawcontainer)
	for index, func in ipairs(self.drawsystems) do
		func(self, drawcontainer)
	end
end

return ECS

