tool
extends HSplitContainer

var action_planner : GOAPActionPlanner = null
var current_action : TreeItem = null
var just_selected : bool = false

onready var action_list = $VBoxContainer/ActionList
onready var preconditions_list = $grid/Preconditions
onready var effect_list = $grid/Effect

const ATOM_ICONS = [ preload("res://addons/goap/icons/atom_false.png"), preload("res://addons/goap/icons/atom_true.png"), preload("res://addons/goap/icons/atom_dontcare.png") ]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func add_action_to_list(a):
	if a.get_script() == preload("res://addons/goap/goap_action.gd"):
		var item = action_list.create_item(action_list.get_root())
		item.set_text(0, a.action)
		item.set_metadata(0, a)

func edit(ap: GOAPActionPlanner):
	action_planner = ap
	action_planner.parse_actions(true)
	action_list.clear()
	var item : TreeItem = action_list.create_item(null)
	for a in action_planner.get_children():
		add_action_to_list(a)
	current_action = null
	just_selected = false
	preconditions_list.clear()
	effect_list.clear()


func on_action_list_gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and !event.pressed and current_action != null and just_selected:
		current_action.set_editable(0, true)
		just_selected = false

func on_action_selected():
	just_selected = true
	$VBoxContainer/HBoxContainer/DeleteAction.disabled = false
	if current_action != null:
		current_action.set_editable(0, false)
	current_action = action_list.get_selected()
	var action : GOAPAction = current_action.get_metadata(0)
	if action != null:
		preconditions_list.update_list(action_planner.state_atoms, action_planner.parse_state(action.preconditions))
		effect_list.update_list(action_planner.state_atoms, action_planner.parse_state(action.effect))

func on_no_action_selected():
	if current_action != null:
		current_action.set_editable(0, false)
	current_action = null
	$VBoxContainer/HBoxContainer/DeleteAction.disabled = true
	preconditions_list.clear()
	effect_list.clear()

func on_action_renamed():
	if current_action != null:
		var action = current_action.get_metadata(0)
		var text = current_action.get_text(0)
		action.name = text
		action.action = text
		var foo = Node.new()
		action_planner.add_child(foo)
		foo.queue_free()

func add_action():
	var action = preload("res://addons/goap/goap_action.gd").new()
	action.name = "new_action"
	action.action = "new_action"
	action_planner.add_child(action)
	action.set_owner(action_planner.get_owner())
	add_action_to_list(action)

func delete_current_action():
	if current_action != null:
		current_action.get_metadata(0).queue_free()
		action_list.get_root().remove_child(current_action)
		on_no_action_selected()

func update_preconditions(value):
	print(value)
	current_action.get_metadata(0).preconditions = value
	
func update_effect(value):
	current_action.get_metadata(0).effect = value
