extends StaticBody

var count = 0

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func get_object_type():
	return "box"

func action(character):
	if character.store_held("wood"):
		count += 1
		$CanvasLayer/Label.text = str(count)
		return true
	else:
		return false
