extends Node

const PROMPT_SCENE = preload("res://ui/InteractionPrompt.tscn")

var _prompt_instance: CanvasLayer = null
var _active_interactables: Array = []

func register_interactable(interactable: Node) -> void:
	if not _active_interactables.has(interactable):
		_active_interactables.append(interactable)
		if _prompt_instance == null:
			_create_prompt()
	_update_prompt()

func unregister_interactable(interactable: Node) -> void:
	var idx = _active_interactables.find(interactable)
	if idx != -1:
		_active_interactables.remove_at(idx)
	_update_prompt()

func _create_prompt() -> void:
	_prompt_instance = PROMPT_SCENE.instantiate()
	get_tree().root.call_deferred("add_child", _prompt_instance)

func _destroy_prompt() -> void:
	if _prompt_instance:
		_prompt_instance.queue_free()
		_prompt_instance = null

func _update_prompt() -> void:
	if _prompt_instance == null:
		return
	var should_show = not _active_interactables.is_empty()
	_prompt_instance.visible = should_show
