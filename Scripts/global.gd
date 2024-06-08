extends Node

const SAVE_PATH = "user://cerdogame.save"
const PASSWORD = "Pig"
var player_scores = [
	0,
	0,
]
# Can either be 0 (for player one) or 1 (for player two)
var turn: int = 0

#Variables for IA
var second_player = 0
var cpu_personality = 0

func quit_game():
	get_tree().quit()

var last_winner : int = 0


func new_save():
	return {
		"PlayerScores" : [
			0,
			0
		],
		"Turn" : 0
	}

func generate_save_dict():
	return {
		"PlayerScores" : player_scores,
		"Turn" : turn
	}

func save_game():
	var new_save_game = FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.WRITE, PASSWORD)
	var json_string = JSON.stringify(generate_save_dict())
	new_save_game.store_line(json_string)
	new_save_game.close()
	print("saved: ", json_string)


func load_game():
	if !FileAccess.file_exists(SAVE_PATH):
		return new_save()
	else:
		var saveFile = FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.READ, PASSWORD)
		var saveData = saveFile.get_as_text()
		saveFile.close()
		var jsonParser = JSON.new()
		var error = jsonParser.parse(saveData)
		if error == OK:
			return jsonParser.data
		else:
			print("JSON Parse Error: ", jsonParser.get_error_message(), " in ", saveData, " at line ", jsonParser.get_error_line())
		

func load_variables():
	var loaded_vars = load_game()
	player_scores = loaded_vars["PlayerScores"]
	turn = loaded_vars["Turn"]
