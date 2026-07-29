extends Node

@export var register_items: Array[ItemData] = [];

@export var items = {};

func get_item(id: String) -> ItemData:
	return items.get(id);

func _ready() -> void:
	for item in register_items:
		if item and item.id.is_empty() == false:
			if items.has(item.id):
				push_warning("重复物品: ", item.id)
			items[item.id] = item
