
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
			effects = {},
			damage = {}
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
			effects = {},
			damage = {}
		}
	}
	wand_hitbox = {
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
			effects = {},
			damage = {}
		}
	}
}

return hitboxes