extends CharacterBody3D


@export var speed = 5.0
@export var jump_velocity = 4.5
@export var angle_speed = 15

@export var model: Node3D

# ---------- 摄像机滚轮缩放 ----------
@export var camera_min_height: float = 3.0
@export var camera_max_height: float = 20.0
@export var camera_zoom_speed: float = 1.5

@onready var camera_3d: Camera3D = $Camera3D

# 摄像机与水平面的夹角（弧度），用于保持摄像机角度不变
var _camera_angle: float


func _ready() -> void:
	# 根据摄像机初始位置计算俯仰角（保持该角度不变）
	var initial_pos: Vector3 = camera_3d.position
	_camera_angle = atan2(initial_pos.y, initial_pos.z)


func _input(event: InputEvent) -> void:
	# 鼠标滚轮缩放摄像机
	if event is InputEventMouseButton:
		var is_zoom_out: bool
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			is_zoom_out = false
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			is_zoom_out = true
		else:
			return

		# 计算新的摄像机高度
		var current_height: float = camera_3d.position.y
		var new_height: float = current_height + (camera_zoom_speed if is_zoom_out else -camera_zoom_speed)
		new_height = clampf(new_height, camera_min_height, camera_max_height)

		# 保持摄像机角度不变，计算对应的 Z 偏移
		var new_z: float = new_height / tan(_camera_angle)
		
		# 更新摄像机位置
		camera_3d.position.y = new_height
		camera_3d.position.z = new_z



func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		#
	if input_dir != Vector2.ZERO:
		model.global_rotation.y = lerp_angle(model.global_rotation.y, atan2(input_dir.x, input_dir.y), delta * angle_speed)

	move_and_slide()
