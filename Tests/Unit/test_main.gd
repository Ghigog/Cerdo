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

func test_render_scores_player1():
	Global.player_scores = [7,8]
	_main.player_1_score_label = double(Label).new()
	_main.player_2_score_label = double(Label).new()
	_main.player_1_score_label.text = "randomtext"
	_main.render_scores();
	assert_eq(_main.player_1_score_label.text, str(Global.player_scores[0]), "Expected player 1 score to be: " + str(Global.player_scores[0]))

func test_render_scores_player2():
	Global.player_scores = [7,8]
	_main.player_1_score_label = double(Label).new()
	_main.player_2_score_label = double(Label).new()
	_main.player_2_score_label.text = "randomtext2"
	_main.render_scores();
	assert_eq(_main.player_2_score_label.text, str(Global.player_scores[1]), "Expected player 2 score to be: " + str(Global.player_scores[1]))

func before_each_ready():
	_main.free()
	_main = partial_double(Main).new()
	stub(_main, "render_scores").to_do_nothing()
	stub(_main, "refresh_turn").to_do_nothing()

func test_ready__spy__render_scores():
	before_each_ready()
	_main._ready()
	assert_called(_main, "render_scores")
	assert_call_count(_main, "render_scores", 1)

func test_ready__spy__refresh_turn():
	before_each_ready()
	_main._ready()
	assert_called(_main, "refresh_turn")
	assert_call_count(_main, "refresh_turn", 1)
