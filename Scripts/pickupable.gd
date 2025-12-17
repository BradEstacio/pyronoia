class_name Pickupable
extends Node3D

@export var active: bool = true
@export var pickup_noise: AudioStream
@export var default_size: float
@export var holding_size: float
@export var fuel_amount: float = 0.0
@export var pickup_error: String = "You do not need this item now."

var is_held: bool = false
var sprite: SpriteBase3D
var map: Node3D
var player: Node3D
var pc: PlayerController
var pickup_point: Node3D

func pick_up() -> void:
	if active and not is_held and not pc.is_holding_item:
		print("Picked up an item!")
		$PickUp.play()
		is_held = true
		pc.is_holding_item = true
		pc.held_item = self
		sprite.pixel_size = holding_size
		sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		global_position = pickup_point.global_position
		reparent(pickup_point)

func drop_item(pos: Vector3) -> void:
	if is_held and pc.is_holding_item:
		print("Dropped an item!")
		is_held = false
		pc.is_holding_item = false
		pc.held_item = null
		sprite.pixel_size = default_size
		sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
		global_position = pos
		$DropOffWood.play()
		reparent(map)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite = get_node("Sprite3D")
	map = get_tree().root.get_node("Map")
	player = map.get_node("Player")
	pc = player as PlayerController
	pickup_point = player.get_node("PlayerCamera/ItemCarryPoint")
