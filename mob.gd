extends CharacterBody2D

signal slime_died 

var health = 3

@onready var player = get_node("/root/game/player")

func _ready():
	add_to_group("Slimes")
	%Slime.play_walk()

func _physics_process(delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * 300.0
	move_and_slide()

func take_damage():
	if health <= 0:
		return
	health -= 1
	%Slime.play_hurt()

	if health <= 0:
		print("[SLIME] emitting slime_died from:", self.get_path())
		emit_signal("slime_died")
		var pos := global_position
		const SMOKE_SCENE := preload("res://smoke_explosion/smoke_explosion.tscn")
		var smoke := SMOKE_SCENE.instantiate()
		get_parent().add_child(smoke)
		smoke.global_position = pos
		queue_free()
