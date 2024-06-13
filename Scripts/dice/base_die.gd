class_name Die
extends Node

var sides = []
var random = RandomNumberGenerator.new()

func preHook():
	pass
	
func getAsset(die_value):
	var folder = "res://Assets/DiceImages/"
	var filename = "dice" + str(die_value) + ".svg"
	return load(folder + filename)

func roll():
	var position = random.randi_range(0, len(sides) - 1)
	var result = sides[position]
	return result

func postHook():
	pass
