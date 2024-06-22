extends "res://addons/gut/test.gd"

var TestDie = load("res://Scripts/dice/vanilla_d6.gd")

var _die = null

func before_each():
	_die = TestDie.new()
	_die.random = double(RandomNumberGenerator).new()

func after_each():
	_die.free()
	assert_no_new_orphans()

func roller(expected):
	var random_result = expected - 1
	stub(_die.random, "randi_range").to_return(random_result)
	var result = _die.roll()
	assert_eq(result, expected, "Expected roll {0} result when ´random.randi_range´ returns {1}".format(str(expected), str(random_result)))

func test_roll_1():
	roller(1)

func test_roll_2():
	roller(2)
	
func test_roll_3():
	roller(3)
	
func test_roll_4():
	roller(4)
	
func test_roll_5():
	roller(5)
	
func test_roll_6():
	roller(6)
	
func test_roll_between_1_and_6():
	_die.random = RandomNumberGenerator.new()
	var result = _die.roll()
	assert_between(result, 0, 6, "Expected roll to be between 1 and 6")
