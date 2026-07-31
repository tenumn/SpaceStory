extends CharacterBody3D


@export var speed = 5.0
@export var jump_velocity = 4.5
@export var angle_speed = 15

@export var model: Node3D


@export var camera_3d: Camera3D

@export var camera_min_height: float = 3.0
@export var camera_max_height: float = 20.0
@export var camera_zoom_step: float = 1.5        # 每次滚轮改变的高度量
@export var camera_zoom_smooth_speed: float = 20.0  # 平滑跟随速度

var _camera_angle: float
var _target_height: float

#模型和载具路径
@onready var player_model = $characteremployee2
@onready var animation_tree = $AnimationTree

func _ready() -> void:
	# 计算初始俯仰角并保存
	_camera_angle = atan2(camera_3d.position.y, camera_3d.position.z)
	_target_height = camera_3d.position.y


func _input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	# 向上滚动拉近（高度降低），向下滚动推远（高度升高）
	var direction := 0
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		direction = -1
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		direction = 1
	else:
		return

	_target_height = clampf(
		_target_height + direction * camera_zoom_step,
		camera_min_height,
		camera_max_height
	)
	
func _process(delta: float) -> void:
	var current_height := camera_3d.position.y
	if is_equal_approx(current_height, _target_height):
		return

	var new_height := move_toward(current_height, _target_height, camera_zoom_smooth_speed * delta)
	
	camera_3d.position.y = new_height
	camera_3d.position.z = new_height / tan(_camera_angle)
	
	#动画树判定
	animation_tree.set("parameters/has_cart", has_cart_attached())

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
	
func has_cart_attached() -> bool:
	return player_model.get_children().any(func(c): return c.is_in_group("cart"))
