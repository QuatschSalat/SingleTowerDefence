extends Node2D

signal play_button_pressed()
signal settings_changed()

onready var play_button := $Play
onready var tutorial_button := $Tutorial
onready var mouse_button := $Mouse
onready var sound_button := $Sound
onready var music_button := $Music
onready var highscore := $Highscore

func _ready():
	tutorial_button.pressed = true if Global.tutorial_on else false
	mouse_button.pressed = true if Global.mouse_mode_on else false
	sound_button.pressed = true if Global.sound_on else false
	music_button.pressed = true if Global.music_on else false

	change_sound_button_text()
	set_highscore(0)

func _input(event):
	if visible == false:
		return

	if event is InputEventKey and event.is_pressed():
		match event.scancode:
			KEY_ENTER:
				emit_signal("play_button_pressed")

func change_sound_button_text():
	tutorial_button.text = "Tutorial on" if tutorial_button.pressed else "Tutorial off"
	mouse_button.text = "Mouse on" if mouse_button.pressed else "Mouse off"
	sound_button.text = "Sound on" if sound_button.pressed else "Sound off"
	music_button.text = "Music on" if music_button.pressed else "Music off"

func set_highscore(value) -> void:
	if value > Global.highscore:
		Global.highscore = value
	
	highscore.text = "Highscore: " + str(Global.highscore) + " Points"

# Signals
func _on_settings_button_pressed():
	change_sound_button_text()
	
	Global.tutorial_on = tutorial_button.pressed
	Global.mouse_mode_on = mouse_button.pressed
	Global.sound_on = sound_button.pressed
	Global.music_on = music_button.pressed
	
	emit_signal("settings_changed")

func _on_play_pressed():
	emit_signal("play_button_pressed")
