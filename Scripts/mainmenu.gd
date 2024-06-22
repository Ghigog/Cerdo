extends Control

@onready var continue_button = $CanvasLayer/VBoxContainer/ContinueButton

# Called when the node enters the scene tree for the first time.
func _ready():
	var save_exists = Global.save_game_exists()
	if !save_exists:
		continue_button.disabled = true
	else:
		Global.load_variables(false)
		continue_button.disabled = !Global.is_game_in_progress


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
