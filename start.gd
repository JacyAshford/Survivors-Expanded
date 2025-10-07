extends CanvasLayer
signal start_requested
signal settings_requested
signal settings_closed

var game_started := false
var pause_enabled := false
var settings_open := false

@onready var settings_btn: Button = %settings_btn

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = true
	if settings_btn and not settings_btn.pressed.is_connected(_on_settings_pressed):
		settings_btn.pressed.connect(_on_settings_pressed)

func _on_settings_pressed() -> void:
	settings_open = true
	settings_requested.emit()

func _unhandled_input(event: InputEvent) -> void:
	if settings_open:
		if event.is_action_pressed("ui_cancel"):
			settings_open = false
			settings_closed.emit()
			get_viewport().set_input_as_handled()
		return

	if not game_started and event.is_action_pressed("pause"):
		game_started = true
		start_requested.emit()
		pause_enabled = false
		get_viewport().set_input_as_handled()
		return

	if not pause_enabled and event.is_action_released("pause"):
		pause_enabled = true
		get_viewport().set_input_as_handled()
		
func on_settings_opened() -> void:
	settings_open = true

func on_settings_closed() -> void:
	settings_open = false
