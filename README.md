![icon](https://user-images.githubusercontent.com/12999437/186977912-32173e22-1325-41bc-94e0-30612efe181e.png)
### TableDB
____
##### simple usage
```
var db = TableDB.new("user://my.db")
db.insert({name='hello', description='world'})
db.insert({name='second', description='row'})
db.insert({name='3', description='world'})


# return total rows count
db.count() # int

# return all rows [{id=1, name="hello", description='world'}, ...]
db.all() # Array

# check if row with id=2 exists (true)
db.has(2) # bool

# find by id ( return {id=2, name="second", description='row'})
db.find(2) # Dictionary

# remove by id (return true if row was deleted)
db.remove(2) # bool

# save all changes to disk
db.save()
```
