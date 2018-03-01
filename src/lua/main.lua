LUA_FOLDER = (...):match("(.-)[^%.]+$")
RESOURCE_FOLDER = "resources.data."

ECS = require(LUA_FOLDER .. 'engine.ecs')			-- ECS class
LEXICON = require(LUA_FOLDER .. 'engine.lexicon')	-- lexicon class
STATE = require(LUA_FOLDER .. 'engine.state')		-- state class

math.randomseed(os.time())

KS = KEYSTATE.new()

local input = Input.new()

local practicestate = require(LUA_FOLDER .. 'states.practicestate')

function update(dt, drawcontainer)
	local is_running = practicestate:update(dt, input)

	practicestate:draw(drawcontainer)

	return is_running
end


