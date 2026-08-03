extends RigidBody3D

# ========== 内部状态 ==========
var driver : Node3D = null           # 当前推车/持握的玩家
var driver_model : Node3D = null     # 玩家的模型节点

## 挂载到玩家身上
func mount(player: Node3D):
	driver = player
	driver_model = player.get_node_or_null("PlayerModels")
	if driver_model:
		print("成功找到模型节点:", driver_model.name)
	else:
		print("警告：找不到模型节点，将直接使用玩家根节点")
		driver_model = player

	# 挂到玩家模型下，放在身前
	self.reparent(driver_model)
	self.position = Vector3(0, 0, 0.4)
	self.rotation = Vector3.ZERO

	# 冻结物理，关闭碰撞
	collision_layer = 0
	collision_mask = 0
	freeze = true

	print("购物车已附着到玩家")
func _ready():
	print("=== 购物车自检 ===")
	print("名称: ", name)
	print("collision_layer: ", collision_layer)
	if $CollisionShape3D:
		print("碰撞形状存在，资源: ", $CollisionShape3D.shape)
	else:
		print("致命错误：找不到 CollisionShape3D 子节点！")

## 放下购物车
func dismount():
	if driver == null or driver_model == null:
		return

	# 恢复物理
	collision_layer = 1   # 根据你的项目设置调整
	collision_mask = 1
	freeze = false
	# 脱离玩家，放回场景根
	var root = get_tree().current_scene
	self.reparent(root)

	# 放在玩家前方
	var exit_pos = driver_model.global_position + driver_model.global_transform.basis * Vector3(0, 0, 0.5)
	global_position = exit_pos
	global_rotation = driver_model.global_rotation

	driver = null
	driver_model = null
	print("购物车已放下")


## 投掷购物车（力度由玩家计算后传入）
func throw_cart(force: float):
	if driver == null or driver_model == null:
		return

	# 恢复物理
	collision_layer = 1
	collision_mask = 1
	freeze = false
	# 在脱离前记录方向和位置
	var exit_pos = driver_model.global_position + driver_model.global_transform.basis * Vector3(0, 0, 0.45)
	var throw_dir = driver_model.global_transform.basis.z

	# 脱离玩家
	var root = get_tree().current_scene
	self.reparent(root)
	global_position = exit_pos
	global_rotation = driver_model.global_rotation

	# 施加冲量
	apply_central_impulse(throw_dir * force)

	driver = null
	driver_model = null
	print("购物车已投掷！力度: ", force)
