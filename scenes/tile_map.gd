extends TileMap

signal end_game
signal game_won
signal flag_placed
signal flag_removed


const CELL_SIZE : int = 50

var tile_id : int = 0

var background_layer : int = 0
var mine_layer : int = 1
var number_layer : int = 2 
var grass_layer : int = 3
var flag_layer : int = 4
var hover_layer : int = 5

var mine_atlas := Vector2i(4, 0)
var flag_atlas := Vector2i(5, 0)
var hover_atlas := Vector2i(6, 0)
var number_atlas : Array = generate_number_atlas()

var mine_coords := []
var scanning := false

func generate_number_atlas():
	var a := []
	for i in range(8):
		a.append(Vector2i(i, 1))
	return a

func _ready():
	new_game()
	
func new_game():
	clear()
	mine_coords.clear()
	generate_background()
	generate_mines()
	generate_numbers()
	generate_grass()
	
func generate_mines():
	for i in range(Global.TOTAL_MINES):
		var mine_pos = Vector2i(randi_range(0, Global.COLS - 1), randi_range(0, Global.ROWS - 1))
		while mine_coords.has(mine_pos):
			mine_pos = Vector2i(randi_range(0, Global.COLS - 1), randi_range(0, Global.ROWS - 1))
		mine_coords.append(mine_pos)
		set_cell(mine_layer, mine_pos, tile_id, mine_atlas)

func generate_numbers():
	clear_layer(number_layer)
	for i in get_empty_cells():
		var mine_count : int = 0
		for j in get_all_surrounding_cells(i):
			if is_mine(j):
				mine_count += 1
		if mine_count > 0 :
			set_cell(number_layer, i, tile_id, number_atlas[mine_count - 1])

func generate_background():
	for y in range(Global.ROWS):
		for x in range(Global.COLS):
			var toggle = ((x + y) % 2)
			set_cell(background_layer, Vector2i(x, y), tile_id, Vector2i(1 - toggle, 0))

func generate_grass():
	for y in range(Global.ROWS):
		for x in range(Global.COLS):
			var toggle = ((x + y) % 2)
			set_cell(grass_layer, Vector2i(x, y), tile_id, Vector2i(3 - toggle, 0))

func get_empty_cells():
	var empty_cells := []
	for y in range(Global.ROWS):
		for x in range(Global.COLS):
			if not is_mine(Vector2i(x, y)):
				empty_cells.append(Vector2i(x, y))
	return empty_cells

func get_all_surrounding_cells(middle_cell):
	var surrounding_cells := []
	var target_cell
	for y in range(3):
		for x in range(3):
			target_cell = middle_cell + Vector2i(x - 1, y - 1)
			if target_cell != middle_cell:
				if (target_cell.x >= 0 and target_cell.x <= Global.COLS - 1
					and target_cell.y >= 0 and target_cell.y <= Global.ROWS - 1):
						surrounding_cells.append(target_cell)
	return surrounding_cells

func _input(event):
	if event is InputEventMouseButton:
		if event.position.y < Global.ROWS * CELL_SIZE:
			var map_pos := local_to_map(event.position)
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				if not is_flag(map_pos):
					if is_mine(map_pos):
						if get_parent().first_click:
							move_mine(map_pos)
							generate_numbers()
							process_left_click(map_pos)
						else:
							end_game.emit()
							show_mines()
					else:
						process_left_click(map_pos)
			elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				process_right_click(map_pos)

func process_left_click(pos):
	get_parent().first_click = false
	var revealed_cells := []
	var cells_to_reveal := [pos]
	
	while not cells_to_reveal.is_empty():
		erase_cell(grass_layer, cells_to_reveal[0])
		revealed_cells.append(cells_to_reveal[0])
		if is_flag(cells_to_reveal[0]):
			erase_cell(flag_layer, cells_to_reveal[0])
			flag_removed.emit()
			
		if not is_number(cells_to_reveal[0]):
			cells_to_reveal = reveal_surrounding_cells(cells_to_reveal, revealed_cells)
		cells_to_reveal.erase(cells_to_reveal[0])
		
	var all_cleared := true
	
	for cell in get_used_cells(number_layer):
		if is_grass(cell):
			all_cleared = false
			
	if all_cleared:
		game_won.emit()

func process_right_click(pos):
	if is_grass(pos):
		if is_flag(pos):
			erase_cell(flag_layer, pos)
			flag_removed.emit()
		else:
			set_cell(flag_layer, pos, tile_id, flag_atlas)
			flag_placed.emit()

func reveal_surrounding_cells(cells_to_reveal, revealed_cells):
	for i in get_all_surrounding_cells(cells_to_reveal[0]):
		if not revealed_cells.has(i):
			if not cells_to_reveal.has(i):
				cells_to_reveal.append(i)
	return cells_to_reveal

func show_mines():
	for mine in mine_coords:
		if is_mine(mine):
			erase_cell(grass_layer, mine)

func move_mine(old_pos):
	for y in range(Global.ROWS):
		for x in range(Global.COLS):
			if not is_mine(Vector2i(x, y)) and get_parent().first_click == true:
				mine_coords[mine_coords.find(old_pos)] = Vector2i(x, y)
				erase_cell(mine_layer, old_pos)
				set_cell(mine_layer, Vector2i(x, y), tile_id, mine_atlas)
				get_parent().first_click = false

func _process(delta):
	highlight_cell()
	if (Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and 
		Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)):
			var scan_pos := local_to_map(get_local_mouse_position())
			if not is_grass(scan_pos):
				if scanning == false:
					scan_mines(scan_pos)
					scanning = true
	else:
		scanning = false
	
func highlight_cell():
	var mouse_pos := local_to_map(get_local_mouse_position())
	clear_layer(hover_layer)
	if is_grass(mouse_pos):
		set_cell(hover_layer, mouse_pos, tile_id, hover_atlas)
	else:
		if is_number(mouse_pos):
			set_cell(hover_layer, mouse_pos, tile_id, hover_atlas)

func scan_mines(pos):
	var unflagged_mines : int = 0
	for i in get_all_surrounding_cells(pos):
		if is_flag(i) and not is_mine(i):
			end_game.emit()
			show_mines()
		if is_mine(i) and not is_flag(i):
			unflagged_mines += 1
	if unflagged_mines == 0:
		for cell in reveal_surrounding_cells([pos], []):
			if not is_mine(cell):
				process_left_click(cell)

func is_mine(pos):
	return get_cell_source_id(mine_layer, pos) != -1

func is_grass(pos):
	return get_cell_source_id(grass_layer, pos) != -1

func is_number(pos):
	return get_cell_source_id(number_layer, pos) != -1

func is_flag(pos):
	return get_cell_source_id(flag_layer, pos) != -1
