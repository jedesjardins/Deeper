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

	self.syntax = {}

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
					tag = scratchboard[tag] or "["..tag.."]"
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

	if not self.syntax[tag] then
		return "<no tag: "..tag..">"
	end

	if self.syntax[tag]["phrase"] and #self.syntax[tag]["phrase"] > 0 then
		if self.syntax[tag][attr] then
			local rand = math.random(1, #self.syntax[tag][attr])
			local attr_index = self.syntax[tag][attr][rand]
			return self.syntax[tag]["phrase"][attr_index]
		else
			return self.syntax[tag]["phrase"][math.random(1, #self.syntax[tag]["phrase"])]
		end
	else
		return "<no phrases in tag: "..tag..">"
	end
end

function Lexicon:addTag(tag_name, phrase)
	if not self.syntax[tag_name] then 
		self.syntax[tag_name] = {phrase = {}}
	end

	for i, tag_attr_string in ipairs(phrase) do
		local tag_attrs = string.split(tag_attr_string, ":")
		local tag = tag_attrs[1]

		table.insert(self.syntax[tag_name]["phrase"], tag)


		local attr = ""
		for j=2,#tag_attrs do
			attr = tag_attrs[j]
			if not self.syntax[tag_name][attr] then
				self.syntax[tag_name][attr] = {}
			end

			table.insert(self.syntax[tag_name][attr], i)
		end
	end
end

function Lexicon:addTags(tags)
	for tag_name, phrase in pairs(tags) do
		self:addTag(tag_name, phrase)
	end
end

return Lexicon





