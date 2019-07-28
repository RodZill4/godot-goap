tool
extends EditorPlugin

var editor = null
var edited_object = null

func _enter_tree():
	var selection = get_editor_interface().get_selection().get_selected_nodes()
	if selection.size() == 1 and selection[0] is GOAPActionPlanner:
		edited_object = selection[0]
		make_visible(true)

func _exit_tree():
	if editor != null:
		remove_control_from_bottom_panel(editor)
		editor.queue_free()
		editor = null

func handles(object):
	if object.script == preload("res://addons/goap/goap_action_planner.gd"):
		edited_object = object
		return true
	return false

func make_visible(visible):
	remove_control_from_bottom_panel(editor)
	if visible:
		if editor == null:
			editor = preload("res://addons/goap/tools/goap_editor.tscn").instance()
		add_control_to_bottom_panel(editor, "GOAP")
		editor.edit(edited_object)
