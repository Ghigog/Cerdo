extends Control

@onready var current_score_label = $CanvasLayer/VBoxContainer/HBoxContainer2/CurrentScoreLabel
@onready var player_turn_h_box_container = $CanvasLayer/VBoxContainer/PlayerTurnHBoxContainer
@onready var dice_texture = $CanvasLayer/VBoxContainer/CenterContainer/DiceTexture

@onready var player_1_score_label = $CanvasLayer/VBoxContainer/HBoxContainer/Player1ScoreLabel
@onready var player_2_score_label = $CanvasLayer/VBoxContainer/HBoxContainer/Player2ScoreLabel

@onready var hold_button = $CanvasLayer/VBoxContainer/HBoxContainer2/HoldButton
@onready var roll_button = $CanvasLayer/VBoxContainer/RollButton

@onready var timer = $CanvasLayer/Timer

## MUSIC
@onready var turn_music = $TurnMusic
@onready var main_tune = $MainTune
@onready var detail_music = $DetailMusic
@onready var bass = $Bass
@onready var bass_2 = $Bass2

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

var dice_value: int = 0
var current_score: int = 0

var random = RandomNumberGenerator.new()


const cpu_personalities = [
	RandomCpu
]

# Called when the node enters the scene tree for the first time.
func _ready():
	refresh_score()
	refresh_turn()
	random.randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/app.tscn")

func _on_roll_button_pressed():
	dice_value = random.randi_range(1, 6)
	var folder = "res://Assets/DiceImages/"
	var filename = "dice" + str(dice_value) + ".svg"
	dice_texture.texture = load(folder + filename)
	#print(dice_value)
	if dice_value == 1:
		_swap_players()
	else:
		current_score += dice_value
		current_score_label.text = str(current_score)

func _on_hold_button_pressed():
	Global.player_scores[Global.turn] += current_score
	check_music()
	refresh_score()
	if Global.player_scores[Global.turn] >= 100:
		Global.last_winner = Global.turn
		for score in len(Global.player_scores):
			Global.player_scores[score] = 0
		get_tree().change_scene_to_file("res://Scenes/end_screen.tscn")
	_swap_players()
	Global.save_game()

func _swap_players():
	_swap_turn_music = true
	
	Global.turn = 1 if Global.turn == 0 else 0
	current_score = 0
	current_score_label.text = str(current_score)
	var cpu_turn = (Global.second_player == 1) and (Global.turn == 1)
	#print("cpu_turn = ", cpu_turn)
	roll_button.disabled = cpu_turn
	hold_button.disabled = cpu_turn
	refresh_turn()
	if cpu_turn:
		#print("cpu_turn")
		cpu_play()

func refresh_score():
	player_1_score_label.text = str(Global.player_scores[0])
	player_2_score_label.text = str(Global.player_scores[1])
	refresh_turn()

func refresh_turn():
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
		var decision = cpu.decide()
		#print("Lets roll" if decision == cpu.DECISION.ROLL else "I will hold")
		if decision == cpu.DECISION.HOLD:
			_on_hold_button_pressed()
		else:
			_on_roll_button_pressed()
			if Global.turn == 1:
				timer.start(2)
		#decision = cpu.decide()
		

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
