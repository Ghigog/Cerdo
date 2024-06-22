extends Control

@onready var option_button = $CanvasLayer/VBoxContainer/HBoxContainer/OptionButton

@onready var cpu_button = $CanvasLayer/VBoxContainer/HBoxContainer2/CPUButton



# Called when the node enters the scene tree for the first time.
func _ready():
	cpu_button.disabled = option_button.selected == 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_option_button_item_selected(index):
	Global.second_player = index
	cpu_button.disabled = option_button.selected == 0

func _on_cpu_button_item_selected(index):
	Global.cpu_personality = index
	
	


func _on_play_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/game.tscn")


func _on_quit_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/mainmenu.tscn")
