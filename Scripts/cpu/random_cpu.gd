class_name randomCPU
extends CPU

var random = RandomNumberGenerator.new()

func decide():
	var decision = random.randi_range(0, 1)
	print("deciding to roll" if decision == 0 else "deciding to hold")
	return DECISION.ROLL if decision == 0 else DECISION.HOLD


