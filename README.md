![icon](https://user-images.githubusercontent.com/12999437/186977912-32173e22-1325-41bc-94e0-30612efe181e.png)
### TableDB 
> Godot 3.5+ addon

Simple database that store you data in Config File format. One file - one table.

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
| select(fields: Array)  | TableDB.Query  | Return simple query builder |

### API (TableDB.Query)
| method  | return type | description |
| ------------- | ------------- | ------------- |
| where(field: String, condition: String, equal)  | TableDB.Query | Add filtration condition for query (AND) |
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
var db = TableDB.new("user://my.db")
db.insert({name='hello', description='world'})
db.insert({name='second', description='row'})
db.insert({name='3', description='world'})

db.count() # 3

db.all() # [{id=1, name="hello", description='world'}, ...]

db.has(2) # true
db.has(4) # false

db.find(2) # {id=2, name="second", description='row'}

db.remove(2) # true

# save all changes to disk
db.save()
```
##### example 2

```gdscript
func _ready():
  var db = TableDB.new("user://my.db")
  for i in range(100):
    db.insert({name='hello', value=randi()%10})

  db.select(['name']).take(5)
  db.select(['name']).orderBy('id','desc').take(5,4)
  db.select().where('value','<',5).take()
  db.select().where('value','>=',7).update({name='updated_name'})
  db.select().where('id','>',2).where('id','<',4).delete()
  db.select().whereCustom(funcref(self, '_where_custom')).take()
    
func _where_custom(data: Dictionary):
  return data["name"]=='hello'
```



