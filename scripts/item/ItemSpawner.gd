class_name ItemSpawner

const LOOT_DROP_SCENE = preload("res://resources/dropped_item.tscn")

static func spawn_by_id(parent_node: Node, position: Vector3, item_id: String) -> RigidBody3D:
	var data = ItemRegistry.get_item(item_id)
	if data == null:
		printerr("未知物品: ", item_id)
		return null;
		
	var drop = LOOT_DROP_SCENE.instantiate()
	drop.position = position
	drop.setup(data)
	
	parent_node.add_child(drop)
	return drop
