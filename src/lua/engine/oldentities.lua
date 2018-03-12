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
		},
		health = {
			max = 100,
			amount = 100
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