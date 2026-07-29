extends RigidBody3D

@onready var mesh_instance: MeshInstance3D = $ModelContainer
@onready var pickup_area: Area3D = $PickupArea

var current_data: ItemData = null

func setup(item_data):
	if item_data == null:
		queue_free()
		push_warning("空物品")
		return
		
	current_data = item_data
	
	if item_data.mesh:
		mesh_instance.mesh = item_data.mesh
		
		var aabb = mesh_instance.mesh.get_aabb()
		if $CollisionShape3D.shape is BoxShape3D:
			var box = $CollisionShape3D.shape as BoxShape3D
			box.size = aabb.size * 0.8
	
	mass = item_data.mass
	gravity_scale = item_data.gravity_scale

func _on_pickup_area_body_entered(body):
	if body.is_in_group("player"):
		print("玩家拾取了: ", current_data.display_name)
		queue_free()
