collision = {}

function collision.collide(A, B)--r1, r2)
	--local A = collision.getPoints(r1)
	--local B = collision.getPoints(r2)


	local axi = {
		{
			x = A[2].x-A[1].x,
			y = A[2].y-A[1].y
		},
		{
			x = A[1].x-A[3].x,
			y = A[1].y-A[3].y
		},
		{
			x = B[2].x-B[1].x,
			y = B[2].y-B[1].y
		},
		{
			x = B[1].x-B[3].x,
			y = B[1].y-B[3].y
		}
	}

	local min = {
		axis = nil,
		overlap = inf,
		sign = 0
	}

	for _, axis in ipairs(axi) do
		-- normalize axis to unit vector
		local mag = collision.magnitude(axis)
		axis.x = axis.x/mag
		axis.y = axis.y/mag

		local overlap, sign = collision.overlap(axis, A, B)

		min.overlap = math.min(min.overlap, overlap)
		if min.overlap == overlap then
			min.axis = axis
			min.sign = sign
		end

		axis_count = axis_count + 1
		if min.overlap == 0 then break end
	end

	--TODO(James): floating point rounding error, min.overlap can be super fuckin tiny amounts of error
	return min.overlap > .0001, {x = min.overlap * min.axis.x * min.sign, y = min.overlap * min.axis.y * min.sign}
end

function collision.getPointsAround(r, vec)
	local p = {
		{x=r.x-r.w/2-vec.x, y=r.y+r.h/2-vec.y},
		{x=r.x+r.w/2-vec.x, y=r.y+r.h/2-vec.y},
		{x=r.x-r.w/2-vec.x, y=r.y-r.h/2-vec.y},
		{x=r.x+r.w/2-vec.x, y=r.y-r.h/2-vec.y}
	}

	local rp = {
		{
			x = (p[1].x * cos(r.r) - p[1].y * sin(r.r)) + vec.x,
			y =	(p[1].x * sin(r.r) + p[1].y * cos(r.r)) + vec.y,
		},
		{
			x = (p[2].x * cos(r.r) - p[2].y * sin(r.r)) + vec.x,
			y =	(p[2].x * sin(r.r) + p[2].y * cos(r.r)) + vec.y,
		},
		{
			x = (p[3].x * cos(r.r) - p[3].y * sin(r.r)) + vec.x,
			y =	(p[3].x * sin(r.r) + p[3].y * cos(r.r)) + vec.y,
		},
		{
			x = (p[4].x * cos(r.r) - p[4].y * sin(r.r)) + vec.x,
			y =	(p[4].x * sin(r.r) + p[4].y * cos(r.r)) + vec.y,
		}
	}
	return rp
end

function collision.getPoints(r)

	-- get points around origin
	local p = {
		{x= -r.w/2, y= r.h/2},
		{x= r.w/2, y= r.h/2},
		{x= -r.w/2, y= -r.h/2},
		{x= r.w/2, y= -r.h/2}
	}
	-- rotate points
	local rp = {
		{
			x = (p[1].x * cos(r.r) - p[1].y * sin(r.r)) + r.x,
			y =	(p[1].x * sin(r.r) + p[1].y * cos(r.r)) + r.y,
		},
		{
			x = (p[2].x * cos(r.r) - p[2].y * sin(r.r)) + r.x,
			y =	(p[2].x * sin(r.r) + p[2].y * cos(r.r)) + r.y,
		},
		{
			x = (p[3].x * cos(r.r) - p[3].y * sin(r.r)) + r.x,
			y =	(p[3].x * sin(r.r) + p[3].y * cos(r.r)) + r.y,
		},
		{
			x = (p[4].x * cos(r.r) - p[4].y * sin(r.r)) + r.x,
			y =	(p[4].x * sin(r.r) + p[4].y * cos(r.r)) + r.y,
		}
	}
	return rp
end

function cos(angle)
	return math.cos(math.rad(angle))
end

function sin(angle)
	return math.sin(math.rad(angle))
end

function collision.magnitude(v)
	return math.sqrt(v.x*v.x + v.y*v.y)
end

function collision.overlap(v, A, B)

	local aVal = collision.projectPoints(v, A)
	local aMin = aVal[1]
	local aMax = aVal[2]

	local bVal = collision.projectPoints(v, B)
	local bMin = bVal[1]
	local bMax = bVal[2]

	if(aMax < bMin or bMax < aMin) then
		return 0, 0
	else
		--find smallest overlap
		if aMax - bMin < bMax - aMin then
			return aMax - bMin, -1 --indicates to move A negatively along colliding axis, A is to the left
		else
			return bMax - aMin, 1 --indicates to move A positively along the colliding axis, A is to the right
		end
	end
end

function collision.projectPoints(v, A)

	local aMin = false
	local aMax = false
	local val = false

	for _, p in ipairs(A) do
		val = (p.x*v.x)+(p.y*v.y)
		if aMin == false then
			aMin = val
			aMax = val
		else
			aMin = math.min(val, aMin)
			aMax = math.max(val, aMax)
		end
	end

	return {aMin, aMax}
end