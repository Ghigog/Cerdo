extends Control

@onready var current_score_label = $CanvasLayer/VBoxContainer/HBoxContainer2/CurrentScoreLabel
@onready var player_turn_h_box_container = $CanvasLayer/VBoxContainer/PlayerTurnHBoxContainer
@onready var dice_texture = $CanvasLayer/VBoxContainer/CenterContainer/DiceTexture

@onready var player_1_score_label = $CanvasLayer/VBoxContainer/HBoxContainer/Player1ScoreLabel
@onready var player_2_score_label = $CanvasLayer/VBoxContainer/HBoxContainer/Player2ScoreLabel

@onready var hold_button = $CanvasLayer/VBoxContainer/HBoxContainer2/HoldButton
@onready var roll_button = $CanvasLayer/VBoxContainer/RollButton

const COMBO_LABEL = preload("res://Scenes/combo_label.tscn")

@onready var timer = $Timer
@onready var delay_timer = $DelayTimer
@onready var one_timer = $OneTimer

var current_roll_history = []

## MUSIC
@onready var turn_music = $TurnMusic
@onready var main_tune = $MainTune
@onready var detail_music = $DetailMusic
@onready var bass = $Bass
@onready var bass_2 = $Bass2


## EFFECTS
@onready var hold_particles = $CanvasLayer/VBoxContainer/HBoxContainer2/HoldButton/Control/HoldParticles
@onready var one_particles = $CanvasLayer/VBoxContainer/CenterContainer/DiceTexture/Control/OneParticles


var music_stage: int
var _swap_turn_music
var toggle_turn_music
const CERDO_SONG_3 = preload("res://Assets/Audio/Music/CerdoSong3.wav")
const CERDO_SONG_4 = preload("res://Assets/Audio/Music/CerdoSong4.wav")
const CERDO_SONG_BELL_A = preload("res://Assets/Audio/Music/CerdoSongBellA.wav")
const CERDO_SONG_BELL_B = preload("res://Assets/Audio/Music/CerdoSongBellB.wav")
const CERDO_SONG_B_2 = preload("res://Assets/Audio/Music/CerdoSongB2.wav")
const CERDO_SONG_B_3 = preload("res://Assets/Audio/Music/CerdoSongB3.wav")

const BaseCpu = preload("res://Scripts/cpu/base_cpu.gd")
const RandomCpu = preload("res://Scripts/cpu/random_cpu.gd")
const StrategicCpu = preload("res://Scripts/cpu/strategic_cpu.gd")
const VanillaD6 = preload("res://Scripts/dice/vanilla_d6.gd")


var dice_value: int = 0
var current_score: int = 0

var random = RandomNumberGenerator.new()

var isShowingCombo: bool = false
var new_combo_label: Label

const cpu_personalities = [
	RandomCpu,
	StrategicCpu,
]

const dice = [
	VanillaD6
]

# Called when the node enters the scene tree for the first time.
func _ready():
	render_scores()
	refresh_turn_icon()
	random.randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if isShowingCombo and new_combo_label != null:
		new_combo_label.position.y -= delta * 50
		new_combo_label.label_settings.font_color.a -= delta 
		new_combo_label.label_settings.outline_color.a -= delta
		new_combo_label.label_settings.shadow_color.a -= delta

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/mainmenu.tscn")

func _on_roll_button_pressed():
	var dice_instance = dice[Global.player_dice[Global.turn]].new()
	dice_value = dice_instance.roll()
	dice_texture.texture = dice_instance.getAsset(dice_value)
	print(dice_value)
	current_roll_history.append(dice_value)
	print(current_roll_history)
	check_repetition()
	check_sequence()
	if dice_value == 1:
		one_timer.start()
		one_particles.emitting = true
		toggle_button_disabled(true)
	else:
		current_score += dice_value
		current_score_label.text = str(current_score)

func on_one_roll():
	current_roll_history.clear()
	_swap_players()
	one_particles.emitting = false

func _on_hold_button_pressed():
	toggle_button_disabled(true)
	current_roll_history.clear()
	Global.player_scores[Global.turn] += current_score
	check_music()
	render_scores()
	hold_particles.emitting = true
	delay_timer.start()

func hold_button_functionality():
	toggle_button_disabled(true)
	hold_particles.emitting = false
	Global.is_game_in_progress = true
	Global.save_game()
	refresh_turn_icon()
	if Global.player_scores[Global.turn] >= 100:
		Global.last_winner = Global.turn
		for score in len(Global.player_scores):
			Global.player_scores[score] = 0
		get_tree().change_scene_to_file("res://Scenes/end_screen.tscn")
	_swap_players()

func _swap_players():
	_swap_turn_music = true
	
	Global.turn = 1 if Global.turn == 0 else 0
	current_score = 0
	current_score_label.text = str(current_score)
	var cpu_turn = Global.is_game_against_cpu() and (Global.turn == 1)
	toggle_button_disabled(cpu_turn)
	refresh_turn_icon()
	if cpu_turn:
		cpu_play()

func render_scores():
	player_1_score_label.text = str(Global.player_scores[0])
	player_2_score_label.text = str(Global.player_scores[1])

func refresh_turn_icon():
	player_turn_h_box_container.alignment = (
		player_turn_h_box_container.ALIGNMENT_BEGIN
		if Global.turn == 0 else
		player_turn_h_box_container.ALIGNMENT_END
	)

func cpu_play():
	#print("cpu_play is being activated")
	#while decision != BaseCpu.DECISION.HOLD and Global.turn == 1:
	if Global.turn == 1:
		var cpu = cpu_personalities[Global.cpu_personality].new()
		var decision = cpu.decide(current_score)
		if decision == cpu.DECISION.HOLD:
			_on_hold_button_pressed()
		else:
			_on_roll_button_pressed()
			if Global.turn == 1:
				timer.start(2)

func toggle_button_disabled(state):
	hold_button.disabled = state
	roll_button.disabled = state

func show_combo(combo_value):
	if new_combo_label != null:
		new_combo_label.queue_free()
	new_combo_label = COMBO_LABEL.instantiate()
	add_child(new_combo_label, true)
	move_child(new_combo_label, -1)
	new_combo_label.text = "Combo + {0}".format([combo_value])
	new_combo_label.label_settings.font_color.a = 1
	new_combo_label.label_settings.outline_color.a = 1
	new_combo_label.label_settings.shadow_color.a = 0.5
	isShowingCombo = true
	var combo_timer = new_combo_label.get_child(0)
	combo_timer.timeout.connect(delete_combo_timer)

func delete_combo_timer():
	if isShowingCombo:
		new_combo_label.queue_free()
		isShowingCombo = false

func countDeltas(last_delta):
	var delta_count = 0
	for i in range(current_roll_history.size() - 1, 0, -1):
		if (current_roll_history[i] - current_roll_history[i - 1]) == last_delta:
			delta_count += 1
		else:
			break
	if last_delta != 0:
		delta_count -= 1
	return delta_count

func check_repetition():
	if current_roll_history.size() > 1:
		var last_number_played = current_roll_history[-1]
		var last_delta = current_roll_history[-1] - current_roll_history[-2]
		var combo_mod = 0
		if last_delta == 0:
			combo_mod = countDeltas(last_delta)
		elif current_roll_history.size() > 2:
			combo_mod = countDeltas(last_delta)
		if combo_mod > 0:
			show_combo(combo_mod)
			current_score += combo_mod
			current_score_label.text = str(current_score)
		print("last number played: ", last_number_played)
		print("last delta: ", last_delta)
		print("combo mod: ", combo_mod)
		
	pass

func check_sequence():
	pass

func _on_timer_timeout():
	cpu_play()

func check_music():
	if Global.player_scores[Global.turn] >= 15:
		music_stage = 1 
	if Global.player_scores[Global.turn] >= 20:
		music_stage = 2 
	if Global.player_scores[Global.turn] >= 30:
		music_stage = 3 
	if Global.player_scores[Global.turn] >= 75:
		music_stage = 4 

func _on_turn_music_finished():
	if _swap_turn_music:
		if toggle_turn_music:
			turn_music.stream = CERDO_SONG_BELL_A
			# assuming that effect 0 on bus 1 is AudioEffectPanner
			var effect = AudioServer.get_bus_effect(2, 0)
			effect.pan = 0.5
		else:
			turn_music.stream = CERDO_SONG_BELL_B
			var effect = AudioServer.get_bus_effect(2, 0)
			effect.pan = -0.5
		#print(turn_music.stream)
		toggle_turn_music = !toggle_turn_music
	turn_music.play()
	_swap_turn_music = false

func _on_main_tune_finished():
	turn_music.play()
	match music_stage:
		1:
			detail_music.play()
			music_stage = 0
		
		2:
			detail_music.stream = CERDO_SONG_B_2
			detail_music.play()
			bass.play()
			music_stage = 0
		3:
			detail_music.stream = CERDO_SONG_B_3
			detail_music.play()
			main_tune.stream = CERDO_SONG_3
			bass.play()
			bass_2.play()
		4:
			detail_music.stop()
			main_tune.stream = CERDO_SONG_4
	main_tune.play()
