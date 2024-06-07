extends Control

const WINNER_MESSAGES = [
	"Congratulations Player 1, you are the best player ever!",
	"Player 2 you surely cheated, there is no way you just won!"
]

@onready var message = $CanvasLayer/VBoxContainer/Message

# Called when the node enters the scene tree for the first time.
func _ready():
	message.text = WINNER_MESSAGES[Global.last_winner]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/app.tscn")
