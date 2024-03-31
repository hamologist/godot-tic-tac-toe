extends Node

@export var button_group: ButtonGroup

enum POSITIONS {
	TOP_LEFT,
	TOP_MIDDLE,
	TOP_RIGHT,
	MIDDLE_LEFT,
	MIDDLE,
	MIDDLE_RIGHT,
	BOTTOM_LEFT,
	BOTTOM_MIDDLE,
	BOTTOM_RIGHT,
}

enum PLAYERS {
	ONE,
	TWO,
}

enum MOVE_STATES {
	NONE,
	PLAYER_ONE,
	PLAYER_TWO,
}

enum GAME_STATES {
	PLAYING,
	PLAYER_ONE_WON,
	PLAYER_TWO_WON,
}

enum DIAGONAL_DIRECTION {
	ONE,
	TWO,
}

var x_texture = load("res://sprites/game-pieces/x.png")
var o_texture = load("res://sprites/game-pieces/o.png")
var horizontal_texture = load("res://sprites/game-pieces/horizontal-line.png")
var vertical_texture = load("res://sprites/game-pieces/vertical-line.png")
var diagonal_one_texture = load("res://sprites/game-pieces/diagonal-line-1.png")
var diagonal_two_texture = load("res://sprites/game-pieces/diagonal-line-2.png")

var current_players_turn: PLAYERS
var game_board: Array
var buttons: Array
var game_state: GAME_STATES
var added_nodes: Array

func button_router(button: BaseButton): 
	for pos in POSITIONS:
		if button == buttons[POSITIONS[pos]]:
			return POSITIONS[pos]
	
	push_error("Invalid button")

func generate_game_piece(player: PLAYERS):
	var texture_rect = TextureRect.new()
	texture_rect.add_to_group('cleanup')
	texture_rect.texture = x_texture if player == PLAYERS.ONE else o_texture
	texture_rect.size = Vector2(32, 32)
	texture_rect.position = Vector2(16, 16)
	
	return texture_rect

func generate_horizontal_line():
	var texture_rect = TextureRect.new()
	texture_rect.add_to_group('cleanup')
	texture_rect.texture = horizontal_texture
	texture_rect.size = Vector2(64, 2)
	texture_rect.position = Vector2(0, 31)
	
	return texture_rect

func generate_vertical_line():
	var texture_rect = TextureRect.new()
	texture_rect.add_to_group('cleanup')
	texture_rect.texture = vertical_texture
	texture_rect.size = Vector2(2, 64)
	texture_rect.position = Vector2(31, 0)
	
	return texture_rect

func generate_diagonal_line(dir: DIAGONAL_DIRECTION):
	var texture_rect = TextureRect.new()
	texture_rect.add_to_group('cleanup')
	texture_rect.texture = diagonal_one_texture if dir == DIAGONAL_DIRECTION.ONE else diagonal_two_texture
	texture_rect.size = Vector2(64, 64)
	texture_rect.position = Vector2(0, 0)
	
	return texture_rect

func check_for_win():
	var winner = false
	
	# Check horizontal lines
	for row in range(0, 7, 3):
		if (
			game_board[row] != MOVE_STATES.NONE
			and game_board[row] == game_board[row + 1]
			and game_board[row + 1] == game_board[row + 2]
		):
			for i in range(0, 3):
				buttons[row + i].get_parent().add_child(generate_horizontal_line())
			winner = true
			break
	
	# Check vertical lines
	if not winner:
		for col in range(0, 3):
			if (
				game_board[col] != MOVE_STATES.NONE
				and game_board[col] == game_board[col + 3]
				and game_board[col] == game_board[col + 6]
			):
				for i in range(0, 7, 3):
					buttons[col + i].get_parent().add_child(generate_vertical_line())
				winner = true
				break
	
	# Check diagonal lines
	if not winner and game_board[4] != MOVE_STATES.NONE:
		if(
			game_board[0] == game_board[4]
			and game_board[4] == game_board[8]
		):
			for button in [buttons[0], buttons[4], buttons[8]]:
				button.get_parent().add_child(generate_diagonal_line(DIAGONAL_DIRECTION.ONE))
			winner = true
		elif (
			game_board[2] == game_board[4]
			and game_board[4] == game_board[6]
		):
			for button in [buttons[2], buttons[4], buttons[6]]:
				button.get_parent().add_child(generate_diagonal_line(DIAGONAL_DIRECTION.TWO))
			winner = true
	
	if (winner and current_players_turn == PLAYERS.ONE):
		game_state = GAME_STATES.PLAYER_ONE_WON
	elif (winner and current_players_turn == PLAYERS.TWO):
		game_state = GAME_STATES.PLAYER_TWO_WON

func handle_button_press(button: BaseButton):
	var pos = button_router(button)
	
	if (
		game_board[pos] != MOVE_STATES.NONE
		or game_state != GAME_STATES.PLAYING
	):
		return

	if current_players_turn == PLAYERS.ONE:
		game_board[pos] = MOVE_STATES.PLAYER_ONE
	else:
		game_board[pos] = MOVE_STATES.PLAYER_TWO
	button.get_parent().add_child(generate_game_piece(current_players_turn))
	check_for_win()
	
	if current_players_turn == PLAYERS.ONE:
		current_players_turn = PLAYERS.TWO
	else:
		current_players_turn = PLAYERS.ONE

func _ready():
	added_nodes = []
	game_state = GAME_STATES.PLAYING
	current_players_turn = PLAYERS.ONE
	
	game_board.resize(9)
	game_board.fill(MOVE_STATES.NONE)
	
	buttons.resize(9)
	buttons[POSITIONS.TOP_LEFT] = $BoardControl/TopLeftControl/Button
	buttons[POSITIONS.TOP_MIDDLE] = $BoardControl/TopMiddleControl/Button
	buttons[POSITIONS.TOP_RIGHT] = $BoardControl/TopRightControl/Button
	buttons[POSITIONS.MIDDLE_LEFT] = $BoardControl/MiddleLeftControl/Button
	buttons[POSITIONS.MIDDLE] = $BoardControl/MiddleControl/Button
	buttons[POSITIONS.MIDDLE_RIGHT] = $BoardControl/MiddleRightControl/Button
	buttons[POSITIONS.BOTTOM_LEFT] = $BoardControl/BottomLeftControl/Button
	buttons[POSITIONS.BOTTOM_MIDDLE] = $BoardControl/BottomMiddleControl/Button
	buttons[POSITIONS.BOTTOM_RIGHT] = $BoardControl/BottomRightControl/Button

	for button in button_group.get_buttons():
		button.button_down.connect(handle_button_press.bind(button))

func new_game():
	game_state = GAME_STATES.PLAYING
	game_board.fill(MOVE_STATES.NONE)
	current_players_turn = PLAYERS.ONE
	
	for node in get_tree().get_nodes_in_group('cleanup'):
		node.queue_free()
