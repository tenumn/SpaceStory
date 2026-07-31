extends Node

@export var test_item_id: String = "wheat"
@export var fallback_distance: float = 5.0
@onready var camera: Camera3D = get_viewport().get_camera_3d()

func _input(event: InputEvent):
	# 仅处理鼠标左键点击
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		spawn_at_mouse_position()

func spawn_at_mouse_position():
	if camera == null:
		printerr("未找到摄像机，无法发射射线")
		return
	
	# 从摄像机向鼠标方向发射射线
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000.0  # 射线距离
	
	# 执行射线检测（检测所有碰撞层，可根据需要过滤）
	var space_state = camera.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.new()
	query.from = from
	query.to = to
	query.collide_with_areas = true   # 如果希望点击Area也能检测
	query.collide_with_bodies = true  # 检测刚体/静态体
	
	var result = space_state.intersect_ray(query)
	
	var spawn_position: Vector3
	if result:
		# 点击到了物体，使用碰撞点
		spawn_position = result.position
		# 可选：稍微抬高一点，避免掉落到地面以下
		spawn_position.y += 0.5
	else:
		# 未点击到任何物体，在摄像机前方固定距离生成
		var forward = -camera.global_transform.basis.z  # 摄像机朝向
		spawn_position = camera.global_position + forward * fallback_distance
		# 也可以保持在地面高度，这里假设y=0
		spawn_position.y = 0.0
	
	# 调用全局生成器
	var dropped = ItemRegistry.spawn_by_id(get_tree().current_scene, spawn_position, test_item_id)
	if dropped:
		print("成功生成掉落物: ", test_item_id, " 位置: ", spawn_position)
	else:
		printerr("生成失败，请检查物品ID是否正确或注册表是否包含该物品")
