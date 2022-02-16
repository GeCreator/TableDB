class_name TableDB
extends Reference

var _db: ConfigFile
var _path: String
var _last_insert_id: int
var _password: String = ''
var _count: int = 0

func _init(dbpath:String, password: String=''):
	_db = ConfigFile.new()
	_path = dbpath
	if password!='':
		_password = password.md5_text()

	if (File.new()).file_exists(_path):
		if _password=='':
			_db.load(_path)
		else:
			_db.load_encrypted_pass(_path, _password)
	_detect_last_insert_id()

func _detect_last_insert_id():
	for id in _db.get_sections():
		_count+=1
		if int(id)>_last_insert_id:
			_last_insert_id = int(id)

func insert(data:Dictionary):
	var id: String
	if 'id' in data:
		id = str(data['id'])
		data.erase('id')
	else:
		_last_insert_id+=1
		id = str(_last_insert_id)
	
	if not has(id): _count +=1
	
	for k in data:
		_db.set_value(id, k, data[k])

func remove(id:String):
	if has(id):
		_count -= 1
		_db.erase_section(id)

func count() -> int:
	return _count

func truncate():
	_db = ConfigFile.new()
	_count = 0

func has(id: String) -> bool:
	return _db.has_section(id) 

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
