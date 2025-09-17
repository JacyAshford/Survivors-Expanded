extends CanvasLayer

@export var cost_lvl10: int = 75
@export var cost_lvl20: int = 150
@export var cost_lvl40: int = 300

@onready var bg: ColorRect   = %shopBG
@onready var s10: Sprite2D   = %L10Shop
@onready var s20: Sprite2D   = %L20Shop
@onready var s40: Sprite2D   = %L40Shop
@onready var b10: Button = %ShopUpgrade10
@onready var b20: Button = %ShopUpgrade20
@onready var b40: Button = %ShopUpgrade40
@onready var close_btn: Button = get_node_or_null("%shopCloseBtn")
@onready var player := get_tree().get_first_node_in_group("Player")

func _ready() -> void:
	visible = false
	_show_sprite(null)
	if close_btn:
		close_btn.pressed.connect(close_shop)
		
	if b10: b10.pressed.connect(func(): _on_upgrade_pressed(10))
	if b20: b20.pressed.connect(func(): _on_upgrade_pressed(20))
	if b40: b40.pressed.connect(func(): _on_upgrade_pressed(40))
	
	if bg: bg.mouse_filter = Control.MOUSE_FILTER_STOP

func show_for_level(level: int, pause_game: bool = true) -> void:
	var target: Sprite2D = null
	if level >= 40:
		target = s40
	elif level >= 20:
		target = s20
	elif level >= 10:
		target = s10
	else:
		return

	_show_sprite(target)
	_enable_buttons_for_level(level)
	visible = true
	if pause_game:
		Engine.time_scale = 0.0
		
func _enable_buttons_for_level(level: int) -> void:
	if b10: b10.visible = level >= 10 and level < 20
	if b20: b20.visible = level >= 20 and level < 40
	if b40: b40.visible = level >= 40
	
func _on_upgrade_pressed(tier: int) -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("Player")
	if player == null:
		push_warning("No player found for shop purchase")
		return

	var cost := 0
	match tier:
		10: cost = cost_lvl10
		20: cost = cost_lvl20
		40: cost = cost_lvl40

	if player.spend_coins(cost):
		print("Upgrade for level %d purchased for %d coins" % [tier, cost])
		close_shop()
	else:
		print("Not enough coins for level %d upgrade (need %d)" % [tier, cost])

func close_shop() -> void:
	visible = false
	_show_sprite(null)
	Engine.time_scale = 1.0

func _show_sprite(target: Sprite2D) -> void:
	if s10: s10.visible = (target == s10)
	if s20: s20.visible = (target == s20)
	if s40: s40.visible = (target == s40)
	if bg:  bg.visible  = (target != null)

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close_shop()
