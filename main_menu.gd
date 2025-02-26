extends Control

var menu_items = []
var current_index = 0
var network := ENetMultiplayerPeer.new()
@onready var start_button = $VBoxContainer2/VBoxContainer/Button2
@onready var exit_button = $VBoxContainer2/VBoxContainer/Button4
@onready var ip_button = $VBoxContainer2/VBoxContainer2/HBoxContainer2/IPtext
@onready var port_button = $VBoxContainer2/VBoxContainer2/HBoxContainer/porttext
@onready var ip_input = $VBoxContainer2/VBoxContainer2/HBoxContainer2/ip
@onready var port_input = $VBoxContainer2/VBoxContainer2/HBoxContainer/port

func _ready() -> void:
	menu_items = [start_button, exit_button, ip_button, port_button]
	start_button.grab_focus()
	
	exit_button.pressed.connect(_on_exit_pressed)
	ip_button.pressed.connect(_on_ip_button_pressed)
	port_button.pressed.connect(_on_port_button_pressed)
	ip_input.text_submitted.connect(_on_ip_input_submitted)
	port_input.text_submitted.connect(_on_port_input_submitted)
	
	var file_path = "user://previous_data.txt"  
	if FileAccess.file_exists(file_path):  
		var file = FileAccess.open(file_path, FileAccess.READ)  
		file.get_line()  # Пропускаем первую строку
		var ip_lineedit = file.get_line()  
		var port_lineedit = file.get_line()  
		file.close()
		$VBoxContainer2/VBoxContainer2/HBoxContainer2/ip.text = ip_lineedit
		$VBoxContainer2/VBoxContainer2/HBoxContainer/port.text = port_lineedit

func _input(event: InputEvent) -> void:
	# Сначала проверяем, не в фокусе ли инпуты
	if ip_input.has_focus() or port_input.has_focus():
		if event.is_action_pressed("ui_accept"):  # Проверяем нажатие Enter в инпутах
			if ip_input.has_focus():
				_on_ip_input_submitted(ip_input.text)
			elif port_input.has_focus():
				_on_port_input_submitted(port_input.text)
			get_viewport().set_input_as_handled()
		return
	
	# Обрабатываем только нажатия клавиш
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_DOWN:
				Global.play_sound(Global.chose_sound)
				get_viewport().set_input_as_handled()
				current_index = (current_index + 1) % menu_items.size()
				menu_items[current_index].grab_focus()
				
			KEY_UP:
				Global.play_sound(Global.chose_sound)
				get_viewport().set_input_as_handled()
				current_index = (current_index - 1) if current_index > 0 else menu_items.size() - 1
				menu_items[current_index].grab_focus()
				
			KEY_ENTER, KEY_KP_ENTER:
				get_viewport().set_input_as_handled()
				Global.play_sound(Global.chose_sound)
				if ip_button.has_focus():
					_on_ip_button_pressed()
				elif port_button.has_focus():
					_on_port_button_pressed()
				elif menu_items[current_index].has_focus():
					menu_items[current_index].emit_signal("pressed")
				
		
func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_start_pressed() -> void:
	$connecting_label.text = ""
	var server_ip = $VBoxContainer2/VBoxContainer2/HBoxContainer2/ip.text  # IP адрес твоего сервера
	var server_port = int($VBoxContainer2/VBoxContainer2/HBoxContainer/port.text)      # Порт твоего сервера
	var tcp_client = Global.tcp_client
	if server_ip == "" or server_port == 0:
		Global.play_sound(Global.errorSound)
		$warning_label.text = "lil bro, please, enter the fucking IP and Port, that's OB-LI-GA-TO-RY"
	else:
		var line1 = ""
		var file_path = "user://previous_data.txt"
		if FileAccess.file_exists(file_path):
			var read_file = FileAccess.open(file_path, FileAccess.READ)
			line1  = read_file.get_line()  # Сохраняем первую строку
			read_file.close()
		var write_file = FileAccess.open(file_path, FileAccess.WRITE)
		write_file.store_string(line1 + "\n")  # Новая первая строка
		write_file.store_string(server_ip + "\n")  # Сохраняем вторую строку
		write_file.store_string(str(server_port))  # Сохраняем третью строку
		write_file.close()


		# Пытаемся подключиться
		if tcp_client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
			tcp_client.disconnect_from_host()
		
		var connection_status = tcp_client.connect_to_host(server_ip, server_port)
		if connection_status == OK:

			# Пока мы в процессе подключения, продолжаем проверять статус
			const DOTS = [".", "..", "..."]
			var dot_counter = 0

			while tcp_client.get_status() == StreamPeerTCP.STATUS_CONNECTING:
				$connecting_label.text = "connecting" + DOTS[dot_counter % 3]
			
				tcp_client.poll()
				await get_tree().create_timer(0.2).timeout
				dot_counter += 1

			# Если подключение успешно установлено, отправляем данные
			if tcp_client.get_status() == StreamPeerTCP.STATUS_CONNECTED:
				Global.play_sound(Global.next)
				get_tree().change_scene_to_file("res://nickname.tscn")
			else:
				$connecting_label.text = "Could not establish a connection."
				Global.play_sound(Global.errorSound)
		else:
			$connecting_label.text = "Failed to connect, no avaible server. Check if the server IP and Port are right"
			Global.play_sound(Global.errorSound)

			

func _on_ip_button_pressed():
	ip_input.grab_focus()

func _on_port_button_pressed():
	port_input.grab_focus()

func _on_ip_input_submitted(new_text):
	ip_button.grab_focus()
	Global.play_sound(Global.chose_sound)
	current_index = menu_items.find(ip_button)

func _on_port_input_submitted(new_text):
	port_button.grab_focus()
	Global.play_sound(Global.chose_sound)
	current_index = menu_items.find(port_button)
