extends Node2D

var enemy_scene = preload("res://characters/enemy.tscn")
var enemy2_scene = preload("res://characters/enemy2.tscn")
var enemy3_scene = preload("res://characters/enemy3.tscn")
var enemy4_scene = preload("res://characters/enemy4.tscn")

signal show_wave_start(wave_name, wave_number)
signal show_game_over()

onready var enemy_path := $EnemyPath
onready var navigation := $Tiles/Navigation2D
onready var hero := $Hero
onready var position_indicators := get_tree().get_nodes_in_group('PositionIndicators')
onready var graves := get_tree().get_nodes_in_group('Graves')
onready var grave_paths := get_tree().get_nodes_in_group('GravePaths')
onready var select_box := $Indicators/SelectBox
onready var footprint_dummy := $Footprint

onready var menu_scene := $UI/Menu
onready var graves_label := $UI/GravesCount
onready var points_label := $UI/PointsCount
onready var graves_image := $UI/GraveCountSprite


var time_passed := 0.0
var waves := {}
var waves_passed := 0
var enemies_config := {}
var wave_enemies := []
var enemy_counter := 0
var default_spawn_speed := 1
var waves_spawn_speed = null
var next_indicator_index = 0
var game_over := false
var points := 0
var footprint_sprites := []

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	if not Global.music_on:
		$BackgroundMusic.autoplay = false
		$BackgroundMusic.stop()
	
	set_process(false)
	reset_game()
	
	$UI.connect("wave_screen_done", self, "_wave_screen_done")
	$UI.connect("game_over_screen_done", self, "_game_over_screen_done")

	menu_scene.connect("play_button_pressed", self, "_play_button_pressed")
	menu_scene.connect("settings_changed", self, "_settings_changed")
	
	hero.connect("path_end_reached", self, "_path_end_reached")
	hero.connect("path_footprint_reached", self, "_path_footprint_reached")

	for indicator in position_indicators:
		indicator.connect("position_indicator_pressed", self, "_on_position_indicator_pressed")

	$UI.visible = true


func _process(delta):

	time_passed += delta
	var spawn_speed = default_spawn_speed
	if waves_spawn_speed and len(waves_spawn_speed) > enemy_counter:
		spawn_speed = waves_spawn_speed[enemy_counter]
			
	if time_passed > spawn_speed:
		if wave_enemies and len(wave_enemies) > 0:
			spawn_enemy_of_type(wave_enemies.pop_front())
			time_passed = 0.0
		else:
			pass
#			print("Wave completed")

func _input(event):
	if Global.mouse_mode_on:
		return
	
	if Global.tutorial_on and not Global.tutorial_done:
		return
	
	if event is InputEventKey and event.is_pressed():
		match event.scancode:
			KEY_ENTER:
				move_to_indicator()
				update_indicator()


# Custom Methods
func start_game() -> void:
	load_waves()
	if waves_passed == 0:
		load_next_wave()
	
	for indicator in position_indicators:
		indicator.visible = Global.mouse_mode_on and !Global.tutorial_on

	if not Global.tutorial_on:
		graves_label.visible = true
		points_label.visible = true
		graves_image.visible = true
		hero.visible = true
		select_box.visible = !Global.mouse_mode_on
	else:
		select_box.visible = false


func reset_game() -> void:
	time_passed = 0.0
	waves = {}
	waves_passed = 0
	enemies_config = {}
	wave_enemies = []
	enemy_counter = 0
	default_spawn_speed = 1
	waves_spawn_speed = null
	next_indicator_index = 0
	game_over = false
	points = 0
	
	for main_child in get_children():
		if main_child is Enemy:
			main_child.remove_enemy()
	
	grave_paths = get_tree().get_nodes_in_group('GravePaths')
	graves = get_tree().get_nodes_in_group('Graves')
	for grave in graves:
		grave.occupied = false
		grave.destroyed = false
	
	graves_label.text = str(len(graves))
	points_label.text = "0 Points"
	graves_label.visible = false
	points_label.visible = false
	graves_image.visible = false
	select_box.visible = false

	hero.position = position_indicators.back().position
	select_box.position = position_indicators[next_indicator_index].position

func load_waves() -> void:
	waves = Global.level
	enemies_config = waves["enemies"]

func load_next_wave() -> void:
	set_process(false)
	
	if game_over:
		return
	
	enemy_counter = 0
	var waves_config = waves["waves"]
	
	if waves_passed == len(waves_config):
		print("ALL WAVES DONE", " GAME OVER, you won")
		emit_signal("show_game_over", true, points)
		if Global.sound_on:
			$WinSound.play()
	
	if waves_config is Array and len(waves_config) > waves_passed:
		emit_signal("show_wave_start", waves_config[waves_passed]["name"], str(waves_passed + 1))
		
		wave_enemies = waves_config[waves_passed]["eniemies"].duplicate(true)
		waves_spawn_speed = waves_config[waves_passed]["spawn_speed"]
		default_spawn_speed = waves_config[waves_passed]["default_spawn_speed"]

func spawn_enemy_of_type(enemy_type: String) -> void:
	var new_enemy = null
	match enemy_type:
		"enemy":
			new_enemy = enemy_scene.instance()
		"enemy2":
			new_enemy = enemy2_scene.instance()
		"enemy3":
			new_enemy = enemy3_scene.instance()
		"enemy4":
			new_enemy = enemy4_scene.instance()
		_:
			new_enemy = enemy_scene.instance()
	
	var enemy_values = enemies_config[enemy_type]
	new_enemy.speed = enemy_values["speed"]
	new_enemy.lives = enemy_values["lives"]
	new_enemy.points = enemy_values["points"]
	print("New enemy: " + enemy_type +
		" lives: " + str(new_enemy.lives) +
		" speed: " + str(new_enemy.speed) +
		" points: ", str(new_enemy.points) +
		" z-indez: ", str(new_enemy.z_index))
	
	new_enemy.connect("enemy_died", self, "_on_enemy_died")
	new_enemy.connect("enemy_reached_end", self, "_on_enemy_reached_end")
	new_enemy.connect("enemy_destroyed_grave", self, "_on_enemy_destroyed_grave")
	add_child(new_enemy)
	new_enemy.set_path_to_follow(PoolVector2Array(enemy_path.curve.tessellate()))
	
	enemy_counter += 1

func move_to_indicator() -> void:
	var indicator_position = position_indicators[next_indicator_index].position
	hero.path = navigation.get_simple_path(hero.global_position, indicator_position)
	show_footprints(hero.path)

func show_footprints(move_paths) -> void:
	clear_footprint()
	
	if move_paths.size() < 2:
		return
	
	for i in range(move_paths.size()):
		
		if i == 0:
			continue
		
		var start_from: Vector2 = move_paths[i - 1]
		var move_to: Vector2 = move_paths[i]
		var move_direction = start_from.angle_to_point(move_to)
		var move_distance = start_from.distance_to(move_to)
		
		var distance_moved = 0
		while distance_moved + footprint_dummy.texture.get_size().y < move_distance:
			distance_moved += footprint_dummy.texture.get_size().y + 8
		
			var new_point = start_from.move_toward(move_to, distance_moved)
			var tmp_footprint = footprint_dummy.duplicate()
			tmp_footprint.position = new_point
			tmp_footprint.rotate(move_direction)
			add_child(tmp_footprint)
			footprint_sprites.append(tmp_footprint)
		
func clear_footprint() -> void:
	if footprint_sprites:
		for footprint_sprite in footprint_sprites:
			remove_child(footprint_sprite)
			footprint_sprite.queue_free()
		footprint_sprites.clear()
		
func update_indicator() -> void:
	if next_indicator_index < len(position_indicators) - 1:
		next_indicator_index += 1
	else:
		next_indicator_index = 0

	select_box.position = position_indicators[next_indicator_index].position

func handle_enemy_removed() -> void:
	if Global.sound_on:
		$EnemyDied.play()
		
	if enemy_counter > 1:
		enemy_counter -= 1
	else:
		print("Wave over")
		waves_passed += 1
		load_next_wave()

# Signals
func _path_end_reached() -> void:
	clear_footprint()
	
func _path_footprint_reached(footprint) -> void:
	if footprint in footprint_sprites:
		remove_child(footprint)
		footprint.queue_free()
		footprint_sprites.erase(footprint)

func _on_position_indicator_pressed(click_position):
	var new_path = navigation.get_simple_path(hero.global_position, click_position)
	hero.path = new_path

func _on_enemy_died(enemy : Enemy) -> void:
	points += enemy.points
	points_label.text = str(points) + " Points"
	handle_enemy_removed()

func _on_enemy_reached_end(enemy : Enemy) -> void:
	for grave in graves:
		if not grave.occupied and not grave.destroyed:
			grave.occupied = true
			var grave_index = graves.find(grave)
			var grave_path = grave_paths[grave_index]
			enemy.grave_path = true
			enemy.grave = grave
			enemy.set_path_to_follow(PoolVector2Array(grave_path.curve.tessellate()))
			break

func _on_enemy_destroyed_grave(enemy: Enemy) -> void:
	if enemy.grave:
		enemy.grave.destroyed = true
		var grave_index = graves.find(enemy.grave)
		if grave_index > -1:
			graves.remove(grave_index)
			grave_paths.remove(grave_index)
			graves_label.text = str(len(graves))
			
			if Global.sound_on:
				$GraveDestroyed.play()
			
		if len(graves) == 0:
			game_over = true
			print("GAME OVER, you failed")
			emit_signal("show_game_over", false, points)
	handle_enemy_removed()

func _play_button_pressed() -> void:
	reset_game()
	menu_scene.visible = false
	start_game()

func _wave_screen_done() -> void:
	if waves_passed == 0 and Global.tutorial_on:
		$AnimatedEnemy/AnimationPlayer.play("intro_enemy")
		$AnimatedHero/AnimationPlayer.play("intro_hero")
	else:
		select_box.visible = !Global.mouse_mode_on
		for indicator in position_indicators:
			indicator.visible = Global.mouse_mode_on 
		set_process(true)


func _game_over_screen_done() -> void:
	menu_scene.visible = true
	menu_scene.set_highscore(points)
	
	graves_label.visible = false
	points_label.visible = false
	graves_image.visible = false
	set_process(false)

func _settings_changed() -> void:
	if Global.music_on and not $BackgroundMusic.playing:
		$BackgroundMusic.play()
	elif not Global.music_on:
		$BackgroundMusic.stop()


func _on_AnimationPlayer_animation_finished(anim_name):
	print("_on_AnimationPlayer_animation_finished: ", anim_name)
	if anim_name == "intro_hero":
		$AnimatedHero/AnimationPlayer.play("start_game")
	elif anim_name == "start_game" and not Global.tutorial_done:
		$Tutorial.start_tutorial()
		hero.visible = true
		select_box.visible = !Global.mouse_mode_on
		for indicator in position_indicators:
			indicator.visible = Global.mouse_mode_on 
		$AnimatedHero.visible = false
		Global.tutorial_on = false
		set_process(true)


func _on_gangway_body_entered(body):
	hero.add_enemy_in_gangway(body)

func _on_gangway_body_exited(body):
	hero.remove_enemy_in_gangway(body)
