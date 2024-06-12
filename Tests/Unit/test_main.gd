extends "res://addons/gut/test.gd"

var Main = load("res://Scripts/main.gd")

var _main = null
const HBOX_ALIGNMENTS =  [
  "ALIGNMENT_BEGIN", "ALIGNMENT_CENTER", "ALIGNMENT_END"
]

func before_each():
	_main = Main.new()

func after_each():
	_main.free()
	
func after_all():
	Global.free()
	assert_no_new_orphans()

func before_each_refresh_turn():
	_main.player_turn_h_box_container = double(HBoxContainer).new()

func refresh_turn_from_to(alignment_from, turn, expected_alignment):
	Global.turn = turn
	_main.player_turn_h_box_container.alignment = alignment_from
	_main.refresh_turn()
	assert_eq(_main.player_turn_h_box_container.alignment, expected_alignment,
	 "Expected to be " + HBOX_ALIGNMENTS[expected_alignment])

func test_refresh_turn_0_from_0():
	before_each_refresh_turn()
	refresh_turn_from_to( _main.player_turn_h_box_container.ALIGNMENT_BEGIN, 
	0, _main.player_turn_h_box_container.ALIGNMENT_BEGIN )
	
func test_refresh_turn_0_from_1():
	before_each_refresh_turn()
	refresh_turn_from_to( _main.player_turn_h_box_container.ALIGNMENT_END, 
	0, _main.player_turn_h_box_container.ALIGNMENT_BEGIN )
	
func test_refresh_turn_1_from_0():
	before_each_refresh_turn()
	refresh_turn_from_to( _main.player_turn_h_box_container.ALIGNMENT_BEGIN, 
	1, _main.player_turn_h_box_container.ALIGNMENT_END )
	
func test_refresh_turn_1_from_1():
	before_each_refresh_turn()
	refresh_turn_from_to( _main.player_turn_h_box_container.ALIGNMENT_END, 
	1, _main.player_turn_h_box_container.ALIGNMENT_END )
