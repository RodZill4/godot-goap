tool
extends Node
class_name GOAPAction

export(String) var action = null setget set_action, get_action
export(String) var preconditions = ""
export(String) var effect = ""
export(float) var cost = 1

func get_action():
	if action == null || action == "":
		return name
	else:
		return action

func set_action(a):
	action = a
