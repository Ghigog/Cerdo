extends Control

@onready var continue_button = $CanvasLayer/VBoxContainer/ContinueButton

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.load_variables()
	continue_button.visible = Global.is_game_active


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_quit_button_pressed():
	Global.quit_game()


func _on_instructions_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/instructions.tscn")


func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/options.tscn")
