extends Area3D

@export var target_group: String = "entity:player"

var _player_count: int = 0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group(target_group):
		_player_count += 1
		if _player_count == 1:
			InteractionUIManager.register_interactable(self)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group(target_group):
		_player_count -= 1
		if _player_count == 0:
			InteractionUIManager.unregister_interactable(self)

func _exit_tree() -> void:
	if _player_count > 0:
		InteractionUIManager.unregister_interactable(self)
