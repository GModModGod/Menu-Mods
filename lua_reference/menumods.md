# menumods

### menumods.include(filename)

Includes an outside file.

Arguments:

- string filename: The name of the .lua file to include.

IMPORTANT: This function must be used in place of the "include" function when in the menu state due to a fatal Lua error in which the file is not found. This function also does not support local file paths, so replace any local file paths with the full Lua file path. Example: If you are including the .lua file "lua/autorun/stuff/test.lua" from another file, type `menumods.include("autorun/stuff/test.lua")` in the desired location.

### menumods.CreateLog(content, extension)

Creates a log in the directory "garrysmod/data/menu_mods/logs" with the given content.

Arguments:

- string content: The content of the log.
- string extension: The file extension of the log. (Ex. `.txt`, `.dat`, etc.)

### menumods.FindID(identifier)

A function that is internally used to find unoccupied indices for custom HTML elements.

Arguments:

- string identifier: The identifier to assign to the index.

Returns:

- number index: The found index.

IMPORTANT: It is highly recommended to refrain from using this function to create luahtml classes unless there is a specific reason for doing so.

### menumods.RemoveID(id)

A function that is internally called to remove assigned identifiers from indices after custom HTML elements have been removed from the page.

Arguments:

- number id: The index to remove the identifier from.

IMPORTANT: It is highly recommended to refrain from using this function to create luahtml classes unless there is a specific reason for doing so.

### menumods.AddElement(identifier, data)

This function can be used to add any HTML tag to the menu.

Arguments:

- any identifier: Used as a unique name for the element (like gamemode hooks).
- table data: The data table for the element.

### menumods.AddOption(identifier, data, onClick)

This function is used to add options to the menu that execute code when clicked.

Arguments:

- any identifier: Used as a unique name for the element (like gamemode hooks).
- table data: The data table for the element.
- string onClick: The JavaScript code to be executed when the option is clicked.

### menumods.AddLuaOption(identifier, data, callback)

This function is used to add options to the menu that execute code when clicked.

Arguments:

- any identifier: Used as a unique name for the element (like gamemode hooks).
- table data: The data table for the element.
- function callback: The Lua function to be executed when the option is clicked. It has no arguments.

### menumods.ExecuteElementCallback(identifier)

A function that is used internally to execute the callbacks of custom HTML elements when they are clicked.

Arguments:

- string identifier: The identifier of the HTML element.

### menumods.RemoveElementFromPage(identifier)

Removes the custom HTML element with the specified identifier from the menu by disabling it.

Arguments:

- string identifier: The identifier of the HTML element.

### menumods.RemoveElement(identifier)

Permenantly removes a custom HTML element from the global table, requiring the user to restart Garry's Mod for it to be added again.

Arguments:

- string identifier: The identifier of the HTML element.

### menumods.RemoveHTMLElement(searchType, search)

Removes the first found HTML element that matches the search.

Arguments:

- string searchType: Determines which property is being searched with the parentClass value (or class value for modifying existing elements). All possible values are "classname", "id", "menumodsid" (searches for an id specific to Menu Mods), "name", and "tagname".
- string search: The search entry to match the property to. Can also be a number when using "id" or "menumodsid" as searchType.

### menumods.ReAddExistingElement(identifier)

Re-adds a disabled custom HTML element by re-enabling it.

Arguments:

- string identifier: The identifier of the HTML element.

### menumods.ElementExists(identifier)

Returns if the specified element exists, disabled or not.

Arguments:

- string identifier: The identifier of the HTML element.

Returns:

- boolean exists: Whether or not the element exists.

### menumods.GetElement(identifier)

Returns the original table of the custom HTML element with the specified identifier.

Arguments:

- string identifier: The identifier of the HTML element.

Returns:

- table tab: The table of the element.

### menumods.GetElementNameByID(id)

Returns the identifier of the custom HTML element with the specified index.

Arguments:

- number index: The index of the HTML element.

Returns:

- string identifier: The identifier of the HTML element.

### menumods.GetActiveElementTable()

Returns a table of all enabled custom HTML elements.

Returns:

- table tab: The table of elements.

### menumods.GetElementTable()

Returns a table of all custom HTML elements, enabled or not.

Returns:

- table tab: The table of elements.

### menumods.RunJavaScript(str)

Runs JavaScript code on the main DHTML panel.

## menumods.string

### menumods.string.LevelPush(str, numLevels, noOuterQuotes)

Escapes a string a certain number of times.

Arguments:

- string str: The string to escape.
- number numLevels: The number of times to escape the string. Default is 1.
- boolean noOuterQuotes: When set to false or nil, the function will add outer quotes to the string every time it is escaped.

Returns:

- string str: The escaped string.

### menumods.string.LevelPop(str, numLevels)

De-escapes a string a certain number of times.

Arguments:

- string str: The string to de-escape.
- number numLevels: The number of times to de-escape the string. Default is 1.

Returns:

- string str: The de-escaped string.

