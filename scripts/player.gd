extends CharacterBody3D


@export var speed: float = 5.0


func _physics_process(delta: float) -> void:
	# 获取输入方向 (WASD + 方向键)
	var input_dir := Vector3(
		Input.get_axis("move_left", "move_right") + Input.get_axis("ui_left", "ui_right"),
		0.0,
		Input.get_axis("move_up", "move_down") + Input.get_axis("ui_up", "ui_down")
	).normalized()

	# 应用移动 (XZ平面)
	if input_dir != Vector3.ZERO:
		velocity.x = input_dir.x * speed
		velocity.z = input_dir.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed * delta * 10)
		velocity.z = move_toward(velocity.z, 0.0, speed * delta * 10)

	move_and_slide()

	# 根据移动方向旋转角色朝向
	if input_dir.length() > 0.1:
		var look_target := Vector3(
			global_position.x + input_dir.x,
			global_position.y,
			global_position.z + input_dir.z
		)
		look_at(look_target, Vector3.UP)
