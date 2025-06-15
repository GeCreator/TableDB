tool
class_name TableDB
extends Reference

signal changed

var _db: ConfigFile
var _path: String
var _last_insert_id: int
var _password: String = ''
var _count: int = 0

func _init(dbpath:String = '', password: String=''):
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
		if int(id)>_last_insert_id:
			_last_insert_id = int(id)

func insert(data:Dictionary) -> String:
	var id: String
	if 'id' in data:
		id = str(data['id'])
		data.erase('id')
		if not has(id):
			_count += 1
	else:
		_count += 1
		_last_insert_id+=1
		id = str(_last_insert_id)
	
	for k in data:
		_db.set_value(id, k, data[k])
	emit_signal("changed")
	return id

func remove(id: String) -> bool:
	if has(id):
		_count -= 1
		_db.erase_section(id)
		emit_signal("changed")
		return true
	return false

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
	assert(_path!="")
	if _password=='':
		_db.save(_path)
	else:
		_db.save_encrypted_pass(_path, _password)

func saveTo(path:String):
	var _p = _path
	_path = path
	save()
	_path = _p

func select(fields: Array = []) -> Query:
	return Query.new(self, fields)

class Query:
	var _selection_fields: Array
	var _use_selection_fields: bool = false
	var _conditions: Array
	var _order
	var _order_field: String
	var _custom_order_object
	var _custom_order_function: String

	var _db: TableDB
	func _init(db: TableDB, fields: Array):
		_use_selection_fields = fields.size()>0
		_selection_fields = fields
		_db = db
	
	func where(field: String, condition: String, equal) -> Query:
		match(condition):
				'=','==': _conditions.append(ConditionEqual.new(field, equal))
				'!=': _conditions.append(ConditionNotEqual.new(field, equal))
				'>':  _conditions.append(ConditionGreater.new(field, equal))
				'>=':  _conditions.append(ConditionGreaterOrEqual.new(field, equal))
				'<': _conditions.append(ConditionLower.new(field, equal))
				'<=': _conditions.append(ConditionLowerOrEqual.new(field, equal))
		return self
	
	func whereIn(field: String, equal: Array) -> Query:
		_conditions.append(ConditionWhereIn.new(field, equal))
		return self
	
	func whereNotIn(field: String, equal: Array) -> Query:
		_conditions.append(ConditionWhereNotIn.new(field, equal))
		return self
	
	func whereCustom(function: FuncRef) -> Query:
		_conditions.append(ConditionCustom.new(function))
		return self

	func update(values: Dictionary) -> int:
		var updated_count: int = 0
		for row in take():
			updated_count+= 1
			values['id'] = row['id']
			_db.insert(values)
		return updated_count

	func delete() -> int:
		var deleted_count: int = 0
		for row in take():
			deleted_count+=1
			_db.remove(row['id'])
		return deleted_count

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
			var passing: bool = true
			for c in _conditions:
				passing = passing && c.check(row)
			
			if passing:
				if offset>0:
					offset-=1
					continue
				limit-=1
				if _use_selection_fields:
					var filtred_row: Dictionary = {}
					for f in _selection_fields:
						if row.has(f):
							filtred_row[f] = row[f]
					result.append(filtred_row)
				else:
					result.append(row)
				if limit==0: break
			
		return result
	
	func orderBy(field: String, direction: String = 'asc') -> Query:
		_order_field = field
		_order = direction.to_lower()
		return self
	
	func orderByCustom(object, function: String) -> Query:
		_custom_order_object = object
		_custom_order_function = function
		_order = 'custom'
		return self
	
	func groupBy(field: String) -> Dictionary:
		var result: Dictionary = {}
		for v in take():
			if v.has(field):
				var key = v[field]
				if not result.has(key): result[key] = Array()
				result[key].append(v)
		return result
	
	func _sort_by_asc(a, b):
		return a[_order_field] < b[_order_field]
	
	func _sort_by_desc(a, b):
		return a[_order_field] > b[_order_field]
		
	
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

	class ConditionWhereNotIn extends ConditionBase:
		func _init(field: String, equal).(field, equal): pass
		func check(data: Dictionary) -> bool:
			for v in _equal:
				if v==data[_field]:
					return false
			return true

	class ConditionWhereIn extends ConditionBase:
		func _init(field: String, equal).(field, equal): pass
		func check(data: Dictionary) -> bool:
			for v in _equal:
				if v==data[_field]:
					return true
			return false
	
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

