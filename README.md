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

# check if row with id=2 exists
db.has(2) # true 
db.has(4) # false

# find by id
db.find(2) # {id=2, name="second", description='row'}

# remove by id
db.remove(id)

# save all changes to disk
db.save()
```
