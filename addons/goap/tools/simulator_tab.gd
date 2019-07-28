tool
extends GridContainer

var action_planner : GOAPActionPlanner = null
var initial : GOAPActionPlanner.State
var goal : GOAPActionPlanner.State

func _ready():
	pass # Replace with function body.

func simulate(ap):
	action_planner = ap
	initial = GOAPActionPlanner.State.new(0, 0)
	goal = GOAPActionPlanner.State.new(0, 0)
	update_ui()

func update_ui():
	$Initial.update_list(action_planner.state_atoms, initial)
	$Goal.update_list(action_planner.state_atoms, goal)

func on_initial_updated(value):
	initial = action_planner.parse_state(value)
	update_plan()

func on_goal_updated(value):
	goal = action_planner.parse_state(value)
	update_plan()

func update_plan():
	$Actions.clear()
	action_planner.parse_actions(true, true)
	var plan = action_planner.plan_from_states(initial, goal)
	for a in plan:
		$Actions.add_item(a)

