extends CanvasLayer
signal close_requested

@onready var close_btn: Button = %settingsCloseBtn
@onready var mute_check: CheckBox = %MuteCheck

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	if mute_check and not mute_check.toggled.is_connected(_on_mute_toggled):
		mute_check.toggled.connect(_on_mute_toggled)
		mute_check.button_pressed = AudioManager.muted

	if close_btn and not close_btn.pressed.is_connected(_on_close_pressed):
		close_btn.pressed.connect(_on_close_pressed)

func _on_mute_toggled(pressed: bool) -> void:
	AudioManager.set_muted(pressed)

func _on_close_pressed() -> void:
	visible = false
	close_requested.emit()

func _unhandled_input(event: InputEvent) -> void:
	if visible and (event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause")):
		_on_close_pressed()
		get_viewport().set_input_as_handled()
