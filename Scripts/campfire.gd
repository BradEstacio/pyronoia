class_name Campfire
extends Node3D

	
var sprite: SpriteBase3D

@export var maximum_fuel_level: float = 255
@export var start_fuel_level: float = 255
@export var fuel_drain_speed: float = 5.0 #Drainage per second
@export var wood_needed: int = 3
@export var belongings_needed: int = 1
@export var fires_needed: int = 3
@export var final_camera: Camera3D

var fuel_level: float
var fuel_percent: float
var cur_wood = 0
var cur_belongings = 0
var cur_fire_items = 0
var cur_fires = 0
var progress_node: Node
var whispers: Node
var stage := 0
var task_list_text: Label
#var stage_one_texT

func add_fuel(fuel_added := 0.0) -> void:
	print("Added fuel!")
	$DropOffWood.play()
	$AddKindling.play()
	fuel_level = min(fuel_level + fuel_added, maximum_fuel_level)
	fuel_percent = fuel_level / maximum_fuel_level
	progress_node.value = fuel_level
	cur_wood += 1
	await $AddKindling.finished

func add_belonging() -> void:
	print("Added belonging!")
	$DropOffWood.play()
	$AddKindling.play()
	cur_belongings += 1
	await $AddKindling.finished

func get_fire_item() -> void:
	print("Obtained fire item!")
	cur_fire_items += 1

func light_fire() -> void:
	print("Created fire!")
	$DropOffWood.play()
	$AddKindling.play()
	cur_fires += 1
	await $AddKindling.finished

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite = get_node("Sprite3D")
	fuel_level = start_fuel_level
	progress_node = %FuelBar.get_node("%ProgressBar")
	progress_node.value = 255.0
	whispers = %Vignette.get_node("AudioStreamPlayer")
	%Vignette.modulate.a = 255.0 - fuel_level
	task_list_text = %TaskList.get_node("ColorRect/Label")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if stage == 0: # Throw wood into fire
		fuel_level = max(fuel_level - fuel_drain_speed * delta, 0)
		fuel_percent = fuel_level / maximum_fuel_level
		progress_node.value = fuel_level
		whispers.volume_db = -40.0 + (30 * abs(1 - fuel_percent))
		%Vignette.modulate.a = abs(1 - fuel_percent)
		if fuel_level <= 0:
			get_tree().change_scene_to_file("res://Scenes/Screens/lose_screen.tscn")
		if cur_wood >= wood_needed:
			print("Stage 0 - Wood: Completed.")
			stage += 1
			var belongings := get_tree().get_nodes_in_group("Belonging")
			for object in belongings:
				var object_pickup := object as Pickupable
				object_pickup.active = true
			task_list_text.text = "-You angered it\n-Throw your belongings in the fire"
			# TO DO: add writing noise
	elif stage == 1: # Throw belongings into fire
		if fuel_level != maximum_fuel_level:
			fuel_level = min(fuel_level + 10 * delta, maximum_fuel_level)
			fuel_percent = fuel_level / maximum_fuel_level
			progress_node.value = fuel_level
			whispers.volume_db = -25.0
			%Vignette.modulate.a = 0.4
		if cur_belongings >= belongings_needed:
			print("Stage 1 - Belongings: Completed.")
			stage += 1
			var fire_items := get_tree().get_nodes_in_group("Fire Item")
			for object in fire_items:
				var object_pickup := object as Pickupable
				object_pickup.active = true
			task_list_text.text = "-Collect lighter\n-Collect gas can"
			# TO DO: add writing noise
	elif stage == 2: # Collect fire items
		if cur_fire_items >= 2:
			print("Stage 2 - Collect fire items: Completed.")
			stage += 1
			var burnables := get_tree().get_nodes_in_group("Burnable")
			for object in burnables:
				var object_pickup := object as Burnable
				object_pickup.active = true
			task_list_text.text = "-Its too late\n-Light everything on fire"
			# TO DO: add writing noise
	elif stage == 3: # Light everything on fire
		if cur_fires >= fires_needed:
			print("Stage 3 - Light fires: Completed.")
			get_tree().change_scene_to_file("res://Scenes/Screens/win_screen.tscn")
