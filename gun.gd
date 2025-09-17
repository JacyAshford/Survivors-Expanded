extends Area2D

@export var base_wait: float = 0.8
@onready var fire_timer: Timer = %Timer 
@onready var player := get_tree().get_first_node_in_group("Player")

func _ready() -> void:
	if fire_timer:
		fire_timer.wait_time = base_wait
		if fire_timer.is_stopped():
			fire_timer.start()

	if player and player.has_signal("fire_rate_changed"):
		player.fire_rate_changed.connect(_on_fire_rate_changed)

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
	const BULLET = preload("res://bullet.tscn")
	var new_bullet = BULLET.instantiate()
	new_bullet.global_position = %shootingpoint.global_position
	new_bullet.global_rotation = %shootingpoint.global_rotation
	%shootingpoint.add_child(new_bullet)

func _on_timer_timeout() -> void:
	shoot()
