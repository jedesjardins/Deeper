
local hitboxes = {
	punch_hitbox = {
		lifetime = {
			time = "$2"
		},
		position = {
			x = 0, y = 0
		},
		lockon = {
			lock_id = "$1",
			offx = 2/16,
			offy = -1/16
		},
		collision = {
			offx = 0,
			offy = 0,
			w = 3/16,
			h = 3/16
		},
		hitbox = {
			ignore_id = "$1",
			ignore_hit_ids = {},
			class = "physical"
			effects = {},
			damage = {
				health = -5
			}
		}
	},
	sword_hitbox = {
		lifetime = {
			time = "$2"
		},
		position = {
			x = 0, y = 0
		},
		lockon = {
			lock_id = "$1",
			offx = 6.5/16,
			offy = -1/16
		},
		collision = {
			offx = 0,
			offy = 0,
			w = 13/16,
			h = 3/16,
			orig_w = 13/16,
			orig_h = 3/16
		},
		hitbox = {
			ignore_id = "$1",
			ignore_hit_ids = {},
			class = "physical"
			effects = {},
			damage = {
				health = -25
			}
		}
	},
	magic_bolt_hitbox = {
		lifetime = {
			time = inf
		},
		sprite = {
			img = "bolt.png",
			scale = 1,
			framex = 1,
			framey = 1,
			framesx = 1,
			framesy = 1,
			animate = false,
			looptime = .8
		},
		position = {
			x = 0, y = 0,
			w = 5/16, h = 3/16
		},
		movement = {
			dx = 0,
			dy = 0,
			direction = "down",
			is_moving = true,
			changed = false
		},
		collision = {
			offx = 0,
			offy = 0,
			w = 3/16,
			h = 1/16,
			orig_w = 3/16,
			orig_h = 1/16
		},
		hitbox = {
			ignore_id = "$1",
			ignore_hit_ids = {},
			class = "magic"
			effects = {},
			damage = {
				health = 10
			}
		},
		projectile = {
			delete_on_collision = true,
			stop_on_collision = true
		}
	},
	arrow_hitbox = {
		lifetime = {
			time = inf
		},
		sprite = {
			img = "arrow.png",
			scale = 1,
			framex = 1,
			framey = 1,
			framesx = 1,
			framesy = 1,
			animate = false,
			looptime = .8
		},
		position = {
			x = 0, y = 0,
			w = 12/16, h = 3/16
		},
		movement = {
			dx = 0,
			dy = 0,
			direction = "down",
			is_moving = true,
			changed = false
		},
		collision = {
			offx = 0,
			offy = 0,
			w = 12/16,
			h = 3/16,
			orig_w = 12/16,
			orig_h = 3/16
		},
		hitbox = {
			ignore_id = "$1",
			ignore_hit_ids = {},
			class = "physical",
			effects = {},
			damage = {
				health = -15
			}
		},
		projectile = {
			delete_on_collision = false,
			stop_on_collision = true
		},
		holdable = {
			offx = 0,
			offy = 0,
			hitbox_name = nil
		}
	}
}

return hitboxes