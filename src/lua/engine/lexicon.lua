local Lexicon = {}
Lexicon.__index = Lexicon

function string:split(char)
	local fmt = "[^" .. char .. "]*"
	local out = {}
	--for str in string.gmatch("Hello my name is perp", "[^ ]* ") do
	for str in string.gmatch(self, fmt) do
		table.insert(out, str)
	end

	return out
end

function Lexicon.new()
	local self = setmetatable({}, Lexicon)

	self.phrases = {}

	return self
end

function Lexicon:string(str, scratchboard)
	-- str = "{greeting}, my name is {name}"

	-- split contents
	local strings = string.split(str, " ")

	local processed = 1
	local start, stop = 0, 0
	for i=1,#strings do

		local output = {}
		--separate tags, fill tag data
		repeat 
			-- find occurence start and stop
			start, stop = string.find(strings[i], "[{%[]%g%g*[}%]]", processed)

			-- if occurence found
			if (start) then
				-- insert non tags in between tags
				if start > processed then
					table.insert(output, string.sub(strings[i], processed, start-1))
				end

				-- found tag
				local tag = string.sub(strings[i], start+1, stop-1)
				-- fill tag with tag contents
				if (string.sub(strings[i], start, start) == "{") then
					-- fill tag
					tag = self:fill(tag)
					tag = self:string(tag)
				else
					-- fill variable
					tag = scratchboard[tag] or ""
				end
				table.insert(output, tag)

				--increment
				processed = stop + 1
			else
				if processed <= string.len(strings[i]) then
					-- insert trailing non tags
					table.insert(output, string.sub(strings[i], processed))
				end
			end
		until (not start)

		strings[i] = table.concat(output)

		--increment
		processed = 1
	end

	-- extract any phrases
	return table.concat(strings, " ")
end

function Lexicon:fill(tag_attr_string)
	local tag_attrs = string.split(tag_attr_string, ":")

	local tag = tag_attrs[1]
	local attr = tag_attrs[2]
	print(tag)

	if self.phrases[tag]["phrase"] then
		if self.phrases[tag][attr] then
			local rand = math.random(1, #self.phrases[tag][attr])
			local attr_index = self.phrases[tag][attr][rand]
			return self.phrases[tag]["phrase"][attr_index]
		else
			return self.phrases[tag]["phrase"][math.random(1, #self.phrases[tag]["phrase"])]
		end
	else
		return "nil"
	end
end

function Lexicon:add(tag_name, phrase)
	self.phrases[tag_name] = {
		phrase = {}
	}

	for i, tag_attr_string in ipairs(phrase) do
		local tag_attrs = string.split(tag_attr_string, ":")
		local tag = tag_attrs[1]

		table.insert(self.phrases[tag_name]["phrase"], tag)


		local attr = ""
		for j=2,#tag_attrs do
			attr = tag_attrs[j]
			if not self.phrases[tag_name][attr] then
				self.phrases[tag_name][attr] = {}
			end

			table.insert(self.phrases[tag_name][attr], i)
		end
	end
end

return Lexicon





