extends Node2D

# Difficulty
@export var base_wait: float = 2.0
@export var min_wait: float = 0.5
@export var wait_decay_per_level: float = 0.15

@export var base_mobs_per_tick: int = 1
@export var extra_mob_every_n_levels: int = 3

@export var max_slimes_on_map: int = 40

var paused: bool = false
var _mobs_per_tick: int = 1

# Scene refs
@onready var player := get_tree().get_first_node_in_group("Player")
@onready var level_num_label := %levelNum
@onready var coin_label := %coinUI
@onready var spawn_timer: Timer = %Timer             # make sure node is actually named "timer"
@onready var path_follow: PathFollow2D = %PathFollow2D
@onready var shop_layer := %shop

func _ready():
	if player:
		if player.has_signal("level_changed"):
			player.level_changed.connect(_on_player_level_changed)
		if player.has_signal("coins_changed"):
			player.coins_changed.connect(_on_player_coins_changed)

	if level_num_label:
		level_num_label.text = "Level: 0"
	if coin_label:
		coin_label.text = "Coins: 0"

	_apply_spawn_rate_for_level(0)

func _on_player_coins_changed(total: int) -> void:
	if coin_label:
		coin_label.text = "Coins: %d" % total

func _on_player_level_changed(new_level: int) -> void:
	if level_num_label:
		level_num_label.text = "Level: %d" % new_level
	if shop_layer and (new_level == 10 or new_level == 20 or new_level == 40):
		shop_layer.show_for_level(new_level)
	_apply_spawn_rate_for_level(new_level)

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

# Pause menu
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		pauseMenu()

func pauseMenu() -> void:
	if paused:
		%pause.hide()
		Engine.time_scale = 1.0
	else:
		%pause.show()
		Engine.time_scale = 0.0
	paused = !paused

# Game over
func _on_player_health_depleted() -> void:
	%gameover.visible = true
	get_tree().paused = true
