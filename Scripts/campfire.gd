class_name Campfire
extends Node3D

#@export var active: bool = true
#@export var pickup_noise: AudioStream
#@export var default_size: float
#@export var holding_size: float
#@export var fuel_amount: float

#var is_held: bool = false
var sprite: SpriteBase3D
#var map: Node3D
#var player: Node3D
#var pc: PlayerController
#var pickup_point: Node3D

@export var maximum_fuel_level: float = 255
@export var start_fuel_level: float = 255
@export var fuel_drain_speed: float = 5.0 #Drainage per second
@export var wood_needed: int = 3

var fuel_level: float
var fuel_percent: float
var cur_wood = 0
var progress_node: Node
var whispers: Node

func add_fuel(fuel_added := 0.0) -> void:
	$DropOffWood.play()
	$AddKindling.play()
	fuel_level = min(fuel_level + fuel_added, maximum_fuel_level)
	fuel_percent = fuel_level / maximum_fuel_level
	cur_wood += 1
	await $AddKindling.finished
	
	if cur_wood >= wood_needed:
		get_tree().change_scene_to_file("res://Scenes/Screens/win_screen.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite = get_node("Sprite3D")
	#map = get_tree().root.get_node("Map")
	#player = map.get_node("Player")
	#pc = player as PlayerController
	#pickup_point = player.get_node("PlayerCamera/ItemCarryPoint")
	fuel_level = start_fuel_level
	progress_node = %FuelBar.get_node("%ProgressBar")
	progress_node.value = 255.0
	whispers = %Vignette.get_node("AudioStreamPlayer")
	%Vignette.modulate.a = 255.0 - fuel_level
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	fuel_level = clamp(fuel_level - fuel_drain_speed * delta, 0, maximum_fuel_level)
	fuel_percent = fuel_level / maximum_fuel_level
	progress_node.value = fuel_level
	whispers.volume_db = -40.0 + (30 * abs(1 - fuel_percent))
	%Vignette.modulate.a = abs(1 - fuel_percent)
	if fuel_level <= 0:
		get_tree().change_scene_to_file("res://Scenes/Screens/lose_screen.tscn")
