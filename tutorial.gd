extends Node2D

var tut_steps = 4
var tut_step = 1

onready var tut_group_one := get_tree().get_nodes_in_group('Tut1')
onready var tut_group_two := get_tree().get_nodes_in_group('Tut2')
onready var tut_group_three := get_tree().get_nodes_in_group('Tut3')
onready var tut_group_four := get_tree().get_nodes_in_group('Tut4')


func start_tutorial() -> void:
	show_tut()
	$TutTimer.start()
	Global.tutorial_done = true
	
	tut_group_three[0].text = 'You can walk here with ' + ('mouse button' if Global.mouse_mode_on else 'enter key')

func get_tut():
	match tut_step:
		1:
			return {"button": tut_group_one[0], "arrow": tut_group_one[1]}
		2:
			return {"button": tut_group_two[0], "arrow": tut_group_two[1]}
		3:
			return {"button": tut_group_three[0], "arrow": tut_group_three[1]}
		4:
			show_tut_four()

func show_tut() -> void:
	if tut_step < tut_steps:
		var elements = get_tut()
		print("button: ", elements["button"], " sprite: ", elements["arrow"])
		elements["button"].visible = true
		elements["arrow"].visible = true
	else:
		show_tut_four()

func show_tut_four() -> void:
	for element in tut_group_four:
		element.visible = true

func hide_tut() -> void:
	if tut_step < tut_steps:
		var elements = get_tut()
		elements["button"].visible = false
		elements["arrow"].visible = false
	else:
		hide_tut_four()

func hide_tut_four() -> void:
	for element in tut_group_four:
		element.visible = false

func _on_timeout():
	hide_tut()
	tut_step += 1
	if tut_step <= tut_steps:
		show_tut()
		$TutTimer.start()
