local entities = {}

entities.man = {
	control = {
		up = "W",
		down = "S",
		left = "A",
		right = "D",
		lockdirection = "Left Shift"
	},
	movement = {
		dx = 0,
		dy = 0,
		direction = "down",
		is_moving = false,
		changed = false
	},
	position = {
		x = "$1", y = "$2",
		w = 1, h = 1,
		r = "$3"
	},
	collision = {
		offx = 0,
		offy = 0,
		w = 1,
		h = 1
	}
}

return entities