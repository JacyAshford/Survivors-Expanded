extends Node

var muted: bool = false

var all_players: Array[Node] = []

func register(player: Node) -> void:
	if player == null: 
		return
	if not _is_audio(player): 
		return
	if not all_players.has(player):
		all_players.append(player)
	_apply(player)

func unregister(player: Node) -> void:
	all_players.erase(player)

func set_muted(state: bool) -> void:
	muted = state
	for p in all_players:
		if is_instance_valid(p):
			_apply(p)

func apply_current_to(player: Node) -> void:
	if _is_audio(player):
		_apply(player)

func _apply(p: Node) -> void:
	p.volume_db = -80.0 if muted else 0.0

func _is_audio(p: Node) -> bool:
	return p is AudioStreamPlayer \
		or p is AudioStreamPlayer2D \
		or p is AudioStreamPlayer3D
