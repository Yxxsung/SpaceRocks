extends CanvasLayer

signal start_game

@onready var lives_counter = $MarginContainer/HBoxContainer/LivesCounter.get_children()
@onready var score_label = $MarginContainer/HBoxContainer/ScoreLabel
@onready var message = $VBoxContainer/Message
@onready var start_button = $VBoxContainer/StartButton

#function change the message text, run when we change from start game to game over
func show_message(text):
	message.text = text
	message.show()
	$Timer.start()
	#function to update the score
func update_score(value):
	score_label.text = str(value)
#function to update lives counter as we lose lives
func update_lives(value):
	for item in 3:
		#[] represents index or position in an array
		lives_counter[item].visible = value > item

#game over
func game_over():
	show_message("Game Over")
	await $Timer.timeout
	start_button.show()

func _on_start_button_pressed() -> void:
	start_button.hide()
	start_game.emit()

func _on_timer_timeout() -> void:
	message.hide()
	message.text = ""





#Spacer so current code is in the middle of the screen
