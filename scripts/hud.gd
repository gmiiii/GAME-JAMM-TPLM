extends CanvasLayer

# Skor live (kiri-atas, dengan stroke) + presentasi kalah:
# kedua sebab kalah (ayam / mobil) memakai animasi koran berputar; mobil pakai
# koran placeholder (newspaper_car.png) + camera shake & bunyi tabrakan.
# Setelah presentasi: tombol play (bawah-tengah) ATAU R/klik -> main lagi.

const FONT := preload("res://assets/fonts/8bit_wonder.ttf")
const NewspaperPopup := preload("res://scripts/newspaper_popup.gd")
const NEWS_CHICKEN := preload("res://assets/ui/newspaper.png")
const NEWS_CAR := preload("res://assets/ui/newspaper_car.png")
const BTN_PLAY := preload("res://assets/ui/btn_play.png")
const BTN_HOME := preload("res://assets/ui/btn_home.png")
const TITLE_SCENE := "res://scenes/title.tscn"

var _score_label: Label
var _play_btn: TextureButton
var _home_btn: TextureButton
var _koran                                  # instance NewspaperPopup (akses dinamis)
var _can_restart: bool = false
var _beat_record: bool = false


func _ready() -> void:
	_score_label = Label.new()
	_score_label.position = Vector2(18, 14)
	_score_label.add_theme_font_override("font", FONT)
	_score_label.add_theme_font_size_override("font_size", 22)
	UiText.outline(_score_label, 6)
	add_child(_score_label)
	_build_buttons()
	GameState.game_over_changed.connect(_on_game_over)
	GameState.escalation_changed.connect(_on_escalation)


func _process(_delta: float) -> void:
	if not GameState.is_game_over:
		_score_label.text = "JARAK %d M\nSKOR %d\nTERBAIK %d" % [
			int(GameState.distance), GameState.score(), GameState.high_score]
		# Denyut sekali saat memecahkan rekor lama.
		if not _beat_record and GameState.high_score > 0 and GameState.score() > GameState.high_score:
			_beat_record = true
			_pulse_score()


func _build_buttons() -> void:
	# Play (main lagi) + Home (ke menu judul). Posisi diatur saat presentasi
	# selesai supaya pas di batas bawah koran.
	_play_btn = UiText.texture_button(BTN_PLAY, 150.0)
	_play_btn.visible = false
	_play_btn.pressed.connect(_restart)
	add_child(_play_btn)

	_home_btn = UiText.texture_button(BTN_HOME, 150.0)
	_home_btn.visible = false
	_home_btn.pressed.connect(_go_home)
	add_child(_home_btn)


func _on_escalation(_step: int) -> void:
	Audio.play_sfx(Audio.SFX_ESCALATION)
	_pulse_score()


func _pulse_score() -> void:
	_score_label.pivot_offset = _score_label.size * 0.5
	var tw := _score_label.create_tween()
	tw.tween_property(_score_label, "scale", Vector2(1.2, 1.2), 0.1).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(_score_label, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK)


func _on_game_over(is_over: bool) -> void:
	if not is_over:
		return
	Audio.stop_music()                      # matikan musik gameplay saat game over
	if GameState.death_cause == "car":
		Audio.play_sfx(Audio.SFX_CRASH)
		var cam := get_tree().get_first_node_in_group("camera")
		if cam != null and cam.has_method("shake"):
			cam.shake(0.06, 0.4)
	Audio.play_sfx(Audio.SFX_GAME_OVER)

	_koran = NewspaperPopup.new()
	_koran.tex = NEWS_CAR if GameState.death_cause == "car" else NEWS_CHICKEN
	add_child(_koran)
	_koran.finished.connect(_on_present_done)
	_koran.play()


func _on_present_done() -> void:
	_can_restart = true
	# Pasangan tombol diletakkan center pada batas bawah koran (separuh menjorok
	# ke bawah koran), dengan grup terpusat horizontal.
	var vp := get_viewport().get_visible_rect().size
	var cy: float = _koran.paper_bottom() if _koran != null else vp.y - 40.0
	var gap := 30.0
	var total := _home_btn.size.x + gap + _play_btn.size.x
	var start_x := (vp.x - total) * 0.5
	# Home di kiri, Play di kanan.
	_home_btn.position = Vector2(start_x, cy - _home_btn.size.y * 0.5)
	_play_btn.position = Vector2(start_x + _home_btn.size.x + gap, cy - _play_btn.size.y * 0.5)

	for b: TextureButton in [_play_btn, _home_btn]:
		b.visible = true
		move_child(b, get_child_count() - 1)
		b.scale = Vector2.ZERO
		var tw: Tween = b.create_tween()
		tw.tween_property(b, "scale", Vector2.ONE, 0.3) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _restart() -> void:
	if not _can_restart:
		return
	Transition.reload()


func _go_home() -> void:
	if not _can_restart:
		return
	Transition.change_scene_to(TITLE_SCENE)


func _unhandled_input(event: InputEvent) -> void:
	# Main lagi: tombol R / klik kiri di mana saja (tombol play menangani klik
	# di atasnya sendiri). Berlaku untuk kalah ayam maupun mobil.
	if not GameState.is_game_over or not _can_restart:
		return
	var clicked: bool = event is InputEventMouseButton and event.pressed \
		and event.button_index == MOUSE_BUTTON_LEFT
	if clicked or event.is_action_pressed("restart"):
		_restart()
