extends Control



func _ready() -> void:
	await get_tree().process_frame
	$VBoxContainer/HBoxContainer/LineEdit.grab_focus()
	$VBoxContainer/HBoxContainer/LineEdit.grab_click_focus()
	var file_path = "user://previous_data.txt"  # Путь к файлу
	if FileAccess.file_exists(file_path):  # Проверяем, есть ли файл
		var file = FileAccess.open(file_path, FileAccess.READ)  # Открываем файл для чтения
		var nickname = file.get_line()  # Читаем строку
		file.close()
		$VBoxContainer/HBoxContainer/LineEdit.text = nickname  # Устанавливаем текст в LineEdit

		
func _on_line_edit_text_submitted(new_text: String) -> void:
	var nickname = $VBoxContainer/HBoxContainer/LineEdit.text
	var tcp_client = Global.tcp_client
	var regex = RegEx.new()
	regex.compile("^[a-zA-Z0-9 ]+$")
	if nickname.strip_edges() == "" or !regex.search(nickname) :
		$VBoxContainer/HBoxContainer/LineEdit.text = ""
		$VBoxContainer/Label.text = "Please, sumbit a proper nickname, don't use symbols aswell "
	else:		
		# Format check message
		var check_message = "nicknameCheck:" + nickname
		var data = check_message.to_ascii_buffer()
		
		# Send check request to server
		var error = tcp_client.put_data(data)
		if error != OK:
			$VBoxContainer/Label.text = "Connection error. Please try again."
			return
			
		# Wait for server response
		while tcp_client.get_available_bytes() == 0:
			await get_tree().create_timer(0.1).timeout
			
		# Read server response
		var response = tcp_client.get_data(tcp_client.get_available_bytes())
		if response[0] != OK:
			$VBoxContainer/Label.text = "Failed to read server response."
			return
			
		# Parse response
		var server_response = response[1].get_string_from_ascii()
		
		# Handle response
		if server_response == "OK":
			# Nickname is available, proceed with actual nickname setting
			var nickname_message = "nicknameAdd:" + nickname
			error = tcp_client.put_data(nickname_message.to_ascii_buffer())
			if error == OK:
				$VBoxContainer/HBoxContainer/LineEdit.text = ""
				Global.play_sound(Global.next)
				get_tree().change_scene_to_file("res://lobby.tscn")
		elif server_response == "notOK":
			$VBoxContainer/Label.text = "This nickname is already taken, choose something else."
		else:
			$VBoxContainer/Label.text = "Invalid server response. Please try again."


		var line2 = ""
		var line3 = ""
		var file_path = "user://previous_data.txt"
		if FileAccess.file_exists(file_path):
			var read_file = FileAccess.open(file_path, FileAccess.READ)
			read_file.get_line()  # Пропускаем первую строку
			line2 = read_file.get_line()  # Сохраняем вторую строку
			line3 = read_file.get_line()  # Сохраняем третью строку
			read_file.close()
		var write_file = FileAccess.open(file_path, FileAccess.WRITE)
		write_file.store_string(new_text + "\n")  # Новая первая строка
		write_file.store_string(line2 + "\n" if line2 else "\n")  # Сохраняем вторую строку
		write_file.store_string(line3 if line3 else "")  # Сохраняем третью строку
		write_file.close()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		Global.play_sound(Global.previous)
		get_tree().change_scene_to_file("res://MainMenu.tscn")
