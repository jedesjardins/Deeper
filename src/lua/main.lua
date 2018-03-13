LUA_FOLDER = (...):match("(.-)[^%.]+$")
RESOURCE_FOLDER = "resources.data."

ECS = require(LUA_FOLDER .. 'engine.ecs')			-- ECS class
LEXICON = require(LUA_FOLDER .. 'engine.lexicon')	-- lexicon class
STATE = require(LUA_FOLDER .. 'engine.state')		-- state class
SM = require(LUA_FOLDER .. 'engine.statemanager')	-- state class
Debug = require(LUA_FOLDER .. 'engine.debug')		-- debug function

math.randomseed(os.time())

function math.sign(x)
  return (x < 0 and -1) or (x > 0 and 1) or 0
end

KS = KEYSTATE.new()
DT = DRAWITEMTYPE.new()
inf = math.huge

local input = Input.new()

Debug:setDefault(true)

function update(dt, drawcontainer)

	local is_running = input:update()

	is_running = is_running and SM:update(dt, input)

	SM:draw(drawcontainer)

	return is_running
end


