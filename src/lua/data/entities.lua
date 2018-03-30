local entities = {}

hand_positions = {
	man = {
		{--framey=1
			{-5.5/16, -2.5/16},--framex=1
			{-4.5/16, -4.5/16},--framex=2 ...
			{-3.5/16, -5.5/16},
			{-1.5/16, -5.5/16},
			{-1.5/16, -5.5/16},
			{-2.5/16, -6.5/16},
			{-3.5/16, -5.5/16},
			{-3.5/16, -5.5/16}
		},
		{--y=2
			{4.5/16, -2.5/16},
			{4.5/16, -0.5/16},
			{3.5/16, 2.5/16}, --{4.5/16, 0},
			{1.5/16, 1/16},
			{1.5/16, 1/16},
			{2.5/16, 2/16},
			{3.5/16, 1/16},
			{3.5/16, 1/16}
		},
		{--y=3
			{-1/16, -4/16},
			{1/16, -5/16},
			{4/16, -3/16},
			{4/16, -3/16},
			{4/16, -3/16},
			{4/16, -4/16},
			{4/16, -5/16},
			{4/16, -5/16}
		},
		{--y=4
			{1/16, -2/16},
			{-1/16, -3/16},
			{-4/16, -1/16},
			{-4/16, -3/16},
			{-4/16, -3/16},
			{-4/16, -2/16},
			{-4/16, -1/16},
			{-4/16, -1/16}
		}
	}
}

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
		dx = 0, dy = 0,	-- instantaneous movement controls in tiles/second
		mx = 0, my = 0,	-- momentum in tiles/second
		is_moving = false
	},
	position = {
		x = "$1", y = "$2", z = nil,
		w = 14/16, h = 19/16,
		r = 0
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
				frames = {2},
				framesw = 8,
				angles = {0},
				hitboxs = {false},
				base_duration = inf,
				interruptable = true,
				stop = "stand"
			},
			walk = {
				frames = {1, 2, 3, 2},
				framesw = 8,
				angles = {0, 0, 0, 0},
				hitboxs = {false, false, false, false},
				base_duration = .7,
				interruptable = true,
				stop = "stand"
			},
			attack = {
				frames = {1, 1, 6, 6, 6, 6},
				framesw = 8,
				angles = {0, 0, 0, 0, 0, 0},
				hitboxs = {false, false, true, true, true, true}, 
				base_duration = .25,
				interruptable = false,
				stop = "stand"
			},
			swing_right = {
				frames = {4, 4, 5, 5, 6, 6, 6, 7, 7, 8, 8},
				framesw = 8,
				angles = {90, 70, 50, 30, 10, 0, -10, -30, -50, -70, -90},
				hitboxs = {true, true, true, true, true, true, true, true, true, true, true}, 
				base_duration = .6,
				interruptable = false,
				stop = "stand"
			},
			swing_left = {
				frames = {8, 8, 7, 7, 6, 6, 6, 5, 5, 4, 4},
				framesw = 8,
				angles = {-90, -70, -50, -30, -10, 0, 10, 30, 50, 70, 90},
				hitboxs = {true, true, true, true, true, true, true, true, true, true, true}, 
				base_duration = .6,
				interruptable = false,
				stop = "stand"
			}
		}
	},
	sprite = {
		img = "man",
		framex = 2,
		framey = 1,
		totalframesx = 3,
		totalframesy = 4,
		time = 0
	},
	hand = {
		item = nil
	}
}

entities.block = {
	group = "obj",
	position = {
		x = "$1", y = "$2", z = nil,
		w = 1, h = 1,
		r = 0
	},
	collision = {
		offx = 0,
		offy = 0,
		w = 1,
		h = 1
	},
	sprite = {
		img = "block",
		framex = 1,
		framey = 1,
		totalframesx = 1,
		totalframesy = 1
	}
}

entities.sword = {
	group = "item",
	position = {
		x = "$1", y = "$2", z = nil,
		w = 16/16, h = 5/16,
		r = 0
	},
	collision = {
		offx = 0,
		offy = 0,
		w = 1,
		h = 5/16
	},
	sprite = {
		img = "sword",
		framex = 1,
		framey = 1,
		totalframesx = 1,
		totalframesy = 1
	},
	holdable = {
		offx = -6/16,
		offy = 0,
		collision = {
			offx = 2/16,
			offy = 0,
			w = 12/16,
			h = 5/16
		},
		hitbox = {
			hit_ids = {},
			-- effects are status effects like paralysis, burns, etc
			effects = {
				-- type = duration? strength?
			},
			-- straight damage
			damage = {
				-- type = amount
			}
		},
		actions = {
			attack = {
				duration = .2,
				combos = {
					attack = "swing_right"
				}
			},
			swing_right = {
				duration = .3,
				combos = {
					attack = "swing_right"
				}
			},
			swing_left = {
				duration = .3,
				combos = {
					attack = "swing_right"
				}
			}
		}
	}
}

return entities