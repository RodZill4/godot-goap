extends RigidBody

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	pass

func get_object_type():
	return "axe"

func action(character):
	character.pickup(self)
