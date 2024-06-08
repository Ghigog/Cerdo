extends "res://addons/gut/test.gd"

var RandomCPU = load("res://Scripts/cpu/random_cpu.gd")

var _random_cpu = null

func before_each():
	_random_cpu = RandomCPU.new()
	_random_cpu.random = double(RandomNumberGenerator).new()

func after_each():
	_random_cpu.free()

func test_decide_roll():
	stub(_random_cpu.random, "randi_range").to_return(0)
	var decision = _random_cpu.decide()
	assert_eq(decision, RandomCPU.DECISION.ROLL, "Expected Random CPU to decide to roll when ´random.randi_range´ returns 0")

func test_decide_hold():
	stub(_random_cpu.random, "randi_range").to_return(1)
	var decision = _random_cpu.decide()
	assert_eq(decision, RandomCPU.DECISION.HOLD, "Expected Random CPU to decide to hold when ´random.randi_range´ returns 1")
