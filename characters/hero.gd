extends KinematicBody2D

signal path_end_reached()
signal path_footprint_reached(footprint)

var sword_scene = preload("res://items/sword.tscn")

# TODO: IDLE und ATTACK Animation erstellen
enum STATE {
	IDLE,
	WALK,
	ATTACK
}

var state = STATE.IDLE
var speed := 200.0
var move_direction = Vector2.ZERO
var path := PoolVector2Array() setget set_path
var attack_cool_down := 1.0
var attack_cool_down_passed := 0.0
var enemies_in_range := []
var enemies_in_gangway := []

onready var animated_sprite := $AnimatedSprite
onready var attack_sound := $AttackSound


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):

	if attack_cool_down_passed <= attack_cool_down:
		attack_cool_down_passed += delta

	if len(enemies_in_range) > 0 and attack_cool_down_passed > attack_cool_down:
		attack_cool_down_passed = 0.0
		attack()

	move_along_path(speed * delta)


# Custom Methods
func move_along_path(distance : float) -> void:
	var start_point := position
	for i in range (path.size()):
		var distance_to_next := start_point.distance_to(path[0])
		if distance <= distance_to_next and distance >= 0.0:
			position = position.move_toward(path[0], distance)
			change_direction(position.direction_to(path[0]))
			state = STATE.WALK
			break
		elif distance < 0.0:
			position = path[0]
			break
		distance -= distance_to_next
		start_point = path[0]
		path.remove(0)
		if path.size() == 0:
			state = STATE.IDLE
			emit_signal('path_end_reached')
			change_direction(move_direction)


func set_path(value : PoolVector2Array) -> void:
	if value.size() == 0:
		return
	path = value

func change_direction(direction: Vector2) -> void:
	# TODO: direction mit Hilfe einer Formel in 4 Teile aufteilen
	# Ist später für den Angriff wichtig
	move_direction = direction
	if move_direction.x > 0.5:
		if state == STATE.WALK:
			animated_sprite.play("walk_right")
		elif state == STATE.IDLE:
			animated_sprite.play("idle_right")
	elif move_direction.x < -0.5:
		if state == STATE.WALK:
			animated_sprite.play("walk_left")
		elif state == STATE.IDLE:
			animated_sprite.play("idle_left")
	elif move_direction.y > 0.5:
		if state == STATE.WALK:
			animated_sprite.play("walk_down")
		elif state == STATE.IDLE:
			animated_sprite.play("idle_down")
	elif move_direction.y < -0.5:
		if state == STATE.WALK:
			animated_sprite.play("walk_up")
		elif state == STATE.IDLE:
			animated_sprite.play("idle_up")

func enemies_not_in_gangway() -> Array:
	var free_enemies := []
	for enemy in enemies_in_range:
		if not enemy in enemies_in_gangway:
			free_enemies.append(enemy)
	return free_enemies

func attack() -> void:

	var free_enemies = enemies_not_in_gangway()
	# Todo: Hier wird dennoch der Gegner im Durchgang abgeworfen
	
	if len(free_enemies) > 0:
		var target_enemy = free_enemies.front()
		
		change_direction(position.direction_to(target_enemy.position))
		state = STATE.ATTACK
		play_attack_animation()
		
		if target_enemy.has_method("get_future_position"):
			var enemy_distance = global_position.distance_to(target_enemy.global_position)
			var future_position = target_enemy.get_future_position(enemy_distance)
			spawn_sword(future_position)
		else:
			spawn_sword(target_enemy.position)

func play_attack_animation() -> void:
	if Global.sound_on:
		attack_sound.play()

	if move_direction.x > 0.5:
		animated_sprite.play("attack_right")
	elif move_direction.x < -0.5:
		animated_sprite.play("attack_left")
	elif move_direction.y > 0.5:
		animated_sprite.play("attack_down")
	elif move_direction.y < -0.5:
		animated_sprite.play("attack_up")

func spawn_sword(target_position) -> void:
	var sword = sword_scene.instance()
	get_tree().root.add_child(sword)
	sword.position = $SwordSpawnPoint.global_position
	sword.set_target(target_position)
	
func add_enemy_in_gangway(enemy) -> void:
	enemies_in_gangway.append(enemy)
	
func remove_enemy_in_gangway(enemy) -> void:
	enemies_in_gangway.erase(enemy)

# Signals
func _on_body_entered(body):
	if body is Enemy:
		enemies_in_range.append(body)


func _on_body_exited(body):
	if body is Enemy:
		var body_index = enemies_in_range.find(body)
		if body_index != -1:
			enemies_in_range.remove(body_index)


func _on_AnimatedSprite_animation_finished():	
	if state == STATE.ATTACK:
		state = STATE.IDLE
		change_direction(move_direction)

func _on_footprint_area_entered(area):
	emit_signal("path_footprint_reached", area.get_parent())
