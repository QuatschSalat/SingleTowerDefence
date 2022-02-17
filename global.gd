extends Node

var sound_on = true
var music_on = false
var tutorial_on = true
var mouse_mode_on = false

var debug_mode = false

var highscore = 0
var tutorial_done = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if debug_mode:
		OS.window_position.y = 0
		OS.set_window_title("DEBUG MODE")

		sound_on = false
		music_on = false
		tutorial_on = false

		print("sound_on: ", sound_on)
		print("music_on: ", music_on)



var level = {
	"enemies": {
		"enemy": {
			"lives": 2,
			"speed": 70,
			"points": 10
		},
		"enemy2": {
			"lives": 3,
			"speed": 90,
			"points": 20
		},
		"enemy3": {
			"lives": 4,
			"speed": 120,
			"points": 30
		},
		"enemy4": {
			"lives": 5,
			"speed": 100,
			"points": 40
		}
	},
	"waves": [
		{
			"spawn_speed": null,
			"default_spawn_speed": 2,
			"name": "First try",
			"eniemies": ["enemy", "enemy", "enemy", "enemy", "enemy", "enemy", "enemy", "enemy"]
		},
		{
			"spawn_speed": [1, 3, 1, 3],
			"default_spawn_speed": 2,
			"name": "Ok, you are ready",
			"eniemies": ["enemy2", "enemy", "enemy2", "enemy2", "enemy", "enemy2"]
		},
		
		{
			"spawn_speed": [1, 3, 1, 1, 2, 2],
			"default_spawn_speed": 2,
			"name": "Bring them all",
			"eniemies": ["enemy2", "enemy", "enemy2", "enemy2", "enemy", "enemy2", "enemy2", "enemy", "enemy2", "enemy2", "enemy2", "enemy", "enemy2", "enemy2"]
		},
		
		{
			"spawn_speed": [1, 1, 3, 1, 2, 1],
			"default_spawn_speed": 2,
			"name": "Now we're talking",
			"eniemies": ["enemy2", "enemy", "enemy3", "enemy2", "enemy2", "enemy", "enemy2", "enemy3", "enemy2"]
		},
		
		{
			"spawn_speed": null,
			"default_spawn_speed": 2,
			"name": "So, you are not a noob.",
			"eniemies": ["enemy3", "enemy2", "enemy3", "enemy2", "enemy3", "enemy2", "enemy3", "enemy2", "enemy3"]
		},
		{
			"spawn_speed": [1, 2, 1, 2, 1, 1],
			"default_spawn_speed": 2,
			"name": "Now you gonna die",
			"eniemies": ["enemy3", "enemy2", "enemy3", "enemy2", "enemy4", "enemy2", "enemy3", "enemy3", "enemy2"]
		}
	]
}
