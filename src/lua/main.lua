local LUA_FOLDER = (...):match("(.-)[^%.]+$")

require(LUA_FOLDER .. 'engine.ecs')

function update(dt)
	return false;
end
