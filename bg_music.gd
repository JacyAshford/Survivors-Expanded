extends AudioStreamPlayer2D

func _ready() -> void:
	AudioManager.register(self)
