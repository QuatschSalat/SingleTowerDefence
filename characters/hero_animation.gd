extends KinematicBody2D

enum STATE {
	IDLE,
	WALK
}

var state = STATE.IDLE
var speed := 200.0
var move_direction = Vector2.ZERO
var path := PoolVector2Array() setget set_path

onready var animated_sprite := $AnimatedSprite

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_along_path(speed * delta)

func set_path(value : PoolVector2Array) -> void:
	if value.size() == 0:
		return
	path = value

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
			change_direction(move_direction)

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
