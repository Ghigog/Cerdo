extends Node

const SAVE_PATH = "user://cerdogame.save"
const PASSWORD = "Pig"
var player_scores = [
	0,
	0,
]
# Can either be 0 (for player one) or 1 (for player two)
var turn: int = 0

var is_game_in_progress = false

#Variables for IA
var second_player = 0
var cpu_personality = 0
var player_dice = [0, 0]

func quit_game():
	get_tree().quit()

var last_winner : int = 0


func new_save():
	return {
		"PlayerScores" : [
			0,
			0
		],
		"Turn" : 0,
		"Dice" : [
			0, 
			0
		],
		"IsGameInProgress": false
	}

func generate_save_dict():
	return {
		"PlayerScores" : player_scores,
		"Turn" : turn,
		"Dice" : player_dice,
		"IsGameInProgress": is_game_in_progress,
	}

func save_game():
	var new_save_game = FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.WRITE, PASSWORD)
	var json_string = JSON.stringify(generate_save_dict())
	new_save_game.store_line(json_string)
	new_save_game.close()
	print("saved: ", json_string)


func save_game_exists():
	return FileAccess.file_exists(SAVE_PATH)


func load_game():
	if !save_game_exists():
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
		

func load_variables(new_game):
	var loaded_vars
	if !new_game:
		loaded_vars = load_game()
	else:
		loaded_vars = new_save()
	player_scores = loaded_vars["PlayerScores"]
	var is_both_scores_0 = player_scores[0] == 0 and player_scores[1] == 0
	turn = 0 if is_both_scores_0 else loaded_vars["Turn"]
	var default_values = new_save()
	player_dice = loaded_vars.get("Dice", default_values["Dice"])
	is_game_in_progress = loaded_vars.get("IsGameInProgress", default_values["IsGameInProgress"])
