class_name Player
extends CharacterBody2D

const DIRECTIONS := {
	"up": Vector2.UP,
	"down": Vector2.DOWN,
	"left": Vector2.LEFT,
	"right": Vector2.RIGHT
}

@export var move_speed := 0.2
@export var bounce_height := 4

@onready var sprite: AnimatedSprite2D = $Sprite

var is_moving := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_moving:
		handle_input()


func handle_input() -> void:
	var direction := Vector2.ZERO

	if Input.is_action_just_pressed("move_up"):
		direction = DIRECTIONS["up"]
	elif Input.is_action_just_pressed("move_down"):
		direction = DIRECTIONS["down"]
	elif Input.is_action_just_pressed("move_left"):
		direction = DIRECTIONS["left"]
	elif Input.is_action_just_pressed("move_right"):
		direction = DIRECTIONS["right"]

	if direction != Vector2.ZERO:
		attempt_move(direction)


func attempt_move(direction: Vector2) -> void:
	var target_position = position + direction * Globals.TILE_SIZE
	if can_move_to(target_position):
		move_to(target_position)


func can_move_to(target_position: Vector2) -> bool:
	return true


func move_to(target_position: Vector2) -> void:
	is_moving = true
	var tween := create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	var start_position = sprite.position
	var up_position = start_position - Vector2(0, bounce_height)
	var bounce_half_speed := move_speed / 2
	tween.tween_property(sprite, "position", up_position, move_speed / 3)
	tween.tween_property(self, "position", target_position, move_speed / 3)
	tween.tween_property(sprite, "position", start_position, move_speed / 3)


	tween.finished.connect(_on_move_finished)


func _on_move_finished() -> void:
	is_moving = false
	EventBus.player_moved.emit(position)
