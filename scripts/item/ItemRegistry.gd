extends Node

@export var register_items: Array[ItemData] = [];
var items = {};

func _ready() -> void:
	for item in register_items:
		if item and item.id.is_empty() == false:
			if items.has(item.id):
				push_warning("重复物品: ", item.id)
			items[item.id] = item
			print("添加物品: ", item.id)

## 获取物品
func get_item(id: String) -> ItemData:
	return items.get(id);

const LOOT_DROP_SCENE = preload("res://scripts/item/item_drop.tscn")

## 生成物品
func spawn_by_id(parent_node: Node, position: Vector3, item_id: String) -> RigidBody3D:
	
	var data = ItemRegistry.get_item(item_id)
	if data == null:
		printerr("未知物品: ", item_id)
		return null;
	print(data)
		
	var drop = LOOT_DROP_SCENE.instantiate()
	drop.position = position
	parent_node.add_child(drop)
	drop.setup(data)
	
	return drop
