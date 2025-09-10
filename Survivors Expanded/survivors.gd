extends Node2D

var paused = false

func spawn_mob():
	var new_mob = preload("res://mob.tscn").instantiate()
	%PathFollow2D.progress_ratio = randf()
	new_mob.global_position = %PathFollow2D.global_position
	add_child(new_mob)
	
func spawn_tree():
	var new_tree = preload("res://pine_tree.tscn").instantiate()
	%PathFollow2D.progress_ratio = randf()
	new_tree.global_position = %PathFollow2D.global_position
	add_child(new_tree)

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		pauseMenu()

func pauseMenu():
	if paused:
		%pause.hide()
		Engine.time_scale = 1
	else:
		%pause.show()
		Engine.time_scale = 0
	
	paused = !paused

func _on_timer_timeout():
	spawn_mob()
	spawn_tree()

func _on_player_health_depleted():
	%gameover.visible = true
	get_tree().paused = true
