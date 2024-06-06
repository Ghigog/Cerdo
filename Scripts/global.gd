extends Node

var player_scores = [
	0,
	0,
]
# Can either be 0 (for player one) or 1 (for player two)
var turn: int = 0

func quit_game():
	get_tree().quit()
