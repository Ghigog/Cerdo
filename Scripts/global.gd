extends Node

const SAVE_PATH = "user://cerdogame.save"
const PROGRESS_PATH = "user://cerdogame_progress.save"
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

var wins_against_cpu = 0
var losses_against_cpu = 0

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
	
func new_progress():
	return {
		"PlayerVsCpuScores": {
			"Wins": 0,
			"Losses": 0
		}
	}

func generate_save_dict():
	return {
		"PlayerScores" : player_scores,
		"Turn" : turn,
		"Dice" : player_dice,
		"IsGameInProgress": is_game_in_progress,
	}
	
func generate_progress_dict():
	return {
		"PlayerVsCpuScores": {
			"Wins": wins_against_cpu,
			"Losses": losses_against_cpu
		}
	}


func is_game_against_cpu():
	return second_player == 1


func register_winner():
	if !is_game_against_cpu(): return
	
	if last_winner == 0: # Player won
		wins_against_cpu += 1
	elif last_winner == 1: # Cpu won
		losses_against_cpu += 1
	
	save_game(PROGRESS_PATH)


func save_game(save_path = SAVE_PATH):
	var new_save_game = FileAccess.open_encrypted_with_pass(save_path, FileAccess.WRITE, PASSWORD)
	var json_string
	if save_path == SAVE_PATH:
		json_string = JSON.stringify(generate_save_dict())
	elif save_path == PROGRESS_PATH:
		json_string = JSON.stringify(generate_progress_dict())
	new_save_game.store_line(json_string)
	new_save_game.close()
	print("saved at {0}: {1}".format([save_path, json_string]))


func save_file_exists(save_path = SAVE_PATH):
	return FileAccess.file_exists(save_path)


func load_game(save_path = SAVE_PATH):
	if !save_file_exists(save_path):
		if save_path == SAVE_PATH:
			return new_save()
		if save_path == PROGRESS_PATH:
			return new_progress()
	else:
		var saveFile = FileAccess.open_encrypted_with_pass(save_path, FileAccess.READ, PASSWORD)
		var saveData = saveFile.get_as_text()
		saveFile.close()
		var jsonParser = JSON.new()
		var error = jsonParser.parse(saveData)
		if error == OK:
			return jsonParser.data
		else:
			print("JSON Parse Error: ", jsonParser.get_error_message(), " in ", saveData, " at line ", jsonParser.get_error_line())


func load_progress_variables():
	var loaded_progress_vars = load_game(PROGRESS_PATH)
	var default_progress_values = new_progress() # For new versions of save files
	var player_vs_cpu_scores = loaded_progress_vars.get("PlayerVsCpuScores", default_progress_values["PlayerVsCpuScores"])
	wins_against_cpu = player_vs_cpu_scores.get("Wins", 0)
	losses_against_cpu = player_vs_cpu_scores.get("Losses", 0)

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
	load_progress_variables()
