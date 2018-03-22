local entities = {}

entities.man = {
	group = "char",
	control = {
		up = "W",
		down = "S",
		left = "A",
		right = "D",
		lockdirection = "Left Shift",
		attack = "Space"
	},
	movement = {
		dx = 0,
		dy = 0,
		is_moving = false
	},
	position = {
		x = "$1", y = "$2",
		w = 14/16, h = 19/16,
		r = "$3"
	},
	collision = {
		offx = 0,
		offy = -2.5/16,
		w = 12/16,
		h = 14/16
	},
	state = {
		action_name = nil,
		action = nil,
		direction = "down",
		time = 0,
		action_queue = {"stand"},

		direction_to_y = {
			down = 1,
			up = 2,
			right = 3,
			left = 4
		},

		actions = {
			stand = {
				img = "walk",
				frames = {2},
				framesw = 3,
				duration = inf,
				interruptable = true,
				stop = "stand"
			},
			walk = {
				img = "walk",
				frames = {1, 2, 3, 2},
				framesw = 3,
				duration = .7,
				interruptable = true,
				stop = "stand"
			},
			stab = {
				img = "attack",
				frames = {1},
				framesw = 4,
				duration = .3,
				interruptable = false,
				stop = "stand",
				combos = {
					stab = "swing"
				}
			},
			swing = {
				img = "attack",
				frames = {1},
				framesw = 4,
				duration = .6,
				interruptable = false,
				stop = "stand",
				combos = {
					stab = "cswing"
				}
			},
			cswing = {
				img = "attack",
				frames = {1},
				framesw = 4,
				duration = .6,
				interruptable = false,
				stop = "stand",
				combos = {
					stab = "swing"
				}
			}
		}
	},
	sprite = {
		img_base = "man",
		img = "man_stand.png",
		framex = 2,
		framey = 1,
		totalframesx = 3,
		totalframesy = 4,
		time = 0
	}
}

entities.block = {
	group = "obj",
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
	},
	sprite = {
		img = "block.png",
		framex = 1,
		framey = 1,
		totalframesx = 1,
		totalframesy = 1
	}
}

entities.sword = {
	group = "item",
	position = {
		x = "$1", y = "$2",
		w = 16/16, h = 5/16,
		r = "$3"
	},
	collision = {
		offx = 0,
		offy = 0,
		w = 1,
		h = 5/16
	},
	sprite = {
		img = "sword.png",
		framex = 1,
		framey = 1,
		totalframesx = 1,
		totalframesy = 1
	}
}

return entities