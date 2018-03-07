local entities = {
	player = {
		position = {x = 0, y = 0,
					sx = 1, sy = 1},
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
			animate = false,
			looptime = .8,
			defaulttime = .8
		}
	},
	block = {
			position = {x = 0, y = 0,
						sx = 1, sy = 1},
			collision = {
				offx = 0,
				offy = 0,
				w = 1,
				h = 1
			},
			animate = {
				img_name = "guy_",
				img = "guy_down.png",
				frame = 1,
				frames = 4,
				animate = false,
				looptime = 1,
				defaulttime = 1
			}
		}
	}

return entities