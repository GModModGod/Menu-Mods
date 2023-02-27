**# luahtml**

### luahtml.Register(tab, name)

Registers a new luahtml class.

Arguments:

- table tab: The class table.
- string name: The class name.

IMPORTANT: It is highly recommended to refrain from using this function to create luahtml classes unless there is a specific reason for doing so.

### luahtml.Create(class)

Creates a new luahtml object of the specified class name.

Arguments:

- string class: The class name of the new object.

### luahtml.GetClasses()

Returns the original table of all luahtml classes.

Returns:

- table tab: The table of classes.

### luahtml.GetClassTable(class)

Returns the original table for the specified luahtml class name.

Arguments:

- string class: The class name.

Returns:

- table tab: The table of the found class. Is nil if the class does not exist.

### luahtml.GetClassTableCopy(class)

Returns a copy of the table for the specified luahtml class name.

Arguments:

- string class: The class name.

Returns:

- table tab: The table of the found class. Is nil if the class does not exist.

### luahtml.GetByIndex(index)

Returns the luahtml object with the specified index.

Arguments:

- number index: The object's index.

Returns:

- luahtml object: The object with the specified index. Returns an invalid object if no such index is occupied.

### luahtml.GetAll()

Returns a table of all created luahtml objects.

Returns:

table tab: The table of objects.

### luahtml.GetCount(includeRemoved)

Returns the number of created luahtml objects.

Arguments:

- boolean includeRemoved: If true, will include the luahtml objects that are just about to be removed in the resulting number.

Returns:

- number count: The number of objects.

### luahtml.FindByClass(class)

Returns a table of luahtml objects with the specified class. Wildcards (`*`) are supported.

Arguments:

- string class: The class name to search for.

Returns:

- table tab: The found objects.
