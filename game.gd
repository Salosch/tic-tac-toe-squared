extends Node2D

var current_player: int = 0
var player_states := ["Circle", "Cross"]
var won := ""
var unique_item_acquired: bool = false
var skip_turn: bool = false
var boards := []
var images := []

func _ready():
	won = ""
	current_player = 0
	unique_item_acquired = false
	skip_turn = false
	
	if boards.size() > 0:
		for board in boards:
			board.reset() 
	else:
		boards.clear()
		for i in range(1, 26):
			var board = get_node("Board" + str(i)) as Board
			boards.append(board)
	
	if images.size() > 0:
		for image in images:
			image.queue_free()
			
	images.clear()
	
	$GUI/WonPlayer.hide()
	_update_next_player_ui()
	set_active_board(true)
	
	for board in boards:
		board.unique_item_pos = Vector2(-1, -1)
	boards[randi() % boards.size()].assign_unique_item()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if won == "":
		if Input.is_action_just_pressed("Click"):
			for board in boards:
				if board.active:
					var grid_pos = board.gridpos_at_mouse()

					if grid_pos == board.unique_item_pos and not unique_item_acquired:
						print("Item acquired")
						display_item()
						unique_item_acquired = true
						return

					if board.get_state(grid_pos) == board.empty_state:
						if board.set_state(grid_pos, player_states[current_player]):
							if board.check_board_win():
								board.hide()
								create_image(board, player_states[current_player])
								board.active = false
								print(player_states[current_player] + " wins a board")
								check_overall_winner()
							
							if skip_turn:
								skip_turn = false
							else:
								current_player = 1 - current_player
								_update_next_player_ui()
						if unique_item_acquired:
							skip_turn = true
							unique_item_acquired = false

func _on_restart_button_pressed():
	_ready()

var _checks = [
	[Vector2i(-1,0), Vector2i(1,0)],
	[Vector2i(0,-1), Vector2i(0,1)],
	[Vector2i(-1,-1), Vector2i(1,1)],
	[Vector2i(-1,1), Vector2i(1,-1)],
]

func check_overall_winner():
	var win_conditions = [
		# Horizontal wins
		[0, 1, 2, 3, 4],
		[5, 6, 7, 8, 9],
		[10, 11, 12, 13, 14],
		[15, 16, 17, 18, 19],
		[20, 21, 22, 23, 24],
		# Vertical wins
		[0, 5, 10, 15, 20],
		[1, 6, 11, 16, 21],
		[2, 7, 12, 17, 22],
		[3, 8, 13, 18, 23],
		[4, 9, 14, 19, 24],
		# Diagonal wins
		[0, 6, 12, 18, 24],
		[4, 8, 12, 16, 20]
	]
	
	for condition in win_conditions:
		if boards[condition[0]].board_winner != "" and	boards[condition[0]].board_winner == boards[condition[1]].board_winner and	boards[condition[0]].board_winner == boards[condition[2]].board_winner and 	boards[condition[0]].board_winner == boards[condition[3]].board_winner and 	boards[condition[0]].board_winner == boards[condition[4]].board_winner:
			won = boards[condition[0]].board_winner
			end_game(won)
			return 
		
func end_game(winner):
	print(winner + " wins the game!")
	set_active_board(false)
	
	var popup_panel = $GUI.get_node("PopupPanel")
	if popup_panel:
		var label_node = popup_panel.get_node("Label")
		if label_node:
			label_node.text = winner + " wins the game!"
			popup_panel.popup_centered()
		else:
			print("Label node not found.")
	else:
		print("PopupPanel node not found.")
		
func _update_next_player_ui():
	var nextPlayer = $GUI/NextPlayer as Sprite2D
	nextPlayer.region_rect.position.x = current_player * 300
	nextPlayer.show()

func _update_winning_player_ui():
	var wonPlayer = $GUI/WonPlayer as Sprite2D
	wonPlayer.region_rect.position.x = player_states.find(won) * 300
	wonPlayer.show()

func set_active_board(active: bool):
	for board in boards:
		board.active = active

func display_item():
	var popup_item = $GUI.get_node("PopupItem")

	if popup_item:
		var label_item = popup_item.get_node("Label")
		if label_item:
			label_item.text = "You have acquired the 'Double Turn' Item!\nYour opponent has a chance to react"
			popup_item.popup_centered()
		else:
			print("Label not found")
	else:
		print("Popup not found")

func create_image(board: TileMap, current_player: String) -> Sprite2D:
	var image_path := ""
	
	if current_player == "Circle":
		image_path = "res://assets/big_o.png" 
	else:
		image_path = "res://assets/big_x.png"
		
	var image_texture = load(image_path)
	
	var sprite = Sprite2D.new()
	
	sprite.texture = image_texture
	sprite.position = board.position - Vector2(-40,-40)
	print(sprite.position)
	add_child(sprite)
	images.append(sprite)
	
	return sprite




