local oldentities = {
	player = {
		position = {x = 0, y = 0,
					sx = 1, sy = 1,
					rotation = 0
		},
		movement = {
			dx = 0,
			dy = 0,
			direction = "down",
			is_moving = false,
			changed = false
		},
		state = {
			action = ""
		},
		collision = {
			offx = 0,
			offy = -0.1875,
			w = .75,
			h = 1
		},
		animate = {
			img_name = "man_",
			img = "man_down.png",
			frame = 1,
			frames = 4,
			animate = true,
			looptime = 3,
			defaulttime = .8
		},
		handloc = {
			right = {
				{-1/16, -6/16},
				{-2/16, -5/16},
				{0, -6/16},
				{3/16, -5/16}
			},
			up = {
				{5.5/16, -2/16},
				{5.5/16, -4/16},
				{5.5/16, 0/16},
				{5/16, -2/16}
			},
			left = {
				{0, -2/16},
				{3/16, -1/16},
				{0, -2/16},
				{-2/16, -1/16}
			},
			down = {
				{-5.5/16, -3/16},
				{-5.5/16, 0/16},
				{-5.5/16, -3/16},
				{-5/16, -4/16}
			},
			rightattack = {
				{4/16, -5/16},
				{4/16, -5/16},
				{4/16, -5/16},
				{4/16, -5/16}
			},
			upattack = {
				{3.5/16, 0},
				{3.5/16, 0},
				{3.5/16, 0},
				{3.5/16, 0}
			},
			leftattack = {
				{-3/16, 0},
				{-3/16, 0},
				{-3/16, 0},
				{-3/16, 0}
			},
			downattack = {
				{-2.5/16, -7/16},
				{-2.5/16, -7/16},
				{-2.5/16, -7/16},
				{-2.5/16, -7/16}
			}
		}
	},
	sword = {
		position = {x = 0, y = 0,
					sx = 1, sy = 1,
					rotation = 0
		},
		lockto = {
			id = 1,
			offx = 7/16,
			offy = 0
		},
		animate = {
			img_name = "sword",
			img = "sword.png",
			frame = 1,
			frames = 1,
			rotation = 0,
			animate = false,
			looptime = 1,
			defaulttime = 1
		}

	},
	block = {
		position = {x = 0, y = 0,
					sx = 1, sy = 1,
					rotation = 0
		},
		collision = {
			offx = 0,
			offy = 0,
			w = 1,
			h = 1
		},
		animate = {
			img_name = "block",
			img = "block.png",
			frame = 1,
			frames = 1,
			animate = false,
			looptime = 1,
			defaulttime = 1
		}
	}
}

local entities = {
	man = {
		control = {
			up = "W",
			down = "S",
			left = "A",
			right = "D",
			attack = "Space",
			lockdirection = "Left Shift",
			interact = "Return",
			freeze_controls = "P",
			can_control = true
		},
		sprite = {
			img = "man.png",
			scale = 1,
			framex = 1,
			framey = 1,
			framesx = 8,
			framesy = 4,
			animate = false,
			looptime = .8,

			actionToFrameX = {
				max = 2,
				walk = 1,
				attack = 2
			},

			directionToFrameY = {
				down = 1,
				up = 2,
				right = 3,
				left = 4,
			}
		},
		position = {
			x = "$1", y = "$2",
			w = 14/16, h = 19/16
		},
		movement = {
			dx = 0,
			dy = 0,
			direction = "down",
			is_moving = false,
			changed = false
		},
		state = {
			action = "walk"
		},
		collision = {
			offx = 0,
			offy = -0.1875,
			w = .75,
			h = 1
		}
	},
	sword = {
		position = {
			x = "$1", y = "$2",
			w = 16/16, h = 5/16
		},
		collision = {
			offx = 0,
			offy = 0,
			w = 1,
			h = 5/16
		},
		sprite = {
			img = "sword.png",
			scale = 1,
			framex = 1,
			framey = 1,
			framesx = 1,
			framesy = 1,
			animate = false,
			looptime = .8
		},
		pickup = {

		}
	},
	block = {
		position = {
			x = "$1", y = "$2",
			w = 16/16, h = 5/16
		},
		collision = {
			offx = 0,
			offy = 0,
			w = 1,
			h = 1
		},
		sprite = {
			img = "block.png",
			scale = 1,
			framex = 1,
			framey = 1,
			framesx = 1,
			framesy = 1,
			animate = false,
			looptime = .8
		}
	}
}

return entities