tool
extends EditorPlugin

func _enter_tree():
	add_tool_menu_item("GOAP Simulator", self, "open_simulator")

func _exit_tree():
	remove_tool_menu_item("GOAP Simulator")

func open_simulator(foo):
	var selection = get_editor_interface().get_selection().get_selected_nodes()
	var node = null
	if selection.size() == 1 && selection[0].get_script() == preload("res://addons/goap/action_planner.gd"):
		node = selection[0]
	print(node)