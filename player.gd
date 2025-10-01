extends CharacterBody2D

signal health_depleted
signal level_changed(new_level: int)
signal coins_changed(new_total: int)
signal fire_rate_changed(multiplier: float)
signal kill_milestone_reached(amount: int)
signal upgrade_purchased

var coins := 0
const COINS_PER_SLIME := 10
var purchased_upgrades := {}
var fire_rate_level: int = 0
var health = 100.0
var level = 8
var slimes_killed = 0
var total_slimes_killed: int = 0
var _hit_10: bool = false
var _hit_100: bool = false
const XP = 1
const SLIMES_NEEDED = 10

@export var fire_rate_step: float = 0.5

@onready var levelup_label := get_node_or_null("%level_up_label")
@onready var levelup_timer := get_node_or_null("%level_up_timer")
@onready var sfx_lvlup: AudioStreamPlayer2D = $sfx_lvlup

var l10_bonus_applied: bool = false
@export var l10_bonus_mult: float = 5

func _ready():
	add_to_group("Player")
	for slime in get_tree().get_nodes_in_group("Slimes"):
		connect_slime(slime)

	if levelup_timer and not levelup_timer.timeout.is_connected(_on_LevelUpTimer_timeout):
		levelup_timer.timeout.connect(_on_LevelUpTimer_timeout)
	if levelup_label:
		levelup_label.visible = false

	print("[PLAYER] ready; found slimes:", get_tree().get_nodes_in_group("Slimes").size())
	level_changed.emit(level)

func add_coins(amount: int) -> void:
	coins += amount
	coins_changed.emit(coins)
	
func spend_coins(amount: int) -> bool:
	if coins >= amount:
		coins -= amount
		coins_changed.emit(coins)
		return true
	else:
		print("Not enough coins!")
		return false
		
func apply_fire_rate_upgrade_for_tier(tier: int, cost: int) -> bool:
	if tier in purchased_upgrades:
		print("Upgrade for level %d already purchased." % tier)
		return false

	if not spend_coins(cost):
		return false

	purchased_upgrades[tier] = true
	_recompute_fire_rate_and_emit()
	fire_rate_level += 2

	var multiplier := 1.0 + fire_rate_level * fire_rate_step
	fire_rate_changed.emit(multiplier)
	emit_signal("upgrade_purchased")
	return true

func _recompute_fire_rate_and_emit() -> void:
	var upgrades_mult := 1.0 + fire_rate_level * fire_rate_step
	var bonus := l10_bonus_mult if l10_bonus_applied else 1.0
	var total := upgrades_mult * bonus
	fire_rate_changed.emit(total)

func connect_slime(slime: Node) -> void:
	if slime and slime.has_signal("slime_died"):
		if not slime.slime_died.is_connected(_on_slime_died):
			slime.slime_died.connect(_on_slime_died)
			print("[PLAYER] connected to", slime.get_path())

func _on_slime_died():
	print("[PLAYER] slime_died received")
	slimes_killed += 1
	total_slimes_killed += 1
	add_coins(COINS_PER_SLIME)
	
	if not _hit_10 and total_slimes_killed >= 10:
		_hit_10 = true
		kill_milestone_reached.emit(10)
	if not _hit_100 and total_slimes_killed >= 100:
		_hit_100 = true
		kill_milestone_reached.emit(100)
	
	if slimes_killed >= SLIMES_NEEDED:
		level_up()
		slimes_killed = 0

func level_up() -> void:
	sfx_lvlup.play()
	level += 1
	print("LEVEL UP! New level:", level)
	
	if not l10_bonus_applied and level >= 10:
		l10_bonus_applied = true
		_recompute_fire_rate_and_emit()
	
	if levelup_label:
		levelup_label.visible = true
		levelup_label.modulate.a = 1.0

	if levelup_timer:
		levelup_timer.stop()
		levelup_timer.start()
	else:
		await get_tree().create_timer(2.0, true, true).timeout
		if levelup_label: levelup_label.visible = false

	level_changed.emit(level)
	
func _on_LevelUpTimer_timeout() -> void:
	if levelup_label:
		levelup_label.visible = false

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
