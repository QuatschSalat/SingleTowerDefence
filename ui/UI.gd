extends Node2D

signal wave_screen_done()
signal game_over_screen_done()

onready var big_screen := $BigScreen
onready var wave_count_label := $BigScreen/WaveBigCount
onready var wave_title_label := $BigScreen/WaveBigTitle
onready var screen_timer := $BigScreen/BigScreenTimer

var game_over = false

# Called when the node enters the scene tree for the first time.
func _ready():
	
	big_screen.visible = false
	
	get_parent().connect("show_wave_start", self, "_show_wave_start")
	get_parent().connect("show_game_over", self, "_show_game_over")


# Signals
func _show_wave_start(wave_name, wave_number):
	game_over = false
	big_screen.visible = true
	wave_count_label.text = "WAVE #" + wave_number
	wave_title_label.text = wave_name
	
	screen_timer.start()

func _show_game_over(won, points) -> void:
	big_screen.visible = true
	wave_count_label.text = "Graves saved!" if won else "Not bad. Try Again!"
	wave_title_label.text = str(points) + " Points"
	game_over = true
	
	screen_timer.start()

func _on_big_screen_timeout():
	screen_timer.stop()
	big_screen.visible = false
	
	if game_over:
		emit_signal("game_over_screen_done")
	else:
		emit_signal("wave_screen_done")
