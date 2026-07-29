extends Node3D


@export var camera_height: float = 8.0
@export var camera_distance: float = 8.0
@export var camera_smoothing: float = 4.0

@onready var player: CharacterBody3D = $Player
@onready var camera: Camera3D = $Camera3D


func _ready() -> void:
	camera.current = true


func _process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	# 计算目标相机位置: 在角色上方偏后方
	var target_pos := player.global_position + Vector3(0, camera_height, camera_distance)

	# 平滑跟随
	camera.global_position = camera.global_position.lerp(target_pos, camera_smoothing * delta)

	# 始终看向角色
	camera.look_at(player.global_position, Vector3.UP)
