local state = STATE.new()


function state:update(dt, input)
	if input:getKeyState("Escape") == KS.PRESSED
	or input:getKeyState("P") == KS.PRESSED then
		return {{"pop", 1}}
	end
end

function state:draw(drawcontainer)
	local di = DrawItem.new(DT.TEXTBOX)
	local dib = di.data.textbox

	dib.x = 0
	dib.y = 3/4
	dib.w = 1
	dib.h = 1/4
	drawcontainer:add(di)

	local di = DrawItem.new(DT.OPTIONBOX)
	local dib = di.data.optionbox

	dib.x = 3/4
	dib.y = 0
	dib.w = 1/4
	dib.h = 3/4
	drawcontainer:add(di)
end

return state
