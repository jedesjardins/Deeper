local LUA_FOLDER = (...):match("(.-)[^%.]+$")

local ECS = require(LUA_FOLDER .. 'engine.ecs')
local Lexicon = require(LUA_FOLDER .. 'engine.lexicon')

local bool = 0

function update(dt)
	math.randomseed(os.time())
	local lex = Lexicon.new()

	local name = {"{first_name} {last_name}"}
	local first_name = {"James"}
	local last_name = {"Desjardins"}
	local greeting = {"Hello", "Yo:casual", "Sup:casual", "Howdy:southern"}

	lex:add("name", name)
	lex:add("greeting", greeting)
	lex:add("first_name", first_name)
	lex:add("last_name", last_name)
	print("output: ", lex:string("{greeting:casual}, my name is [name]", {name = "James Desjardins"}))

	return false
end
