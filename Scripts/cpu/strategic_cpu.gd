class_name StrategicCPU
extends CPU

var random = RandomNumberGenerator.new()

func decide(current_score: int):
	return DECISION.ROLL if current_score < 13 else DECISION.HOLD
