extends RigidBody3D

@export var move_speed : float = 8.0
@export var turn_speed : float = 3.0
@export var force_multiplier : float = 2.0

var driver : Node3D = null
var can_interact : bool = false
var player_in_range : Node3D = null
var driver_model : Node3D = null

# 投掷相关参数
@export var throw_base_force : float = 1.0          # 最短长按的基础力度
@export var throw_force_per_second : float = 2.0   # 每秒增加的力度
@export var throw_max_force : float = 30.0          # 最大力度上限
@export var charge_threshold : float = 0.3          # 长按判定阈值（秒）

var interact_pressed : bool = false
var interact_hold_time : float = 0.0


func _ready():
	$InteractionArea.body_entered.connect(_on_body_entered)
	$InteractionArea.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	print("检测到物体进入: ", body.name, " 是否玩家组: ", body.is_in_group("Player"))
	print("进入物体:", body.name, " 组:", body.get_groups())
	if body.is_in_group("entity:player"):
		player_in_range = body
		can_interact = true

func _on_body_exited(body):
	if body == player_in_range:
		player_in_range = null
		can_interact = false

func _process(delta):
	# 按键按下瞬间记录
	if Input.is_action_just_pressed("interact"):
		interact_pressed = true
		interact_hold_time = 0.0
	# 按住时累计时间
	if Input.is_action_pressed("interact") and interact_pressed:
		interact_hold_time += delta
	# 松开时根据状态和时长执行对应操作
	if Input.is_action_just_released("interact") and interact_pressed:
		interact_pressed = false
		if driver == null:
			# 购物车未附着时，无论长按短按都执行附着
			if can_interact and player_in_range:
				mount(player_in_range)
		else:
			# 购物车已附着时，短按放下，长按投掷
			if interact_hold_time < charge_threshold:
				dismount()
			else:
				throw_cart(interact_hold_time)

		interact_hold_time = 0.0
		
func mount(player: Node3D):
	driver = player
	driver_model = player.get_node_or_null("characteremployee2")
	if driver_model:
		print("成功找到模型节点:", driver_model.name)
	else:
		print("警告：找不到模型节点，使用根节点")
	# 将购物车挂载到玩家身上，作为子节点
	self.reparent(driver_model)
	# 固定相对位置：放在玩家前方（Z轴负方向为模型前方，可调）
	self.position = Vector3(0, 0, 0.4)   # 也可使用 $BehindPosition 的值
	self.rotation = Vector3.ZERO

	# 禁用购物车的物理和碰撞，使其完全“粘”在玩家身上
	collision_layer = 0
	collision_mask = 0
	freeze = true   # 完全冻结刚体

	# 关闭交互区域，防止购物车检测到附着的玩家
	$InteractionArea.monitoring = false
	$InteractionArea.monitorable = false

	# 不再禁用玩家控制，玩家保持原有移动能力
	print("购物车已附着到玩家")

func dismount():
	if driver == null:
		return

	var player = driver

	# 恢复物理属性
	collision_layer = 1   # 请改为你项目中购物车原本的碰撞层
	collision_mask = 1    # 同理
	freeze = false

	# 重新启用交互区域
	$InteractionArea.monitoring = true
	$InteractionArea.monitorable = true

	# 脱离玩家，放回场景根节点
	var root = get_tree().current_scene
	self.reparent(root)

	# 计算放置位置：玩家前方一定距离
	var exit_pos = driver_model.global_position + driver_model.global_transform.basis * Vector3(0, 0,0.5)
	global_position = exit_pos
	global_rotation = Vector3.ZERO
	global_rotation = driver_model.global_rotation
	
	driver = null
	print("购物车已放下")
	
	
func throw_cart(charge_time: float):
	if driver == null or driver_model == null:
		return
	# 恢复物理
	collision_layer = 1
	collision_mask = 1
	freeze = false
	$InteractionArea.monitoring = true
	$InteractionArea.monitorable = true
	# 脱离玩家
	var root = get_tree().current_scene
	self.reparent(root)
	var exit_pos = driver_model.global_position + driver_model.global_transform.basis * Vector3(0, 0, 0.6)
	global_position = exit_pos
	global_rotation = driver_model.global_rotation
	# 计算投掷力度（有上限）
	var throw_force = min(throw_base_force + throw_force_per_second * charge_time, throw_max_force)
	var throw_direction = driver_model.global_transform.basis.z
	# 施加冲量
	apply_central_impulse(throw_direction * throw_force)
	driver = null
	print("购物车已投掷！力度: ", throw_force)
