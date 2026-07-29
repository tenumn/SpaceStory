extends Node3D


@export var camera_height: float = 8.0
@export var camera_distance: float = 8.0
@export var camera_smoothing: float = 4.0

@onready var player: CharacterBody3D = $Player
@onready var camera: Camera3D = $Camera3D
@onready var grid_map: GridMap = $GridMap
