extends Control


func _on_easy_pressed():
	Global.TOTAL_MINES = 10
	Global.ROWS = 9
	Global.COLS = 9
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_medium_pressed():
	Global.TOTAL_MINES = 40
	Global.ROWS = 16
	Global.COLS = 16
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_hard_pressed():
	Global.ROWS = 16
	Global.COLS = 30
	Global.TOTAL_MINES = 99
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/UI.tscn") # Replace with function body.


func _on_easy_mouse_entered():
	$TextureRect.texture = load("res://assets/photo_2024-07-31_10-28-17.jpg")


func _on_medium_mouse_entered():
	$TextureRect.texture = load("res://assets/photo_2024-07-30_09-47-24.jpg")


func _on_hard_mouse_entered():
	$TextureRect.texture = load("res://assets/photo_2024-07-30_09-46-29.jpg")


func _on_back_mouse_entered():
	$TextureRect.texture = load("res://assets/720ce3ed3ecefab5698f0255431a466f.jpg")
