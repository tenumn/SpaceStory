extends Node3D

# 数据表：等级 -> [对角点A, 对角点B]
const LEVEL_AREAS = {
	1.0: [Vector3i(-27, 0, 18), Vector3i(-18, 1, 31)],
	2.0: [Vector3i(-17, 0, 18), Vector3i(-9, 1, 31)],
	3.0: [Vector3i(-8, 0, 18), Vector3i(-1, 1, 31)],
	4.0: [Vector3i(0, 0, 18), Vector3i(11, 1, 31)],
	5.0: [Vector3i(12, 0, 18), Vector3i(20, 1, 31)],
	6.0: [Vector3i(21, 0, 18), Vector3i(28, 1, 31)],
}

@onready var grid_map: GridMap = $Tiles/NotLoaded

var _level: int = 0

@export var world_level: int:
	get:
		return _level
	set(value):
		_level = value
		update_map_by_level(value)

func _ready():
	update_map_by_level(_level)
	
# 根据等级更新地图（调用 lib 中的工具函数）
func update_map_by_level(level: int):
	if grid_map:
		var cleared = Lib.clear_area_by_level(grid_map, level, LEVEL_AREAS)
		if cleared > 0:
			print("已清除 ", cleared, " 块地砖")
