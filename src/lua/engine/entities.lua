local entities = {
	player = {
		control = {},
		position = {x = 0, y = 0},
		movement = {
			dx = 0,
			dy = 0,
			direction = "down",
			is_moving = false,
			changed = false,
			--direction = {x, y}
		},
		collision = {
			offx = 0,
			offy = 0,
			w = 1,
			h = 1
		},
		size = {w = 1, h = 1},
		animate = {
			img_name = "guy_", 
			img = "guy_down.png",
			frame = 1,
			frames = 4,
			animate = true,
			looptime = 1,
			defaulttime = 1
		}
	},
	block = {
		position = {x = 1, y = 1},
		size = {w = 1, h = 1},
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
			animate = true,
			looptime = 1,
			defaulttime = 1
		}
	}
}