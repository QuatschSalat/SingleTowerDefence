extends KinematicBody2D

class_name Enemy

signal enemy_died(enemy)
signal enemy_reached_end(enemy)
signal enemy_destroyed_grave(enemy)

enum STATE {
	IDLE,
	WALK,
	DIE,
	EXPLODE
}

var state = STATE.IDLE
var speed = 50
var lives = 2
var points = 0
var grave_path := false
var grave = null

#var path_to_follow := Path2D
var current_path_array = null
var move_direction := Vector2.ZERO

onready var animated_sprite := $AnimatedSprite
onready var animation_player := $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if state == STATE.WALK and state != STATE.EXPLODE and current_path_array:
		var target_position = current_path_array[0]
		if position.distance_to(target_position) > 2:
			var velocity = move_direction * speed
			velocity = move_and_slide(velocity, move_direction)
		elif position.distance_to(target_position) <= 2:
			position = get_next_point()


func get_future_position(distance: float) -> Vector2:
	return position + (move_direction * (speed / 60) * (distance / 10))

# Custom Methods
func set_path_to_follow(path_array: PoolVector2Array) -> void:
	if Global.sound_on:
		$SpawnSound.play()
	current_path_array = path_array
	if current_path_array:
		state = STATE.WALK
		position = get_next_point()

func get_next_point() -> Vector2:
	if state == STATE.WALK and current_path_array and len(current_path_array) > 1:
		var first_point = current_path_array[0]
		var second_point = current_path_array[1]
		move_direction = first_point.direction_to(second_point)
		change_direction()
		current_path_array.remove(0)
		return first_point
	else:
		if grave_path:
			state = STATE.EXPLODE
			emit_signal("enemy_destroyed_grave", self)
			get_parent().remove_child(self)
			queue_free()
		else:
			emit_signal('enemy_reached_end', self)
		
	return position
	
func change_direction() -> void:
	if move_direction.x > 0.5:
		animated_sprite.animation = "walk_right"
	elif move_direction.x < -0.5:
		animated_sprite.animation = "walk_left"
	elif move_direction.y > 0.5:
		animated_sprite.animation = "walk_down"
	elif move_direction.y < -0.5:
		animated_sprite.animation = "walk_up"

func take_hit_from(shot) -> void:
	lives -= 1
	animation_player.play("hit")
	if Global.sound_on:
		$HitSound.play()
	
	if lives <= 0:
		if grave:
			grave.occupied = false
		emit_signal('enemy_died', self)
		get_parent().remove_child(self)
		queue_free()

func remove_enemy() -> void:
	get_parent().remove_child(self)
	queue_free()
