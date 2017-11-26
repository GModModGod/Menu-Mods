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

- oldURL: The old URL.
- newURL: The new URL.

### PostPageChange(oldURL, newURL)

Called just after the URL changes.

Arguments:

- oldURL: The old URL.
- newURL: The new URL.
