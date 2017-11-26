# luahtml

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
