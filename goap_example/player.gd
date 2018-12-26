extends KinematicBody

export(float) var run_speed = 10.0

var motion = Vector3(0, 0, 0)
var previous_position = Vector3(0, 0, 0)
var blocked_time = 0.0
var target = null
var life = 100.0

var held = null

signal action_end

func _ready():
	pass

func _physics_process(delta):
	life -= delta
	if life <= 0:
		set_physics_process(false)
		$Model.anim("Die")
		return
	$UI/ProgressBar.value = life
	motion.y += -9.8*delta
	move_and_slide(motion, Vector3(0, 1, 0))
	var direction = Vector2(0, 0)
	if target == null:
		direction.y += run_speed*Input.get_joy_axis(0, 0)
		direction.x -= run_speed*Input.get_joy_axis(0, 1)
		if Input.is_action_pressed("ui_up"):
			direction.x += run_speed
		if Input.is_action_pressed("ui_down"):
			direction.x -= run_speed
		if Input.is_action_pressed("ui_left"):
			direction.y -= run_speed
		if Input.is_action_pressed("ui_right"):
			direction.y += run_speed
		var camera = get_node("../Camera")
		if camera != null:
			direction = direction.rotated(-0.5*PI - camera.rotation.y)
	else:
		var remaining = Vector2(target.x, target.z) - Vector2(translation.x, translation.z)
		if remaining.length() < 0.8:
			target = null
			emit_signal("action_end")
			return
		else:
			direction = run_speed*(remaining).normalized()
	if direction.length() > run_speed:
		direction /= direction.length()
		direction *= run_speed
	var h_motion_influence = delta
	if is_on_floor():
		h_motion_influence *= 10
		motion.y = 0
		if Input.is_action_just_pressed("jump"):
			motion.y = 10
	var h_motion = Vector2(motion.x, motion.z)
	h_motion.x = lerp(h_motion.x, direction.x, h_motion_influence)
	h_motion.y = lerp(h_motion.y, direction.y, h_motion_influence)
	if (previous_position-translation).length()/delta > 1:
		$Model.anim("Run")
		rotation.y = 0.5*PI - h_motion.angle()
		blocked_time = 0.0
	else:
		$Model.anim("Idle")
		if (previous_position-translation).length()/delta < 0.1:
			blocked_time += delta
			if blocked_time > 3.0:
				target = null
				emit_signal("action_end")
	previous_position = translation
	motion.x = h_motion.x
	motion.z = h_motion.y

func run_to(p):
	blocked_time = 0.0
	target = p

func get_nearest_object(object_type = null):
	var nearest_distance = 100
	var nearest_object = null
	for o in $Detect.get_overlapping_bodies():
		if o.is_inside_tree():
			var distance = (global_transform.origin - o.global_transform.origin).length()
			if o != self and o.get_script() != null and (object_type == null or o.get_object_type() == object_type) and distance < nearest_distance:
				nearest_distance = distance
				nearest_object = o
	return { object=nearest_object, distance=nearest_distance }

func find_good_tree_location():
	var box = get_node("../Box")
	for i in range(5, 100, 5):
		for j in range(10):
			var p = Vector3(rand_range(-i, i), 0.0, rand_range(-i, i))
			var ok = true
			for c in get_parent().get_children():
				if (c == box or c.has_method("get_object_type") and c.get_object_type().left(4) == "tree") and (c.translation - p).length() < 5.0:
					ok = false
			if ok:
				return p
	return null

func _input(event):
	if event is InputEventKey and event.is_pressed():
		if event.get_scancode() == KEY_SPACE:
			var obj = get_nearest_object()
			if obj.distance < 1.0 and obj.object.has_method("action"):
				obj.object.action(self)
			else:
				plant_fruit()
		elif event.get_scancode() == KEY_S:
			scripted_behaviour()
		elif event.get_scancode() == KEY_G:
			goap()

func holds(object_type):
	if held != null and held.get_object_type() == object_type:
		return true
	return false

func update_held_icon():
	if held == null || name != "Player":
		$UI/Held.visible = false
	else:
		$UI/Held.visible = true
		$UI/Held.texture = load("res://goap_example/"+held.get_object_type()+"/"+held.get_object_type()+".png")

func pickup_object(object_type):
	var nearest = get_nearest_object(object_type)
	if nearest.object == null or nearest.distance > 1.0:
		return false
	pickup(nearest.object)
	return true

func pickup(object):
	if held != null:
		get_parent().add_child(held)
		held.translation = translation + Vector3(0.0, 1.0, 1.0).rotated(Vector3(0.0, 1.0, 0.0), rotation.y)
		held.apply_impulse(Vector3(0.0, 0.0, 0.0), Vector3(0.0, 1.0, 1.0).rotated(Vector3(0.0, 1.0, 0.0), rotation.y))
	object.get_parent().remove_child(object)
	held = object
	update_held_icon()

func store_held(object_type):
	if held != null && held.get_object_type() == object_type:
		held = null
		update_held_icon()
		return true
	else:
		return false

func eat_fruit():
	if held != null and held.get_object_type() == "fruit":
		held.free()
		held = null
		update_held_icon()
		life += 20
		if life > 100: life = 100
		return true
	return false
	
func plant_fruit():
	if held != null and held.get_object_type() == "fruit":
		held.free()
		held = null
		update_held_icon()
		var tree = preload("res://goap_example/tree/tree.tscn").instance()
		tree.translation = translation + 2.0*Vector3(sin(rotation.y), 0.0, cos(rotation.y))
		get_parent().add_child(tree)
		return true
	return false

func scripted_behaviour():
	while true:
		var wood = get_nearest_object("wood").object
		if wood != null:
			target = wood.translation
			yield(self, "action_end")
			wood = get_nearest_object("wood").object
			if wood != null:
				pickup(wood)
				var box = get_nearest_object("box").object
				if box != null:
					target = box.translation
					yield(self, "action_end")
					box.action(self)
		else:
			if !holds("axe"):
				var axe = get_nearest_object("axe").object
				if axe != null:
					target = axe.translation
					yield(self, "action_end")
					axe = get_nearest_object("axe").object
					if axe != null:
						pickup(axe)
			else:
				print("Cannot see an axe")
			if holds("axe"):
				var tree = get_nearest_object("tree").object
				if tree == null:
					break
				target = tree.translation
				yield(self, "action_end")
				tree = get_nearest_object("tree").object
				if tree != null:
					tree.action(self)
					$Timer.start()
					yield($Timer, "timeout")
			else:
				$Timer.start()
				yield($Timer, "timeout")

func goap():
	var action_planner = get_node("ActionPlanner")
	if action_planner == null:
		return
	while true:
		# Calculate current state
		var state = ""
		for o in ["axe", "wood", "fruit"]:
			if !holds(o):
				state += "!"
			state += "has_"
			state += o
			state += " "
		for o in ["axe", "wood", "fruit", "tree", "box"]:
			if get_nearest_object(o).object == null:
				state += "!"
			state += "sees_"
			state += o
			state += " "
		# calculate plan
		var goal = "wood_stored"
		if life < 75:
			goal += " !hungry"
		else:
			goal += " sees_growing_tree"
		var plan = action_planner.plan(state, goal)
		$UI/ActionQueue.text = PoolStringArray(plan).join(", ")
		# execute plan
		for a in plan:
			var error = false
			if a == "get_axe":
				var axe = get_nearest_object("axe").object
				if holds("axe") or axe == null:
					error = true
				else:
					run_to(axe.translation)
					yield(self, "action_end")
					error = !pickup_object("axe")
			elif a == "get_wood":
				var wood = get_nearest_object("wood").object
				if holds("wood") or wood == null:
					error = true
				else:
					run_to(wood.translation)
					yield(self, "action_end")
					error = !pickup_object("wood")
			elif a == "get_fruit":
				var fruit = get_nearest_object("fruit").object
				if holds("fruit") or fruit == null:
					error = true
				else:
					run_to(fruit.translation)
					yield(self, "action_end")
					error = !pickup_object("fruit")
			elif a == "cut_tree":
				var tree = get_nearest_object("tree").object
				if holds("tree") or tree == null:
					error = true
				else:
					run_to(tree.translation)
					yield(self, "action_end")
					tree.action(self)
			elif a == "store_wood":
				var box = get_nearest_object("box").object
				if box != null:
					run_to(box.translation)
					yield(self, "action_end")
					box.action(self)
			elif a == "plant_fruit":
				var p = find_good_tree_location()
				if p != null:
					run_to(p)
					yield(self, "action_end")
					error = !plant_fruit()
				else:
					error = true
			elif a == "eat_fruit":
				error = !eat_fruit()
			elif a == "wait":
				error = true
			else:
				print("Cannot perform action "+a)
				error = true
			if error: break
			$Timer.start()
			yield($Timer, "timeout")
		$Timer.start()
		yield($Timer, "timeout")
