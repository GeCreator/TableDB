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
	var _order
	var _order_field: String
	var _custom_order_object
	var _custom_order_function: String

	var _db: TableDB
	func _init(db: TableDB):
		_db = db
	
	func where(field: String, condition: String, equal) -> Query:
		match(condition):
				'=': _conditions.append(ConditionEqual.new(field, equal))
				'!=': _conditions.append(ConditionNotEqual.new(field, equal))
				'>':  _conditions.append(ConditionGreater.new(field, equal))
				'>=':  _conditions.append(ConditionGreaterOrEqual.new(field, equal))
				'<': _conditions.append(ConditionLower.new(field, equal))
				'<=': _conditions.append(ConditionLowerOrEqual.new(field, equal))
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
	func take(limit: int = -1, offset: int = 0) -> Array:
		var result: Array
		var list: Array = _db.all()
		match(_order):
			'asc': list.sort_custom(self, "_sort_by_asc")
			'desc': list.sort_custom(self, "_sort_by_desc")
			'custom': list.sort_custom(_custom_order_object, _custom_order_function)
		
		for row in list:
			if offset>0:
				offset-=1
				continue
			limit-=1
			var passing: bool = true
			for c in _conditions:
				passing = passing && c.check(row)
			
			if passing: result.append(row)
			if limit==0: break
			
		return result
	
	func orderyBy(field: String, direction: String = 'asc') -> Query:
		_order_field = field
		_order = direction.to_lower()
		return self
	
	func orderByCustom(object, function: String) -> Query:
		_custom_order_object = object
		_custom_order_function = function
		_order = 'custom'
		return self
	
	func _sort_by_asc(a, b):
		return a[_order_field] < b[_order_field]
	
	func _sort_by_desc(a, b):
		return a[_order_field] > b[_order_field]
		
	
	func whereCustom(function: FuncRef) -> Query:
		_conditions.append(ConditionCustom.new(function))
		return self
	
	class ConditionCustom:
		var _function: FuncRef
		func _init(function: FuncRef):
			_function = function
		
		func check(data:Dictionary) -> bool:
			return _function.call_func(data)
	
	class ConditionBase:
		var _field: String
		var _equal
		func _init(field: String, equal):
			_field = field
			_equal = equal
	
	class ConditionEqual extends ConditionBase:
		func _init(field: String, equal).(field, equal): pass
		func check(data: Dictionary) -> bool:
			return data.has(_field) and data[_field] == _equal
	
	class ConditionNotEqual extends ConditionBase:
		func _init(field: String, equal).(field, equal): pass
		func check(data: Dictionary) -> bool:
			return data.has(_field) and data[_field] != _equal
	
	class ConditionGreater extends ConditionBase:
		func _init(field: String, equal).(field, equal): pass
		func check(data: Dictionary) -> bool:
			return data.has(_field) and data[_field] > _equal
	
	class ConditionGreaterOrEqual extends ConditionBase:
		func _init(field: String, equal).(field, equal): pass
		func check(data: Dictionary) -> bool:
			return data.has(_field) and data[_field] >= _equal

	class ConditionLower extends ConditionBase:
		func _init(field: String, equal).(field, equal): pass
		func check(data: Dictionary) -> bool:
			return data.has(_field) and data[_field] < _equal

	class ConditionLowerOrEqual extends ConditionBase:
		func _init(field: String, equal).(field, equal): pass
		func check(data: Dictionary) -> bool:
			return data.has(_field) and data[_field] <= _equal

