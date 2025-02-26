extends Node
var tcp_client = StreamPeerTCP.new()


var next = load("res://uiSounds/dialog_open.wav")
var errorSound = load("res://uiSounds/dialog_cancel.wav")
var skip = load("res://uiSounds/cant_place_tile.wav")
var answer = load("res://uiSounds/getpoint.wav")
var joined = load("res://uiSounds/friend_logon.wav")
var left = load("res://uiSounds/friend_logoff.wav")
var previous = load("res://uiSounds/dialog_close.wav")
var chose_sound = load("res://uiSounds/blip_lock.wav")
var stasrted = load("res://uiSounds/gong.wav")
var nextQuestion = load("res://uiSounds/page_turn.wav")

	
	# Загружаем звуки один раз
	
func play_sound(sound: AudioStream) -> void:
	var player = AudioStreamPlayer.new()
	player.stream = sound 
	player.bus = "Master"
	add_child(player)
	player.play()
	player.connect("finished", player.queue_free)
