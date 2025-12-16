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

@export var maximum_fuel_level: float = 100
@export var start_fuel_level: float = 100
@export var fuel_drain_speed: float = 5.0 #Drainage per second

var fuel_level: float
var fuel_percent: float

func add_fuel(fuel_added := 0.0) -> void:
	print("Added fuel to fire!")
	fuel_level = min(fuel_level + fuel_added, maximum_fuel_level)
	fuel_percent = fuel_level / maximum_fuel_level

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite = get_node("Sprite3D")
	#map = get_tree().root.get_node("Map")
	#player = map.get_node("Player")
	#pc = player as PlayerController
	#pickup_point = player.get_node("PlayerCamera/ItemCarryPoint")
	fuel_level = start_fuel_level

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	fuel_level = max(fuel_level - fuel_drain_speed * delta, 0)
	fuel_percent = fuel_level / maximum_fuel_level
	#print(fuel_level)
