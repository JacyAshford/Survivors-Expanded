extends CharacterBody2D

signal health_depleted

var health = 100.0
var level = 0
var slimes_killed = 0
const XP = 1
const SLIMES_NEEDED = 10

func _ready():
	for slime in get_tree().get_nodes_in_group("Slimes"):
		connect_slime(slime)

func connect_slime(slime: Node) -> void:
	if slime.has_signal("slime_died") and not slime.slime_died.is_connected(_on_slime_died):
		slime.slime_died.connect(_on_slime_died)

func _on_slime_died() -> void:
	slimes_killed += 1
	if slimes_killed >= SLIMES_NEEDED:
		level_up()
		slimes_killed = 0

func level_up() -> void:
	level += 1
	print("LEVEL UP! New level:", level)
	%LevelUpLabel.visible = true
	%LevelUpTimer.start()
	
func _on_LevelUpTimer_timeout() -> void:
	%LevelUpLabel.visible = false

func _physics_process(delta):
	var direction = Input.get_vector("move_left","move_right","move_up","move_down")
	velocity = direction * 600
	move_and_slide()
	
	if velocity.length() > 0.0:
		$HappyBoo.play_walk_animation()
	else:
		$HappyBoo.play_idle_animation()
	

	const DAMAGE_RATE = 6.0
	var overlapping_mobs = %hurtbox.get_overlapping_bodies()
	if overlapping_mobs.size() > 0:
		health -= DAMAGE_RATE * overlapping_mobs.size() * delta
		%ProgressBar.value = health
		if health <= 0.0:
			health_depleted.emit()
