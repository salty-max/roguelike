@tool
class_name Map
extends Node2D

@export var generate: bool
@export var biome: Biome
@export var grid_size: Vector2i
@export var room_count: int
@export var min_room_size: Vector2i
@export var max_room_size: Vector2i

@onready var floor_layer: TileMapLayer = $FloorLayer # Floor
@onready var environment_layer: TileMapLayer = $EnvironmentLayer # Walls and objects


var walls_atlas_id := 0
var world_atlas_id := 1
var rooms: Array[Rect2i] = []
var floor_cells: Array[Vector2i]
var mst: Array = []


func _ready() -> void:
	generate_map()


func _process(delta: float) -> void:
	if generate:
		generate = false
		generate_map()


func generate_map() -> void:
	clear_map()

	if not biome:
		push_error("No biome set")
		return

	place_rooms()
	carve_corridors_with_mst()
	place_walls()


func clear_map() -> void:
	rooms.clear()
	floor_cells.clear()
	floor_layer.clear()
	environment_layer.clear()


###############################################################
# Map generation
###############################################################


func place_rooms() -> void:
	var attempts = 0
	while rooms.size() < room_count and attempts < room_count * 5:
		attempts += 1
		var room_size = Vector2i(
			randi_range(min_room_size.x, max_room_size.x),
			randi_range(min_room_size.y, max_room_size.y)
		)
		var room_pos = Vector2i(
			randi_range(1, grid_size.x - room_size.x - 1),
			randi_range(1, grid_size.y - room_size.y - 1)
		)
		var room = Rect2i(room_pos, room_size)

		if not is_room_valid(room):
			continue

		rooms.append(room)
		carve_room(room)


func carve_room(room: Rect2i) -> void:
	for y in range(room.position.y, room.position.y + room.size.y):
		for x in range(room.position.x, room.position.x + room.size.x):
			floor_layer.set_cell(Vector2i(x, y), world_atlas_id, biome.floor_atlases.pick_random())
			floor_cells.append(Vector2i(x, y))


func carve_corridors_with_mst() -> void:
	var graph = []
	for i in range(rooms.size()):
		for j in range(i + 1, rooms.size()):
			var dist = (rooms[i].position + rooms[i].size / 2).distance_to(
				rooms[j].position + rooms[j].size / 2
			)
			graph.append({"start": i, "end": j, "weight": dist})

	graph = sort_graph_by_weight(graph)
	var parent = initialize_parent(rooms.size())

	mst.clear()
	for edge in graph:
		var start = edge["start"]
		var end = edge["end"]
		if find(start, parent) != find(end, parent):
			union(start, end, parent)
			mst.append(edge)

	for edge in mst:
		var room_a = rooms[edge["start"]]
		var room_b = rooms[edge["end"]]
		carve_corridor(room_a, room_b)


func carve_corridor(room_a: Rect2i, room_b: Rect2i) -> void:
	var start = room_a.position + room_a.size / 2
	var end = room_b.position + room_b.size / 2

	var current = start
	while current != end:
		if current.x != end.x:
			current.x += sign(end.x - current.x)
		elif current.y != end.y:
			current.y += sign(end.y - current.y)

		floor_layer.set_cell(Vector2i(current.x, current.y), world_atlas_id, Vector2i(4, 1))
		floor_cells.append(Vector2i(current.x, current.y))


func place_walls() -> void:
	var wall_tiles = []
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			if is_void_tile(Vector2i(x, y)) and is_adjacent_to_floor(Vector2i(x, y)):
				wall_tiles.append(Vector2i(x, y))

	environment_layer.set_cells_terrain_connect(wall_tiles, 0, 0)


###############################################################
# Helpers
###############################################################


func is_room_valid(room: Rect2i) -> bool:
	for existing_room in rooms:
		if room.intersects(existing_room):
			return false
	return true


func is_void_tile(pos: Vector2i) -> bool:
	return not floor_cells.has(pos)


func is_adjacent_to_floor(pos: Vector2i) -> bool:
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			var neighbor = pos + Vector2i(dx, dy)
			if is_floor_tile(neighbor):
				return true
	return false


func is_floor_tile(pos: Vector2i) -> bool:
	return floor_cells.has(pos)


###############################################################
# Kruskal's Algorithm Helpers
###############################################################


func initialize_parent(size: int) -> Array:
	var parent = []
	for i in range(size):
		parent.append(i)
	return parent


func find(x: int, parent: Array) -> int:
	var root = x
	while root != parent[root]:
		root = parent[root]
	while x != root:
		var next = parent[x]
		parent[x] = root
		x = next
	return root


func union(x: int, y: int, parent: Array) -> void:
	var root_x = find(x, parent)
	var root_y = find(y, parent)
	if root_x != root_y:
		parent[root_x] = root_y


func sort_graph_by_weight(graph: Array) -> Array:
	for i in range(graph.size() - 1):
		for j in range(graph.size() - i - 1):
			if graph[j]["weight"] > graph[j + 1]["weight"]:
				var temp = graph[j]
				graph[j] = graph[j + 1]
				graph[j + 1] = temp
	return graph


###############################################################
# Debug
###############################################################


#func _draw() -> void:
	#for room in rooms:
		#draw_rect(Rect2(room.position, room.size), Color(0, 1, 0, 0.5), true)  # Green for rooms
#
	#for edge in mst:
		#var start = rooms[edge["start"]].position + rooms[edge["start"]].size / 2
		#var end = rooms[edge["end"]].position + rooms[edge["end"]].size / 2
		#draw_line(start, end, Color(1, 0, 0))  # Red for corridors
