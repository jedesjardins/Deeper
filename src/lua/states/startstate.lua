local state = STATE.new()


function state:update(dt, input)
	return {{"switch", "practicestate"}}
end

function state:draw(drawcontainer)

end

return state
