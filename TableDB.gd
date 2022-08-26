class_name TableDB
extends Reference

signal changed

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
	
	# detect_last_insert_id
	for id in _db.get_sections():
		_count+=1
		if not (id as String).is_valid_integer(): continue
		if int(id)>_last_insert_id:
			_last_insert_id = int(id)

func insert(data:Dictionary) -> String:
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
	emit_signal("changed")
	return id

func remove(id:String):
	if has(id):
		_count -= 1
		_db.erase_section(id)
	emit_signal("changed")

func count() -> int:
	return _count

func truncate():
	_db = ConfigFile.new()
	_count = 0
	emit_signal("changed")

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


func query() -> Query:
	return Query.new(self)


class Query:
	var _conditions: Array

	var _db: TableDB
	func _init(db: TableDB):
		_db = db
	
	func where(field: String, condition: String, equal) -> Query:
		_conditions.append(Condition.new(field, condition, equal))
		return self
	
	func update(values: Dictionary):
		for row in take():
			values['id'] = row['id']
			_db.insert(values)
	
	func delete():
		for row in take():
			_db.remove(row['id'])
	
	func count() -> int:
		return take().size()
	
	# execute query and return result
	func take(limit: int = 0, offset: int = 0) -> Array:
		var result: Array
		for row in _db.all():
			var passing: bool = true
			for c in _conditions:
				passing = passing && (c as Condition).check(row)
			
			if passing: result.append(row)
		return result
	
	class Condition:
		const TYPE_EQUAL = 0
		const TYPE_NOT_EQUAL = 1
		const TYPE_GREATER = 2
		const TYPE_GREATER_OR_EQUAL = 3
		const TYPE_LOWER = 4
		const TYPE_LOWER_OR_EQUAL = 5
		
		var _type: int
		var _field: String
		var _equal
		
		func _init(field: String, condition: String, equal):
			_field = field
			_equal = equal
			match(condition):
				'=':  _type = TYPE_EQUAL
				'!=': _type = TYPE_NOT_EQUAL
				'>':  _type = TYPE_GREATER
				'>=': _type = TYPE_GREATER_OR_EQUAL
				'<':  _type = TYPE_LOWER
				'<=': _type = TYPE_LOWER_OR_EQUAL
				_: printerr('unknow condition type "%s"' % condition)
		
		func check(data: Dictionary) -> bool:
			if not data.has(_field): return false
			match (_type):
				TYPE_EQUAL: return data[_field] == _equal
				TYPE_NOT_EQUAL: return data[_field] != _equal
				TYPE_GREATER: return data[_field]>_equal
				TYPE_GREATER_OR_EQUAL: return data[_field]>=_equal
				TYPE_LOWER: return data[_field]<_equal
				TYPE_LOWER_OR_EQUAL: return data[_field]<=_equal
			return false
