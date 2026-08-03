extends RigidBody3D

@onready var mesh_container: Node3D = $ModelContainer
@onready var pickup_area: Area3D = $PickupArea
var current_data: ItemData = null

func _ready():
	pickup_area.body_entered.connect(_on_pickup_area_body_entered)

func setup(item_data):
	if item_data == null:
		queue_free()
		push_warning("空物品")
		return
	current_data = item_data
	
	for child in mesh_container.get_children():
		mesh_container.remove_child(child)
		child.free()
		
	if item_data.model:
		var instance = item_data.model.instantiate()
		mesh_container.add_child(instance)
		instance.transform = Transform3D.IDENTITY
		auto_fit_collision(instance)
	else:
		push_warning("物品 " + item_data.id + " 缺少模型！")
		
		mass = item_data.mass
	gravity_scale = item_data.gravity_scale

func auto_fit_collision(model_node: Node):
	var mesh_instance = null
	for child in model_node.get_children(true):
		if child is MeshInstance3D:
			mesh_instance = child
			break
	if mesh_instance and mesh_instance.mesh:
		var aabb = mesh_instance.mesh.get_aabb()
		if $CollisionShape3D.shape is BoxShape3D:
			var box = $CollisionShape3D.shape as BoxShape3D
			box.size = aabb.size * 1.8
	else:
		print("未找到 MeshInstance，碰撞体保持默认尺寸")
		
func _on_pickup_area_body_entered(body: Node):
	if body is Player:   # 需要确保 Player 类已预先加载或使用 class_name
		if body.try_pickup(current_data):
			queue_free()
