![icon](https://user-images.githubusercontent.com/12999437/186977912-32173e22-1325-41bc-94e0-30612efe181e.png)
### TableDB

### API (TableDB)

| method  | return type | description |
| ------------- | ------------- | ------------- |
| insert(data: Dictionary)  | int  | Add new row and return id |
| remove(id: int)  | bool  | remove row by id  |
| has(id: int)  | bool  | check if row exists |
| find(id: int)  | Dictionary  | find by id |
| all  | Array  | Return all rows |
| count  | int  | return total rows count |
| save  | null  | save all changes to disk |

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


