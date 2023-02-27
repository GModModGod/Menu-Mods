### Luajs. 


### luajs.Register(tab, name)

Registers a new luajs class.

Arguments:

- table tab: The class table.
- string name: The class name.

IMPORTANT: It is highly recommended to refrain from using this function to create luajs classes unless there is a specific reason for doing so.

### luajs.Create(class)

Creates a new luajs object of the specified class name.

Arguments:

- string class: The class name of the new object.

### luajs.GetClasses()

Returns the original table of all luajs classes.

Returns:

- table tab: The table of classes.

### luajs.GetClassTable(class)

Returns the original table for the specified luajs class name.

Arguments:

- string class: The class name.

Returns:

- table tab: The table of the found class. Is nil if the class does not exist.

### luajs.GetClassTableCopy(class)

Returns a copy of the table for the specified luajs class name.

Arguments:

- string class: The class name.

Returns:

- table tab: The table of the found class. Is nil if the class does not exist.

### luajs.GetByIndex(index)

Returns the luajs object with the specified index.

Arguments:

- number index: The object's index.

Returns:

- luajs object: The object with the specified index. Returns an invalid object if no such index is occupied.

### luajs.GetAll()

Returns a table of all created luajs objects.

Returns:

table tab: The table of objects.

### luajs.GetCount(includeRemoved)

Returns the number of created luajs objects.

Arguments:

- boolean includeRemoved: If true, will include the luajs objects that are just about to be removed in the resulting number.

Returns:

- number count: The number of objects.

### luajs.FindByClass(class)

Returns a table of luajs objects with the specified class. Wildcards (`*`) are supported.

Arguments:

- string class: The class name to search for.

Returns:

- table tab: The found objects.
