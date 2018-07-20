# menumods

### menumods.include(filename)

Includes an outside file. Works like the normal "include" function.

Arguments:

- string filename: The name of the .lua file to include.

IMPORTANT: This function must be used in place of the "include" function when in the menu state due to a fatal Lua error in which the file is not found.

NOTE: This function will include the first file of the specified name, regardless of which addon it comes from. Ensure to give your .lua files unique names.

### menumods.GetFullLuaFileName(filename)

Returns the full path of a .lua file relative to the "lua/" folder (as if you were including the file using "menumods.include").

Arguments:

- string filename: The name of the file. Can be relative to the current file or relative to the "lua/" folder.

Returns:

- string fullFilename: The full path of the file.

### menumods.LogLuaError(content)

Logs a Lua error in the directory "garrysmod/data/menu_mods/logs" with the given content.

Arguments:

- string content: The content of the log.

### menumods.NewLuaErrorLogFile(filename, extension)

Changes the destination of logs created with "menumods.LogLuaError" to a new file.

Arguments:

- string filename: The prefix name of the file. (Do not include a file extension.)
- string extension: The file extension of the new file. (Ex: `".txt"`, `".dat"`, etc.)

### menumods.ChangeLuaErrorLogFile(filename, extension, index)

Changes the destination of logs created with "menumods.LogLuaError" to an already existing file. Will create a new file if the file doesn't exist.

Arguments:

- string filename: The prefix name of the file. (Do not include a file extension.)
- string extension: The file extension of the new file. (Ex: `".txt"`, `".dat"`, etc.)
- number index: The index of the file. Will choose the file with the last index if none is provided.

### menumods.LogJavaScript(content)

Logs JavaScript code in the directory "garrysmod/data/menu_mods/logs" with the given content.

Arguments:

- string content: The content of the log.

### menumods.CreateLog(content) DEPRECIATED

Logs JavaScript code in the directory "garrysmod/data/menu_mods/logs" with the given content. Alias of "menumods.LogJavaScript".

Arguments:

- string content: The content of the log.

### menumods.NewJavaScriptLogFile(filename, extension)

Changes the destination of logs created with "menumods.LogJavaScript" to a new file.

Arguments:

- string filename: The prefix name of the file. (Do not include a file extension.)
- string extension: The file extension of the new file. (Ex: `".txt"`, `".dat"`, etc.)

### menumods.ChangeJavaScriptLogFile(filename, extension, index)

Changes the destination of logs created with "menumods.LogJavaScript" to an already existing file. Will create a new file if the file doesn't exist.

Arguments:

- string filename: The prefix name of the file. (Do not include a file extension.)
- string extension: The file extension of the new file. (Ex: `".txt"`, `".dat"`, etc.)
- number index: The index of the file. Will choose the file with the last index if none is provided.

### menumods.FindID(identifier) INTERNAL

A function that is internally used to find unoccupied indices for custom HTML elements.

Arguments:

- string identifier: The identifier to assign to the index.

Returns:

- number index: The found index.

IMPORTANT: This is an internal function. It is highly recommended to refrain from using it unless there is a specific reason for doing so.

### menumods.RemoveID(id) INTERNAL

A function that is internally called to remove assigned identifiers from indices after custom HTML elements have been removed from the page.

Arguments:

- number id: The index to remove the identifier from.

IMPORTANT: This is an internal function. It is highly recommended to refrain from using it unless there is a specific reason for doing so.

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

### menumods.ExecuteElementCallback(identifier) INTERNAL

A function that is used internally to execute the callbacks of custom HTML elements when they are clicked.

Arguments:

- string identifier: The identifier of the HTML element.

IMPORTANT: This is an internal function. It is highly recommended to refrain from using it unless there is a specific reason for doing so.

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

## menumods.hook

### menumods.hook.Add(eventName, identifier, func)

Adds a hook exclusive to Menu Mods. The hook is like a regular gamemode hook.

Arguments:

- string eventName: The event name.
- any identifier: The unique identifier.
- function func: The function to run.

### menumods.hook.Remove(eventName, identifier)

Removes a hook exclusive to Menu Mods. The hook is like a regular gamemode hook.

Arguments:

- string eventName: The event name.
- any identifier: The unique identifier.

### menumods.hook.Run(eventName)

Runs an event exclusive to Menu Mods. The event is like a regular gamemode event.

Arguments:

- string eventName: The event name.

### menumods.hook.GetTable()

Returns a table of all Menu Mods hooks.

Returns:

- table tab: The table of hooks.

## menumods.net

The menumods net library is similar to the regular net library, only instead of sending data between the client and server states, this library sends data between the menu and client states.

### menumods.net.IsConnected()

Returns if the client state is active and currently using the net library.

Returns:

- boolean isConnected: Whether or not the client state is connected.

### menumods.net.Start(identifier)

Starts a new net message to send to either the client or menu state.

Arguments:

- string identifier: The unique identifier used to name the net message.

### menumods.net.Send()

Sends the current net message to either the client or menu state.

### menumods.net.Receive(identifier, func)

Adds a function that is run when a net message with the specified identifier is received.

Arguments:

- string identifier: The unique identifier of the net message.
- function func: The function to run when the message is received. It has no arguments.

### menumods.net.IsValidType(val)

Returns if the value is of a valid type that can be used with the function "menumods.net.WriteType".

Arguments:

- any val: The value to check.

Returns:

- boolean isValid: Whether or not the type is valid.

### menumods.net.WriteAngle(val)

Writes an angle to the current net message.

Arguments:

- angle val: The angle to write.

### menumods.net.WriteBool(val)

Writes a boolean to the current net message.

Arguments:

- boolean val: The boolean to write.

### menumods.net.WriteEntity(val)

Writes an entity to the current net message.

Arguments:

- Entity val: The entity to write.

### menumods.net.WriteNumber(val)

Writes a number to the current net message.

Arguments:

- number val: The number to write.

### menumods.net.WritePanel(val)

Writes a panel to the current net message. Alias of "menumods.net.WriteEntity".

Arguments:

- Panel val: The panel to write.

### menumods.net.WriteString(val)

Writes a string to the current net message.

Arguments:

- string val: The string to write.

### menumods.net.WriteTable(val)

Writes a table to the current net message.

Arguments:

- table val: The table to write.

### menumods.net.WriteVector(val)

Writes a vector to the current net message.

Arguments:

- vector val: The vector to write.

### menumods.net.WriteType(val)

Writes a value with a valid type to the current net message.

Arguments:

- any val: The value to write.

### menumods.net.ReadAngle()

Reads an angle from the current net message.

Returns:

- angle val: The angle read.

### menumods.net.ReadBool()

Reads a boolean from the current net message.

Returns:

- boolean val: The boolean read.

### menumods.net.ReadEntity()

Reads an entity from the current net message.

Returns:

- Entity val: The entity read.

### menumods.net.ReadNumber()

Reads a number from the current net message.

Returns:

- number val: The number read.

### menumods.net.ReadPanel()

Reads a panel from the current net message. Alias of "menumods.net.ReadEntity".

Returns:

- Panel val: The panel read.

### menumods.net.ReadString()

Reads a string from the current net message.

Returns:

- string val: The string read.

### menumods.net.ReadTable(newTab)

Reads a table from the current net message.

Arguments:

- table newTab: If specified, fills this table with the values from the read table.

Returns:

- table val: The table read.

### menumods.net.ReadVector()

Reads a vector from the current net message.

Returns:

- vector val: The vector read.

### menumods.net.ReadType()

Reads a value with a valid type from the current net message.

Returns:

- any val: The value read.
