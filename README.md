![icon](https://user-images.githubusercontent.com/12999437/186977912-32173e22-1325-41bc-94e0-30612efe181e.png)
### TableDB

### API (TableDB)

| method  | return type | description |
| ------------- | ------------- | ------------- |
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
| take(limit: int = -1, offset: int = 0) | Array | Return query result |

____

##### simple example
```
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


