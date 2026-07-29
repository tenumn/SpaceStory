# lib.gd - 通用地图工具库
extends RefCounted
class_name Lib
## 清除 GridMap 中指定矩形区域内的地砖
## @param grid_map: 要操作的 GridMap 节点
## @param corner_a: 矩形对角点A（网格坐标）
## @param corner_b: 矩形对角点B（网格坐标）
## @return: 清除的地砖数量
static func clear_area(grid_map: GridMap, corner_a: Vector3i, corner_b: Vector3i) -> int:
	if not grid_map:
		return 0
	
	var min_x = mini(corner_a.x, corner_b.x)
	var max_x = maxi(corner_a.x, corner_b.x)
	var min_y = mini(corner_a.y, corner_b.y)
	var max_y = maxi(corner_a.y, corner_b.y)
	var min_z = mini(corner_a.z, corner_b.z)
	var max_z = maxi(corner_a.z, corner_b.z)
	
	var cleared_count = 0
	for cell in grid_map.get_used_cells():
		if cell.x >= min_x and cell.x <= max_x and \
		   cell.y >= min_y and cell.y <= max_y and \
		   cell.z >= min_z and cell.z <= max_z:
			grid_map.set_cell_item(cell, -1)
			cleared_count += 1
	
	return cleared_count

## 根据等级从数据表中获取区域并清除
## @param grid_map: 要操作的 GridMap 节点
## @param level: 等级值
## @param level_areas: 等级-区域映射字典
## @return: 清除的地砖数量
static func clear_area_by_level(grid_map: GridMap, level: float, level_areas: Dictionary) -> int:
	var area = level_areas.get(level)
	if area and area.size() >= 2:
		return clear_area(grid_map, area[0], area[1])
	return 0
