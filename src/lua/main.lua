local LUA_FOLDER = (...):match("(.-)[^%.]+$")

require(LUA_FOLDER .. 'engine.ecs')

local bool = 0

function update(dt)
	if bool < 200 then
		bool = bool + 1
		return true
	else
		return false
	end
end
