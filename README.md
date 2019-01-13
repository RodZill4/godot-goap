# godot-goap

This addon provides a simple Goal Oriented Action Planning implementation for the Godot Engine and an example of how it can be used.

## What is GOAP ?

GOAP is an approach to non-playing character AI where:
* the state of the character (and its environment) is defined as a set of boolean variables
* the possible actions for the character are defined as a precondition and an outcome, defined in terms of those boolean variables
* the action planner generates a sequence of actions from an initial state and a goal

This approach makes it easy to create complex behaviors (without explicitly defining the corresponding state machine), and add or remove possible actions dynamically.

## The addon

The Action Planner is defined in the **action_planner.gd**, that can be attached to a Node. It provides the following methods:
* **clear_actions()**: this method clears all defined actions
* **add_action(function, preconditions, effect, cost)**: this method adds a new action
  * **function** is the string that represents the action (and that will be returned in plans)
  * **preconditions** is a string describing the action's preconditions
  * **outcome** is a string describing the action's outcome
  * **cost** is a value that describes the action's cost (used to calculate the *cheapest* plan)
* **parse_actions()**: this method clears all defined actions and parses all actions that are defined as subnodes
* **plan(state, goal)**: this method accepts a state and a goal, described as strings and returns a plan as an Array of strings

The syntax for all boolean expressions is simple. Valid characters for variables are letters, digits and underscores. A **!** prefix for a variable means that the variable is set to false. All other characters are separators (but space is a good choice for readability).

For example, is the state of the character is **!hungry has_axe sees_tree !sees fruit**, this means the character is not hungry, is holding an axe, and he sees a tree and no fruit.

When attaching the action planner script to a Node in a scene, actions can be added as children of type Node with the **action.gd** script, whose exported variables are similar to the parameters of the **add_action** method. In this case, actions are parsed automatically when the planner is inserted in the scene tree, and the **plan** can directly be used.

Actions can also be declared programmatically using the **clear_actions** and **add_action** functions. 

## The example

The example is a scene that shows a character, a box, an axe and a few trees. The character can be controlled either directly or by the AI that can be started using the G key.

[![A small video of the demo](https://img.youtube.com/vi/orQPfIlsfk4/0.jpg)](https://www.youtube.com/watch?v=orQPfIlsfk4)

The character can only hold one object at a time: an axe, a piece of wood or a fruit.

The main goal of the AI is to gather wood and stay alive. A secondary goal is to make sure there are always more than 10 trees available (so the character does not just concentrate on gathering wood, but makes sure wood will be available in the future).

The boolean variables that describe the world are:
* **has_axe**: the character holds an axe
* **sees_axe**: the character sees an axe, either in his hands or on the floor
* **has_wood**: the character holds a piece of wood
* **sees_wood**: the character sees a piece of wood, either in his hands or on the floor
* **has_fruit**: the character holds a fruit
* **sees_fruit**: the character sees a fruit, either in his hands or on the floor
* **hungry**: the character is hungry, his life bar is less than 75% (life decreases with time)
* **sees_tree**: the character sees a tree
* **sees_box**: the character sees a box where it can store wood
There are also additional variables that describe goals, but are not part of the world state:
* **store_wood**: the character stored wood in the box (this is the main goal)
* **sees growing_tree**: the character sees a growing tree (this is the secondary goal, that is active only when the character sees less than 10 mature trees)

The available actions are:
* **store_wood**: the character will store wood into the box
  * *preconditions:* has_wood sees_box
  * *outcome:* !has_wood wood_stored
* **cut_tree**: the character cuts a tree (which can generate pieces of wood and fruits)
  * *preconditions:* has_axe sees_tree
  * *outcome:* sees_wood sees_fruit
* **pickup_wood**: the character picks up wood (and drops whatever he's holding)
  * *preconditions:* sees_wood !has_wood
  * *outcome:* has_wood !has_fruit !has_axe
* **pickup_fruit**: the character picks up a fruit (and drops whatever he's holding)
  * *preconditions:* sees_fruit !has_fruit
  * *outcome:* has_fruit !has_axe !has_wood
* **pickup_axe**: the character picks up an axe (and drops whatever he's holding)
  * *preconditions:* sees_axe !has_axe
  * *outcome:* has_axe !has_fruit !has_wood
* **grow_tree**: the character uses a fruit to grow a tree
  * *preconditions:* has_fruit
  * *outcome:* !has_fruit sees_growing_tree
* **eat_fruit**: the character eats a fruit to grow a tree
  * *preconditions:* has_fruit
  * *outcome:* !has_fruit !hungry
* **wait**: the character waits for growing trees to become mature (this action will avoid action planning failure in case no mature tree is available)
  * *preconditions:* sees_growing_tree
  * *outcome:* sees_tree
