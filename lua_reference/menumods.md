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

- any identifier: The identifier of the HTML element.

### menumods.RemoveElementFromPage(identifier)

Removes the custom HTML element with the specified identifier from the menu by disabling it.

Arguments:

- any identifier: The identifier of the HTML element.
