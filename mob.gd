extends CharacterBody2D

signal slime_died 

var health = 3

@onready var player = get_node("/root/game/player")
@onready var sfx_hurt: AudioStreamPlayer2D = $sfx_hurt

func _ready():
	add_to_group("Slimes")
	%Slime.play_walk()

func _physics_process(delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * 300.0
	move_and_slide()

func take_damage():
	health -= 1
	%Slime.play_hurt()

	if health <= 0:
		var pos := global_position

		var p := AudioStreamPlayer2D.new()
		p.stream = sfx_hurt.stream
		p.global_position = pos
		p.bus = sfx_hurt.bus
		p.volume_db = -16.0
		get_tree().current_scene.add_child(p)
		p.play()
		p.finished.connect(p.queue_free)

		emit_signal("slime_died")

		const SMOKE_SCENE := preload("res://smoke_explosion/smoke_explosion.tscn")
		var smoke := SMOKE_SCENE.instantiate()
		get_parent().add_child(smoke)
		smoke.global_position = pos

		queue_free()
