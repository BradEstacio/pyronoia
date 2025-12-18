class_name PlayerController
extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var mouse_sensitivity := 0.1
var rotation_x := 0.0
var rotation_y := 0.0


@export var pickup_distance: float
@export var fire_scene: PackedScene

var camera: Camera3D
var campfire: Node3D
var is_holding_item: bool = false
var held_item: Node3D
var looked_at_object: Node3D

func get_group_rids(group_name: String) -> Array[RID]:
	var rids: Array[RID] = []

	for node in get_tree().get_nodes_in_group(group_name):
		if node is CollisionObject3D:
			rids.append(node.get_rid())

	return rids

func get_look_position(max_distance := 100.0) -> Vector3:
	var viewport := get_viewport()

	# Screen center
	var screen_center := viewport.get_visible_rect().size * 0.5

	# Ray
	var origin := camera.project_ray_origin(screen_center)
	var direction := camera.project_ray_normal(screen_center)
	var to := origin + direction * max_distance

	# Raycast
	var exclude_items := get_group_rids("Sprite Collider")
	if held_item:
		var item := held_item.get_node("SpriteStaticBody")
		exclude_items.append(item.get_rid())
	var space := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(origin, to, 0xFFFFFFFF, exclude_items)
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var result := space.intersect_ray(query)
	if result:
		return result.position
	
	return Vector3.ZERO

func get_looked_at_node(max_distance := 100.0) -> Node3D:
	var viewport := get_viewport()

	# Screen center
	var screen_center := viewport.get_visible_rect().size * 0.5

	# Ray
	var origin := camera.project_ray_origin(screen_center)
	var direction := camera.project_ray_normal(screen_center)
	var to := origin + direction * max_distance

	# Raycast
	var space := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(origin, to)
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var result := space.intersect_ray(query)
	if result:
		return result["collider"]  # This is the node you're looking at

	return null

func get_looked_at_object(max_distance := 100.0) -> Node3D:
	var viewport := get_viewport()

	# Screen center
	var screen_center := viewport.get_visible_rect().size * 0.5

	# Ray
	var origin := camera.project_ray_origin(screen_center)
	var direction := camera.project_ray_normal(screen_center)
	var to := origin + direction * max_distance

	# Raycast
	var space := get_world_3d().direct_space_state
	var query
	if held_item:
		var item: StaticBody3D =  held_item.get_node("SpriteStaticBody")
		var a = [item.get_rid()]
		query = PhysicsRayQueryParameters3D.create(origin, to, 0xFFFFFFFF, a)
	else:
		query = PhysicsRayQueryParameters3D.create(origin, to)
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var result := space.intersect_ray(query)
	if not result:
		return null
		
	if not (result["collider"] is Node):
		return null

	var collider: Node = result["collider"]

	# Walk up the tree until we find an Item
	while collider and not ("Interactable" in collider.get_groups()):
		collider = collider.get_parent()

	if not collider:
		return null

	if "Interactable" in collider.get_groups():
		#var col_sprite3d_child = collider.get_node("Sprite3D")
		#if col_sprite3d_child:
			# outlines object when within visible range
			#col_sprite3d_child.material_override.set_shader_parameter("onoff", 1.0)
		return collider
	else:
		return null

func _ready() -> void:
	camera = $PlayerCamera
	campfire = get_tree().root.get_node("Map/Campfire") as Campfire
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	if (velocity.x != 0) || (velocity.z != 0):
		if !$WalkAudio.playing && $Timer.is_stopped():
			$WalkAudio.play()
			$WalkAudio.pitch_scale = randf_range(0.3, 0.4)
			$WalkAudio.volume_db = randf_range(-17.5, -15.0)
			$Timer.start()

	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation_x -= event.relative.x * mouse_sensitivity
		rotation_y -= event.relative.y * mouse_sensitivity
		
		rotation_y = clamp(rotation_y, -90, 90)
		
		rotation_degrees.y = rotation_x # some methods without the class automatically assume the script's parent
		camera.rotation_degrees.x = rotation_y

func _process(_delta: float) -> void:
	# Handle picking up and dropping items
	get_looked_at_object(pickup_distance)
	if Input.is_action_just_pressed("ui_interact"):
		if not is_holding_item: # Pick up item
			var node := get_looked_at_object(pickup_distance)
			if node:
				if "Fire Item" in node.get_groups():
					campfire.get_fire_item()
					node.queue_free()
				elif "Burnable" in node.get_groups():
					# TO DO: Burn Object/ add fire effect; currently adds fire sprite
					var burnable_item = node as Burnable
					if burnable_item.active and not burnable_item.is_on_fire:
						burnable_item.is_on_fire = true
						var instance: Node3D = fire_scene.instantiate()
						node.add_child(instance)
						instance.global_position = node.global_position
						campfire.light_fire()
				elif not "Campfire" in node.get_groups():
					var pickup := node as Pickupable
					pickup.pick_up()
		else: # Drop item or add to fire
			var node := get_looked_at_object(pickup_distance)
			if node:
				if "Campfire" in node.get_groups() and "Wood" in held_item.get_groups():
					var fuel_item := held_item as Pickupable
					campfire.add_fuel(fuel_item.fuel_amount)
					held_item.queue_free()
					is_holding_item = false
					held_item = null
				elif "Campfire" in node.get_groups() and "Belonging" in held_item.get_groups():
					campfire.add_belonging()
					held_item.queue_free()
					is_holding_item = false
					held_item = null
				else:
					var drop_pos := get_look_position(pickup_distance)
					if drop_pos != Vector3.ZERO:
						held_item.drop_item(drop_pos)
			else:
				var drop_pos := get_look_position(pickup_distance)
				if drop_pos != Vector3.ZERO:
					held_item.drop_item(drop_pos)
	
	# Handle hover/outline shader
	#var last_looked_at_object = looked_at_object
	#looked_at_object = get_looked_at_object(pickup_distance)
	#if last_looked_at_object and looked_at_object != last_looked_at_object:
		#var col_sprite3d_child = last_looked_at_object.get_node("Sprite3D")
		#if col_sprite3d_child:
			##col_sprite3d_child.material_override.set_shader_parameter("onoff", 0.0)
