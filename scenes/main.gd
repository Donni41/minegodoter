extends Node

var time_elapsed : float
var remaining_mines : int
var first_click : bool

func _ready():
	get_viewport().connect("size_changed", _on_viewport_resize)
	new_game()
	
func new_game():
	first_click = true
	time_elapsed = 0
	remaining_mines = Global.TOTAL_MINES
	$TileMap.new_game()
	$GameOver.hide()
	$HUD/PanelContainer.position.x = 0
	$GameOver/RestartButton.position.x = Global.COLS * 50 / 2 - 100
	$GameOver/RestartButton.position.y = Global.ROWS * 50
	get_window().size = Vector2i(Global.COLS * 50, Global.ROWS * 50 + 50)
	get_tree().paused = false
	

func _process(delta):
	time_elapsed += delta
	$HUD/PanelContainer/HBoxContainerMain.get_node("HBoxContainer2").get_node("Stopwatch").text = str(int(time_elapsed))
	$HUD/PanelContainer/HBoxContainerMain.get_node("HBoxContainer").get_node("RemainingMines").text = str(remaining_mines)

func end_game(result):
	get_tree().paused = true
	$GameOver.show()
	if result == 1:
		$GameOver.get_node("Label").text = "YOU WIN!"
	else:
		$GameOver.get_node("Label").text = "BOOM!"

func _on_tile_map_flag_placed():
	remaining_mines -= 1

func _on_tile_map_flag_removed():
	remaining_mines += 1

func _on_tile_map_end_game():
	end_game(-1)

func _on_tile_map_game_won():
	end_game(1)
	
func _on_game_over_restart():
	new_game()
	
func _on_viewport_resize():
	$HUD/PanelContainer.size.x = get_window().size.x
	$HUD/PanelContainer.position.y = get_window().size.y - 50
