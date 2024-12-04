class_name Door
extends Area2D

const TILESET := preload("res://resources/dungeon_tileset.tres")

enum DoorState {
	OPEN,
	CLOSED,
	LOCKED
}

@export var biome: Biome
@export var state: DoorState : set = _set_state
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var sprite_2d: Sprite2D = $Sprite2D

var source: TileSetAtlasSource

func _ready() -> void:
	source = TILESET.get_source(biome.world_atlas_source_id)
	collision_shape_2d.shape.set("size", TILESET.tile_size)
	state = DoorState.OPEN

func _set_state(value: DoorState) -> void:
	state = value
	sprite_2d.texture = get_state_sprite()


func get_state_sprite() -> AtlasTexture:
	var atlas_coords: Vector2i

	match state:
		DoorState.OPEN:
			atlas_coords = biome.open_door_atlas
		DoorState.CLOSED:
			atlas_coords = biome.closed_door_atlas
		DoorState.LOCKED:
			atlas_coords = biome.closed_door_atlas

	var tile_size := TILESET.tile_size
	var atlas_texture := AtlasTexture.new()

	atlas_texture.atlas = source.texture
	atlas_texture.region = Rect2i(atlas_coords * tile_size, tile_size)

	return atlas_texture
