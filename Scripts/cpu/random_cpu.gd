extends CPU

var random = RandomNumberGenerator.new()

func decide():
	var decision = random.randi_range(0, 1)
	return DECISION.ROLL if decision == 0 else DECISION.HOLD

