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
var slow_heartbeat_playing := false
var fast_heartbeat_playing := false
var whispers_playing := false
var vignette_tween: Tween

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

	$CampfireCrackle.play()
	
	fuel_level = start_fuel_level
	progress_node = %FuelBar.get_node("%ProgressBar")
	progress_node.value = 255.0
	whispers = %Vignette.get_node("AudioStreamPlayer")
	%Vignette.modulate.a = 255.0 - fuel_level
	task_list_text = %TaskList.get_node("Sprite2D/Label")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if vignette_tween:
		vignette_tween.kill()
	
	if stage == 0: # Throw wood into fire
		fuel_level = max(fuel_level - fuel_drain_speed * delta, 0)
		fuel_percent = fuel_level / maximum_fuel_level
		var fuel_percent_offset = min(fuel_percent, 0.75)
		progress_node.value = fuel_level
		vignette_tween = create_tween()
		vignette_tween.tween_property(%Vignette, "scale", Vector2(max(1 - (0.75 * abs(0.75 - fuel_percent_offset)), 0.5), max(1 - (0.75 * abs(0.75 - fuel_percent_offset)), 0.5)), 0.1)
		%Vignette.modulate.a = abs(1 - fuel_percent)
		whispers.volume_db = -40.0 + (30 * abs(0.75 - fuel_percent_offset))
		if fuel_level <= 0:
			get_tree().change_scene_to_file("res://Scenes/Screens/lose_screen.tscn")
		if cur_wood >= wood_needed:
			print("Stage 0 - Wood: Completed.")
			stage += 1
			var belongings := get_tree().get_nodes_in_group("Belonging")
			for object in belongings:
				var object_pickup := object as Pickupable
				object_pickup.active = true
			TaskUpdate.play()
			task_list_text.text = "-You angered it\n-Throw your belongings in the fire"
			# TO DO: add writing noise
	elif stage == 1: # Throw belongings into fire
		#if fuel_level != maximum_fuel_level:
		fuel_level = fuel_level + 10 * delta
		fuel_percent = fuel_level / maximum_fuel_level
		progress_node.value = fuel_level
		whispers.volume_db = -25.0
		vignette_tween = create_tween()
		vignette_tween.tween_property(%Vignette, "scale", Vector2(0.5, 0.5), 0.1)
		%Vignette.modulate.a = 0.4
		if cur_belongings >= belongings_needed:
			print("Stage 1 - Belongings: Completed.")
			stage += 1
			var fire_items := get_tree().get_nodes_in_group("Fire Item")
			for object in fire_items:
				var object_pickup := object as Pickupable
				object_pickup.active = true
			TaskUpdate.volume_db = -5.0
			TaskUpdate.pitch_scale = 1.0 
			TaskUpdate.play()
			task_list_text.text = "-Collect lighter\n-Collect gas can"
			# TO DO: add writing noise
	elif stage == 2: # Collect fire items
		if cur_fire_items >= 2:
			print("Stage 2 - Collect fire items: Completed.")
			stage += 1
			var burnables := get_tree().get_nodes_in_group("Burnable")
			for object in burnables:
				object.show()
				var object_pickup := object as Burnable
				object_pickup.active = true
			TaskUpdate.pitch_scale = 1.25
			TaskUpdate.play()
			task_list_text.text = "-Its too late\n-Light everything on fire\n-Tents, Corn, LakeHouse, Deep Forest, Building"
			# TO DO: add writing noise
	elif stage == 3: # Light everything on fire
		if cur_fires >= fires_needed:
			print("Stage 3 - Light fires: Completed.")
			get_tree().change_scene_to_file("res://Scenes/Screens/win_screen.tscn")
		
	if ((fuel_percent <= 0.75 and fuel_percent > 0.5) or (stage >= 1 and stage < 3)) and !slow_heartbeat_playing:
		if fast_heartbeat_playing:
			$Heartbeat.stop()
			$Heartbeat.stream = load("res://Assets/SFX/369017__patobottos__heartbeats-61.wav")
			fast_heartbeat_playing = false
		$Heartbeat.play()
		slow_heartbeat_playing = true
	if (fuel_percent <= 0.5 or stage >= 3) and !fast_heartbeat_playing:
		if slow_heartbeat_playing:
			$Heartbeat.stop()
			$Heartbeat.stream = load("res://Assets/SFX/332809__loudernoises__heartbeat-100bpm-limited.wav")
			slow_heartbeat_playing = false
		$Heartbeat.play()
		fast_heartbeat_playing = true
	if fuel_percent > 0.75 and (slow_heartbeat_playing) and stage < 1:
		$Heartbeat.stop()
		slow_heartbeat_playing = false
		fast_heartbeat_playing = false
	
	if stage < 1:
		vignette_tween = create_tween()
		vignette_tween.tween_property(%Vignette, "scale", Vector2(1 - (.5 * abs(1 - fuel_percent)), 1 - (.5 * abs(1 - fuel_percent))), 0.1)
	else:
		pass

func _on_campfire_sound_finished() -> void:
	if stage <= 0:
		if fuel_percent <= 50:	
			$CampfireCrackle.volume_db = randf_range(-10.0, -7.5)
			$CampfireCrackle.pitch_scale = randf_range(0.5, 0.75)
		else:
			$CampfireCrackle.volume_db = randf_range(-2.5, 5.0)
			$CampfireCrackle.pitch_scale = randf_range(0.83, 1.2)
			$CampfireCrackle.play()
	if stage >= 1 || stage <= 2:
		$CampfireCrackle.volume_db = randf_range(0.0, 20.0)
		$CampfireCrackle.pitch_scale = 1.2
		$CampfireCrackle.play()
	if stage >= 3:
		$CampfireCrackle.volume_db = randf_range(20.0, 40.0)
		$CampfireCrackle.pitch_scale = 1.5
		$CampfireCrackle.play()
	else:
		$CampfireCrackle.play()
