extends Node

var _music_player: AudioStreamPlayer
var _sfx_player: AudioStreamPlayer

const SFX = {
	"flip": "res://assets/audio/sfx/card_flip.ogg",
	"match": "res://assets/audio/sfx/match.ogg",
	"mismatch": "res://assets/audio/sfx/mismatch.ogg",
	"victory": "res://assets/audio/sfx/victory.ogg",
	"unlock": "res://assets/audio/sfx/unlock.ogg",
	"hint": "res://assets/audio/sfx/hint.ogg",
	"button": "res://assets/audio/sfx/button_click.ogg"
}

func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	add_child(_music_player)

	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.bus = "SFX"
	add_child(_sfx_player)

	_apply_saved_volumes()

func play_music(track_path: String, fade_in: bool = true) -> void:
	if _music_player.stream and _music_player.playing:
		if fade_in:
			var tween = create_tween()
			tween.tween_property(_music_player, "volume_db", -80.0, 0.5)
			await tween.finished
	if ResourceLoader.exists(track_path):
		_music_player.stream = load(track_path)
		_music_player.volume_db = -80.0 if fade_in else linear_to_db(SaveSystem.get_setting("music_volume"))
		_music_player.play()
		if fade_in:
			var tween = create_tween()
			tween.tween_property(_music_player, "volume_db", linear_to_db(SaveSystem.get_setting("music_volume")), 0.5)

func stop_music() -> void:
	_music_player.stop()

func play_sfx(sfx_key: String) -> void:
	var path = SFX.get(sfx_key, "")
	if path == "" or not ResourceLoader.exists(path):
		return
	_sfx_player.stream = load(path)
	_sfx_player.volume_db = linear_to_db(SaveSystem.get_setting("sfx_volume"))
	_sfx_player.play()

func set_music_volume(linear: float) -> void:
	SaveSystem.set_setting("music_volume", linear)
	_music_player.volume_db = linear_to_db(linear)

func set_sfx_volume(linear: float) -> void:
	SaveSystem.set_setting("sfx_volume", linear)

func set_master_volume(linear: float) -> void:
	SaveSystem.set_setting("master_volume", linear)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(linear))

func _apply_saved_volumes() -> void:
	var master = SaveSystem.get_setting("master_volume")
	if master != null:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master))
