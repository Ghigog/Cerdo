extends Control

@onready var continue_button = $CanvasLayer/VBoxContainer/ContinueButton
@onready var score_against_cpu = $CanvasLayer/VBoxContainer/ScoreAgainstCpu

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.load_progress_variables()
	_update_score_against_cpu_text()
	var save_exists = Global.save_file_exists()
	if !save_exists:
		continue_button.disabled = true
	else:
		Global.load_variables(false)
		continue_button.disabled = !Global.is_game_in_progress

func _update_score_against_cpu_text():
	var base_text = "You have {0} wins and {1} losses against CPU!"
	score_against_cpu.text = base_text.format([Global.wins_against_cpu, Global.losses_against_cpu])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_quit_button_pressed():
	Global.quit_game()


func _on_continue_button_pressed():
	Global.load_variables(false)
	get_tree().change_scene_to_file("res://Scenes/game.tscn")


func _on_play_button_pressed():
	Global.load_variables(true)
	get_tree().change_scene_to_file("res://Scenes/gamesetup.tscn")
