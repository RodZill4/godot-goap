extends Spatial

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	seed(OS.get_unix_time())
	var tree_positions = PoolVector2Array()
	for i in range(5):
		var tree = preload("res://goap_example/tree/tree.tscn").instance()
		while true:
			var p = Vector2((randf()-0.5)*40.0, (randf()-0.5)*40.0)
			var ok = true
			for t in tree_positions:
				if (p-t).length() < 3:
					ok = false
					break
			if ok:
				tree.translation = Vector3(p.x, 0, p.y)
				tree_positions.append(p)
				break
		add_child(tree)
		tree.set_grown()
