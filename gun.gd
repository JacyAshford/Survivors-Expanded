extends Area2D

@export var base_wait: float = 0.05
@onready var fire_timer: Timer = %Timer 
@onready var player := get_tree().get_first_node_in_group("Player")
@onready var sfx_gun: AudioStreamPlayer2D = $"../sfx_gun"

func _ready() -> void:
	if fire_timer:
		fire_timer.one_shot = false
		if fire_timer.is_stopped():
			fire_timer.start()
			
	_try_connect_player()
	call_deferred("_deferred_connect")

func _try_connect_player() -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("Player")
	if player and player.has_signal("fire_rate_changed"):
		if not player.fire_rate_changed.is_connected(_on_fire_rate_changed):
			player.fire_rate_changed.connect(_on_fire_rate_changed)
		if player.has_method("_recompute_fire_rate_and_emit"):
			player._recompute_fire_rate_and_emit()

func _deferred_connect() -> void:
	_try_connect_player()

func _on_fire_rate_changed(multiplier: float) -> void:
	if fire_timer:
		fire_timer.wait_time = base_wait / max(multiplier, 0.0001)
		if not fire_timer.is_stopped():
			fire_timer.start()

func _physics_process(delta: float) -> void:
	var enemies_in_range = get_overlapping_bodies()
	if enemies_in_range.size() > 0:
		var target_enemy = enemies_in_range.front()
		look_at(target_enemy.global_position)

func shoot() -> void:
	sfx_gun.play()
	const BULLET = preload("res://bullet.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.global_position = %shootingpoint.global_position
	new_bullet.global_rotation = %shootingpoint.global_rotation
	%shootingpoint.add_child(new_bullet)

func _on_timer_timeout() -> void:
	shoot()
