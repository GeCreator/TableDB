class_name TableDB
extends Reference

var _db:ConfigFile
var _path: String
var _last_insert_id: int
var _password: String = ''


func _detect_last_insert_id():
	for id in _db.get_sections():
		if int(id)>_last_insert_id:
			_last_insert_id = int(id)

func _init(dbpath:String, password: String=''):
	
	_db = ConfigFile.new()
	_path = dbpath
	if (File.new()).file_exists(_path):
		if password=='':
			_db.load(_path)
		else:
			_password = password.md5_text()
			_db.load_encrypted_pass(_path, _password)
	_detect_last_insert_id()

func insert(data:Dictionary):
	var id: String
	if 'id' in data:
		id = str(data['id'])
	else:
		_last_insert_id+=1
		id = str(_last_insert_id)
	
	for k in data:
		_db.set_value(id, k, data[k])

func remove(id:String):
	_db.erase_section('id')

func has(id: String) -> bool:
	return _db.has_section('id') 

func find(id: String) -> Dictionary:
	var result: Dictionary
	for key in _db.get_section_keys(id):
		result[key] = _db.get_value(id, key)
	return result

func all() -> Array:
	var result: Array
	for id in _db.get_sections():
		var row: Dictionary
		row['id'] = id
		for key in _db.get_section_keys(id):
			row[key] = _db.get_value(id, key)
		result.append(row)
	return result

func save():
	if _password=='':
		_db.save(_path)
	else:
		_db.save_encrypted_pass(_path, _password)
