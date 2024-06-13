extends Control

@onready var current_score_label = $CanvasLayer/VBoxContainer/HBoxContainer2/CurrentScoreLabel
@onready var player_turn_h_box_container = $CanvasLayer/VBoxContainer/PlayerTurnHBoxContainer
@onready var dice_texture = $CanvasLayer/VBoxContainer/CenterContainer/DiceTexture

@onready var player_1_score_label = $CanvasLayer/VBoxContainer/HBoxContainer/Player1ScoreLabel
@onready var player_2_score_label = $CanvasLayer/VBoxContainer/HBoxContainer/Player2ScoreLabel

@onready var hold_button = $CanvasLayer/VBoxContainer/HBoxContainer2/HoldButton
@onready var roll_button = $CanvasLayer/VBoxContainer/RollButton

@onready var timer = $CanvasLayer/Timer

@onready var turn_music = $TurnMusic
const CERDO_SONG_BELL_A = preload("res://Assets/Audio/Music/CerdoSongBellA.wav")
const CERDO_SONG_BELL_B = preload("res://Assets/Audio/Music/CerdoSongBellB.wav")


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
	print(dice_value)
	if dice_value == 1:
		_swap_players()
	else:
		current_score += dice_value
		current_score_label.text = str(current_score)

func _on_hold_button_pressed():
	check_music()
	print("cpu holding")
	Global.player_scores[Global.turn] += current_score
	refresh_score()
	if Global.player_scores[Global.turn] >= 100:
		Global.last_winner = Global.turn
		for score in len(Global.player_scores):
			Global.player_scores[score] = 0
		get_tree().change_scene_to_file("res://Scenes/end_screen.tscn")
	_swap_players()
	Global.save_game()

func _swap_players():
	turn_music.stream = CERDO_SONG_BELL_A
	turn_music.play()
	Global.turn = 1 if Global.turn == 0 else 0
	current_score = 0
	current_score_label.text = str(current_score)
	var cpu_turn = (Global.second_player == 1) and (Global.turn == 1)
	print("cpu_turn = ", cpu_turn)
	roll_button.disabled = cpu_turn
	hold_button.disabled = cpu_turn
	refresh_turn()
	if cpu_turn:
		turn_music.stream = CERDO_SONG_BELL_B
		turn_music.play()
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
	print("cpu_play is being activated")
	#while decision != BaseCpu.DECISION.HOLD and Global.turn == 1:
	if Global.turn == 1:
		var cpu = cpu_personalities[Global.cpu_personality].new()
		var decision = cpu.decide()
		print("Lets roll" if decision == cpu.DECISION.ROLL else "I will hold")
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
	if Global.player_scores[Global.turn] >= 20:
		set_music(1)

func set_music(stage):
	if stage == 1:
		pass
	pass
