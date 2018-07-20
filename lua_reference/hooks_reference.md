# Menu Mods Hooks

These are the event hooks that can be created with the function "menumods.hook.Add".

### ElementCreated(currURL, urls, tag, class, parentClass, parentNum, content, attributes)

Called when an HTML element has been created.

Arguments:

- string currURL: The URL the element is being created on.
- table urls: The table of URLs the element exists on.
- string tag: The type of HTML tag.
- string class: The class name.
- string parentClass: The class name of the parent element.
- number parentNum: The ranking of the search results for the parent.
- string content: The inner HTML content of the element.
- vararg attributes: The attributes of the element.

### ElementModified(currURL, urls, class, num, content, attributes)

Called when an HTML element is modified.

Arguments:

- string currURL: The URL the element is being modified on.
- table urls: The table of URLs the element exists on.
- string class: The class name.
- number num: The ranking of the search results for the element.
- string content: The inner HTML content of the element.
- vararg attributes: The attributes of the element.

### ElementRemoved(attributeName, attributeValue)

Called when an HTML element is removed.

Arguments:

- string attributeName: The name of the attribute that was used to find the element.
- any attributeValue: The value of the attribute that was used to find the element.

### PrePageChange(oldURL, newURL)

Called just before the URL changes.

Arguments:

- string oldURL: The old URL.
- string newURL: The new URL.

### PostPageChange(oldURL, newURL)

Called just after the URL changes.

Arguments:

- string oldURL: The old URL.
- string newURL: The new URL.

### PageThink()

Called when the page thinks.

NOTE: When in game, this hook will only be called when the pause menu is open.

### Think()

Called when the main panel thinks.

NOTE: When in game, this hook will only be called when the pause menu is open.

IMPORTANT: When running JavaScript inside a thinking hook, use "PageThink" instead. Otherwise, the JavaScript code will be added to the queue faster than it is run, resulting in gradually increasing lag.

### Initialize()

Called when the main panel initializes. This can happen more than once.

### OnLuaError(text, realm, name, id)

Called when a Lua error occurs. Functionally equivalent to the regular "OnLuaError" gamemode hook. Additionally works with errors that occur in the menu state.

Arguments:

- string text: The error message.
- number realm: The realm (state) in which the error occurred. Does not seem to work currently.
- string name: The name of the addon that caused the error. Will be an empty string if the addon is a legacy addon (not a .gma file).
- string id: The Steam ID of the addon. Will be nil if the addon is a legacy addon (not a .gma file).
