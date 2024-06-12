extends "res://addons/gut/test.gd"

var StrategicCPU = load("res://Scripts/cpu/strategic_cpu.gd")

var _strategic_cpu = null

func before_each():
	_strategic_cpu = StrategicCPU.new()

func after_each():
	_strategic_cpu.free()
	assert_no_new_orphans()

func test_decide_roll():
	var decision = _strategic_cpu.decide(5)
	assert_eq(decision, StrategicCPU.DECISION.ROLL, "Expected Strategic CPU to decide to roll when points are lower than 13")

func test_decide_hold():
	var decision = _strategic_cpu.decide(13)
	assert_eq(decision, StrategicCPU.DECISION.HOLD, "Expected Strategic CPU to decide to hold when points are higher or equal than 13")
