extends Spatial

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func anim(a):
	var anim = $"Human Armature/AnimationPlayer"
	if anim.current_animation != a:
		anim.play(a)