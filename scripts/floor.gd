class_name Floor
extends Node2D

const PLAYER_SCENE := preload("res://scenes/player.tscn")

@export var biome: Biome

@onready var map: Map = $Map
@onready var entities: Node = $Entities


func _ready() -> void:
	map.entities = entities
	map.biome = biome
	map.generate_map()
	spawn_player()


func spawn_player() -> void:
	var player := PLAYER_SCENE.instantiate()
	var room = map.rooms[0]
	var starting_pos: Vector2 = room.position + room.size / 2
	player.position = starting_pos * Globals.TILE_SIZE + Vector2(Globals.TILE_SIZE / 2, Globals.TILE_SIZE / 2)
	entities.add_child(player)
