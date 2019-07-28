tool
extends ItemList

var atom_names = null

const ATOM_ICONS = [ preload("res://addons/goap/icons/atom_false.png"), preload("res://addons/goap/icons/atom_true.png"), preload("res://addons/goap/icons/atom_dontcare.png") ]

signal state_updated

func _ready():
	pass # Replace with function body.

func update_list(atoms, state):
	atom_names = atoms
	clear()
	for i in range(atoms.size()):
		var atom : String = atoms[i]
		var atom_state = 2 if (((state.mask >> i) & 1) == 0) else (1 if (((state.value >> i) & 1) == 1) else 0)
		add_item(atom, ATOM_ICONS[atom_state])
		set_item_metadata(i, atom_state)

func on_item_selected(index):
	unselect(index)
	var atom_value = get_item_metadata(index)
	atom_value = (atom_value+1) % 3
	set_item_metadata(index, atom_value)
	set_item_icon(index, ATOM_ICONS[atom_value])
	var desc = PoolStringArray()
	for i in range(atom_names.size()):
		match get_item_metadata(i):
			0: desc.append("!"+atom_names[i])
			1: desc.append(atom_names[i])
	emit_signal("state_updated", desc.join(" "))
