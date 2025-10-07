extends Node2D

# Difficulty
@export var base_wait: float = 2.0
@export var min_wait: float = 0.5
@export var wait_decay_per_level: float = 0.15
@export var base_mobs_per_tick: int = 1
@export var extra_mob_every_n_levels: int = 3

@export var max_slimes_on_map: int = 40

var paused: bool = false
var game_started: bool = false
var _mobs_per_tick: int = 1

# Objectives
@onready var obj1: Label = %obj1
@onready var obj2: Label = %obj2
@onready var obj3: Label = %obj3
@onready var obj4: Label = %obj4

var objectives_completed: Array[bool] = [false, false, false, false]

# Scene refs
@onready var player := get_tree().get_first_node_in_group("Player")
@onready var level_num_label := %levelNum
@onready var coin_label := %coinUI
@onready var spawn_timer: Timer = %Timer
@onready var path_follow: PathFollow2D = %PathFollow2D
@onready var shop_layer := %shop
@onready var sfx_shop: AudioStreamPlayer2D = $sfx_shop
@onready var sfx_gameover: AudioStreamPlayer2D = $sfx_gameover
@onready var win_layer: CanvasLayer = %win
@onready var start_layer: CanvasLayer = %start
@onready var settings_layer: CanvasLayer = %settings
@onready var tile_l10: TileMapLayer = %base
@onready var spawn_l10: Marker2D = %Spawn_L10
@onready var l10_obj_layer: CanvasLayer = %L10_OBJ
@onready var l10_obj_sprite: Sprite2D = %L10Obj
@onready var settings_layer_script := settings_layer
@onready var pause_layer: CanvasLayer = %pause
@onready var pause_settings_btn: Button = %settings_btn2

var l10_popup_shown: bool = false
var l10_layers: Array[TileMapLayer] = []
var _l10_col_layer: int
var _l10_col_mask: int
var moved_to_l10: bool = false
var has_won: bool = false
var _settings_opened_from_pause := false

func _ready():
	
	get_tree().paused = true
	start_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	start_layer.visible = true
	start_layer.start_requested.connect(_start_game)
	start_layer.settings_requested.connect(_show_settings)
	
	settings_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	settings_layer.visible = false
	
	if settings_layer.has_signal("close_requested"):
		settings_layer.close_requested.connect(_on_settings_closed)
	
	if pause_settings_btn and not pause_settings_btn.pressed.is_connected(_on_pause_settings_pressed):
		pause_settings_btn.pressed.connect(_on_pause_settings_pressed)
	
	if start_layer:
		start_layer.visible = true
	
	_refresh_objectives()
	
	if win_layer:
		win_layer.visible = false
	
	if player:
		if player.has_signal("level_changed"):
			player.level_changed.connect(_on_player_level_changed)
		if player.has_signal("coins_changed"):
			player.coins_changed.connect(_on_player_coins_changed)
		if player.has_signal("kill_milestone_reached"):
			player.kill_milestone_reached.connect(_on_kill_milestone)
		if player.has_signal("upgrade_purchased"):
			player.upgrade_purchased.connect(_on_upgrade_purchased)

	AudioManager.register(sfx_gameover)
	AudioManager.register(sfx_shop)

	l10_layers.clear()
	if l10_obj_layer:
		l10_obj_layer.visible = false
	for n in get_tree().get_nodes_in_group("Level10"):
		if n is TileMapLayer:
			l10_layers.append(n)
			
	for layer in l10_layers:
		layer.visible = false
		layer.collision_enabled = false

	if level_num_label:
		level_num_label.text = "Level: 0"
	if coin_label:
		coin_label.text = "Coins: 0"

	_apply_spawn_rate_for_level(0)

func _show_settings() -> void:
	if settings_layer:
		settings_layer.visible = true
	if start_layer and start_layer.has_method("on_settings_opened"):
		start_layer.on_settings_opened()

func _on_settings_closed() -> void:
	if settings_layer:
		settings_layer.visible = false
	if start_layer and start_layer.has_method("on_settings_closed"):
		start_layer.on_settings_closed()
	
	if _settings_opened_from_pause:
		_settings_opened_from_pause = false
		if pause_layer:
			pause_layer.visible = true

func _on_kill_milestone(amount: int) -> void:
	if amount == 10:
		complete_objective(0)  # obj1
	elif amount == 100:
		complete_objective(1)  # obj2
	elif amount == 1000:
		if not has_won and player and player.level >= 10:
			_on_player_won()

func _on_upgrade_purchased() -> void:
	complete_objective(2)      # obj3

func complete_objective(index: int) -> void:
	if index < 0 or index >= objectives_completed.size():
		return
	if objectives_completed[index]:
		return

	objectives_completed[index] = true
	_refresh_objectives()
	print("Objective %d completed!" % (index + 1))

func reset_objectives() -> void:
	for i in objectives_completed.size():
		objectives_completed[i] = false
	_refresh_objectives()

func _refresh_objectives() -> void:
	obj1.visible = objectives_completed[0]
	obj2.visible = objectives_completed[1]
	obj3.visible = objectives_completed[2]
	obj4.visible = objectives_completed[3]

func _on_player_coins_changed(total: int) -> void:
	if coin_label:
		coin_label.text = "Coins: %d" % total

func _on_player_level_changed(new_level: int) -> void:
	if level_num_label:
		level_num_label.text = "Level: %d" % new_level
	if shop_layer and (new_level == 10 or new_level == 20 or new_level == 40):
		shop_layer.show_for_level(new_level)
		_play_ui_sfx_from(sfx_shop, -10.0)
	
	if not moved_to_l10 and new_level >= 10:
		_switch_to_l10_area()
		
	if not l10_popup_shown and new_level >= 10:
		l10_popup_shown = true
		_show_l10_objective_popup()

	_apply_spawn_rate_for_level(new_level)
	if new_level >= 100:
		complete_objective(3)  # obj4

# New level
func _switch_to_l10_area() -> void:
	moved_to_l10 = true

	for layer in l10_layers:
		layer.collision_enabled = true
		layer.visible = true

	if player and spawn_l10:
		player.global_position = spawn_l10.global_position

	for s in get_tree().get_nodes_in_group("Slimes"):
		if is_instance_valid(s):
			s.queue_free()
			
func _show_l10_objective_popup() -> void:
	if l10_obj_layer:
		l10_obj_layer.visible = true
		await get_tree().create_timer(3.0).timeout
		l10_obj_layer.visible = false


# Spawn interval
func _apply_spawn_rate_for_level(level: int) -> void:
	var desired: float = base_wait - wait_decay_per_level * float(level)
	var new_wait: float = maxf(min_wait, desired)
	if absf(spawn_timer.wait_time - new_wait) > 0.0001:
		spawn_timer.wait_time = new_wait
		if not spawn_timer.is_stopped():
			spawn_timer.start()

	var steps: int = int(floor(float(level) / float(extra_mob_every_n_levels)))
	_mobs_per_tick = max(1, base_mobs_per_tick + steps)

# Spawning
func spawn_mob() -> void:
	var new_mob := preload("res://mob.tscn").instantiate()
	path_follow.progress_ratio = randf()
	new_mob.global_position = path_follow.global_position
	add_child(new_mob)

	if player == null:
		player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("connect_slime"):
		player.connect_slime(new_mob)
	else:
		push_warning("Player not found or connect_slime missing")

func spawn_tree() -> void:
	var new_tree := preload("res://pine_tree.tscn").instantiate()
	path_follow.progress_ratio = randf()
	new_tree.global_position = path_follow.global_position
	add_child(new_tree)

func _on_timer_timeout() -> void:
	var current_slimes: int = get_tree().get_nodes_in_group("Slimes").size()
	var allowed: int = maxi(0, max_slimes_on_map - current_slimes)
	if allowed > 0:
		var to_spawn: int = mini(allowed, _mobs_per_tick)
		for i in to_spawn:
			spawn_mob()
	spawn_tree()

# Temp audio player
func _play_ui_sfx_from(base_player: AudioStreamPlayer2D, volume_db: float = 0.0, pitch: float = 1.0) -> void:
	if base_player == null or base_player.stream == null:
		return
	_play_ui_sfx(base_player.stream, base_player.bus, volume_db, pitch)

func _play_ui_sfx(stream: AudioStream, bus: String = "Master", volume_db: float = 0.0, pitch: float = 1.0) -> void:
	var p := AudioStreamPlayer.new()
	p.stream = stream
	p.bus = bus
	p.volume_db = volume_db
	p.pitch_scale = pitch

	p.process_mode = Node.PROCESS_MODE_ALWAYS

	get_tree().current_scene.add_child(p)
	AudioManager.apply_current_to(p)
	p.play()
	p.finished.connect(p.queue_free)

# Pause menu & start
func _process(delta: float) -> void:
	if not game_started and Input.is_action_just_pressed("pause"):
		_start_game()
		return
	
	if game_started and Input.is_action_just_pressed("pause"):
		pauseMenu()

func _start_game() -> void:
	game_started = true
	if start_layer: start_layer.visible = false
	get_tree().paused = false
	if spawn_timer and spawn_timer.is_stopped():
		spawn_timer.start()

func pauseMenu() -> void:
	if paused:
		%pause.hide()
		Engine.time_scale = 1.0
	else:
		%pause.show()
		Engine.time_scale = 0.0
	paused = !paused

func _on_pause_settings_pressed() -> void:
	_settings_opened_from_pause = true
	if pause_layer:
		pause_layer.visible = false       
	_show_settings()                     

# Game over
func _on_player_health_depleted() -> void:
	%gameover.visible = true
	_play_ui_sfx_from(sfx_gameover, -10.0)
	get_tree().paused = true

# Win
func _on_player_won() -> void:
	has_won = true

	if win_layer:
		win_layer.visible = true

	for s in get_tree().get_nodes_in_group("Slimes"):
		if is_instance_valid(s):
			s.queue_free()

	get_tree().paused = true
