extends Area3D

@export var target_group: String = "entity:player"

var ui_visible: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group(target_group):
		ui_visible = true
		InteractionUIManager.register_interactable(self)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group(target_group):
		ui_visible = false
		InteractionUIManager.unregister_interactable(self)

func _exit_tree() -> void:
	if ui_visible:
		InteractionUIManager.unregister_interactable(self)
