extends Node

# ============================================================
# Manajer audio global. Dua bus dibuat lewat kode: "Music" & "SFX".
# Toggle hanya mematikan bus Music (SFX, termasuk engine, tetap bunyi).
# Setelan on/off disimpan ke user://settings.cfg.
# ============================================================

const MUSIC_MENU := preload("res://assets/audio/music/menu.wav")
const MUSIC_INGAME := preload("res://assets/audio/music/ingame.wav")

const SFX_ENGINE := preload("res://assets/audio/sfx/engine_idle.wav")
const SFX_ACCEL := preload("res://assets/audio/sfx/accel.wav")
const SFX_TIRE := preload("res://assets/audio/sfx/tire_screech.wav")
const SFX_WHOOSH := preload("res://assets/audio/sfx/whoosh.wav")
const SFX_CLUCK := [
	preload("res://assets/audio/sfx/chicken_cluck_1.wav"),
	preload("res://assets/audio/sfx/chicken_cluck_2.wav"),
	preload("res://assets/audio/sfx/chicken_cluck_3.wav"),
]
const SFX_HURT := [
	preload("res://assets/audio/sfx/chicken_hurt_1.wav"),
	preload("res://assets/audio/sfx/chicken_hurt_2.wav"),
]
const SFX_CHICKEN_SPAWN := preload("res://assets/audio/sfx/chicken_spawn.wav")
const SFX_ESCALATION := preload("res://assets/audio/sfx/escalation.wav")
const SFX_CRASH := preload("res://assets/audio/sfx/crash.wav")
const SFX_GAME_OVER := preload("res://assets/audio/sfx/game_over.wav")
const SFX_NEWSPAPER := preload("res://assets/audio/sfx/newspaper.wav")
const SFX_CLICK := preload("res://assets/audio/sfx/click.wav")

const SFX_POOL_SIZE := 10
const SETTINGS_PATH := "user://settings.cfg"
const SFX_BUS_DB := -8.0           # SFX dikecilkan agar musik tetap terdengar
const MUSIC_BUS_DB := 0.0

var _music: AudioStreamPlayer
var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_idx: int = 0
var _music_on: bool = true
var _music_bus: int = 0
var _sfx_bus: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS    # tetap bunyi saat game di-pause
	_setup_buses()
	_setup_players()
	_load_settings()
	AudioServer.set_bus_mute(_music_bus, not _music_on)


func _setup_buses() -> void:
	_music_bus = _ensure_bus("Music")
	_sfx_bus = _ensure_bus("SFX")
	AudioServer.set_bus_volume_db(_music_bus, MUSIC_BUS_DB)
	AudioServer.set_bus_volume_db(_sfx_bus, SFX_BUS_DB)


func _ensure_bus(bus_name: String) -> int:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx != -1:
		return idx
	idx = AudioServer.bus_count
	AudioServer.add_bus(idx)
	AudioServer.set_bus_name(idx, bus_name)
	AudioServer.set_bus_send(idx, "Master")
	return idx


func _setup_players() -> void:
	_music = AudioStreamPlayer.new()
	_music.bus = "Music"
	add_child(_music)
	for i in SFX_POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_sfx_pool.append(p)


# Ganti & mainkan musik latar (di-loop). Tidak restart bila trek sama sudah jalan.
func play_music(stream: AudioStream) -> void:
	if stream == null:
		return
	if _music.stream == stream and _music.playing:
		return
	if stream is AudioStreamWAV:
		var w := stream as AudioStreamWAV
		# loop_end default 0 + LOOP_FORWARD = loop nol-panjang di posisi 0 (senyap).
		# Set rentang loop ke seluruh sampel (dalam frame).
		w.loop_begin = 0
		w.loop_end = int(w.get_length() * w.mix_rate)
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
	_music.stream = stream
	_music.play()


# Mainkan SFX one-shot lewat pool (cari player bebas, fallback round-robin).
func play_sfx(stream: AudioStream, pitch: float = 1.0, volume_db: float = 0.0) -> void:
	if stream == null:
		return
	var p: AudioStreamPlayer = null
	for cand in _sfx_pool:
		if not cand.playing:
			p = cand
			break
	if p == null:
		p = _sfx_pool[_sfx_idx]
		_sfx_idx = (_sfx_idx + 1) % _sfx_pool.size()
	p.stream = stream
	p.pitch_scale = pitch
	p.volume_db = volume_db
	p.play()


# Hentikan semua SFX (mis. sting game-over) saat pindah/ulang layar.
func stop_sfx() -> void:
	for p in _sfx_pool:
		p.stop()


func stop_music() -> void:
	_music.stop()


func is_music_on() -> bool:
	return _music_on


func toggle_music() -> void:
	set_music_enabled(not _music_on)


func set_music_enabled(on: bool) -> void:
	_music_on = on
	AudioServer.set_bus_mute(_music_bus, not on)
	_save_settings()


func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) == OK:
		_music_on = bool(cfg.get_value("audio", "music_on", true))


func _save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.load(SETTINGS_PATH)
	cfg.set_value("audio", "music_on", _music_on)
	cfg.save(SETTINGS_PATH)
