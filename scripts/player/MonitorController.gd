extends Node3D

@export var throw_base_force : float = 0.0        # 最小投掷力度
@export var throw_force_per_second : float = 2.0  # 每秒增加的力度
@export var throw_max_force : float = 30.0        # 力度上限

var near_carts : Array[RigidBody3D] = []
var mounted_cart : RigidBody3D = null
var charge_time : float = 0.0

@onready var player_node : Node3D = get_parent()


func _ready():
	var detector = $CartDetector
	if detector:
		detector.body_entered.connect(_on_cart_entered)
		detector.body_exited.connect(_on_cart_exited)


func _process(delta):
	if Input.is_action_pressed("interact"):
		charge_time += delta


func _input(event):
	if event.is_action_released("interact"):
		if mounted_cart == null:
			# 空手 → 拾取
			if not near_carts.is_empty():
				var cart = _get_closest_cart()
				if cart:
					cart.mount(player_node)
					mounted_cart = cart
		else:
			# 手上有车 → 投掷（力度 = 基础 + 长按时间加成）
			var force = min(throw_base_force + throw_force_per_second * charge_time, throw_max_force)
			mounted_cart.throw_cart(max(force-1,0.2))
			mounted_cart = null

		charge_time = 0.0


func _on_cart_entered(body: Node):
	if body is RigidBody3D and body.is_in_group("entity:cart"):
		if not near_carts.has(body):
			near_carts.append(body)


func _on_cart_exited(body: Node):
	if body is RigidBody3D and body.is_in_group("entity:cart"):
		near_carts.erase(body)


func _get_closest_cart() -> RigidBody3D:
	var closest: RigidBody3D = null
	var min_dist = INF
	var player_pos = player_node.global_position
	for cart in near_carts:
		var dist = player_pos.distance_squared_to(cart.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = cart
	return closest
