LUA_FOLDER = (...):match("(.-)[^%.]+$")
RESOURCE_FOLDER = "resources.data."

inf = math.huge

require(LUA_FOLDER .. 'engine.collision')

ECS = require(LUA_FOLDER .. 'engine.ecs')			-- ECS class
LEXICON = require(LUA_FOLDER .. 'engine.lexicon')	-- lexicon class
STATE = require(LUA_FOLDER .. 'engine.state')		-- state class
SM = require(LUA_FOLDER .. 'engine.statemanager')	-- state class
Debug = require(LUA_FOLDER .. 'engine.debug')		-- debug function

math.randomseed(os.time())

function math.sign(x)
	return (x < 0 and -1) or (x > 0 and 1) or 0
end

function math.clamp(val, min, max)
	return (val < min and min) or (val > max and max) or val
end

KS = KEYSTATE.new()
--DT = DRAWITEMTYPE.new()

local input = Input.new()

Debug:setDefault(true)

function update(dt)

	local is_running = input:update()

	is_running = is_running and SM:update(dt, input)

	SM:draw()

	return is_running
end


