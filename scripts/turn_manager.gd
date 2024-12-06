class_name TurnManager
extends Node

@onready var floor: Floor = %Floor

var entities: Node
var turn_queue: Array = []

func _ready() -> void:
	entities = floor.entities
	turn_queue = entities.get_children()
	EventBus.player_moved.connect(_on_player_moved)


func start_turn() -> void:
	var current = turn_queue[0]

	if current is Player:
		print("Player's turn")
		current.take_turn()
	#elif current is Enemy:
		#print("Enemy's turn")
		#current.take_turn()


func advance_turn() -> void:
	rotate_turn_queue()
	start_turn()


func rotate_turn_queue() -> void:
	if turn_queue.size() > 0:
		var first_element = turn_queue.pop_front()
		turn_queue.append(first_element)


func _on_player_moved(position: Vector2) -> void:
	print("Player has moved")
	advance_turn()
