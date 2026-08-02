class_name Inventory extends Node

@export var max_slots: int = 1

var slots: Array[Dictionary] = []

func add_item(item_data: ItemData, count: int = 1) -> bool:
	if item_data == null or count <= 0:
		return false

	if item_data.max_stack > 1:
		for slot in slots:
			if slot["item"] == item_data and slot["count"] < item_data.max_stack:
				var space = item_data.max_stack - slot["count"]
				var add = min(count, space)
				slot["count"] += add
				count -= add
				if count == 0:
					return true
					
	while count > 0:
		if slots.size() >= max_slots:
			return false  # 库存已满
		var add = min(count, item_data.max_stack)
		slots.append({ "item": item_data, "count": add })
		count -= add
	return true
