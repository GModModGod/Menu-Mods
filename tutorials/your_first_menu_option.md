# Tutorial: Your First Menu Option

One of the main features this addon offers is the ability to run user-created Lua files in the main menu. In this tutorial, we will be
learning how to add custom menu options to the main menu and pause menu.

## Preparing Your Autorun File

Place a blank .lua file with a unique name into the "lua/autorun/menu" directory of your addon. This will be the file containing the code for your menu option.

## Choosing a Location for Your Menu Option

For adding an option to the Garry's Mod menu, Menu Mods offers almost every location on the screen.
The class names of these locations can be seen in the diagram below.

![Main Menu Diagram](/tutorials/images/Main_Menu_Diagram.png?raw=true "Main Menu Diagram")

Refer to this diagram for further instruction.

## Different Methods

There are three main functions used to add HTML tags to different parts of the page, the last two of which are specific to `<a>` tags. 

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

## Data Structure

The functions used to add HTML elements to the page use the data structure shown below as the "data" argument.

Key | Value Type | Purpose
--- | ---------- | -------
urls | table | Determines which pages this element should be added to. It is a table of strings.
tag | string | Determines the type of HTML tag the element is. Unlike html, the tag name should be in all caps. (Ex. "A" for a `<a>` tag, "P" for a `<p>` tag, etc.)
modifyExisting | boolean | Determines whether this data should be used to modify an existing element (true), or should be used to add a new one (false or nil).
class | string | Determines the class name of the object, which can be used for identifying it. It should be a unique value unless there is a specific reason for it being otherwise.
parentClass | string | Determines the class name (or tag name, or some other property if specified) that should be searched to find a parent for the new element.
searchType | string | Determines which property is being searched with the parentClass value (or class value for modifying existing elements). All possible values are "classname", "id", "menumodsid" (searches for an id specific to Menu Mods), "name", and "tagname".
parentNum | number | Determines which element to parent the new element to. (1 is the first element found, 2 is the second element found, etc.)
num | number | Determines which element to modify. (1 is the first element found, 2 is the second element found, etc.) This value is exclusive to modifying existing elements. (modifyExisting must be set to true.)
onClick | string (function when used in "menumods.AddLuaOption") | Determines the action taken when the element is clicked by the cursor. If it is a string, this action is written in JavaScript. If it is a function, it is written in Lua.
content | string | Determines the inner HTML content of the element.
attributes | table | Determines the HTML attributes of the element. It is a table of tables of strings. Example: For setting the "src", "w", and "h" attributes on an `<img>` tag, this value can be set to `{{"src", "path/to/image"}, {"w", 512}, {"h", 512}}`.

## Finishing Up

After writing your code, save the file, copy your addon into your addons directory, and test it. If there are any errors, they will show up in the console.
