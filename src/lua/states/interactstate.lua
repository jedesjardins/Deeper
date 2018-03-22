local state = STATE.new()

function state:enter(arguments)
	--self.message = require('resources.script')
	self.message = arguments["script"] or ""

	self.cursortime = 0
	self.cursorshow = false

	self.linenum = 1
	self.messagelineindex = 1
	self.messageletterindex = 1
	self.lettertime = 0

	self.messagelines = {""}
end

function state:exit()

end

function state:update(dt, input)
	if input:getKeyState("Escape") == KS.PRESSED then
		return {{"pop", 2}}
	end

	self.messagelines[self.linenum] = string.sub(self.message, self.messagelineindex, self.messageletterindex)


	if self.messageletterindex+1 > #self.message then
		self.cursortime = self.cursortime + dt
		if self.cursortime >= 500 then
			self.cursortime = 0
			self.cursorshow = not self.cursorshow
		end
		if input:getKeyState("Return") == KS.PRESSED then
			return {{"pop", 1}}
		end
	else if string.sub(self.message, self.messageletterindex+1, self.messageletterindex+1) == "\0" then
		self.cursortime = self.cursortime + dt
		if self.cursortime >= 500 then
			self.cursortime = 0
			self.cursorshow = not self.cursorshow
		end

		if input:getKeyState("Return") == KS.PRESSED then
			self.linenum = self.linenum + 1
			self.messageletterindex = self.messageletterindex + 2
			self.messagelineindex = self.messageletterindex
		end
	else
		if input:getKeyState("Return") == KS.PRESSED 
			or input:getKeyState("Return") == KS.HELD then
			self.lettertime = self.lettertime + 4*dt
		else
			self.lettertime = self.lettertime + dt
		end

		if self.lettertime >= 90 then
			self.lettertime = 0
			self.messageletterindex = self.messageletterindex + 1
		end

		if string.sub(self.message, self.messageletterindex, self.messageletterindex) == "\n" then
			self.linenum = self.linenum + 1
			self.messageletterindex = self.messageletterindex + 1
			self.messagelineindex = self.messageletterindex
		end

		self.cursorshow = false
	end end
end

function state:draw(drawcontainer)

	local di = DrawItem.new(DT.TEXTBOX)
	local dib = di.data.textbox

	if #self.messagelines == 1 then
		dib.firstline = self.messagelines[1]
		dib.secondline = ""
	else
		dib.firstline = self.messagelines[#self.messagelines-1]
		dib.secondline = self.messagelines[#self.messagelines]
	end

	--dib.firstline = "Hello, my name is Jimmy. It is nice to meet"
	--dib.secondline = "meet you."
	dib.showcontinuecursor = self.cursorshow;

	dib.x = 0
	dib.y = 3/4
	dib.w = 1
	dib.h = 1/4
	drawcontainer:add(di)

	--[[
	local di = DrawItem.new(DT.OPTIONBOX)
	local dib = di.data.optionbox

	dib.x = 3/4
	dib.y = 0
	dib.w = 1/4
	dib.h = 3/4
	drawcontainer:add(di)
	]]
end

return state
