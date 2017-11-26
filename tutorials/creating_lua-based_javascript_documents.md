# Tutorial: Creating Lua-Based JavaScript Documents

In this tutorial, we will be learning how to create Lua-Based JavaScript Documents that can be opened in any lua browser.

## Preparing your File

Place a blank .lua file with a unique name into the "lua/jsdocs" directory of your addon. This will be the file containing the code for your JavaScript document.

## Setting the Base Class

If you would not like to start from scratch, type `LUA_JS.Base = "BASE CLASS NAME HERE"` in your file to set the desired base class for your script.

## Creating the Content

Type `LUA_JS.Content = [[JAVASCRIPT CONTENT HERE]]` to set the content of your script.

## Object Functions

The following are functions that can be used to do certain things with the script.

### LUA_JS:IsValid()

Checks to see if the object is valid.

Returns:

- bool isvalid: Whether or not the object is valid.

### LUA_JS:Index()

Returns the unique index of the object.

Returns:

- number index: The unique index of the object.

### LUA_JS:Remove()

Removes the object, making it no longer valid or useable.

### LUA_JS:GetClass()

Returns the class name of the object.

Returns:

- string classname: The class name of the object.

### LUA_JS:GetContent()

Returns the content of the object.

Returns:

- string content: The content of the object.

### LUA_JS:SetContent(content)

Sets the content of the object.

Arguments:

- string content: The new content for the object.

### LUA_JS:RunInPanel(HTML)

Runs the script in a DHTML panel.

Arguments:

- Panel HTML: The DHTML panel to run the script in.

### LUA_JS:RunNewInCurrentPanel(class, doNotRemove)

Runs a new script in this script's current panel.

Arguments:

- string class: The class name of the new script.
- boolean doNotRemove: Set to true to not remove this script when opening the other one.

### LUA_JS:GetCurrentPanel()

Returns the current panel of the script.

Returns:

- panel currentpanel: The current panel the script was opened in.

## Optional Custom Object Functions

The following are customizable functions that are called whenever certain events happen.

### LUA_JS:Initialize()

Called when the script is first created.

### LUA_JS:OnRemove()

Called when the script is removed with its `LUA_JS:Remove()` function.

### LUA_JS:OnRunInPanel(HTML)

Called when the script is ran in a DHTML panel.

Arguments:

- Panel HTML: The DHTML panel the script was run in.

## Finishing Up

After writing your code, save the file, copy your addon into your addons directory, and test it. If there are any errors, they will show up in the console.
