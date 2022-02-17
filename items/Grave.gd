extends Node2D

var occupied := false
var destroyed := false setget set_destroyed

onready var normal_sprite := $Normal
onready var dust_particle := $ExplosionDust
onready var dust_timer := $Timer

func set_destroyed(is_destroyed) -> void:
	destroyed = is_destroyed
	
	if destroyed:
		dust_timer.start()
		dust_particle.emitting = true
		normal_sprite.visible = false
	else:
		dust_particle.emitting = false
		normal_sprite.visible = true


# Signals
func _on_timeout():
	dust_timer.stop()
	dust_particle.emitting = false
