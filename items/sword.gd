extends Node2D

class_name Sword

var speed := 500
var rotation_speed := 10
var target := Vector2.ZERO
var move_direction := Vector2.ZERO

var viewport_rect = null

# Called when the node enters the scene tree for the first time.
func _ready():
	viewport_rect = get_viewport().get_visible_rect()
	set_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if target != Vector2.ZERO:
		var rotation_direction = 1 if move_direction.x >= 0 else -1
		position += move_direction * speed * delta
		rotation += rotation_direction * rotation_speed * delta
		
	if not viewport_rect.has_point(position):
		get_parent().remove_child(self)
		queue_free()

# Custom Methods
func set_target(target_position: Vector2) -> void:
	target = target_position
	move_direction = position.direction_to(target_position)
	set_process(true)


# Signal
func _on_body_entered(body):
	if body is Enemy and body.has_method("take_hit_from"):
		body.take_hit_from(self)
		queue_free()
