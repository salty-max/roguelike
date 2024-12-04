class_name Tile
extends Resource

enum TileType {
	FLOOR,
	WALL,
	DOOR
}

@export var type: TileType
@export var solid: bool
