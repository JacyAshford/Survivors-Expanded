extends CanvasLayer

@onready var bg: ColorRect   = %shopBG
@onready var s10: Sprite2D   = %L10Shop
@onready var s20: Sprite2D   = %L20Shop
@onready var s40: Sprite2D   = %L40Shop
@onready var close_btn: Button = get_node_or_null("%shopCloseBtn")

func _ready() -> void:
	visible = false
	_show_sprite(null) # hide all at start
	if close_btn:
		close_btn.pressed.connect(close_shop)

func show_for_level(level: int, pause_game: bool = true) -> void:
	# pick the highest tier the player qualifies for at this level
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
	visible = true
	if pause_game:
		Engine.time_scale = 0.0  # matches your pauseMenu approach

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
	# allow closing with Esc as well
	if visible and event.is_action_pressed("ui_cancel"):
		close_shop()
