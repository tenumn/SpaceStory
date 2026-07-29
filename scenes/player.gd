extends CharacterBody3D


@export var speed = 5.0
@export var jump_velocity = 4.5
@export var angle_speed = 15

@export var model:Node3D


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
		model.global_rotation.y=lerp_angle(model.global_rotation.y,atan2(input_dir.x,input_dir.y),delta*angle_speed)
	
	move_and_slide()
