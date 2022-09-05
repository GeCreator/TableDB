![icon](https://user-images.githubusercontent.com/12999437/186977912-32173e22-1325-41bc-94e0-30612efe181e.png)
### TableDB 
> Godot 3.5+ addon

Simple database that store you data in Config File format. One file - one table. Good for small data storage (~10mb). Tested with [GUT](https://github.com/bitwes/Gut)

### API (TableDB)

| method  | return type | description |
| ------------- | ------------- | ------------- |
| _init(dbpath:String, password: String)| TableDB | Database can be encripted if you set password |
| insert(data: Dictionary)  | int  | Add new row and return id |
| remove(id: int)  | bool  | Remove row by id  |
| has(id: int)  | bool  | Check if row exists |
| find(id: int)  | Dictionary  | Find row by id |
| all()  | Array  | Return all rows |
| count()  | int  | Return total rows count |
| save()  | null  | Save all changes to disk |
| saveTo(path:String)  | null  | Save changes to another place |
| select(fields: Array)  | TableDB.Query  | Return simple query builder |

### API (TableDB.Query)
| method  | return type | description |
| ------------- | ------------- | ------------- |
| where(field: String, condition: String, equal)  | TableDB.Query | Add filtration condition for query (AND) |
| whereIn(field: String, equal: Array)  | TableDB.Query |  |
| whereNotIn(field: String, equal: Array)  | TableDB.Query |  |
| whereCustom(function: FuncRef)  | TableDB.Query | Add custom WHERE. Filtration function must have one argument and return true/false |
| update(values: Dictionary) | int | Set new "values" for selected rows and return changed count |
| delete() | int | Delete selected rows and return deleted count |
| count() | int | Return selected count |
| orderyBy(field: String, direction: String = 'asc') | TableDB.Query | Set sort by field (direction: 'asc'/'desc') |
| orderByCustom(object, function: String) | TableDB.Query | Use custom sort function |
| take(limit: int, offset: int) | Array | Return query result |

____

##### example 1
```gdscript
var table = TableDB.new("user://data.table")
table.insert({name='hello', description='world'})
table.insert({name='second', description='row'})
table.insert({name='3', description='world'})

table.count() # 3

table.all() # [{id=1, name="hello", description='world'}, ...]

table.has(2) # true
table.has(4) # false

table.find(2) # {id=2, name="second", description='row'}

table.remove(2) # true

# save all changes to disk
table.save()
```
##### example 2

```gdscript
func _ready():
  var table = TableDB.new("user://data.table")
  for i in range(100):
    table.insert({name='hello'+str(i), value=randi()%10})
  
  table.select(['name']).take(5)
  # [{name:hello0}, {name:hello1}, {name:hello2}, {name:hello3}, {name:hello4}]

  table.select(['id']).orderBy('id','desc').take(5,4)
  # [{id:95}, {id:94}, {id:93}, {id:92}, {id:91}]

  table.select(['value']).where('value','<',5).take()
  # [{value:0}, {value:0}, {value:2}, {value:3}, {value:2}, {value:1}, {value:1}, {value:4} ...]
  
  
  table.select().where('value','>=',7).update({name='updated_name'})
  table.select().where('id','>',2).where('id','<',4).delete()
  table.select().whereIn('id',[1,2,3]).delete()
  table.select().whereCustom(funcref(self, '_where_custom')).take()
  # ....
    
func _where_custom(data: Dictionary):
  return data["name"]=='hello0' || data["name"]=='hello1'
```



