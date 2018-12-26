extends StaticBody

export(bool) var can_cut = false

func _ready():
	pass

func get_object_type():
	if can_cut:
		return "tree"
	else:
		return "tree_not_ready"

func set_grown():
	$AnimationPlayer.play("Grown")

func action(character):
	if !can_cut:
		print("This tree cannot be cut")
	elif (character.translation - translation).length() > 1:
		print("This tree is too far")
	elif character.held != null and character.held.get_object_type() == "axe":
		$AnimationPlayer.play("Cut")
		return true
	else:
		print("you need an axe to cut a tree")
	return false

func drop_items():
	for c in [ preload("res://goap_example/wood/wood.tscn"), preload("res://goap_example/fruit/fruit.tscn") ]:
		for i in range(randi() % 6):
			var object = c.instance()
			var direction = Vector3(rand_range(-2.0, 2.0), 0.0, rand_range(-2.0, 2.0))
			object.translation = translation + direction + Vector3(0, 4.0, 0)
			object.rotation = Vector3(rand_range(-3.0, 3.0), rand_range(-3.0, 3.0), rand_range(-3.0, 3.0))
			object.apply_impulse(Vector3(0.0, 0.0, 0.0), direction)
			get_parent().add_child(object)