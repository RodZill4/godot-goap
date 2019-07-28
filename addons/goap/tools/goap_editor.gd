tool
extends Panel

func _ready():
	pass # Replace with function body.

func edit(ap: GOAPActionPlanner):
	$VBoxContainer/TabContainer/Editor.edit(ap)
	$VBoxContainer/TabContainer/Simulator.simulate(ap)
