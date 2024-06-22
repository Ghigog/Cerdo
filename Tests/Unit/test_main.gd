extends "res://addons/gut/test.gd"

var Game = load("res://Scripts/game.gd")

var _game = null
const HBOX_ALIGNMENTS =  [
  "ALIGNMENT_BEGIN", "ALIGNMENT_CENTER", "ALIGNMENT_END"
]

func before_each():
	_game = Game.new()

func after_each():
	_game.free()
	
func after_all():
	Global.free()
	assert_no_new_orphans()

func before_each_refresh_turn():
	_game.player_turn_h_box_container = double(HBoxContainer).new()

func refresh_turn_from_to(alignment_from, turn, expected_alignment):
	Global.turn = turn
	_game.player_turn_h_box_container.alignment = alignment_from
	_game.refresh_turn_icon()
	assert_eq(_game.player_turn_h_box_container.alignment, expected_alignment,
	 "Expected to be " + HBOX_ALIGNMENTS[expected_alignment])

func test_refresh_turn_0_from_0():
	before_each_refresh_turn()
	refresh_turn_from_to( _game.player_turn_h_box_container.ALIGNMENT_BEGIN, 
	0, _game.player_turn_h_box_container.ALIGNMENT_BEGIN )
	
func test_refresh_turn_0_from_1():
	before_each_refresh_turn()
	refresh_turn_from_to( _game.player_turn_h_box_container.ALIGNMENT_END, 
	0, _game.player_turn_h_box_container.ALIGNMENT_BEGIN )
	
func test_refresh_turn_1_from_0():
	before_each_refresh_turn()
	refresh_turn_from_to( _game.player_turn_h_box_container.ALIGNMENT_BEGIN, 
	1, _game.player_turn_h_box_container.ALIGNMENT_END )
	
func test_refresh_turn_1_from_1():
	before_each_refresh_turn()
	refresh_turn_from_to( _game.player_turn_h_box_container.ALIGNMENT_END, 
	1, _game.player_turn_h_box_container.ALIGNMENT_END )

func test_render_scores_player1():
	Global.player_scores = [7,8]
	_game.player_1_score_label = double(Label).new()
	_game.player_2_score_label = double(Label).new()
	_game.player_1_score_label.text = "randomtext"
	_game.render_scores();
	assert_eq(_game.player_1_score_label.text, str(Global.player_scores[0]), "Expected player 1 score to be: " + str(Global.player_scores[0]))

func test_render_scores_player2():
	Global.player_scores = [7,8]
	_game.player_1_score_label = double(Label).new()
	_game.player_2_score_label = double(Label).new()
	_game.player_2_score_label.text = "randomtext2"
	_game.render_scores();
	assert_eq(_game.player_2_score_label.text, str(Global.player_scores[1]), "Expected player 2 score to be: " + str(Global.player_scores[1]))

func before_each_ready():
	_game.free()
	_game = partial_double(Game).new()
	stub(_game, "render_scores").to_do_nothing()
	stub(_game, "refresh_turn_icon").to_do_nothing()

func test_ready__spy__render_scores():
	before_each_ready()
	_game._ready()
	assert_called(_game, "render_scores")
	assert_call_count(_game, "render_scores", 1)

func test_ready__spy__refresh_turn():
	before_each_ready()
	_game._ready()
	assert_called(_game, "refresh_turn_icon")
	assert_call_count(_game, "refresh_turn_icon", 1)
